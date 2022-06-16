//
//  Movie.swift
//  MovieList
//


import Foundation

struct Result: Codable {
    var Search: [Movie]?
}

struct Movie: Codable {
    var imdbID: String?
    var Title: String?
    var Year: String?
    var Poster: String?
}
