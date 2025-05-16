import UIKit

final class DependencyContainer {
    private let dataManager: DataManaging
    
    init() {
        self.dataManager = DataManager()
    }
    
    func makeMainViewController() -> MainViewController {
        let viewController = MainViewController()
        let viewModel = makeMainViewModel()
        viewModel.delegate = viewController
        viewController.viewModel = viewModel
        return viewController
    }
    
    private func makeMainViewModel() -> MainViewModelProtocol {
        return MainViewModel(dataManager: dataManager)
    }
} 