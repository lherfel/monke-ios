//
//  AppDelegate.swift
//  MinterKeyboard
//
//  Created by Alexey Sidorov on 15/06/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import UIKit
import MinterCore
import Fabric
import Crashlytics
import BackgroundTasks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

		Fabric.with([Crashlytics.self])

		MinterSDKConfigurator.configure(isTestnet: false)

		UINavigationBar.appearance().backgroundColor = .clear
		UINavigationBar.appearance().shadowImage = UIImage()
		UINavigationBar.appearance().isTranslucent = true
		UINavigationBar.appearance().setBackgroundImage(UIImage(), for: UIBarMetrics.default)

//		registerBackgroundTaks()
//		registerLocalNotification()
		
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		if #available(iOS 13.0, *) {
//			cancelAllPandingBGTask()
//			scheduleAppRefresh()
//			scheduleAutodelegator()
		} else {
			// Fallback on earlier versions
		}
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
	
	//MARK: Regiater BackGround Tasks
	private func registerBackgroundTaks() {
			if #available(iOS 13.0, *) {
			BGTaskScheduler.shared.register(forTaskWithIdentifier: "io.monke.autodelegator", using: nil) { task in
				//This task is cast with processing request (BGProcessingTask)
				self.scheduleLocalNotification()
				self.handleImageFetcherTask(task: task as! BGProcessingTask)
			}
			
			BGTaskScheduler.shared.register(forTaskWithIdentifier: "io.monke.apprefresh", using: nil) { task in
				//This task is cast with processing request (BGAppRefreshTask)
				self.scheduleLocalNotification()
				self.handleAppRefreshTask(task: task as! BGAppRefreshTask)
			}
		}
	}
}

// MARK: - BGTask Helper

extension AppDelegate {

	@available(iOS 13.0, *)
	func cancelAllPandingBGTask() {
		BGTaskScheduler.shared.cancelAllTaskRequests()
	}

	@available(iOS 13.0, *)
	func scheduleAutodelegator() {
		let request = BGProcessingTaskRequest(identifier: "io.monke.autodelegator")
		request.requiresNetworkConnectivity = true // Need to true if your task need to network process. Defaults to false.
		request.requiresExternalPower = false
		
		request.earliestBeginDate = Date(timeIntervalSinceNow: 60) // Featch Image Count after 1 minute.
		//Note :: EarliestBeginDate should not be set to too far into the future.
		do {
				try BGTaskScheduler.shared.submit(request)
		} catch {
				print("Could not schedule image featch: \(error)")
		}
	}

	@available(iOS 13.0, *)
	func scheduleAppRefresh() {
		let request = BGAppRefreshTaskRequest(identifier: "io.monke.apprefresh")
		request.earliestBeginDate = Date(timeIntervalSinceNow: 2 * 60) // App Refresh after 2 minute.
		//Note :: EarliestBeginDate should not be set to too far into the future.
		do {
				try BGTaskScheduler.shared.submit(request)
		} catch {
				print("Could not schedule app refresh: \(error)")
		}
	}

	@available(iOS 13.0, *)
	func handleAppRefreshTask(task: BGAppRefreshTask) {
		scheduleAppRefresh()

		task.expirationHandler = {}
		scheduleLocalNotification()
		task.setTaskCompleted(success: true)
	}

	@available(iOS 13.0, *)
	func handleImageFetcherTask(task: BGProcessingTask) {
		scheduleAutodelegator()
		task.expirationHandler = {}
		task.setTaskCompleted(success: true)
	}
}

// MARK: - Notification Helper

extension AppDelegate {

	func registerLocalNotification() {
		let notificationCenter = UNUserNotificationCenter.current()
		let options: UNAuthorizationOptions = [.alert, .sound, .badge]

		notificationCenter.requestAuthorization(options: options) {
				(didAllow, error) in
			if !didAllow {
					print("User has declined notifications")
			}
		}
	}

	func scheduleLocalNotification() {
		let notificationCenter = UNUserNotificationCenter.current()
		notificationCenter.getNotificationSettings { (settings) in
			if settings.authorizationStatus == .authorized {
				self.fireNotification()
			}
		}
	}

	func fireNotification() {
		// Create Notification Content
		let notificationContent = UNMutableNotificationContent()

		// Configure Notification Content
		notificationContent.title = "Bg"
		notificationContent.body = "BG Notifications. " + Date().description

		// Add Trigger
		let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)

		// Create Notification Request
		let notificationRequest = UNNotificationRequest(identifier: "local_notification" + Date().description, content: notificationContent, trigger: notificationTrigger)

		// Add Request to User Notification Center
		UNUserNotificationCenter.current().add(notificationRequest) { (error) in
			if let error = error {
					print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
			}
		}
	}
}
