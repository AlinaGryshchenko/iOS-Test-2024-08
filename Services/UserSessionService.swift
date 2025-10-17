//
//  UserSessionService.swift
//  iOS-Test
//
//  Created by Alina Hryshchenko on 17/10/2025.
//

import Foundation
import os.log

protocol UserSessionTracking {
  var completedSessionsCount: Int { get }
  var totalUsageTime: TimeInterval { get }
  func enterForeground()
  func enterBackground()
}

final class UserSessionService: UserSessionTracking {
  private enum Keys {
    static let lastBackgroundDate = "lastBackgroundDate"
    static let sessionStartDate = "sessionStartDate"
    static let totalUsageTime = "totalUsageTime"
    static let completedSessions = "completedSessions"
  }
  
  private let sessionTimeout: TimeInterval = 3600

  private let storage: UserDefaults
  private var currentSessionStart: Date?
  
  var completedSessionsCount: Int {
    storage.integer(forKey: Keys.completedSessions)
  }
  
  var totalUsageTime: TimeInterval {
    storage.double(forKey: Keys.totalUsageTime)
  }
  
  init(storage: UserDefaults = .standard) {
    self.storage = storage
    if let savedStart = storage.object(forKey: Keys.sessionStartDate) as? Date {
      currentSessionStart = savedStart
    }
  }
  
  // MARK: - Session Lifecycle
  
  /// Called when app enters foreground. Checks if previous session should be completed based on timeout.
  func enterForeground() {
    let now = Date()
    
    if let lastBackground = storage.object(forKey: Keys.lastBackgroundDate) as? Date {
      let bgTime = now.timeIntervalSince(lastBackground)
      #if DEBUG
      os_log("Background duration: %.0fs (timeout: %.0fs)", bgTime, sessionTimeout)
      #endif
      
      if bgTime > sessionTimeout {
        completeSession()
        #if DEBUG
        os_log("Session completed! Total: %d", completedSessionsCount)
        #endif
      }
    }
    
    if currentSessionStart == nil {
      currentSessionStart = now
      storage.set(now, forKey: Keys.sessionStartDate)
      #if DEBUG
      os_log("Session started. Completed: %d, Total time: %.0fs",
             completedSessionsCount, totalUsageTime)
      #endif
    }
  }
  
  /// Called when app enters background. Saves current session time and marks background timestamp.
  func enterBackground() {
    guard let start = currentSessionStart else { return }
    
    let usage = Date().timeIntervalSince(start)
    let total = totalUsageTime + usage
    storage.set(total, forKey: Keys.totalUsageTime)
    storage.set(Date(), forKey: Keys.lastBackgroundDate)
    
    #if DEBUG
    os_log("Background. Session time: %.0fs, Total: %.0fs", usage, total)
    #endif
    
    currentSessionStart = nil
    storage.removeObject(forKey: Keys.sessionStartDate)
  }
  
  private func completeSession() {
    let count = completedSessionsCount + 1
    storage.set(count, forKey: Keys.completedSessions)
  }
}
