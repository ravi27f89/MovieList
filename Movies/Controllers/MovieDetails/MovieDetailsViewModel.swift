//
//  MovieDetailsViewModel.swift
//  MovieList
//


import Foundation

protocol MovieDetailsViewModel {
    var movie: MovieDetails? { get set }
    var details: [String] { get set }
    
    func info(at index: Int) -> String
    func getGenre(at index: Int) -> String
    func getText(for index: Int) -> String
    func getGenreCount() -> Int
}

class MovieDetailsViewModelImplementation: MovieDetailsViewModel {
    
    var details = ["Year", "Release Date", "Runtime", "Genre", "Director", "Writer", "Actors", "Language", "Country", "Rating", "Votes"]
    var movie: MovieDetails?
    let na = "N/A"
    
    init(movie: MovieDetails) {
        self.movie = movie
    }
    
    func info(at index: Int) -> String {
        var stringToReturn = ""
        switch index {
        case 0:
            stringToReturn = movie?.Year ?? na
        case 1:
            stringToReturn = movie?.Released ?? na
        case 2:
            stringToReturn = movie?.Runtime ?? na
        case 3:
            stringToReturn = movie?.Genre ?? na
        case 4:
            stringToReturn = movie?.Director ?? na
        case 5:
            stringToReturn = movie?.Writer ?? na
        case 6:
            stringToReturn = movie?.Actors ?? na
        case 7:
            stringToReturn = movie?.Language ?? na
        case 8:
            stringToReturn = movie?.Country ?? na
        case 9:
            stringToReturn = movie?.imdbRating ?? na
        case 10:
            stringToReturn = movie?.imdbVotes ?? na
        default:
            fatalError("Index out of bounds.")
        }
        return stringToReturn
    }
    
    func getGenre(at index: Int) -> String {
        if let genres = self.movie?.Genre?.split(separator: ",") {
            return "\(genres[index])".trimmingCharacters(in: .whitespaces)
        }
        return ""
    }
    
    func getText(for index: Int) -> String {
        return "\(details[index]): " + info(at: index)
    }
    
    func getGenreCount() -> Int {
        return movie?.Genre?.split(separator: ",").count ?? 0
    }
}
