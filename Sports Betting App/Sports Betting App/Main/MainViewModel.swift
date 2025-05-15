//
//  MainViewModel.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 15.05.2025.
//

protocol MainViewModelDelegate: AnyObject {

}

protocol MainViewModelProtocol {
    var delegate: MainViewModelDelegate? { get set }
}

final class MainViewModel: MainViewModelProtocol {
    
    private var dataManager: DataManaging
    weak var delegate: MainViewModelDelegate?
    
    init(dataManager: DataManaging) {
        self.dataManager = dataManager
    }
}
