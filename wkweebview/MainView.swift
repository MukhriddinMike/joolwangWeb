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
    
    @State private var selection = 0
  @State private var a = UUID()
    @State private var b = UUID()
    @State private var c = UUID()
    var body: some View {
        
        let selectable = Binding(
            get: { self.selection },
            set: { self.selection = $0
                self.a = UUID()
                self.b = UUID()
                self.c = UUID()
            })
        
        return TabView(selection: selectable) {
            ReloadableContentView(url:"https://joolwang.com", resetNavigationID: $a)
                .tabItem {
                    Label("홈", systemImage: "house")
                }.tag(0)
                
            ReloadableContentView(url:"https://joolwang.com/request", resetNavigationID: $b)
                .tabItem {
                    Label("마켓", systemImage: "person.badge.plus")
                        
                }.tag(1)
            ReloadableContentView(url:"https://joolwang.com/user/profile", resetNavigationID: $c)
                .tabItem {
                    Label("찜", systemImage: "person")
                }.tag(2)
        }
        //.font(.system(size: 32, weight: .semibold, design: .monospaced))
        .accentColor(Color(red: 0, green: 0.4, blue: 0))
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
