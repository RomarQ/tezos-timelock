var fs = require("fs");
var shell = require("./shell.js");

const files = {};
Promise.all(
    shell.my_modules.map(fileName => {
        const buffer = fs.readFileSync(fileName + ".wasm");
        files[fileName] = buffer.toJSON();
    })
).then(() => {
    fs.writeFileSync("./wasm_buffers.json", JSON.stringify(files, null, 4), { encoding: "utf-8" });
    console.log();
    console.log("Finished building ./wasm_buffers.json");
    console.log();
})
