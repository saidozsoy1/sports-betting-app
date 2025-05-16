//
//  AppCoordinator.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 15.05.2025.
//

import UIKit

final class AppCoordinator {
    private let window: UIWindow
    private let navigationController: UINavigationController
    private let dependencyContainer: DependencyContainer

    private var splashCoordinator: SplashCoordinator?
    private var mainCoordinator: MainCoordinator?

    init(window: UIWindow, dependencyContainer: DependencyContainer) {
        self.window = window
        self.navigationController = UINavigationController()
        self.dependencyContainer = dependencyContainer
    }

    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        showSplash()
    }

    private func showSplash() {
        let coordinator = SplashCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer,
            onFinish: { [weak self] in
                self?.showMain()
            }
        )
        splashCoordinator = coordinator
        coordinator.start()
    }

    private func showMain() {
        let coordinator = MainCoordinator(
            navigationController: navigationController,
            dataManager: dependencyContainer.dataManager
        )
        mainCoordinator = coordinator
        coordinator.start()
    }
}
