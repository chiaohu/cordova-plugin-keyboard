import UIKit

@objc(CustomKeyboard) class CustomKeyboard: CDVPlugin {

    @objc(addDoneButtonOnKeyboard:)
    func addDoneButtonOnKeyboard(command: CDVInvokedUrlCommand) {

        let emailTxt = UITextField()
        let numTxt = UITextField()
        
        // 設定 email 輸入欄位
        emailTxt.keyboardType = .emailAddress
        emailTxt.clearButtonMode = .whileEditing

        // 設定數字輸入欄位
        numTxt.keyboardType = .numberPad

        // 加入自訂的工具列到鍵盤
        self.addToolbarToTextField(emailTxt)
        
        // 回傳成功訊息給 JavaScript
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "完成按鈕已新增")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    func addToolbarToTextField(_ textField: UITextField) {

        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(title: "確定", style: UIBarButtonItemStyle.done, target: self, action: #selector(doneButtonAction))
        let gogoBtn = UIBarButtonItem(image: UIImage(named: "tab-album"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(gogoButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(gogoBtn)
        items.append(flexSpace)
        items.append(doneBtn)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        // 將工具列加到鍵盤輸入欄位上
        textField.inputAccessoryView = doneToolbar
    }

    @objc func gogoButtonAction() {
        print("gogo.....")
        // 執行一些操作
    }

    @objc func doneButtonAction() {
        // 處理 "確定" 按鈕操作
        print("done.....")
    }
}
