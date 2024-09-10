var exec = require('cordova/exec');

var IOSKeyboardExtension = {
    addHyphenKey: function(successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'IOSKeyboardExtension', 'addHyphenKey', []);
    }
};

module.exports = IOSKeyboardExtension;
