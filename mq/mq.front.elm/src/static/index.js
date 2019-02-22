// pull in desired CSS/SASS files
require('./styles/main.scss');
window.ace = require('../../node_modules/brace/index.js');
require('../../node_modules/brace/mode/matlab.js');
var FileSaver = require('file-saver');
// inject bundled Elm app into div#main
var storedState = localStorage.getItem('state');
var startingState = storedState ? JSON.parse(storedState) : null;

var Elm = require('../elm/Main');
var app = Elm.Main.fullscreen(startingState);

app.ports.store.subscribe(function (state) { localStorage.setItem('state', JSON.stringify(state)) });

app.ports.clear.subscribe(function () { localStorage.removeItem('state') });


// app.ports.unzip.subscribe((hex) => {
//     var view = new Uint8Array(hex.length / 2)
//     var hex = hex.substring(2)
//     for (var i = 0; i < hex.length; i += 2) {
//         view[i / 2] = parseInt(hex. substring(i, i + 2), 16)
//     }
//     new JSZip(view)
//         .loadAsync()
//         .then(x => app.ports.fileList)
// });


app.ports.downloadZip.subscribe(function(hex) {
    var view = new Uint8Array(hex.length / 2)
    var hex = hex.substring(2)
    for (var i = 0; i < hex.length; i += 2) {
        view[i / 2] = parseInt(hex.substring(i, i + 2), 16)
    }
    FileSaver.saveAs(new Blob([view], {
        type: "application/zip"
    }), "results.zip")
})
