import * as vscode from 'vscode'; 
import { getState } from './state';
import { activateTSIL, checkToActivate } from './activation';
import { buildProject } from './buildProject';

export function activate(context: vscode.ExtensionContext) {
	const state = getState(context);

	// Add init command
	let initProjectCMD = vscode.commands.registerCommand(
		'library-of-isaac-extension.init-project',
		() => activateTSIL(context)
	);
	context.subscriptions.push(initProjectCMD);

	// Add build command
	let buildProjectCMD = vscode.commands.registerCommand(
		'library-of-isaac-extension.build-project',
		() => buildProject(context)
	);
	context.subscriptions.push(buildProjectCMD);

	// Ask to automatically initialize
	if(!state.hasAskedToInit) {
		//Try to activate inmediately
		checkToActivate(context);

		//And try to activate when opening a lua file
		context.subscriptions.push(vscode.workspace.onDidOpenTextDocument((ev) => onDidOpenFile(ev, context)));
	}
}

export function deactivate() {}

function onDidOpenFile(ev: vscode.TextDocument, context: vscode.ExtensionContext) {
	if(ev.languageId === "lua") {
		checkToActivate(context);
	}
}