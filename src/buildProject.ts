import * as fs from 'fs';
import * as path from 'path';
import * as vscode from 'vscode';
import { getUsedModules, parseLuaFile, resetUsedModules } from './TSILParser';

const DEFAULT_LIBRARY_FOLDER = "library_of_isaac";
const EXTENSION_LIBRARY_FOLDER = "library_of_isaac";
const BUILD_DESTINATION_FOLDER = "release-mod";
const MAIN_LIBRARY_FILE = "TSIL.lua";
const CUSTOM_CALLBACKS_FILE = "Enums/CustomCallback.lua";
const DEPENDENCIES_FILE = "dependencies.json";
const SCRIPTS_FILE = "scripts.lua";
/**
 * Files that should only exist if the library is a full download
 */
const EXTRA_LIBRARY_FILES = [
    DEPENDENCIES_FILE,
    SCRIPTS_FILE,
    "docs.lua"
];

interface FileDependencies {
    functions: string[],
    modules: string[]
}

interface FunctionDepenencies {
    file: string,
    requiredFiles: string[],
    modules: string[]
}

interface Dependencies {
    files: { [key: string]: FileDependencies },
    functions: { [key: string]: FunctionDepenencies }
}

interface ModDependencies {
    modules: string[],
    requiredFiles: string[]
}

export async function buildProject(context: vscode.ExtensionContext) {
    // 1 - Get dependencies needed
    // 2 - Check if the TSIL file exists already
    // 3 - Check if it's a full download or if it was created
    //  3.1 - Check if the extra files exist (docs.lua, dependencies.json, scripts.lua)
    //  3.2 - If all of these files exist check the scripts.lua, if any files are missing it's not a full download
    // 4 - If it's a full download, copy the mod to a release folder
    // 5 - Minimize the library and put it in the corresponding folder
    //  5.1 - If no library exists already, create a default folder. Extension library -> Default folder
    //  5.2 - If a library exists, but isn't a full download. Extension library -> Library folder
    //  5.3 - If full library exists, copy it to the library folder in the release. Full library -> Release library folder

    const workspaceFolders = vscode.workspace.workspaceFolders;

    if (workspaceFolders === undefined) {
        console.log("Not opened inside a workspace folder, aborting.");
        vscode.window.showErrorMessage("A workspace folder needs to be open in order for this command to work");
        return;
    }

    const dependencies = await getModDependencies(context);

    const libraryExists = await doesLibraryExist();

    if (!libraryExists) {
        console.log("No folder with the library exists.");

        const targetFolder = getDefaultLibraryFolder();

        vscode.window.showWarningMessage("A default folder was created by the extension to put the library in. Make sure to rename it to avoid conflicts with other mods.");

        const extensionLibraryFolder = getExtensionLibraryPath(context);

        buildLibraryToFolder(context, extensionLibraryFolder, targetFolder, dependencies);
    } else {
        const currentLibraryPath = await getLibraryPath();

        if (doExtraFilesExist(currentLibraryPath) && doAllScriptsExist(currentLibraryPath)) {
            console.log("A full library exists");

            if (doesReleaseModFolderExist()) {
                console.log("Release mod folder exists, remove everything inside");

                emptyReleaseModFolder();
            } else {
                console.log("Release mod folder doesn't exist, creating it.");
                vscode.window.showInformationMessage("Since you're using the full version of the library in this workspace, a copy of your mod will be created with the reduced library to prevent conflicts.");
            }

            await copyModToReleaseFolder();

            const targetFolder = await getLibraryPathInsideReleaseFolder();
            buildLibraryToFolder(context, currentLibraryPath, targetFolder, dependencies);
        } else {
            console.log("A library created by the extension already exists.");

            removeFolderContents(currentLibraryPath);

            const extensionLibraryFolder = getExtensionLibraryPath(context);

            buildLibraryToFolder(context, extensionLibraryFolder, currentLibraryPath, dependencies);
        }
    }

    console.log("Project build succesfully");
    vscode.window.showInformationMessage("Project built succesfully");
}

/**
 * Returns the list of TSIL functions and enums used in the mod.
 */
async function getModDependencies(context: vscode.ExtensionContext): Promise<ModDependencies> {
    const libraryExists = await doesLibraryExist();
    let luaFiles: vscode.Uri[] = [];
    let libraryPath = "";

    if (libraryExists) {
        libraryPath = await getLibraryPath();
        const relativeLibraryPath = vscode.workspace.asRelativePath(libraryPath);

        luaFiles = await vscode.workspace.findFiles("**/*.lua", `**/{${relativeLibraryPath},${BUILD_DESTINATION_FOLDER}}/**`);
    } else {
        libraryPath = getExtensionLibraryPath(context);
        luaFiles = await vscode.workspace.findFiles("**/*.lua", `**/${BUILD_DESTINATION_FOLDER}/**`);
    }

    resetUsedModules();

    luaFiles.forEach(luaFile => {
        const content = fs.readFileSync(luaFile.fsPath, 'utf-8');
        parseLuaFile(content);
    });

    const mainFilePath = path.join(libraryPath, MAIN_LIBRARY_FILE);
    const mainFileContents = fs.readFileSync(mainFilePath, 'utf-8');
    parseLuaFile(mainFileContents);

    const usedModules = getUsedModules();
    const dependenciesInfo = await getLibraryDependencies(context);

    const necessaryModules: string[] = [];
    const requiredFiles: string[] = [MAIN_LIBRARY_FILE, CUSTOM_CALLBACKS_FILE, SCRIPTS_FILE];
    const modulesToCheck: string[] = [];

    usedModules.forEach(x => {
        necessaryModules.push(x);
        modulesToCheck.push(x);
    });

    while (modulesToCheck.length > 0) {
        const module = modulesToCheck.pop();

        if (!module) {
            continue;
        }

        const functionDepenencies = dependenciesInfo.functions[module];

        if (!functionDepenencies) {
            continue;
        }

        functionDepenencies.modules.forEach(module => {
            if (necessaryModules.includes(module)) {
                return;
            }

            necessaryModules.push(module);
            modulesToCheck.push(module);
        });

        functionDepenencies.requiredFiles.forEach(file => {
            const fileDependencies = dependenciesInfo.files[file];

            if (!fileDependencies) {
                return;
            }

            if (requiredFiles.includes(file)) {
                return;
            }

            requiredFiles.push(file);

            fileDependencies.modules.forEach(module => {
                if (necessaryModules.includes(module)) {
                    return;
                }

                necessaryModules.push(module);
                modulesToCheck.push(module);
            });
        });
    }

    return {
        modules: necessaryModules,
        requiredFiles: requiredFiles
    };
}

/**
 * Parses the dependencies.json file.
 * @returns 
 */
async function getLibraryDependencies(context: vscode.ExtensionContext) {
    let dependenciesFilePath: string | undefined = undefined;
    const libraryExists = await doesLibraryExist();

    if (libraryExists) {
        const libraryPath = await getLibraryPath();
        const relativeLibraryPath = vscode.workspace.asRelativePath(libraryPath);
        const dependenciesFile = (await vscode.workspace.findFiles(`**/${relativeLibraryPath}/${DEPENDENCIES_FILE}`, `**/${BUILD_DESTINATION_FOLDER}/**`))[0];

        if (dependenciesFile) {
            dependenciesFilePath = dependenciesFile.fsPath;
        }
    }

    if (!dependenciesFilePath) {
        const extensionLibraryFolder = getExtensionLibraryPath(context);
        dependenciesFilePath = path.join(extensionLibraryFolder, DEPENDENCIES_FILE);
    }

    const dependenciesContent = fs.readFileSync(dependenciesFilePath, 'utf-8');
    const dependencies: Dependencies = JSON.parse(dependenciesContent);

    return dependencies;
}

/**
 * Checks if the library is in the workspace.
 * 
 * Ignores the release library.
 * @returns 
 */
async function doesLibraryExist() {
    const releaseModPath = getReleaseModPath();
    const mainFiles = await vscode.workspace.findFiles("**/TSIL.lua", `**/${releaseModPath}/**`, 1);

    return mainFiles.length > 0;
}

/**
 * Returns the path of the library the extension has
 */
function getExtensionLibraryPath(context: vscode.ExtensionContext) {
    return path.join(context.extensionPath, "out", EXTENSION_LIBRARY_FOLDER);
}

/**
 * Helper function to get the folder the library is currently at.
 * 
 * Ignores the release folder and assumes there is a library.
 * Use `doesLibraryExist` to check if there is a library beforehand.
 * @returns 
 */
async function getLibraryPath(): Promise<string> {
    const mainFile = (await vscode.workspace.findFiles(`**/${MAIN_LIBRARY_FILE}`, `**/${BUILD_DESTINATION_FOLDER}/**`, 1))[0];
    const mainFilePath = path.parse(mainFile.fsPath);
    return mainFilePath.dir;
}

/**
 * Helper function to get the default folder for the library.
 * @returns
 */
function getDefaultLibraryFolder(): string {
    const workspacePath = getWorkspacePath();
    return path.join(workspacePath, DEFAULT_LIBRARY_FOLDER);
}

/**
 * Checks if all the extra files of the library exist.
 * 
 * Used to check if it's a full instalation or just created by the extension.
 * @param currentLibraryPath 
 * @returns
 */
function doExtraFilesExist(currentLibraryPath: string): boolean {
    for (let i = 0; i < EXTRA_LIBRARY_FILES.length; i++) {
        const extraFile = EXTRA_LIBRARY_FILES[i];

        if (!fs.existsSync(path.join(currentLibraryPath, extraFile))) {
            return false;
        }
    }

    return true;
}

/**
 * Checks if all the scripts listed in the `scripts.lua` file exist inside the library.
 * 
 * This function assumes the `scritps.lua` exists. Use `doExtraFilesExist` beforehand to check.
 * @param currentLibraryPath 
 * @returns 
 */
function doAllScriptsExist(currentLibraryPath: string): boolean {
    const scriptsPath = path.join(currentLibraryPath, SCRIPTS_FILE);
    const scriptsContents = fs.readFileSync(scriptsPath, 'utf-8');

    const regexPattern = /"([^"]+)"/g;

    const matches = scriptsContents.match(regexPattern);

    if (matches) {
        for (const match of matches) {
            // You gotta do the regex because if we put "." it only replaces the first instace
            const filePath = match.slice(1, -1).replace(/\./g, path.sep);
            const fullPath = path.join(currentLibraryPath, filePath) + ".lua";

            if (!fs.existsSync(fullPath)) {
                return false;
            }
        }
    }

    return true;
}

/**
 * Removes everything inside the release mod folder.
 */
function emptyReleaseModFolder() {
    const releasePath = getReleaseModPath();
    removeFolderContents(releasePath);
}

/**
 * Copies a file to a destination folder. Creates it's parent folders if needed.
 * @param source 
 * @param destination 
 */
function copyFile(source: string, destination: string) {
    createMissingFolders(destination);
    fs.copyFileSync(source, destination);
}

/**
 * Copies a folder into another folder recursively.
 * @param basePath Base path of the folder we're copying from.
 * @param targetPath Target path the folder will be copied to.
 * @param relativePath Relative path inside the base folder we're copying from currently.
 * @param exclude List of paths that will be excluded from the copy.
 */
function copyFolderContents(basePath: string, targetPath: string, relativePath: string, exclude: string[]) {
    const fullBasePath = path.join(basePath, relativePath);

    fs.readdirSync(fullBasePath).forEach(contentPath => {
        const newRelativePath = path.join(relativePath, contentPath);
        const newFullFilePath = path.join(fullBasePath, contentPath);

        if (exclude.includes(newFullFilePath)) {
            return;
        }

        if (fs.statSync(newFullFilePath).isDirectory()) {
            copyFolderContents(
                basePath,
                targetPath,
                newRelativePath,
                exclude
            );
        } else {
            copyFile(
                newFullFilePath,
                path.join(targetPath, newRelativePath)
            );
        }
    });
}

/**
 * Copies all of the mod contents to the release folder.
 */
async function copyModToReleaseFolder() {
    const workspacePath = getWorkspacePath();
    const libraryPath = await getLibraryPath();
    const releasePath = getReleaseModPath();

    copyFolderContents(workspacePath, releasePath, "", [libraryPath, releasePath]);
}

/**
 * Helper function to check if the release mod folder already exists.
 * @returns
 */
function doesReleaseModFolderExist() {
    return fs.existsSync(getReleaseModPath());
}

/**
 * Helper function to get the library path inside of the release mod folder.
 */
async function getLibraryPathInsideReleaseFolder(): Promise<string> {
    const libraryPath = await getLibraryPath();
    const relativeLibraryPath = vscode.workspace.asRelativePath(libraryPath);

    const releaseModPath = getReleaseModPath();

    return path.join(releaseModPath, relativeLibraryPath);
}

/**
 * Helper function to get the release mod folder path.
 */
function getReleaseModPath(): string {
    const workspacePath = getWorkspacePath();
    return path.join(workspacePath, BUILD_DESTINATION_FOLDER);
}

/**
 * Helper function to remove all of the files and folders inside another directory.
 * @param folderPath
 */
function removeFolderContents(folderPath: string) {
    console.log("removing " + folderPath);
    const files = fs.readdirSync(folderPath);

    for (let i = 0; i < files.length; i++) {
        const file = files[i];

        const filePath = path.join(folderPath, file);

        fs.rmSync(filePath, { force: true, recursive: true });
    }
}

/**
 * Helper function to get the path of the current workspace.
 * 
 * Ignores the posibility that there may not be any workspace folders open, so check beforehand.
 * @returns 
 */
function getWorkspacePath() {
    const workspaceFolders = vscode.workspace.workspaceFolders as readonly vscode.WorkspaceFolder[];
    return workspaceFolders[0].uri.fsPath;
}

/**
 * Copies a library file only keeping the necessary contents.
 * @param filePath 
 * @param targetPath 
 * @param modules 
 */
function copyReducedLibraryFile(filePath: string, targetPath: string, modules: string[]) {
    const fileContents = fs.readFileSync(filePath, 'utf-8');
    const fileLines = fileContents.split("\n");
    const reducedFileLines: string[] = [];

    let isSkippingFunction = false;
    let isSkippingEnum = false;
    let isSkippingMultilineComment = false;

    fileLines.forEach(line => {
        // If we're currently skipping a function, wait until we find the end
        if (isSkippingFunction) {
            if (line.trimEnd() === "end") {
                isSkippingFunction = false;
            }

            return;
        }

        // If we're currently skipping an enum, wait until the closing brackets
        if (isSkippingEnum) {
            if (line.trim() === "}") {
                isSkippingEnum = false;
            }

            return;
        }

        if (isSkippingMultilineComment) {
            if (line.trimEnd().endsWith("]]")) {
                isSkippingMultilineComment = false;
            }

            return;
        }

        if (line.trim().startsWith("--[[")) {
            isSkippingMultilineComment = true;
            return;
        }

        // Don't need to include comments
        if (line.trim().startsWith("--")) {
            return;
        }

        // We're starting a library function declaration
        if (line.startsWith("function TSIL.")) {
            const moduleName = line.split("(")[0].substring(9).trim();

            if (!modules.includes(moduleName)) {
                isSkippingFunction = true;

                return;
            }
        }

        if (line.startsWith("TSIL.Enums.")) {
            const moduleName = line.split("=")[0].trim();

            if (!modules.includes(moduleName)) {
                isSkippingEnum = true;

                return;
            }
        }

        reducedFileLines.push(line);
    });

    const reducedContents = reducedFileLines.join("\n");

    createMissingFolders(targetPath);
    fs.writeFileSync(targetPath, reducedContents);
}

/**
 * Creates all the necessary folders that are missing from a path.
 * @param destination 
 */
function createMissingFolders(destination: string) {
    const destFolder = path.dirname(destination);

    if (!fs.existsSync(destFolder)) {
        fs.mkdirSync(destFolder, { recursive: true });
    }
}

/**
 * Copies the necessary files from the library to the target folder. 
 * @param libraryFolder 
 * @param targetFolder 
 * @param dependencies
 */
async function buildLibraryToFolder(context: vscode.ExtensionContext, libraryFolder: string, targetFolder: string, dependencies: ModDependencies) {
    const libraryDependencies = await getLibraryDependencies(context);
    const addedFiles: string[] = [];

    dependencies.requiredFiles.forEach(requiredFile => {
        const libraryFilePath = path.join(libraryFolder, requiredFile);
        const targetPath = path.join(targetFolder, requiredFile);

        copyFile(libraryFilePath, targetPath);
        addedFiles.push(requiredFile);
    });

    dependencies.modules.forEach(module => {
        if (module.startsWith("TSIL.Enums") && !module.startsWith("TSIL.Enums.CustomCallback")) {
            const libraryFiles = libraryDependencies.files;
            for (const moduleFile in libraryFiles) {
                if (!moduleFile.startsWith("Enums")) {
                    continue;
                }

                if (addedFiles.includes(moduleFile)) {
                    continue;
                }

                const fileDependencies = libraryFiles[moduleFile];
                const allModulesInFile = fileDependencies.modules;

                if (allModulesInFile.includes(module)) {
                    addedFiles.push(moduleFile);
                    const modulesToAddFromFile = allModulesInFile.filter(x => dependencies.modules.includes(x));

                    copyReducedLibraryFile(
                        path.join(libraryFolder, moduleFile),
                        path.join(targetFolder, moduleFile),
                        modulesToAddFromFile
                    );
                }
            }
        } else {
            const moduleDependencies = libraryDependencies.functions[module];
            if (!moduleDependencies) {
                return;
            }

            const moduleFile = moduleDependencies.file;

            if (addedFiles.includes(moduleFile)) {
                return;
            }

            addedFiles.push(moduleFile);
            const allModulesInFile = libraryDependencies.files[moduleFile].functions;
            const modulesToAddFromFile = allModulesInFile.filter(x => dependencies.modules.includes(x));

            copyReducedLibraryFile(
                path.join(libraryFolder, moduleFile),
                path.join(targetFolder, moduleFile),
                modulesToAddFromFile
            );
        }
    });
}