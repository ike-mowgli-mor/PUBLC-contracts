
const fs = require('fs');
const path = require('path');

let files = fs.readdirSync("./contracts");

files = files.filter(f => {
    if (f.endsWith("unified.sol")) return false;
    if (!f.endsWith(".sol") || f.toLowerCase() === "migrations.sol") return false;
    return true;
});

files.map(f => {

    console.log("file = " + f);
    let imports = [];
    doRec("./contracts/", f, imports);

    const importsFiltered = [];
    for (let i = 0 ; i < imports.length ; i++) {
        const imp = imports[i];
        let found = false;
        for (let j = i + 1 ; j < imports.length ; j++) {
            if (imports[j] === imp) {
                found = true;
                break;
            }
        }

        if (!found) {
            importsFiltered.push(imp);
        }
    }

    imports = importsFiltered;

    imports.unshift("./contracts/" + f);

    console.log(imports);

    let lineDelimMain = null;
    let importLoc = -1;
    let linesMain = null;

    imports.map(i => {
        let contract = fs.readFileSync(i, 'utf8');

        let lineDelim = "\r\n";
        if (!contract.includes(lineDelim))
            lineDelim = "\n";

        if (lineDelimMain === null) {
            lineDelimMain = lineDelim;
        }

        let lines = contract.split(lineDelim);

        lines = lines.filter((l, ind) => {

            if (l.trim().toLowerCase().startsWith("pragma")) {
                if (importLoc===-1) return true; // If this is the main contract
                return false;
            }

            if (l.trim().toLowerCase().startsWith("import")) {
                const importLineParts = l.split(" ");
                if (importLineParts.length!==2) {
                    return true;
                }

                if (!(importLineParts[1].startsWith("\"") && importLineParts[1].endsWith("\";"))) {
                    return true;
                }

                if (importLoc === -1) {
                    importLoc = ind;
                }
                return false;
            }

            return true;
        });

        if (linesMain === null) {
            linesMain = lines;
        }
        else {
            contract = lines.join(lineDelim);
            linesMain.splice(importLoc, 0, contract.replace(lineDelim, lineDelimMain));
            //linesMain.splice(importLoc, 0, "// *******************************************************");
            //linesMain.splice(importLoc, 0, "// Import '" + path.basename(i) + "'");
            //linesMain.splice(importLoc, 0, "// *******************************************************");
        }
    });

    fs.writeFileSync(("./contracts/" + f).replace(".sol", "_unified.sol"), linesMain.join(lineDelimMain));
});

function doRec(basePath, f, imports) {
    let contract = fs.readFileSync(basePath + f, 'utf8');

    const importsInt = getFileImports(contract, basePath, imports);
    importsInt.map(i => {
        doRec(path.dirname(i) + "/", path.basename(i), imports);
    });
}

function getFileImports(contract, basePath, imports) {
    const importsInt = [];
    let lineDelim = "\r\n";
    if (!contract.includes(lineDelim))
        lineDelim = "\n";
    const lines = contract.split(lineDelim);

    lines.map(l => {
        if (l.trim().toLowerCase().startsWith("import")) {
            const importLineParts = l.split(" ");
            if (importLineParts.length!==2) {
                throw new Error("error");
            }

            if (!(importLineParts[1].startsWith("\"") && importLineParts[1].endsWith("\";"))) {
                throw new Error("error 2");
            }

            const imp = path.resolve(basePath + importLineParts[1].substr(1,importLineParts[1].length-3));
            imports.push(imp);
            importsInt.push(imp);
        }
    });

    return importsInt;

}
