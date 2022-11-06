import * as parser from "luaparse";

interface TreeNode {
    key: string; // type for unknown keys.
    children: TreeNode[]; // type for a known property.
}

let modulesUsed: TreeNode = {key: "TSIL", children: []};
let currentLevel = 0;
let scopeVariables: {[level: number] : {[id: string] : string;}; };


function isIdentifierTSILModule(name: string) : boolean{
    for (let level = currentLevel; level >= 0; level--) {
        const variables = scopeVariables[level];    

        if(variables[name] !== undefined){
            return true;
        }
    }

    return false;
}


function getTSILModuleFromIdentifier(name: string): string{
    for (let level = currentLevel; level >= 0; level--) {
        const variables = scopeVariables[level];    

        if(variables[name] !== undefined){
            return variables[name];
        }
    }

    return "";
}


function getIdentifierFromMemberExpression(init: parser.MemberExpression) : string{
    if(init.base.type === "Identifier"){
        if(isIdentifierTSILModule(init.base.name)){
            return getTSILModuleFromIdentifier(init.base.name) + "." + init.identifier.name;
        }else{
            return init.base.name + "." + init.identifier.name;
        }
    }else if(init.base.type === "MemberExpression"){
        return getIdentifierFromMemberExpression(init.base) + "." + init.identifier.name;
    }

    return "";
}


function addTSILModuleToTree(module: string){
    const modules = module.split(".");
    let currentNode = modulesUsed;

    for (let i = 1; i < modules.length; i++) {
        const name = modules[i];
        let foundChildren = false;

        currentNode.children.forEach(children => {
            if(children.key === name){
                currentNode = children;
                foundChildren = true;
            }
        });

        if(!foundChildren){
            const newNode = {key: name, children: []};
            currentNode.children.push(newNode);
            currentNode = newNode;
        }
    }
}


function onCreateNode(node: parser.Node){
    switch(node.type){
        case 'MemberExpression':{
            const value = getIdentifierFromMemberExpression(node);

            if(value.startsWith("TSIL")){
                addTSILModuleToTree(value);
            }

            break;
        }
        case 'CallExpression':{
            const args = node.arguments;

            args.forEach(argument => {
                if(argument.type === "MemberExpression"){
                    const value = getIdentifierFromMemberExpression(argument);

                    if(value.startsWith("TSIL")){
                        addTSILModuleToTree(value);
                    }
                }
            });

            if(node.base.type === "MemberExpression"){
                const value = getIdentifierFromMemberExpression(node.base);

                if(value.startsWith("TSIL")){
                    addTSILModuleToTree(value);
                }
            }
            
            break;
        }

        case 'LocalStatement':{
            for (let i = 0; i < node.variables.length; i++) {
                const variable = node.variables[i];
                const init = node.init[i];
                let value: string = "";

                if(init === undefined){ break; }
                if(init.type === undefined){ break; }

                if(init.type === "Identifier"){
                    //Is single identifier
                    if(isIdentifierTSILModule(init.name)){
                        value = getTSILModuleFromIdentifier(init.name);
                    }
                }else if(init.type === "MemberExpression"){
                    //Is indexing table
                    value = getIdentifierFromMemberExpression(init);
                }

                if(value.startsWith("TSIL")){
                    scopeVariables[currentLevel][variable.name] = value;
                    addTSILModuleToTree(value);
                }
            }
            break;
        }
    }
}


function onCreateScope(){
    currentLevel++;
    scopeVariables[currentLevel] = {};
}


function onDestroyScope(){
    scopeVariables[currentLevel] = {};
    currentLevel--;
}


export function parseLuaFile(luaString : string){
    currentLevel = 0;
    // eslint-disable-next-line @typescript-eslint/naming-convention
    scopeVariables = {0: {}};
    parser.parse(luaString, {
        scope: true,
        luaVersion: "5.3",
        onCreateNode: onCreateNode,
        onCreateScope: onCreateScope,
        onDestroyScope: onDestroyScope
    });
}


function treeToSet(tree: TreeNode, prefix = "", used = new Set<string>): Set<string>{
    if(tree.children.length === 0){
        return used.add(prefix + tree.key);
    }else{
        tree.children.forEach(child => {
            treeToSet(child, prefix + tree.key + ".", used);
        });
    }

    return used;
}


export function resetUsedModules(){
    modulesUsed = {key: "TSIL", children: []};
}


export function getUsedModules(): Set<string>{
    return treeToSet(modulesUsed);
}