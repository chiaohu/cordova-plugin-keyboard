import Foundation
import Cordova

@objc(MyPlugin) class MyPlugin: CDVPlugin {
    
    var doneToolbar: UIToolbar!

    // 初始化時設置工具欄
    override func pluginInitialize() {
        super.pluginInitialize()
        setupToolbar()
    }

    @objc(addMinusButtonToKeyboard:)
    func addMinusButtonToKeyboard(command: CDVInvokedUrlCommand) {
        // 設置工具欄
        setupToolbar()
        
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Keyboard setup completed")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    @objc(minusButtonAction:)
    func minusButtonAction(command: CDVInvokedUrlCommand) {
        // 處理 "-" 按鈕點擊事件
        handleMinusButtonAction()
        
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Minus button pressed")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    @objc(doneButtonAction:)
    func doneButtonAction(command: CDVInvokedUrlCommand) {
        // 處理 "完成" 按鈕點擊事件
        handleDoneButtonAction()
        
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Done button pressed")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    // 設置工具欄
    func setupToolbar() {
        // 初始化工具欄
        doneToolbar = UIToolbar()
        doneToolbar.sizeToFit()
        
        // 設置按鈕
        let minusBtn = UIBarButtonItem(title: "-", style: .plain, target: self, action: #selector(minusButtonAction))
        let doneBtn = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(doneButtonAction))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        doneToolbar.items = [minusBtn, flexSpace, doneBtn]
        
        // 添加工具欄到鍵盤
        if let webView = self.webView as? WKWebView {
            if let inputElement = webView.evaluateJavaScript("document.activeElement", completionHandler: nil) as? HTMLElement {
                inputElement.inputAccessoryView = doneToolbar
            }
        }
    }

    @objc func handleMinusButtonAction() {
        // 在當前活動的輸入框中插入 "-"
        if let webView = self.webView as? WKWebView {
            let js = """
            (function() {
                var inputs = document.querySelectorAll('input[type="text"], input[type="number"]');
                for (var i = 0; i < inputs.length; i++) {
                    var input = inputs[i];
                    if (document.activeElement === input) {
                        input.value += '-';
                        input.focus();
                    }
                }
            })();
            """
            webView.evaluateJavaScript(js) { _, error in
                if let error = error {
                    print("Error evaluating JavaScript: \(error.localizedDescription)")
                }
            }
        }
    }

    @objc func handleDoneButtonAction() {
        // 收起鍵盤
        if let webView = self.webView as? WKWebView {
            let js = "document.activeElement.blur();"
            webView.evaluateJavaScript(js) { _, error in
                if let error = error {
                    print("Error evaluating JavaScript: \(error.localizedDescription)")
                }
            }
        }
    }
}
