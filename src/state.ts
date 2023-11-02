import * as vscode from 'vscode';


/**
 * Returns the current state in this workspace, which is persistent
 * @param context
 * @returns 
 */
export function getState(context: vscode.ExtensionContext) {
    return new State(context);
}

class State {
    private state: vscode.Memento;

    private _hasAskedToInit: boolean;

    constructor(context: vscode.ExtensionContext) {
        this.state = context.globalState;

        this._hasAskedToInit = this.state.get("hasAskedToInit") ?? false;
    }

    /**
     * Whether the user has been asked to initialize the workspace.
     */
    public get hasAskedToInit() {
        return this._hasAskedToInit;
    }

    public set hasAskedToInit(val: boolean) {
        this._hasAskedToInit = val;
        this.state.update("hasAskedToInit", val);
    }
}