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
    private _hasInitialized: boolean;
    private _previousLibraryPath: string;
    private _previousDocsPath: string;

    constructor(context: vscode.ExtensionContext) {
        this.state = context.globalState;

        this._hasAskedToInit = this.state.get("hasAskedToInit") ?? false;
        this._hasInitialized = this.state.get("hasInitialized") ?? false;
        this._previousLibraryPath = this.state.get("previousLibraryPath") ?? "";
        this._previousDocsPath = this.state.get("previousDocsPath") ?? "";
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

    /**
     * Whether this workspace was initialized.
     */
    public get hasInitialized() {
        return this._hasInitialized;
    }

    public set hasInitialized(val: boolean) {
        this._hasInitialized = val;
        this.state.update("hasInitialized", val);
    }

    /**
     * The library path that was set in the last initialization.
     */
    public get previousLibraryPath() {
        return this._previousLibraryPath;
    }

    public set previousLibraryPath(val: string) {
        this._previousLibraryPath = val;
        this.state.update("previousLibraryPath", val);
    }

    /**
     * The docs path that was set in the last initialization.
     */
    public get previousDocsPath() {
        return this._previousDocsPath;
    }

    public set previousDocsPath(val: string) {
        this._previousDocsPath = val;
        this.state.update("previousDocsPath", val);
    }
}