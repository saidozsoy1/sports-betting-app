//
//  AppDependencyContainer.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 15.05.2025.
//

import UIKit

final class DependencyContainer {
    lazy var dataManager: DataManaging = DataManager()
    
    init() {
        self.dataManager = DataManager()
    }
    
    func makeMainViewController() -> MainViewController {
        let viewController = MainViewController()
        let viewModel = makeMainViewModel()
        viewController.viewModel = viewModel
        return viewController
    }
    
    private func makeMainViewModel() -> MainViewModelProtocol {
        return MainViewModel(dataManager: dataManager)
    }
}
