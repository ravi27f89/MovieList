//
//  movieDetailVC.swift
//  MovieList
//

import UIKit

class movieDetailVC: UIViewController {

    @IBOutlet weak var movieImageView: MovieImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var genreCollectionView: UICollectionView!
    
    var viewModel: MovieDetailsViewModel!
    
    let tableViewCellId = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateUI()
        setupTableView()
        setupGenreCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = viewModel.movie?.Title
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: tableViewCellId)
        tableView.tableFooterView = UIView()
    }
    
    private func setupGenreCollectionView() {
        genreCollectionView.delegate = self
        genreCollectionView.dataSource = self
        genreCollectionView.register(generalCollCell.nib(), forCellWithReuseIdentifier: generalCollCell.identifier)
        (genreCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    }

    private func populateUI() {
        guard let movie = viewModel.movie else { return }
        movieImageView.fetchImage(for: movie.Poster ?? "")
        descriptionLabel.text = movie.Plot
    }
}

extension movieDetailVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.details.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            fatalError("Cannot dequeue cell!")
        }
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        cell.textLabel?.tintColor = .systemGray6
        cell.textLabel?.textColor = .darkGray
        cell.textLabel?.text = viewModel.getText(for: indexPath.row)
        
        return cell
    }
    
}

extension movieDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getGenreCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: generalCollCell.identifier, for: indexPath) as? generalCollCell else {
            fatalError("Cannot dequeue cell of type \(generalCollCell.description())")
        }
        cell.genreLabel.text = viewModel.getGenre(at: indexPath.row)
        return cell
    }
}
