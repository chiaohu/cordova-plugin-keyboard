var exec = require('cordova/exec');

var KeyboardPlugin = {
    addMinusButton: function(successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'KeyboardPlugin', 'addMinusButton', []);
    }
};

module.exports = KeyboardPlugin;
