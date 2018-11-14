
const fs = require('fs');
const path = require('path');

let files = fs.readdirSync("./contracts");

files = files.filter(f => {
    if (f.endsWith("unified.sol")) return false;
    if (!f.endsWith(".sol") || f.toLowerCase() === "migrations.sol") return false;
    return true;
});


const importList = {
    escrow: ["safemath", "roles", "pauserrole", "pausable", "ownable", "proxied", "ierc20", "ierc20extension", "publcentity", "publcaccount"],
    reserve: ["safemath", "roles", "pauserrole", "pausable", "ownable", "proxied", "ierc20", "ierc20extension", "publcentity", "publcaccount"],
    publc: ["safemath", "roles", "pauserrole", "pausable", "ownable", "proxied", "ierc20", "ierc20extension", "publcentity", "publcaccount", "escrow", "reservce"],
    publx: ["safemath", "roles", "pauserrole", "pausable", "ierc20", "erc20", "erc20pausable", "publcentity"]
};


files.map(f => {

    console.log("file = " + f);
    let imports = [];
    doRec("./contracts/", f, imports);

    //console.log(imports);

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
        imports.push(i);
    });
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
            if (!imports.includes(imp))
                importsInt.push(imp);
        }
    });

    return importsInt;

}
