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
        
        if let mainViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController {
            let viewModel: MainViewModelProtocol = MainViewModel(dataManager: dataManager)
            mainViewController.viewModel = viewModel
            navigationController.setViewControllers([mainViewController], animated: true)
        } else {
            fatalError("Could not instantiate MainViewController from storyboard")
        }
    }
}
