import { lstatSync, readdirSync } from "fs";
import { join } from "path";

export function findFile(basePath: string, fileToFind: string): string | undefined{
    const files = readdirSync(basePath);

	for (let index = 0; index < files.length; index++) {
		const file = files[index];

		if(file === fileToFind){
			return basePath;
		}else if(lstatSync(join(basePath, file)).isDirectory()){
			const found = findFile(join(basePath, file), fileToFind);

			if(found !== undefined){
				return found;
			}
		}
	}

	return undefined;
}