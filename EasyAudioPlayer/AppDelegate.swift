//
//  AppDelegate.swift
//  EasyAudioPlayer
//
//  Created by Zhou Yang on 6/17/23.
//
import AVFoundation
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        let session = AVAudioSession.sharedInstance()
        do{
            try session.setCategory(.playback, mode: .default)
        } catch{
            print(error.localizedDescription)
        }
        
        return true
    }
}

