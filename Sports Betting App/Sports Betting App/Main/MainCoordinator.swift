//
//  MainCoordinator.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 15.05.2025.
//

import UIKit

final class MainCoordinator {
    private let navigationController: UINavigationController
    private let dataManager: DataManaging

    init(navigationController: UINavigationController, dataManager: DataManaging) {
        self.navigationController = navigationController
        self.dataManager = dataManager
    }

    func start() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateInitialViewController() as? MainViewController else {
            fatalError("Could not instantiate MainViewController from storyboard")
        }
        
        let viewModel: MainViewModelProtocol = MainViewModel(dataManager: dataManager)
        viewController.viewModel = viewModel
        navigationController.setViewControllers([viewController], animated: true)
    }
}
