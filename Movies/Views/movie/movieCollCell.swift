//
//  movieCollCell.swift
//  MovieList
//


import UIKit

class movieCollCell: UICollectionViewCell {

    @IBOutlet weak var movieImageView: MovieImageView!
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var movieGenreLabel: UILabel!
    
    static var identifier = "movieCollCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "movieCollCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        movieImageView.clipsToBounds = true
        movieImageView.layer.cornerRadius = 5
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.movieImageView.image = nil
    }
}
