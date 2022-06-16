//
//  ViewController.swift
//  MovieList
//


import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var viewChangeBarButton: UIBarButtonItem!
    
    var viewModel: ViewModel!
    var debounce_timer: Timer?
    var searchController: UISearchController!
    var paginationActivity = UIActivityIndicatorView(style: .large)
    var fetchingMore = false
    var currentPage = 1
    var numberOfRows = 3
    let FOOTER_ID = "footer"
    let HEADER_ID = "header"
    let LIST_IMAGE = UIImage(systemName: "list.bullet")
    let GRID_IMAGE = UIImage(systemName: "square.grid.2x2.fill")
    let FOOTER_SIZE: CGFloat = 60
    let HEADER_HEIGHT: CGFloat = 50
    let INSET: CGFloat = 10
    let BAR_BUTTON_SIZE: CGFloat = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ViewModelImplementation()
        setupCollectionView()
        configureSearch()
        updateRighBarButton(isGrid: true)
        bindViewModel()
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.backgroundColor = .systemGray6
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(movieCollCell.nib(), forCellWithReuseIdentifier: movieCollCell.identifier)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: FOOTER_ID)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HEADER_ID)
    }
    
    private func configureSearch() {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search Movie Here"
        search.searchBar.delegate = self
        navigationItem.searchController = search
        self.searchController = search
    }

    private func bindViewModel() {
        viewModel.didFetchMoviesSucceed = { [weak self] in
            guard let self = self else {
                return
            }
            DispatchQueue.main.async {
                self.paginationActivity.stopAnimating()
                self.refreshUI()
                self.fetchingMore = false
            }
        }
        
        viewModel.didFetchMoviesFail = { [weak self] error in
            guard let self = self else {
                return
            }
            self.fetchingMore = false
            self.paginationActivity.stopAnimating()
            // Show alert to user.
            DispatchQueue.main.async {
                let errorString = error?.localizedDescription ?? "Something went wrong."
                let alert = UIAlertController(title: "Error", message: errorString, preferredStyle: .alert)
                let button = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alert.addAction(button)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        viewModel.didFetchMovieDetailsSucceed = { [weak self] movie in
            guard let self = self else {
                return
            }
            DispatchQueue.main.async {
                // Navigate to details screen
                self.removeLoader()
                guard let VC = UIStoryboard(name: "movieDetailVC", bundle: nil).instantiateInitialViewController() as? movieDetailVC else {
                    fatalError("Could not instantiate ViewController of type \(movieDetailVC.description())")
                }
                let VM = MovieDetailsViewModelImplementation(movie: movie)
                VC.viewModel = VM
                self.navigationController?.pushViewController(VC, animated: true)
            }
        }
        
    }
    
    private func refreshUI() {
        emptyView.isHidden = !(viewModel.movies?.count == 0)
        collectionView.reloadSections(IndexSet.init(integer: 0))
    }
    
    @objc func didTapViewChangeButton(_ sender: UIBarButtonItem) {
        if numberOfRows == 1 {
            numberOfRows = 3
            updateRighBarButton(isGrid: true)
        } else {
            numberOfRows = 1
            updateRighBarButton(isGrid: false)
        }
        collectionView.reloadData()
    }
    
    func updateRighBarButton(isGrid : Bool){
        let navBarButton = UIButton(type: .custom)
        navBarButton.frame = CGRect(x: 0, y: 0, width: BAR_BUTTON_SIZE, height: BAR_BUTTON_SIZE)
        navBarButton.addTarget(self, action: #selector(didTapViewChangeButton(_:)), for: .touchUpInside)

        if isGrid {
            navBarButton.setImage(LIST_IMAGE, for: .normal)
        } else {
            navBarButton.setImage(GRID_IMAGE, for: .normal)
        }
        let rightButton = UIBarButtonItem(customView: navBarButton)
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    func addLoader() {
        let loaderView = UIView(frame: self.view.frame)
        loaderView.backgroundColor = .white
        loaderView.alpha = 0.75
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .black
        indicator.frame = loaderView.frame
        loaderView.addSubview(indicator)
        indicator.startAnimating()
        loaderView.tag = 1298
        view.addSubview(loaderView)
    }
    
    func removeLoader() {
        let loaderView = self.view.viewWithTag(1298)
        loaderView?.removeFromSuperview()
    }
    
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.movies?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: movieCollCell.identifier, for: indexPath) as? movieCollCell else {
            fatalError("Cannot dequeue cell of type \(movieCollCell.description())")
        }
        configure(cell, for: indexPath)
        return cell
    }
    
    // cell congifuration here
    private func configure(_ cell: movieCollCell, for indexPath: IndexPath) {
        let movie = viewModel.getMovie(at: indexPath.row)
        cell.movieImageView.fetchImage(for: movie.Poster ?? "")
        cell.movieNameLabel.text = movie.Title
        cell.movieGenreLabel.text = movie.Year
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: INSET, left: INSET, bottom: INSET, right: INSET);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if numberOfRows == 1 {
            let cellWidth = (view.frame.size.width / CGFloat(numberOfRows)) - 100
            return CGSize(width: cellWidth, height: (223))
        }
        let cellWidth = (view.frame.size.width / CGFloat(numberOfRows)) - 15
        return CGSize(width: cellWidth, height: (223.0))
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HEADER_ID, for: indexPath)
            let label = UILabel()
            label.text = "Search Results"
            headerView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
            return headerView
            
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: FOOTER_ID, for: indexPath)
            footerView.addSubview(paginationActivity)
            paginationActivity.translatesAutoresizingMaskIntoConstraints = false
            paginationActivity.centerXAnchor.constraint(equalTo: footerView.centerXAnchor).isActive = true
            paginationActivity.centerYAnchor.constraint(equalTo: footerView.centerYAnchor).isActive = true
            return footerView
            
        default:
            fatalError("Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
            return CGSize(width: collectionView.frame.width, height: HEADER_HEIGHT)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
            return CGSize(width: FOOTER_SIZE, height: FOOTER_SIZE)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.addLoader()
        viewModel.fetchMovieDetails(for: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let moviesCount = viewModel.movies?.count else {
            return
        }
        if (indexPath.row == moviesCount - 1) && (moviesCount > 9) { //it's your last cell
          //Load more data & reload your collection view
           if !fetchingMore {
               beginBatchFetch()
           }
        }
    }
    
    private func beginBatchFetch() {
        self.paginationActivity.startAnimating()
        self.fetchingMore = true
        viewModel.isPaginating = true
        currentPage = currentPage + 1
        viewModel.fetchMovies(for: searchController.searchBar.searchTextField.text, pageNumber: currentPage)
    }
    
}

extension ViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        cache.removeAllObjects()
        self.currentPage = 1
        viewModel.isPaginating = false
        guard let text = searchController.searchBar.text, !text.isEmpty else { return }
        debounce_timer?.invalidate()
        debounce_timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            self.viewModel.fetchMovies(for: text, pageNumber: self.currentPage)
        }
    }
    
}
