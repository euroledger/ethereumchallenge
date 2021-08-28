const crypto = require('crypto');

function sha256(data) {
    return crypto.createHash("sha256").update(data, "binary").digest("hex");
}

function genHexString(len) {
    const hex = '0123456789ABCDEF';
    let output = '';
    for (let i = 0; i < len; ++i) {
        output += hex.charAt(Math.floor(Math.random() * hex.length));
    }
    return output;
}

function decimalToHex(d, padding) {
    var hex = Number(d).toString(16);
    padding = typeof (padding) === "undefined" || padding === null ? padding = 2 : padding;

    while (hex.length < padding) {
        hex = "0" + hex;
    }

    return hex;
}
var args = process.argv.slice(2);
let words = args[0];

// 794339D3F1F0E8F600261E500824A02343F594E7A8F42429EC9D37C81C4C4F44
//We set the difficulty
let difficulty = "cafe";
// nonce start at 0
let nonce = 0;
// The final hash will be updated in this var
let hex = "";
// Our switch
let check = true;

// loop until we found the nonce
while (check) {

    // add the hash to random string
    let digestHex = sha256(nonce.toString() + words);

    // check if the digest start with the difficulty
    if (digestHex.endsWith(difficulty)) {
        hex = digestHex;
        check = false;
    } else {
        nonce++;
    }
}

console.log(hex);
console.log(decimalToHex(nonce, 8));
