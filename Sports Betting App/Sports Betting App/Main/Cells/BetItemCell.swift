//
//  BetItemCell.swift
//  Sports Betting App
//
//  Created by Said Ozsoy on 15.05.2025.
//

import UIKit

class BetItemCell: UITableViewCell {
    static let identifier = "BetItemCell"
    static func nib() -> UINib {
        return UINib(nibName: "BetItemCell", bundle: nil)
    }

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var oddsLabel: UILabel!
    
    weak var delegate: BetItemCellDelegate?
    private var betItem: BetItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Make the cell's content view rounded
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true

        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        
        oddsLabel.layer.cornerRadius = 5
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
    func configure(with betItem: BetItem) {
        self.betItem = betItem
        titleLabel.text = betItem.eventName
        subtitleLabel.text = betItem.outcome.name
        oddsLabel.text = betItem.formattedPrice
    }
    
    @IBAction func DeleteButtonPressed(_ sender: Any) {
        if let betItem = betItem {
            delegate?.didTapDeleteButton(for: betItem)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        subtitleLabel.text = nil
        oddsLabel.text = nil
        betItem = nil
    }
}
