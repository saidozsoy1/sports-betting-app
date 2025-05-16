//
//  EventCell.swift
//  Sports Betting App
//
//  Created by Said Ozsoy on 15.05.2025.
//

import UIKit

class EventCell: UITableViewCell {
    static let identifier = "EventCell"
    static func nib() -> UINib {
        return UINib(nibName: "EventCell", bundle: nil)
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var sportTitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var teamsStackView: UIStackView!
    @IBOutlet weak var homeTeamLabel: UILabel!
    @IBOutlet weak var vsLabel: UILabel!
    @IBOutlet weak var awayTeamLabel: UILabel!
    @IBOutlet weak var bestOddsStackView: UIStackView!
    @IBOutlet weak var homeOddsButton: UIButton!
    @IBOutlet weak var drawOddsButton: UIButton!
    @IBOutlet weak var awayOddsButton: UIButton!
    
    var event: Event?
    weak var delegate: EventCellDelegate?
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        
        // Add button targets
        homeOddsButton.addTarget(self, action: #selector(oddsButtonTapped(_:)), for: .touchUpInside)
        drawOddsButton.addTarget(self, action: #selector(oddsButtonTapped(_:)), for: .touchUpInside)
        awayOddsButton.addTarget(self, action: #selector(oddsButtonTapped(_:)), for: .touchUpInside)
        
        // Set button corner radius properties
        homeOddsButton.layer.cornerRadius = 8
        drawOddsButton.layer.cornerRadius = 8
        awayOddsButton.layer.cornerRadius = 8
        
        // Set initial button background colors with transparency
        homeOddsButton.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        drawOddsButton.backgroundColor = .systemGray.withAlphaComponent(0.1)
        awayOddsButton.backgroundColor = .systemRed.withAlphaComponent(0.1)
    }
    
    func configure(with event: Event) {
        self.event = event
        
        sportTitleLabel.text = event.sportTitle
        dateLabel.text = event.formattedDate
        homeTeamLabel.text = event.homeTeam
        awayTeamLabel.text = event.awayTeam
        
        // Find the best odds for each team
        if let bestBookmaker = event.bookmakers.first {
            if let h2hMarket = bestBookmaker.markets.first(where: { $0.key == "h2h" }) {
                let outcomes = h2hMarket.outcomes
                
                let isSoccerMatch = event.sportKey.contains("soccer")
                
                if isSoccerMatch {
                    // For soccer matches with home, away, and draw outcomes
                    let homeOutcome = outcomes.first(where: { $0.name == event.homeTeam })
                    let awayOutcome = outcomes.first(where: { $0.name == event.awayTeam })
                    let drawOutcome = outcomes.first(where: { $0.name == "Draw" })
                    
                    homeOddsButton.setTitle(homeOutcome != nil ? String(format: "%.2f", homeOutcome!.price) : "N/A", for: .normal)
                    awayOddsButton.setTitle(awayOutcome != nil ? String(format: "%.2f", awayOutcome!.price) : "N/A", for: .normal)
                    drawOddsButton.setTitle(drawOutcome != nil ? String(format: "%.2f", drawOutcome!.price) : "N/A", for: .normal)
                    drawOddsButton.isHidden = false
                } else {
                    // For non-soccer matches with just home and away outcomes
                    if outcomes.count >= 2 {
                        homeOddsButton.setTitle(String(format: "%.2f", outcomes[0].price), for: .normal)
                        awayOddsButton.setTitle(String(format: "%.2f", outcomes[1].price), for: .normal)
                    }
                    drawOddsButton.isHidden = true
                }
            }
        }
    }
    
    @objc private func oddsButtonTapped(_ sender: UIButton) {
        guard let event = event else { return }
        
        if sender == homeOddsButton {
            if let title = homeOddsButton.title(for: .normal), let odds = Double(title) {
                delegate?.didSelectOdd(for: event, oddType: .home, selectedOdd: odds)
            }
        } else if sender == awayOddsButton {
            if let title = awayOddsButton.title(for: .normal), let odds = Double(title) {
                delegate?.didSelectOdd(for: event, oddType: .away, selectedOdd: odds)
            }
        } else if sender == drawOddsButton {
            if let title = drawOddsButton.title(for: .normal), let odds = Double(title) {
                delegate?.didSelectOdd(for: event, oddType: .draw, selectedOdd: odds)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        homeOddsButton.setTitle("", for: .normal)
        awayOddsButton.setTitle("", for: .normal)
        drawOddsButton.setTitle("", for: .normal)
        drawOddsButton.isHidden = true
    }
}
