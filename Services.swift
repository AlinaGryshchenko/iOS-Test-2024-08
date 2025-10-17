//
//  Services.swift
//

struct Services {
  static let userSession = UserSessionService()
  static let appReview = AppReviewService(sessionService: userSession)
}
