import * as vscode from 'vscode';
import * as TSILParser from "./TSILParser";
import * as fs from 'fs';
import { TextEncoder } from 'util';
import * as path from "path";


function findLuaCfgFile(pathToSearch: string): string|undefined{
	const files = fs.readdirSync(pathToSearch);

	for (let index = 0; index < files.length; index++) {
		const file = files[index];

		if(file === ".luarc.json"){
			return pathToSearch;
		}else if(fs.lstatSync(path.join(pathToSearch, file)).isDirectory()){
			const found = findLuaCfgFile(path.join(pathToSearch, file));

			if(found !== undefined){
				return found;
			}
		}
	}

	return undefined;
}


function findTSILFile(pathToSearch: string) : string|undefined{
	const files = fs.readdirSync(pathToSearch);

	for (let index = 0; index < files.length; index++) {
		const file = files[index];

		if(file === "TSIL.lua"){
			return pathToSearch;
		}else if(fs.lstatSync(path.join(pathToSearch, file)).isDirectory()){
			const found = findTSILFile(path.join(pathToSearch, file));

			if(found !== undefined){
				return found;
			}
		}
	}

	return undefined;
}


function findMainLua(pathToSearch: string) : string|undefined{
	const files = fs.readdirSync(pathToSearch);

	for (let index = 0; index < files.length; index++) {
		const file = files[index];

		if(file === "main.lua"){
			return pathToSearch;
		}else if(fs.lstatSync(path.join(pathToSearch, file)).isDirectory()){
			const found = findMainLua(path.join(pathToSearch, file));

			if(found !== undefined){
				return found;
			}
		}
	}

	return undefined;
}


function parseLuaFiles(pathToSearch: string, tsilPath: string | undefined){
	if(tsilPath !== undefined && pathToSearch === tsilPath){ return; }

	fs.readdirSync(pathToSearch).forEach(file => {
		if(file.endsWith(".lua")){
			//Read file
			const fileContents = fs.readFileSync(path.join(pathToSearch, file), 'utf-8');
			TSILParser.parseLuaFile(fileContents);
		}else if(fs.lstatSync(path.join(pathToSearch, file)).isDirectory()){
			parseLuaFiles(path.join(pathToSearch, file), tsilPath);
		}
	});
}


function writeFileToLibrary(tsilPath: string, relativePath: string, content: string, workspaceEdit: vscode.WorkspaceEdit){
	const encoder = new TextEncoder();

	const filePath = vscode.Uri.file(path.join(tsilPath, relativePath));

	if(fs.existsSync(filePath.toString())){ 
		const oldContents = fs.readFileSync(filePath.toString(), {encoding: "utf-8"});

		if(oldContents.length >= content.length){
			//Old contents where the same or more
			return;
		}
	}

	workspaceEdit.createFile(filePath, { 
		overwrite: true,
		ignoreIfExists: true,
		contents: encoder.encode(content)
	});
}


function minifyLuaFile(baseLibfile: string, relativePath: string, tsilPath: string, usedModules: string[], workspaceEdit: vscode.WorkspaceEdit, addedFiles: string[]){
	const fileContents = fs.readFileSync(path.join(baseLibfile, relativePath), 'utf-8');
	const fileLines = fileContents.split("\n");
	let minifiedContents = "";

	let isReadingNotNeccessaryFunction = false;
	let isReadingNotNeccessaryEnum = false;
	let commentLines = 0;
	let addCallback:undefined|boolean = undefined;
	let forcedFiles: string[] = [];

	fileLines.forEach(line => {
		if(addCallback === undefined){
			if(line.startsWith("--##")){
				//Special parser comment
				if(line.startsWith("--##use")){
					//Uses another file
					forcedFiles.push(line.split(" ")[1].trim());
				}else{
					//Is callback file
					const callback = line.replace("--##", "").trim();
					const fullCallback = "TSIL.Enums.CustomCallback." + callback;

					addCallback = usedModules.includes(fullCallback);
				}
			}else if(isReadingNotNeccessaryFunction || isReadingNotNeccessaryEnum){
				if(line.trimEnd() === "end" && isReadingNotNeccessaryFunction){
					isReadingNotNeccessaryFunction = false;
				}else if(line.trimEnd() === "}" && isReadingNotNeccessaryEnum){
					isReadingNotNeccessaryEnum = false;
				}
			}else{
				if(line.startsWith("function TSIL.")){
					//Get function identifier
					let auxLine = line;

					auxLine = auxLine.replace("function ", "");
					const identifier = auxLine.split("(")[0];

					if(!usedModules.includes(identifier)){
						let minifiedLines = minifiedContents.split("\n");
						minifiedLines = minifiedLines.filter((v) => v.length>0);
						for (let i = 0; i < commentLines; i++) {
							minifiedLines.pop();
						}

						minifiedContents = minifiedLines.join("\n");

						isReadingNotNeccessaryFunction = true;
						commentLines = 0;
						return;
					}

					commentLines = 0;
				}else if(line.startsWith("TSIL.Enums.")){


					let auxLine = line;

					auxLine = auxLine.replace("function ", "");
					const identifier = auxLine.split("=")[0].trim();

					if(!usedModules.includes(identifier)){
						let minifiedLines = minifiedContents.split("\n");
						minifiedLines = minifiedLines.filter((v) => v.length>0);
						for (let i = 0; i < commentLines; i++) {
							minifiedLines.pop();
						}

						minifiedContents = minifiedLines.join("\n");

						isReadingNotNeccessaryEnum = true;
						commentLines = 0;
						return;
					}

					commentLines = 0;
				}else if(line.startsWith("---")){
					commentLines++;
				}

				minifiedContents += line + "\n";
			}
		}else if(addCallback){
			minifiedContents += line + "\n";
		}
	});

	if(minifiedContents.includes("function TSIL.") ||
	minifiedContents.includes("---@enum") || minifiedContents.includes("--- @enum") ||
	(addCallback !== undefined && addCallback)){
		forcedFiles.forEach(forcedFile => {
			const content = fs.readFileSync(path.join(baseLibfile, forcedFile), 'utf-8');
	
			writeFileToLibrary(tsilPath, forcedFile, content, workspaceEdit);

			addedFiles.push(path.join(tsilPath, forcedFile));
		});

		addedFiles.push(path.join(tsilPath, relativePath));

		writeFileToLibrary(tsilPath, relativePath, minifiedContents.trim(), workspaceEdit);
	}
}


function moveFilesToLibrary(baseLibPath: string, tsilPath: string, filePath: string, usedModules: string[], workspaceEdit: vscode.WorkspaceEdit, addedFiles: string[]){
	fs.readdirSync(path.join(baseLibPath, filePath)).forEach(file => {
		if(file.endsWith(".lua")){
			minifyLuaFile(baseLibPath, path.join(filePath, file), tsilPath, usedModules, workspaceEdit, addedFiles);
		}else if(fs.lstatSync(path.join(baseLibPath, filePath, file)).isDirectory()){
			moveFilesToLibrary(baseLibPath, tsilPath, path.join(filePath, file), usedModules, workspaceEdit, addedFiles);
		}
	});
}


function updateUsedModulesListFiles(pathToSearch: string, usedModulesList: string[], addedFiles: string[]){
	fs.readdirSync(pathToSearch).forEach(file => {
		if(fs.lstatSync(path.join(pathToSearch, file)).isDirectory()){
			updateUsedModulesListFiles(path.join(pathToSearch, file), usedModulesList, addedFiles);
		}else if(file.endsWith(".lua")){
			const foundFile = addedFiles.find(s => {
				const fullPath = path.join(pathToSearch, file);
				return fullPath.includes(s);
			});

			if(foundFile !== undefined){
				const fileContents = fs.readFileSync(path.join(pathToSearch, file), {encoding: "utf-8"});
				TSILParser.parseLuaFile(fileContents);
			}
		}
	});
}


function updateUsedModulesList(tsilPath: string, usedModulesList: string[], addedFiles: string[]){
	fs.readdirSync(tsilPath).forEach(file => {
		if(fs.lstatSync(path.join(tsilPath, file)).isDirectory()){
			updateUsedModulesListFiles(path.join(tsilPath, file), usedModulesList, addedFiles);
		}
	});
}


function getModulesList(dependencies: {[key: string]: string[]}): string[]{
	const usedModules = TSILParser.getUsedModules();
	let hasAddedModule = false;

	do{
		hasAddedModule = false;

		usedModules.forEach(usedModule => {
			const moduleDependencies = dependencies[usedModule];	

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
	const usedModulesList: string[] = [];
	usedModules.forEach(usedModule =>{
		if(usedModule === "TSIL"){ return; }

		if(usedModule.startsWith("TSIL.Enums") && !usedModule.startsWith("TSIL.Enums.CustomCallback")){
			const tokens = usedModule.split(".");
			tokens.pop();
			let newModule = tokens.join(".");
			usedModulesList.push(newModule);
		}else{
			usedModulesList.push(usedModule);
		}
	});

	return usedModulesList;
}


export function activate(context: vscode.ExtensionContext) {
	let initProject = vscode.commands.registerCommand('library-of-isaac-extension.init-project', () => {
		const workspaceFolders = vscode.workspace.workspaceFolders;

		if(workspaceFolders === undefined){ return; }

		let workspacePath = workspaceFolders[0].uri.fsPath; // gets the path of the first workspace folder

		const luaCfgPath = findLuaCfgFile(workspacePath);

		if(luaCfgPath === undefined){
			vscode.window.showErrorMessage("Can't find .luarc.json file, make sure you installed the required extensions");
			return;
		}
		const fullLuaCfgPath = path.join(luaCfgPath, ".luarc.json");
		const luarcContents = fs.readFileSync(fullLuaCfgPath, {encoding: "utf-8"});
		const luarcConfig = JSON.parse(luarcContents);

		luarcConfig["workspace.library"].push(path.join(context.extensionPath, "out", "emmylua"));
		luarcConfig["diagnostics.globals"].push("TSIL");

		const newContents = JSON.stringify(luarcConfig);
		const luaCfgFile = vscode.Uri.file(fullLuaCfgPath);

		const workspaceEdit = new vscode.WorkspaceEdit();
		const encoder = new TextEncoder();

		workspaceEdit.createFile(luaCfgFile, { 
			overwrite: true,
			ignoreIfExists: true,
			contents: encoder.encode(newContents)
		});

		vscode.workspace.applyEdit(workspaceEdit);

		vscode.window.showInformationMessage("Updated .luarc.json file");
	});

	context.subscriptions.push(initProject);

	let buildProject = vscode.commands.registerCommand('library-of-isaac-extension.build-project', () => {
		const workspaceFolders = vscode.workspace.workspaceFolders;

		if(workspaceFolders === undefined){ return; }

		let workspacePath = workspaceFolders[0].uri.fsPath; // gets the path of the first workspace folder

		let tsilPath = findTSILFile(workspacePath);

		if(tsilPath === undefined){
			const mainLuaPath = findMainLua(workspacePath);

			if(mainLuaPath === undefined){
				vscode.window.showInformationMessage("No main.lua file has been found, create one to start.");
				return;
			}

			if(!fs.existsSync(path.join(mainLuaPath, "LibraryOfIsaac"))){
				fs.mkdirSync(path.join(mainLuaPath, "LibraryOfIsaac"));
			}
			vscode.window.showInformationMessage("A new folder has been created for the library, make sure to change it's name.");
			tsilPath = path.join(mainLuaPath, "LibraryOfIsaac"); 
		}

		//Calculate dependencies
		const dependenciesFile = fs.readFileSync(path.join(context.extensionPath, "/out/data/dependencies.json"), 'utf-8');
		const dependencies: {[key: string]: string[]} = JSON.parse(dependenciesFile);

		TSILParser.resetUsedModules();

		parseLuaFiles(workspacePath, tsilPath);

		let usedModulesList = getModulesList(dependencies);

		//Remove all files inside the tsil folder
		const workspaceEdit = new vscode.WorkspaceEdit();
		fs.readdirSync(tsilPath).forEach(file => {
			if(tsilPath === undefined){ return; } //ts crying again
			const fileToDelete = vscode.Uri.file(path.join(tsilPath, file));
			workspaceEdit.deleteFile(fileToDelete, {recursive: true});
		});

		//Mandatory files
		if(usedModulesList.length === 0){
			vscode.workspace.applyEdit(workspaceEdit);
			return;
		}

		const libBasePath = path.join(context.extensionPath, "/out/data/lib");

		const mandatoryFiles = [
			"TSIL.lua",
			"scripts.lua",
		];
		mandatoryFiles.forEach(mandatoryFile => {
			if(tsilPath === undefined){ return; } //typecript is crying idk

			const content = fs.readFileSync(path.join(libBasePath, mandatoryFile), 'utf-8');
			writeFileToLibrary(tsilPath, mandatoryFile, content, workspaceEdit);
		});

		while(true){
			const addedFiles: string[] = [];
			moveFilesToLibrary(libBasePath, tsilPath, "", usedModulesList, workspaceEdit, addedFiles);

			//Check if we are missing any modules
			const oldUsedModulesLength = usedModulesList.length;
			updateUsedModulesList(tsilPath, usedModulesList, addedFiles);
			usedModulesList = getModulesList(dependencies);
			const newUsedModulesLength = usedModulesList.length;

			if(newUsedModulesLength === oldUsedModulesLength){
				break;
			}
		}

		vscode.workspace.applyEdit(workspaceEdit);
	});

	context.subscriptions.push(buildProject);
}

export function deactivate() {}
