import UIKit

@objc(KeyboardPlugin) class KeyboardPlugin: CDVPlugin {
    
    @objc(addMinusButton:)
    func addMinusButton(command: CDVInvokedUrlCommand) {
        DispatchQueue.main.async {
            // 確保 viewController 存在
            if let viewController = self.viewController {
                // 搜尋 WKWebView 中的 input 元素
                if let webView = viewController.view.subviews.first(where: { $0 is WKWebView }) as? WKWebView {
                    self.addMinusButtonToWebView(webView: webView)
                    let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Minus button added")
                    self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                } else {
                    let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "WKWebView not found")
                    self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                }
            }
        }
    }

    // 添加 Minus 按鈕到 WKWebView 的 input 元素的鍵盤
    func addMinusButtonToWebView(webView: WKWebView) {
        // 建立 UIToolbar 作為鍵盤上方的工具列
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        // 建立 minus 按鈕
        let minusButton = UIBarButtonItem(title: "-", style: .plain, target: self, action: #selector(insertMinus))

        // 建立完成按鈕
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))

        // 建立彈性空間讓按鈕分開
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        // 將按鈕添加到工具列上
        toolbar.setItems([minusButton, flexibleSpace, doneButton], animated: false)

        // 為 WKWebView 的鍵盤設置 inputAccessoryView
        for subview in webView.scrollView.subviews {
            if let textField = subview as? UITextField {
                textField.inputAccessoryView = toolbar
            }
        }
    }

    // 按下 minus 按鈕時的行為
    @objc func insertMinus() {
        if let firstResponder = UIResponder.currentFirstResponder as? UITextField {
            firstResponder.insertText("-")
        }
    }

    // 按下完成按鈕時的行為
    @objc func donePressed() {
        self.viewController.view.endEditing(true)
    }
}

// 擴展 UIResponder 來找到當前的 first responder
extension UIResponder {
    private weak static var _currentFirstResponder: UIResponder? = nil

    public static var currentFirstResponder: UIResponder? {
        _currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(findFirstResponder(_:)), to: nil, from: nil, for: nil)
        return _currentFirstResponder
    }

    @objc private func findFirstResponder(_ sender: AnyObject) {
        UIResponder._currentFirstResponder = self
    }
}
