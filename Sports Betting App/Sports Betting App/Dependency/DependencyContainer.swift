import UIKit

final class DependencyContainer {
    private let apiService: ApiServiceProtocol
    private let serviceManager: ServiceManager
    private let dataManager: DataManaging
    
    init() {
        self.apiService = ApiManager()
        self.serviceManager = ServiceManager(apiService: apiService)
        self.dataManager = DataManager(serviceManager: serviceManager)
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
