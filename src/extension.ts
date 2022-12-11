import * as vscode from 'vscode';
import * as fs from 'fs';
import { TextEncoder } from 'util';
import * as path from "path";
import { buildProject } from './buildProject';
import { findFile } from './helpers';


export function activate(context: vscode.ExtensionContext) {
	let initProject = vscode.commands.registerCommand('library-of-isaac-extension.init-project', () => {
		const workspaceFolders = vscode.workspace.workspaceFolders;

		if(workspaceFolders === undefined){ return; }

		let workspacePath = workspaceFolders[0].uri.fsPath; // gets the path of the first workspace folder

		const luaCfgPath = findFile(workspacePath, ".luarc.json");

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

	let buildProjectCMD = vscode.commands.registerCommand('library-of-isaac-extension.build-project', () => buildProject(context));

	context.subscriptions.push(buildProjectCMD);
}

export function deactivate() {}
