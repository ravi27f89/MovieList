//
//  ViewModel.swift
//  MovieList
//

import Foundation

protocol ViewModel {
    var movies: [Movie]? { get set }
    var isPaginating: Bool { get set }
    
    var didFetchMoviesSucceed: (()->Void)? { get set }
    var didFetchMoviesFail: ((Error?)->Void)? { get set }
    
    var didFetchMovieDetailsSucceed: ((MovieDetails)->Void)? { get set }
    var didFetchMovieDetailsFail: ((Error?)->Void)? { get set }
    
    func fetchMovies(for searchText: String?, pageNumber: Int)
    func getMovie(at index: Int) -> Movie
    func fetchMovieDetails(for index: Int)
}

class ViewModelImplementation: ViewModel {
    var didFetchMovieDetailsSucceed: ((MovieDetails) -> Void)?
    var didFetchMovieDetailsFail: ((Error?) -> Void)?
    var didFetchMoviesSucceed: (() -> Void)?
    var didFetchMoviesFail: ((Error?) -> Void)?
    var isPaginating: Bool = false
    
    var movies: [Movie]?
    var movieService = NetworkManager()
    
    func fetchMovies(for searchText: String?, pageNumber: Int) {
        self.movieService.downloadMovies(for: searchText, pageNumber: pageNumber) { result in
            guard !(result.Search?.isEmpty ?? true) else { return }
            if self.isPaginating {
                self.movies?.append(contentsOf: result.Search ?? [])
            } else {
                self.movies = result.Search ?? []
            }
            self.didFetchMoviesSucceed?()
        } failure: { error in
            self.didFetchMoviesFail?(error)
        }
    }
    
    func fetchMovieDetails(for index: Int) {
        guard let imdbId = getMovie(at: index).imdbID else {
            print("Invalid imdbId!!")
            return
        }
        movieService.downloadMovieDetails(imdbId: imdbId) { movie in
            self.didFetchMovieDetailsSucceed?(movie)
        } failure: { error in
            self.didFetchMovieDetailsFail?(error)
        }
    }
    
    func getMovie(at index: Int) -> Movie {
        guard let movieCount = self.movies?.count, index < movieCount, let movie = self.movies?[index] else {
            fatalError("Movie index out of range. Please check the datasource count.")
        }
        return movie
    }
    
}
