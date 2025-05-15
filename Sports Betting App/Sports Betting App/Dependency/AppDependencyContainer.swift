//
//  AppDependencyContainer.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 15.05.2025.
//

import UIKit

final class AppDependencyContainer {
    lazy var dataManager: DataManaging = DataManager()

    init() {
        
    }
    
    // View Models
    func makeMainViewModel() -> MainViewModel {
        return MainViewModel(dataManager: dataManager)
    }

    // Coordinators
    func makeMainCoordinator(navigationController: UINavigationController) -> MainCoordinator {
        return MainCoordinator(
            navigationController: navigationController,
            dataManager: dataManager
        )
    }
}

