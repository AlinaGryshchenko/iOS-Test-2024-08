//
//  DummyViewController.swift
//  iOS-Test
//

import UIKit
import os.log

protocol DummyDisplayLogic: AnyObject {
  func display(model: DummyModels.Load.ViewModel)
}

class DummyViewController: UIViewController {
  var interactor: DummyBusinessLogic?
  var router: DummyRoutingLogic?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    interactor?.load(request: .init())
    setupUI()
  }
 
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  func setupUI() {
    self.navigationItem.title = "Hello world!"
  }
}

extension DummyViewController: DummyDisplayLogic {
  func display(model: DummyModels.Load.ViewModel) {
    
  }
}
