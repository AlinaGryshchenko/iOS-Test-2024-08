//
//  AppReviewService.swift
//  iOS-Test
//
//  Created by Alina Hryshchenko on 17/10/2025.
//

import StoreKit
import os.log

protocol AppReviewRequesting {
  func requestReviewIfNeeded() async
}

final class AppReviewService: AppReviewRequesting {
  private enum Keys {
    static let lastReviewRequestDate = "lastReviewRequestDate"
  }
  
  private let sessionService: UserSessionTracking
  private let storage: UserDefaults
  private let minCompletedSessions = 2
  private let minUsageTime: TimeInterval = 600
  private let reviewCooldown: TimeInterval = 259200
  
  init(sessionService: UserSessionTracking, storage: UserDefaults = .standard) {
    self.sessionService = sessionService
    self.storage = storage
  }
  
  // MARK: - Review Request
  
  /// Requests app review if all conditions are met: 2 completed sessions, 10 minutes usage, 3 days cooldown.
  func requestReviewIfNeeded() async {
    let conditions = checkConditions()
    
    #if DEBUG
    os_log("Review Check: sessions=%d, time=%.0f, cooldown=%@, result=%@",
           conditions.sessions, conditions.time, 
           conditions.cooldown ? "OK" : "FAIL",
           conditions.canRequest ? "REQUESTING" : "BLOCKED")
    #endif
    
    guard conditions.canRequest else { return }
    
    await MainActor.run {
      guard let windowScene = UIApplication.shared.connectedScenes
        .compactMap({ $0 as? UIWindowScene })
        .first(where: { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }) else {
        #if DEBUG
        os_log("No windowScene found")
        #endif
        return
      }
      
      #if DEBUG
      os_log("WindowScene found (state: %d), requesting review...", windowScene.activationState.rawValue)
      #endif
      
      SKStoreReviewController.requestReview(in: windowScene)
      storage.set(Date(), forKey: Keys.lastReviewRequestDate)
      
      #if DEBUG
      os_log("Review popup requested from StoreKit")
      #endif
    }
  }
  
  /// Checks if all review request conditions are satisfied.
  private func checkConditions() -> (sessions: Int, time: TimeInterval, cooldown: Bool, canRequest: Bool) {
    let sessions = sessionService.completedSessionsCount
    let time = sessionService.totalUsageTime
    
    let sessionsPassed = sessions >= minCompletedSessions
    let timePassed = time >= minUsageTime
    
    var cooldownPassed = true
    if let lastRequest = storage.object(forKey: Keys.lastReviewRequestDate) as? Date {
      cooldownPassed = Date().timeIntervalSince(lastRequest) >= reviewCooldown
    }
    
    let canRequest = sessionsPassed && timePassed && cooldownPassed
    return (sessions, time, cooldownPassed, canRequest)
  }
}
