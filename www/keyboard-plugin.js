var exec = require('cordova/exec');

var KeyboardPlugin = {
    /**
     * 顯示鍵盤並添加 "-" 按鈕。
     * @param {Function} successCallback 成功回調
     * @param {Function} errorCallback 失敗回調
     */
    addMinusButtonToKeyboard: function(successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'KeyboardPlugin', 'addMinusButtonToKeyboard', []);
    },

    /**
     * 點擊 "-" 按鈕的處理方法。
     * @param {Function} successCallback 成功回調
     * @param {Function} errorCallback 失敗回調
     */
    minusButtonAction: function(successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'KeyboardPlugin', 'minusButtonAction', []);
    },

    /**
     * 點擊 "確定" 按鈕的處理方法。
     * @param {Function} successCallback 成功回調
     * @param {Function} errorCallback 失敗回調
     */
    doneButtonAction: function(successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'KeyboardPlugin', 'doneButtonAction', []);
    }
};

module.exports = KeyboardPlugin;