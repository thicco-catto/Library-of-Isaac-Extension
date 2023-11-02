"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const fs = require("fs");
const path = require("path");

/**
 * Copies a folder into another folder recursively.
 * @param basePath Base path of the folder we're copying from.
 * @param targetPath Target path the folder will be copied to.
 * @param relativePath Relative path inside the base folder we're copying from currently.
 * @param exclude List of paths that will be excluded from the copy.
 */
function copyFolderContents(basePath, targetPath, relativePath, exclude) {
    const fullBasePath = path.join(basePath, relativePath);
    fs.readdirSync(fullBasePath).forEach(contentPath => {
        const newRelativePath = path.join(relativePath, contentPath);
        const newFullFilePath = path.join(fullBasePath, contentPath);
        if (exclude.includes(newFullFilePath)) {
            return;
        }
        if (fs.statSync(newFullFilePath).isDirectory()) {
            copyFolderContents(basePath, targetPath, newRelativePath, exclude);
        }
        else {
            copyFile(newFullFilePath, path.join(targetPath, newRelativePath));
        }
    });
}

function copyFile(source, destination) {
    createMissingFolders(destination);
    fs.copyFileSync(source, destination);
}

function createMissingFolders(destination) {
    const destFolder = path.dirname(destination);
    if (!fs.existsSync(destFolder)) {
        fs.mkdirSync(destFolder, { recursive: true });
    }
}
copyFolderContents("src/library_of_isaac", "out/library_of_isaac", "", []);
