iimport UIKit
import Firebase
import GoogleSignIn
@main
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
                 withError error: Error!) {
           if let error = error {
               print("\(error.localizedDescription)")
               // [START_EXCLUDE silent]
               NotificationCenter.default.post(
                   name: Notification.Name(rawValue: "ToggleAuthUINotification"), object: nil, userInfo: nil)
               // [END_EXCLUDE]
           } else {
               // Perform any operations on signed in user here.
               let userId = user.userID                  // For client-side use only!
               let idToken = user.authentication.idToken // Safe to send to the server
               let fullName = user.profile.name
               let givenName = user.profile.givenName
               let familyName = user.profile.familyName
               let email = user.profile.email
               // [START_EXCLUDE]
               NotificationCenter.default.post(
                   name: Notification.Name(rawValue: "ToggleAuthUINotification"),
                   object: nil,
                   userInfo: ["statusText": "Signed in user:\n\(fullName)"])
               // [END_EXCLUDE]
           }
       }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
                  withError error: Error!) {
            // Perform any operations when the user disconnects from app here.
            // [START_EXCLUDE]
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: "ToggleAuthUINotification"),
                object: nil,
                userInfo: ["statusText": "User has disconnected."])
            // [END_EXCLUDE]
        }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        GIDSignIn.sharedInstance()?.clientID = "581332005548-jjl5oo817a0clbaa619004059efti2ur.apps.googleusercontent.com"
               
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
           return GIDSignIn.sharedInstance().handle(url,
                                                    sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                    annotation: options[UIApplication.OpenURLOptionsKey.annotation])
       }
}
