//
//  NetworkManager.swift
//  MovieList
//

import Foundation

class NetworkManager {
    private let API_KEY = "f83e6658"
    let baseUrl = "http://www.omdbapi.com/?apikey="
    let session = URLSession.shared
    
    private func getUrl(for searchTerm: String?, pageNumber: Int?) -> URL {
        var string = baseUrl + API_KEY
        if let text = searchTerm?.addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
            string += "&s=\(text)"
        }
        if let page = pageNumber {
            string += "&page=\(page)"
        }
        guard let url = URL(string: string) else {
            fatalError("Cannot create url from string: \(string)")
        }
        return url
    }
    
    private func getUrl(forId imdbId: String) -> URL {
        let string = "http://www.omdbapi.com/?i=" + imdbId + "&apikey=\(API_KEY)"
        guard let url = URL(string: string) else {
            fatalError("Cannot create url from string: \(string)")
        }
        return url
    }
    
    func downloadMovies(for searchTerm: String?, pageNumber: Int, success: @escaping (Result)->Void, failure: @escaping (Error?)->Void ) {
        let url = getUrl(for: searchTerm, pageNumber: pageNumber)
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                failure(error)
                return
            }
            if let json = data {
                do {
                    let result = try JSONDecoder().decode(Result.self, from: json)
                    success(result)
                } catch (let error) {
                    failure(error)
                }
            } else {
                failure(error)
            }
        }.resume()
    }
    
    func downloadMovieDetails(imdbId: String, success: @escaping (MovieDetails)->Void, failure: @escaping (Error?)->Void ) {
        let url = getUrl(forId: imdbId)
        session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                failure(error)
                return
            }
            if let json = data {
                do {
                    let result = try JSONDecoder().decode(MovieDetails.self, from: json)
                    success(result)
                } catch (let error) {
                    failure(error)
                }
            } else {
                failure(error)
            }
        }.resume()
    }
    
}
