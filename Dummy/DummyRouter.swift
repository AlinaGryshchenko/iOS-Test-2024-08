//
//  DummyRouter.swift
//  iOS-Test
//

import UIKit

protocol DummyRoutingLogic {
    
}

class DummyRouter {
  weak var controller: DummyViewController?
}

extension DummyRouter: DummyRoutingLogic {
    
}

// MARK: - Module Factory

extension DummyRouter {
  
  /// Creates and configures Dummy module with all dependencies.
  static func createModule() -> DummyViewController {
    let controller = UIStoryboard(name: "Dummy", bundle: nil)
      .instantiateViewController(withIdentifier: "DummyViewController") as! DummyViewController
    let interactor = DummyInteractor()
    let presenter = DummyPresenter()
    let router = DummyRouter()
    
    controller.interactor = interactor
    controller.router = router
    interactor.presenter = presenter
    presenter.view = controller
    return controller
  }
}
