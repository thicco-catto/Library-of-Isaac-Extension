# Library Of Isaac Extension

![Version (including pre-releases)](https://img.shields.io/visual-studio-marketplace/v/ThiccoCatto.library-of-isaac-extension)
![Downloads](https://img.shields.io/visual-studio-marketplace/i/ThiccoCatto.library-of-isaac-extension)

<img src="https://imgur.com/3Z6cAMm.png" alt="Library of Isaac Logo" width="300"></img>

The Library of Isaac is a repository packed with missing enums, frequently used functions, new custom callbacks and even more incredibly useful utilities. It provides mod developers with a powerful and lightweight toolbox to help develop their projects even faster.

Check out the [github repository](https://github.com/Team-Compliance/libraryofisaac) and the [documentation](https://team-compliance.gitbook.io/library-of-isaac/) for the library.

## Features

The extension offers two main utilities, and you don't need to download the library separately to use them. However, it's highly recommended to add the library as a git submodule to ensure you are using the latest version.

### Initialize Library of Isaac Project

This command configures your workspace for lua autocompletion, enabling the recognition of all library functions. The extension will also automatically ask you to initialize it if it detects the library being in your workspace.

If you already have the complete library downloaded or as a submodule in your project, the extension will seamlessly use the corresponding autocomplete for that specific version. In cases where you don't have the complete library, the extension provides a built-in default version for autocompletion.

To enable the autocomplete to have the [Lua Language Server Extension](https://marketplace.visualstudio.com/items?itemName=sumneko.lua) installed.

<img src="https://imgur.com/azueo2s.png" alt="Enum Autocomplete Showcase" width="500"></img>

### Build Library of Isaac Project

This command scans your project's lua files, identifying the specific library functionalities you're utilizing, and automatically trims any unnecessary library files to optimize performance and reduce bloat.

If you have the complete library downloaded or as a submodule in your project, the extension will create a new  folder called `release-mod` and place your mod files alongside the reduced library version to avoid conflicts.

Otherwise, it will replace your current library in the mod with the reduced version, extracting the file from the built-in default version.

![Build Command Showcase](https://imgur.com/EinZUy0.gif)

## Requirements

While this extension doesn't have specific requirements, it's highly recommended to install the following extensions to enhance your experience:

- [Lua Language Server Extension](https://marketplace.visualstudio.com/items?itemName=sumneko.lua): Enables autocomplete for lua.

- [Filloax's Binding of Isaac API autocomplete](https://marketplace.visualstudio.com/items?itemName=Filloax.isaac-lua-api-vscode): Provides comprehensive autocomplete support for the Binding of Isaac API, further enhancing your modding capabilities.

## Known Issues

As of now, there are no known issues. If you encounter any, please feel free to create a new issue in the repository, and it'll be addressed promptly.

## Release Notes

See [CHANGELOG.md](CHANGELOG.md) for a full list of changes.

### 1.0.0

- Initial full release.
- Automatically checks if the library is in the workspace and prompts the user to initialize it.
- If the full library is in the workspace, the build command creates a copy of the mod with the reduced library.

### 0.1.0

- Improved build command.

### 0.0.1

- Beta release of Library Of Isaac Extension
