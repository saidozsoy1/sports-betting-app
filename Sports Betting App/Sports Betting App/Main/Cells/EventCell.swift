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
        
        // Hide draw button by default
        drawOddsButton.isHidden = true
        
        // Clear buttons titles
        homeOddsButton.setTitle("", for: .normal)
        drawOddsButton.setTitle("", for: .normal)
        awayOddsButton.setTitle("", for: .normal)
    }
    
    func configure(with event: Event) {
        self.event = event
        
        sportTitleLabel.text = event.sportTitle
        dateLabel.text = event.formattedDate
        homeTeamLabel.text = event.homeTeam
        awayTeamLabel.text = event.awayTeam
        
        // Reset buttons to default state and hide them
        homeOddsButton.setTitle("", for: .normal)
        drawOddsButton.setTitle("", for: .normal)
        awayOddsButton.setTitle("", for: .normal)
        
        // Hide all odds buttons initially
        homeOddsButton.isHidden = true
        drawOddsButton.isHidden = true
        awayOddsButton.isHidden = true
        
        // Find a bookmaker with odds
        var foundBookmaker = false
        
        for bookmaker in event.bookmakers {
            if let h2hMarket = bookmaker.markets.first(where: { $0.key == "h2h" }) {
                let outcomes = h2hMarket.outcomes
                
                // Find outcomes for home, away, and draw
                let homeOutcome = outcomes.first(where: { $0.name == event.homeTeam })
                let awayOutcome = outcomes.first(where: { $0.name == event.awayTeam })
                let drawOutcome = outcomes.first(where: { $0.name == "Draw" })
                
                // Check if we have at least home and away odds
                if homeOutcome != nil && awayOutcome != nil {
                    // Set home and away odds
                    homeOddsButton.setTitle(String(format: "%.2f", homeOutcome!.price), for: .normal)
                    homeOddsButton.isHidden = false
                    
                    awayOddsButton.setTitle(String(format: "%.2f", awayOutcome!.price), for: .normal)
                    awayOddsButton.isHidden = false
                    
                    // Set draw odds if available
                    if let drawOutcome = drawOutcome {
                        drawOddsButton.setTitle(String(format: "%.2f", drawOutcome.price), for: .normal)
                        drawOddsButton.isHidden = false
                    }
                    
                    foundBookmaker = true
                    break
                }
            }
        }
        
        // If no bookmaker with both home and away odds, try to find any with partial odds
        if !foundBookmaker && !event.bookmakers.isEmpty {
            for bookmaker in event.bookmakers {
                if let h2hMarket = bookmaker.markets.first(where: { $0.key == "h2h" }) {
                    let outcomes = h2hMarket.outcomes
                    var hasAnyOdds = false
                    
                    // Try to find any available odds
                    if let homeOutcome = outcomes.first(where: { $0.name == event.homeTeam }) {
                        homeOddsButton.setTitle(String(format: "%.2f", homeOutcome.price), for: .normal)
                        homeOddsButton.isHidden = false
                        hasAnyOdds = true
                    }
                    
                    if let awayOutcome = outcomes.first(where: { $0.name == event.awayTeam }) {
                        awayOddsButton.setTitle(String(format: "%.2f", awayOutcome.price), for: .normal)
                        awayOddsButton.isHidden = false
                        hasAnyOdds = true
                    }
                    
                    if let drawOutcome = outcomes.first(where: { $0.name == "Draw" }) {
                        drawOddsButton.setTitle(String(format: "%.2f", drawOutcome.price), for: .normal)
                        drawOddsButton.isHidden = false
                        hasAnyOdds = true
                    }
                    
                    // If we found at least one odd, use this bookmaker
                    if hasAnyOdds {
                        break
                    }
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
        // Reset all labels and buttons
        sportTitleLabel.text = nil
        dateLabel.text = nil
        homeTeamLabel.text = nil
        awayTeamLabel.text = nil
        
        // Reset odds buttons
        homeOddsButton.setTitle("", for: .normal)
        drawOddsButton.setTitle("", for: .normal)
        awayOddsButton.setTitle("", for: .normal)
        
        // Hide draw button by default until configured
        drawOddsButton.isHidden = true
        
        // Clear event data
        event = nil
    }
}

