//
//  generalCollCell.swift
//  MovieList
//


import UIKit

class generalCollCell: UICollectionViewCell {

    @IBOutlet weak var genreLabel: UILabel!
    
    static var identifier = "generalCollCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "generalCollCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        contentView.layer.masksToBounds = false
        contentView.layer.cornerRadius = 4
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.cgColor
    }

}
