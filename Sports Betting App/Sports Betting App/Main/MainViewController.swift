//
//  MainViewController.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 18.04.2025.
//

import UIKit
import CoreLocation
import MapKit

final class MainViewController: UIViewController {
    var viewModel: MainViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

extension MainViewController: MainViewModelDelegate {
    
}

