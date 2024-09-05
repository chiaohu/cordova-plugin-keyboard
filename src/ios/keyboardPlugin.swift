import Foundation

@objc(KeyboardPlugin) class KeyboardPlugin: CDVPlugin {
    
    var doneToolbar: UIToolbar!
    
    override func pluginInitialize() {
        super.pluginInitialize()
        setupToolbar()
    }

    func setupToolbar() {
        doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.webView!.frame.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let minusBtn = UIBarButtonItem(title: "-", style: .plain, target: self, action: #selector(minusButtonAction))
        let doneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))

        doneToolbar.items = [minusBtn, flexSpace, doneBtn]
        doneToolbar.sizeToFit()
    }

    @objc func minusButtonAction() {
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

    @objc func doneButtonAction() {
        if let webView = self.webView as? WKWebView {
            let js = "document.activeElement.blur();"
            webView.evaluateJavaScript(js) { _, error in
                if let error = error {
                    print("Error evaluating JavaScript: \(error.localizedDescription)")
                }
            }
        }
    }

    @objc(addCustomToolbar:)
    func addCustomToolbar(command: CDVInvokedUrlCommand) {
        if let webView = self.webView as? WKWebView {
            webView.inputAccessoryView = doneToolbar
        }
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Toolbar added")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }
}
