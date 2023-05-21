import { existsSync, lstatSync, mkdirSync, readdirSync, readFileSync } from 'fs';
import { join } from 'path';
import { TextEncoder } from 'util';
import { WorkspaceEdit, workspace, window, ExtensionContext, Uri } from 'vscode';
import { findFile } from './helpers';
import { getUsedModules, parseLuaFile, resetUsedModules } from './TSILParser';

interface BuildProjectVariables {
    tsilPath: string,
    workspaceEdit: WorkspaceEdit,
    usedModules: Set<string>,
    filesToRead: Set<string>,
    addedFiles: Set<string>,
    dependencies: {[key: string]: string[]},
    libBasePath: string
}

const v: BuildProjectVariables = {
    tsilPath: "",
    workspaceEdit: new WorkspaceEdit(),
    usedModules: new Set<string>(),
    filesToRead: new Set<string>(),
    addedFiles: new Set<string>(),
    dependencies: {},
    libBasePath: ""
};

const MANDATORY_FILES = [
    "TSIL.lua",
    "scripts.lua",
    "Enums\\CustomCallback.lua",
    "CustomCallbacks\\InternalCallbacks.lua",
    "CustomCallbacks\\RegisterCustomCallback.lua"
];


function writeFileToLibrary(relativePath: string, content: string){
	content = "---@diagnostic disable: duplicate-set-field\n" + content;
	const encoder = new TextEncoder();
    const fullFilePath = join(v.tsilPath, relativePath);

	const filePath = Uri.file(fullFilePath);

	if(existsSync(filePath.toString())){ 
        if(MANDATORY_FILES.includes(relativePath)) { return; }

		const oldContents = readFileSync(filePath.toString(), {encoding: "utf-8"});

		if(oldContents.length >= content.length){
			//Old contents where the same or more
			return;
		}
	}

	v.workspaceEdit.createFile(filePath, { 
		overwrite: true,
		ignoreIfExists: true,
		contents: encoder.encode(content)
	});
}


function findUserLuaFiles(workspacePath: string){
    readdirSync(workspacePath).forEach(file => {
        const fullFilePath = join(workspacePath, file);

        if(fullFilePath.includes(v.tsilPath)){
            return;
        }else if(lstatSync(fullFilePath).isDirectory()){
            findUserLuaFiles(fullFilePath);
        }else if(file.endsWith(".lua")){
            v.filesToRead.add(fullFilePath);
        }
    });
}


function updateUsedModules(){
    const usedModules = getUsedModules();
	let hasAddedModule = false;

	do{
		hasAddedModule = false;

		usedModules.forEach(usedModule => {
			const moduleDependencies = v.dependencies[usedModule];	

			if(moduleDependencies === undefined){ return; }

			moduleDependencies.forEach(moduleDependency => {
				if(!usedModules.has(moduleDependency)){
					hasAddedModule = true;
				}

				usedModules.add(moduleDependency);
			});
		});

	}while(hasAddedModule);

	//Convert enums to just the enum type
	usedModules.forEach(usedModule =>{
		if(usedModule === "TSIL"){ return; }

		if(usedModule.startsWith("TSIL.Enums") && !usedModule.startsWith("TSIL.Enums.CustomCallback")){
			const newModule = usedModule.split(".").slice(0, 3).join(".");
			v.usedModules.add(newModule);
		}else{
			v.usedModules.add(usedModule);
		}
	});
}


function handleSpecialComment(line: string, forcedFiles: string[]): boolean{
    if(line.startsWith("--##use")){
        const forcedFile = line.split(" ")[1].trim();
        forcedFiles.push(forcedFile);
    }else{
        const callback = line.replace("--##", "").trim();
        const fullCallbackName = "TSIL.Enums.CustomCallback." + callback;

        // v.usedModules.forEach(module => {
        //     if(module.startsWith("TSIL.Enums.CustomCallback.")){
        //         if(callback === "POST_NEW_ROOM_EARLY"){
        //             console.log(module);
        //         }
                
        //     }
        // });

        if(v.usedModules.has(fullCallbackName)){
            //console.log(fullCallbackName);
            return true;
        }
    }

    return false;
}


function minifyLuaFile(relativeFilePath: string, forceAdd: boolean){
    if(MANDATORY_FILES.includes(relativeFilePath)){ return; }

    const fullFilePath = join(v.libBasePath, relativeFilePath);

    const fileContents = readFileSync(fullFilePath, 'utf-8');
    const fileLines = fileContents.split(`\n`);
    let minifiedContent = "";
    const forcedFiles: string[] = [];
    let isGoingThroughUselessFunction = false;
    let isEnum = false;
    let hasAddedUsefulFunction = false;

    fileLines.forEach(line => {
        if(line.startsWith("--##")){
            forceAdd = forceAdd || handleSpecialComment(line, forcedFiles);
        }

        if(line.trimStart().startsWith("--") && 
        (!line.trimStart().startsWith("--[[") && !line.trimStart().startsWith("--]]"))){
            //Skip comments, we shouldn't need them
            return;
        }

        if(isGoingThroughUselessFunction){
            if((line.trimEnd() === "end" && !isEnum) ||
            (line.trimEnd() === "}" && isEnum)){
                isGoingThroughUselessFunction = false;
            }
            return;
        }

        if(forceAdd){
            //If we set force add, we just add everything
            minifiedContent += line + "\n";
            return;
        }

        if(line.startsWith("function TSIL.")){
            const moduleName = line.replace("function ", "").split("(")[0].trim();

            if(!v.usedModules.has(moduleName)){
                isGoingThroughUselessFunction = true;
                isEnum = false;
                return;
            }else{
                hasAddedUsefulFunction = true;
            }
        }else if(line.startsWith("TSIL.Enums.")){
            const moduleName = line.split(" ")[0];

            if(!v.usedModules.has(moduleName)){
                isGoingThroughUselessFunction = true;
                isEnum = true;
                return;
            }else{
                hasAddedUsefulFunction = true;
            }
        }

        minifiedContent += line + "\n";
    });

    if(hasAddedUsefulFunction || forceAdd){
        forcedFiles.forEach(forcedFile => {
            const fullForcedFilePath = join(v.libBasePath, forcedFile);
            if(!v.addedFiles.has(fullForcedFilePath)){
                v.addedFiles.add(fullForcedFilePath);
                v.filesToRead.add(fullForcedFilePath);
                minifyLuaFile(forcedFile, true);
            }
        });

        writeFileToLibrary(relativeFilePath, minifiedContent);
    }
}


function addNecessaryFilesToLibrary(filePath: string = ""){
    const fullLibPath = join(v.libBasePath, filePath);

    readdirSync(fullLibPath).forEach(file => {
        const relativeFilePath = join(filePath, file);
        const fullFilePath = join(fullLibPath, file);

		if(file.endsWith(".lua")){
			minifyLuaFile(relativeFilePath, false);
		}else if(lstatSync(fullFilePath).isDirectory()){
			addNecessaryFilesToLibrary(relativeFilePath);
		}
	});
}


export function buildProject(context: ExtensionContext){
    const workspaceFolders = workspace.workspaceFolders;

    if(workspaceFolders === undefined){ return; }

    let workspacePath = workspaceFolders[0].uri.fsPath; // gets the path of the first workspace folder

    const foundTSIL = findFile(workspacePath, "TSIL.lua");

    if(foundTSIL === undefined){
        //There is no TSIL file, create a default folder for the library
        const mainLuaPath = findFile(workspacePath, "main.lua");

        if(mainLuaPath === undefined){
            window.showWarningMessage("No main.lua file has been found, create one to start.");
            return;
        }

        if(!existsSync(join(mainLuaPath, "LibraryOfIsaac"))){
            mkdirSync(join(mainLuaPath, "LibraryOfIsaac"));
        }
        window.showWarningMessage("A new folder has been created for the library, make sure to change it's name.");
        v.tsilPath = join(mainLuaPath, "LibraryOfIsaac"); 
    }else{
        v.tsilPath = foundTSIL;
    }

    //Parse dependencies file
    const dependenciesFile = readFileSync(join(context.extensionPath, "/out/data/dependencies.json"), 'utf-8');
	v.dependencies = JSON.parse(dependenciesFile);

    v.workspaceEdit = new WorkspaceEdit();
    v.libBasePath = join(context.extensionPath, "/out/data/lib");


    //Remove all files inside the tsil folder
    readdirSync(v.tsilPath).forEach(file => {
        const fileToDelete = Uri.file(join(v.tsilPath, file));
        v.workspaceEdit.deleteFile(fileToDelete, {recursive: true});
    });

    //Add necessary library files
    MANDATORY_FILES.forEach(mandatoryFile => {
        const content = readFileSync(join(v.libBasePath, mandatoryFile), 'utf-8');
        writeFileToLibrary(mandatoryFile, content);
        v.filesToRead.add(join(v.libBasePath, mandatoryFile));
    });

    v.addedFiles = new Set();
    v.usedModules = new Set();
    v.filesToRead = new Set();

    findUserLuaFiles(workspacePath);

    resetUsedModules();

    while(v.filesToRead.size !== 0){
        const filesToCheck = [...v.filesToRead];

        filesToCheck.forEach(file => {
            v.filesToRead.delete(file);

            if(lstatSync(file).isDirectory()){ return; }

            const content = readFileSync(file, 'utf-8');
            parseLuaFile(content);
        });

        updateUsedModules();

        addNecessaryFilesToLibrary();
    }

    workspace.applyEdit(v.workspaceEdit);

    window.showInformationMessage("Library built succesfully");
}