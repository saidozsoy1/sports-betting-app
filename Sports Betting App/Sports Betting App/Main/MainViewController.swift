//
//  MainViewController.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 18.04.2025.
//

import UIKit
import CoreLocation
import MapKit

class MainViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var basketInfoView: UIView!
    @IBOutlet weak var basketCountLabel: UILabel!
    @IBOutlet weak var basketTotalLabel: UILabel!
    
    var viewModel: MainViewModelProtocol!
    
    // MARK: - Initializers
    convenience init(viewModel: MainViewModelProtocol) {
        self.init()
        self.viewModel = viewModel
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupBindings()
        
        viewModel.fetchEvents()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        registerCells()
        
        tableView.allowsMultipleSelection = false
        tableView.backgroundColor = .systemGroupedBackground
    }
    
    private func registerCells() {
        // Register EventCell from XIB
        let eventNib = UINib(nibName: "EventCell", bundle: nil)
        tableView.register(eventNib, forCellReuseIdentifier: "EventCell")
        
        // Register BetItemCell from XIB
        let betItemNib = UINib(nibName: "BetItemCell", bundle: nil)
        tableView.register(betItemNib, forCellReuseIdentifier: "BetItemCell")
    }
    
    private func setupBindings() {
        viewModel.delegate = self
    }
    
    // MARK: - Update UI
    func updateBasketInfo() {
        let basketCount = BetBasket.shared.items.count
        basketCountLabel.text = "\(basketCount) Event\(basketCount == 1 ? "" : "s")"
        
        basketTotalLabel.text = "Total Odds: \(BetBasket.shared.formattedTotalPrice)"
        
        basketInfoView.isHidden = basketCount == 0
    }
    
    // MARK: - Actions
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        tableView.reloadData()
        searchBar.resignFirstResponder()
        updateBasketInfo()
        searchBar.isHidden = segmentedControl.selectedSegmentIndex != 0
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return segmentedControl.selectedSegmentIndex == 0 ? viewModel.filteredEvents.count : BetBasket.shared.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if segmentedControl.selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
            let event = viewModel.filteredEvents[indexPath.row]
            cell.configure(with: event)
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BetItemCell", for: indexPath) as! BetItemCell
            let betItem = BetBasket.shared.items[indexPath.row]
            cell.configure(with: betItem)
            cell.delegate = self
            return cell
        }
    }
}

// MARK: - UISearchBarDelegate
extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filterEvents(by: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - MainViewModelDelegate
extension MainViewController: MainViewModelDelegate {
    func eventsUpdated() {
        tableView.reloadData()
    }
    
    func didFetchEvents() {
        tableView.reloadData()
    }
    
    func didFailToFetchEvents(with error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func didUpdateBetBasket() {
        updateBasketInfo()
        if segmentedControl.selectedSegmentIndex == 1 {
            tableView.reloadData()
        }
    }
}

// MARK: - EventCellDelegate
extension MainViewController: EventCellDelegate {
    func didSelectOdd(for event: Event, oddType: OddType, selectedOdd: Double) {
        let outcome = Outcome(name: oddType.rawValue, price: selectedOdd)
        BetBasket.shared.addBet(
            eventId: event.id,
            eventName: "\(event.homeTeam) vs \(event.awayTeam)",
            outcome: outcome,
            marketKey: "h2h",
            bookmakerTitle: "Default"
        )
        
        updateBasketInfo()
    }
}

// MARK: - BetItemCellDelegate
extension MainViewController: BetItemCellDelegate {
    func didTapDeleteButton(for betItem: BetItem) {
        BetBasket.shared.removeBet(eventId: betItem.eventId)
        
        tableView.reloadData()
        updateBasketInfo()
    }
}

