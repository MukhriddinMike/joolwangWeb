//
//  MainView.swift
//  wkweebview
//
//  Created by  Corp. Dmonster on 2021/11/03.
//
import UIKit
import SwiftUI
import Firebase
import FirebaseMessaging


struct MainView: View {
  
    var body: some View {

        TabView {
            ContentView(url:"https://joolwang.com/test?Access_token=${msg}")
                .tabItem {
                    Label("홈", systemImage: "house")
                }
            ContentView(url:"https://joolwang.com/request")
                .tabItem {
                    Label("마켓", systemImage: "person.badge.plus")
                }
            ContentView(url:"https://joolwang.com/profile/user")
                .tabItem {
                    Label("찜", systemImage: "person")
                }
            
        

          
            
        }
        
        
        .font(.system(size: 25, weight: .semibold, design: .monospaced))
        .accentColor(.black)
    }
    
    
    
    
    struct MainView_Previews: PreviewProvider {
        static var previews: some View {
            MainView()
            
            
        }
        
    }
    
  
    
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    
    let gcmMessageIDKey = "gcm.message_id"
 
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions
      launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
      
      
      FirebaseApp.configure()
      
      Messaging.messaging().delegate = self

      
      if #available(iOS 10.0, *) {
        // For iOS 10 display notification (sent via APNS)
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )
      } else {
        let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
      }

      application.registerForRemoteNotifications()


    return true
  }
    
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult)
                       -> Void) {

      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }

      // Print full message.
      print(userInfo)

      completionHandler(UIBackgroundFetchResult.newData)
    }


}

extension AppDelegate: MessagingDelegate{
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
  

      let dataDict: [String: String] = ["token": fcmToken ?? ""]
       
        print(dataDict)
    }


    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    
    


func userNotificationCenter(_ center: UNUserNotificationCenter,
                            willPresent notification: UNNotification,
  withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
  let userInfo = notification.request.content.userInfo

  Messaging.messaging().appDidReceiveMessage(userInfo)

  // Change this to your preferred presentation option
    completionHandler([[.banner, .badge, .sound]])
}

func userNotificationCenter(_ center: UNUserNotificationCenter,
                            didReceive response: UNNotificationResponse,
                            withCompletionHandler completionHandler: @escaping () -> Void) {
  let userInfo = response.notification.request.content.userInfo

  Messaging.messaging().appDidReceiveMessage(userInfo)

  completionHandler()
}

    func application(_ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error) {
      
    }
     
    func application(_ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      Messaging.messaging().apnsToken = deviceToken;
    }
     

}
