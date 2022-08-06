import UIKit
import FirebaseAuth
import Firebase
import GoogleSignIn
import FirebaseCore
class LoginPage2: UIViewController, UITextFieldDelegate, GIDSignInDelegate  {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else{
            print(error ?? "error")
            return
        }
        account.text = user.profile.email!
        
        
        
    }
    // 這個是拿來儲存一個flag，告訴APP我已經成功登入過了。
    fileprivate func setUserDefaultForLogin() {
        UserDefaults.standard.set(true, forKey: "IsLoginWithGoogle")
        UserDefaults.standard.synchronize()
    }
    

    var mAuth:Auth!
    @IBOutlet weak var account: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var resultLbl: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var countingLbl: UILabel!
    @IBOutlet weak var loginStatus:UILabel!
    @IBAction func createAccount(_ sender: Any) {
        let account = account.text ?? ""
        let password = password.text ?? ""
        
        if account == "" {toast(message: "請輸入帳號");return}
        if password == "" {toast(message: "請輸入密碼");return}
        
        Auth.auth().createUser(withEmail: "xiemengy7@gemail.yuntech.edu.tw", password: password, completion: { (result, error) -> Void in
               if (error == nil) {

                       print("Account created :)")
                      self.dismiss(animated: true, completion: nil)
               }

               else{
                       print(error)
               }
           })
    }
    
    
    
    var checkMsg:[String] = []
    @IBOutlet weak var mainLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        mAuth = Auth.auth()
        
        GIDSignIn.sharedInstance().delegate = self
        Auth.auth().createUser(withEmail: "peter@neverland.com", password: "123456") { result, error in
                    
             guard let user = result?.user,
                   error == nil else {
                 print(error?.localizedDescription)
                 return
             }
             print(user.email, user.uid)
        }
        Auth.auth().signIn(withEmail: "peter@neverlad.com", password: "123456") { result, error in
             guard error == nil else {
                print(error?.localizedDescription)
                return
             }
            
        }
        
        
        if let user = Auth.auth().currentUser {
            print("\(user.uid) login")
            print("success")
            self.toast(message: "登入成功")
            if let url = URL(string: "https://www.sencha.com/grid/demo/modern/#/rendering-and-scrolling/live-data-grid") {
                    if UIApplication.shared.canOpenURL(url) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(url)
                        }
                    }
                }
        } else {
            print("not login")
        }
                
    }
 
    @objc func countPassword(_ sender: UITextField) {
        if let passwordCounting = password.text?.count{
        if passwordCounting != 0{
            countingLbl.text = String(passwordCounting)
            }
            else {
                countingLbl.text = ""
            }
        }
        guard password.isEditing == true else{
            countingLbl.isHidden = true
            password.isSecureTextEntry = true
            return
        }
        countingLbl.isHidden = false
        password.isSecureTextEntry = false
    }
    
    
    @objc func check() {
        let usernameTxt = account.text ?? ""
        let password = password.text ?? ""
        
        guard usernameTxt != "" else{
            resultLbl.text = inputStatus.usernameisEmpty.alert
            return
        }
        guard password != "" else{
            resultLbl.text = inputStatus.passwordisEmpty.alert
            return
        }

        checkMsg = []
        for i in warning.allCases{
        checkMsg.append(i.rawValue)
        }

        //檢查字數
        if password.count >= 16{
            removeWarning(warning.count.rawValue)
        }
        
        //檢查數字
        for digit in passwordPolicy.digits{
            if password.contains(digit) == true{
                removeWarning(warning.digit.rawValue)
                break
            }
        }

        //檢查標點符號
        for i in passwordPolicy.punctuation{
            if password.contains(i) == true{
                removeWarning(warning.punctuation.rawValue)
                break
            }
        }
        
        //檢查使用者名稱
        if password.contains(usernameTxt) == false{
            removeWarning(warning.username.rawValue)
        }
        
        //檢查大寫
        for character in password{
            if character.isUppercase == true{
                removeWarning(warning.uppercase.rawValue)
            }
        }
        
        //檢查小寫
        for character in password{
            if character.isLowercase == true{
                removeWarning(warning.lowercase.rawValue)
            }
        }
                  
        let checkResult = checkMsg.map {$0}.joined(separator: "\n")
        resultLbl.text = checkResult

        guard usernameTxt != "", checkMsg == [] else{
            sendBtn.isEnabled = false
            return
        }
        sendBtn.isEnabled = true
        if(account.isEqual("sme322")){
            if(password.isEqual("~@Xiemengy7~@@@@")){
                print("帳密正確")
            }
            
            
        }
        }
    
    func removeWarning(_ warningString: String){
        checkMsg.removeAll { (removeMessage) -> Bool in
            let removeMessage = removeMessage == warningString
            return removeMessage
    }
}
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.contains(" ") == true{
            return false
        }else{
            return true
        }
    }
    
    @IBAction func closeKeyboard(_ sender: Any) {
    }
    @IBAction func forgetPassword(_ sender:Any){
        let accountString = account.text ?? ""
        if accountString != "" {
            mAuth.sendPasswordReset(withEmail: accountString){ (error) in
                if accountString != "" {
                    self.toast(message: "重設密碼郵件已送出，請檢查您的電子郵件")
                }else{
                    self.toast(message: "無法重設，說明：\(error!.localizedDescription)")
                }
            }
                               }else{
                                   self.toast(message: "請輸入帳號")
                    }
    }
    @IBAction func logingIn(_sender:Any){
        let accountString = account.text ?? ""
        let passwordString = password.text ?? ""
        if accountString != "" && passwordString != "" {
            mAuth.signIn(withEmail:accountString,password:passwordString){ (user,error) in
                if error != nil{
                    self.toast(message: "錯誤 \(error!.localizedDescription)")
                    
                }else{
                    self.toast(message:"請輸入帳號密碼")
                }
                }
        
        }
        
        
    }
    
    @IBSegueAction func nextPage(_ coder: NSCoder) -> ViewController? {
        let infoConfirmViewController = ViewController(coder: coder)
        let username = account.text ?? ""
        let password = password.text ?? ""
        return infoConfirmViewController
    }
    
    @IBAction func unwindSegueBack(segue: UIStoryboardSegue){
    }
}
class passwordPolicy{
    
    static let digits = "0123456789"
    static let punctuation = "!@#$%^&*(),.<>;'`~[]{}\\|/?_-+="

}


enum warning:String, CaseIterable{
    
    case count = "密碼至少須包含16個字元"
    case digit = "密碼至少須包含一個數字"
    case punctuation = "密碼至少須包含一個標點符號"
    case lowercase = "密碼至少須包含一個小寫字母"
    case uppercase = "密碼至少須包含一個大寫字母"
    case username = "密碼不可包含使用者名稱"

}

enum inputStatus{
    case usernameisEmpty
    case passwordisEmpty
 
    var alert: String{
        switch self {
        case .usernameisEmpty:
            return "請輸入使用者名稱"
        case .passwordisEmpty:
            return "請輸入密碼"
            
        }
    }
}
extension UIColor{
    
    class func hexToRGB(hex:String) -> UIColor{
        let nInt = Int(hex, radix: 16)
        let rColor = (nInt! >> 16) & 0xFF
        let gColor = (nInt! >> 8) & 0xFF
        let bColor = nInt! & 0xFF
        
        return UIColor(red: CGFloat(rColor) / 255, green: CGFloat(gColor) / 255, blue: CGFloat(bColor) / 255, alpha: 1)
        
    }

}
extension UIViewController{
    func toast(message:String){
        let alert = UIAlertController.init(title:message,message:nil,preferredStyle: .actionSheet)
        present(alert,animated:true){
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                alert.dismiss(animated: true, completion: nil)
            })
        }
    }
}
class infoConfirmVC: UIViewController {
    
   
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var passwordLbl: UILabel!
    
    var confirmUsername = ""
    var confirmPassword = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        usernameLbl.text = confirmUsername
        passwordLbl.text = confirmPassword
        

    }
    


}
