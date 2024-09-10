var exec = require('cordova/exec');

var KeyboardMinus = {
    addMinusButton: function(successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'KeyboardMinus', 'addMinusButton', []);
    }
};

module.exports = KeyboardMinus;
