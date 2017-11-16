//
//  AppSettings.swift
//  UtilityMaster
//
//  Created by Do Hoang Viet on 11/15/17.
//  Copyright © 2017 DoHoangViet. All rights reserved.
//

import UIKit

//Pilot Utilities
let kAppSettingsPilotUtilityDefaultSegmentIndex = "last_selected_utility_segment_index"
let kAppSettingsPilotUtilitySelectedFavCities = "selected_favorite_cities"
let kAppSettingsTimerFireDate = "timer_fire_date"
let kAppSettingsTimerTimeLeftSincePaused = "timer_time_left_since_paused"
let kAppSettingsTimerLastKnownInterval = "timer_last_known_interval"
let kAppSettingsStopWatchStartTime = "stop_watch_start_time"
let kAppSettingsStopWatchTimeInterval = "stop_watch_time_interval"
let kAppSettingsStopWatchRecords = "stop_watch_records"

class AppSettings: NSObject {
    static let defaultSettings = [:] as [String: Any]
    
    class func registerDefaults() {
        let userDefaults = UserDefaults.standard
        userDefaults.register(defaults: defaultSettings)
    }
    
    class func resetToDefault(){
        let userDefaults = UserDefaults.standard
        userDefaults.setValuesForKeys(defaultSettings)
    }
    
    /**
     Retrieves the setting object associated with the key in the app settings.
     - Parameter param: key The key to the setting object.
     - Returns: The setting object if present, or nil otherwise.
     */
    class func settingForKey(_ key: String) -> Any? {
        let userDefaults = UserDefaults.standard
        return userDefaults.object(forKey: key) as Any?
    }
    
    /**
     Sets the setting of the specified key in the app settings. If nil is passed, the setting for the key, if present, will be removed.
     - Parameter setting: Object to store.
     - Parameter key: The key to the setting object.
     */
    class func setSetting(_ setting: Any?, forKey key: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(setting, forKey: key)
    }
}
