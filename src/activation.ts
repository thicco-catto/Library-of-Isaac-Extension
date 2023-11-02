import * as vscode from 'vscode';
import * as fs from 'fs';
import { getState } from './state';
import * as path from "path";

const TSIL_MAIN_FILE_NAME = "TSIL.lua";
const LUA_CONFIG_FILE_NAME = ".luarc.json";
const DOCS_FILE_NAME = "docs.lua";

const YES = "Yes";
const NO = "No";

/**
 * Asks the user to activate the extension if the workspace is suitable.
 * 
 * Won't ask again if the user already answered, whether it was yes or no.
 * @param context 
 */
export async function checkToActivate(context: vscode.ExtensionContext) {
	const state = getState(context);

	if(state.hasAskedToInit) {
		return;
	}

	const isTSIL = await isTSILWorkspace();
	if(isTSIL) {
		askToActivate().then(response => {
			if(!response) {
				console.log("No response, will ask again later.");
				return;
			}else if(response === YES) {
				console.log("Answered yes, activating...");
				activateTSIL(context);
			}

			console.log("User answered something, won't ask again later.");
			state.hasAskedToInit = true;
		});
	}
}

/**
 * Asks the user if they want to initialize the project.
 * @returns The option the user choosed, if any.
 */
async function askToActivate() {
	return await vscode.window.showInformationMessage(
		"A TSIL.lua file has been found, do you want to activate Library of Isaac for this workspace?\n"
		+ "You can activate it later using the command `Library of Isaac: Initialize Library Of Isaac Project`.",
		YES,
		NO
	);
}

/**
 * Changes the .luarc.json to prepare it for TSIL and autocomplete to work properly.
 * @param context 
 * @returns 
 */
export async function activateTSIL(context: vscode.ExtensionContext) {
	const luaConfigPath = getLuaConfigPath();

	if(!luaConfigPath) {
		console.log("Couldn't get the lua config path.");
		vscode.window.showErrorMessage("Can't activate the extension since there are no workspaces open.");
		return;
	}

	const luaConfig: any = {};
	if(fs.existsSync(luaConfigPath)) {
		const doc = await vscode.workspace.openTextDocument(luaConfigPath);
		const configContents = JSON.parse(doc.getText());

		for (const key in configContents) {
			luaConfig[key] = configContents[key];
		}
	} else {
		const defaultConfig = getDefaultLuaConfig();
		for (const key in defaultConfig) {
			luaConfig[key] = defaultConfig[key];
		}
	}

	const isTSIL = await isTSILWorkspace();

	// Path of the TSIL documentation file for autocomplete
	let libPath = "";

	if(isTSIL) {
		console.log("TSIL found in the workspace, initializing accordingly.");

		const mainFile = (await vscode.workspace.findFiles(`**/${TSIL_MAIN_FILE_NAME}`))[0];
		const mainFilePath = mainFile.fsPath;
		const folderPath = path.parse(mainFilePath).dir;
		const relativeFolderPath = vscode.workspace.asRelativePath(folderPath);

		libPath = path.join(folderPath, DOCS_FILE_NAME);

		// Add the TSIL foler to the list of ignored directories
		if(!luaConfig["workspace.ignoreDir"]) {
			luaConfig["workspace.ignoreDir"] = [];
		}

		luaConfig["workspace.ignoreDir"].push(relativeFolderPath);
	} else {
		console.log("TSIL not found in the workspace, initializing accodingly.");
		libPath = path.join(context.extensionPath, "out", "library_of_isaac");
	}

	// Add TSIL global
	if(!luaConfig["diagnostics.globals"]){
		luaConfig["diagnostics.globals"] = [];
	}

	if(!luaConfig["diagnostics.globals"].includes("TSIL")) {
		luaConfig["diagnostics.globals"].push("TSIL");
	}

	// Add docs file to library
	if(!luaConfig["workspace.library"]) {
		luaConfig["workspace.library"] = [];
	}

	luaConfig["workspace.library"].push(libPath);

	// Write contents to .luarc.json
	fs.writeFileSync(luaConfigPath, JSON.stringify(luaConfig));

	console.log("TSIL initialized correctly");
	vscode.window.showInformationMessage("TSIL has been initialized in this workspace correctly");
}


/**
 * Checks if the workspace contains a file named `TSIL.lua`.
 */
async function isTSILWorkspace() {
	return (await vscode.workspace.findFiles(`**/${TSIL_MAIN_FILE_NAME}`)).length > 0;
}


/**
 * Returns the path the lua config should have, even if it doesn't exist.
 */
function getLuaConfigPath() {
	const workspaceFolders = vscode.workspace.workspaceFolders;
	if(!workspaceFolders) {
		return;
	}

	return path.join(workspaceFolders[0].uri.fsPath, LUA_CONFIG_FILE_NAME);
}


function getDefaultLuaConfig(): any {
	return {
		["$schema"]: "https://raw.githubusercontent.com/sumneko/vscode-lua/master/setting/schema.json",
		["runtime.version"]: "Lua 5.3",
		["workspace.library"]: [],
		["diagnostics.globals"]: [],
		["workspace.ignoreDir"]: [],
	};
}