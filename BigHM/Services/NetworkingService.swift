//
//  NetworkingService.swift
//  BigHM
//
//  Created by Майя Герасимова on 06.12.2020.
//

import UIKit

class NetworkService {
    private init() {}

    static let shared = NetworkService()
    
    private let apiKey = "19425754-12dac8ba261b0c84ec7f624fb"
    
    private var baseUrlComponent: URLComponents {
        var _urlComps = URLComponents(string: "https://pixabay.com")!
        _urlComps.path = "/api"
        _urlComps.queryItems = [
            URLQueryItem(name: "key", value: apiKey)
        ]
        return _urlComps
    }
    
    //MARK:- Load Image
    func loadImage(from url: URL?, completion: @escaping (UIImage?) -> Void) {
        guard let url = url else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            DispatchQueue.main.async {
                if let data = data {
                    completion(UIImage(data: data))
                } else {
                    completion(nil)
                }
            }
            
        }.resume()
        
    }
    
    //MARK:- Fetch Images
    func fetchImages(word: [String], completion: @escaping (Result<[ImageInfo], SessionError>) -> Void) {
        if word.count == 1,
           let word = Int(word[0]){
                    var urlComps = baseUrlComponent
                    //let amount = 1
                    urlComps.queryItems? += [
                        //URLQueryItem(name: "per_page", value: "\(amount)"),
                        URLQueryItem(name: "id", value: "\(word)"),
                       //URLQueryItem(name: "per_page", value: "\(amount)"),
                        //URLQueryItem(name: "editors_choice", value: "\(true)")
                    ]
                    guard let url = urlComps.url else {
                        completion(.failure(.invalidUrl))
                        return
                    }
                    
                    URLSession.shared.dataTask(with: url) { (data, response, error) in
                        if let error = error {
                            DispatchQueue.main.async {
                                completion(.failure(.other(error)))
                            }
                            return
                        }
                        
                        let response = response as! HTTPURLResponse
                        guard let data = data, response.statusCode == 200 else {
                            DispatchQueue.main.async {
                                completion(.failure(.serverError(response.statusCode)))
                            }
                            return
                        }
                        
                        do {
                            let serverResponse = try JSONDecoder().decode(ServerResponse<ImageInfo>.self, from: data)
                            DispatchQueue.main.async {
                                completion(.success(serverResponse.hits))
                            }
                        }
                        catch let decodingError {
                            DispatchQueue.main.async {
                                completion(.failure(.decodingError(decodingError)))
                            }
                        }
                        
                    }.resume()
                }
            else{
                    var urlComps = baseUrlComponent
                    var result = ""
                    var k = 1
                    for i in word{
                        if k == 1{
                            result += "\(i)"
                            k += 1
                        }
                        else{
                            result += "+\(i)"
                        }
                    }
                    let amount = 60
                    urlComps.queryItems? += [
                        //URLQueryItem(name: "per_page", value: "\(amount)"),
                        URLQueryItem(name: "q", value: "\(result)"),
                       URLQueryItem(name: "per_page", value: "\(amount)"),
                        URLQueryItem(name: "editors_choice", value: "\(true)")
                    ]
                    guard let url = urlComps.url else {
                        completion(.failure(.invalidUrl))
                        return
                    }
                    
                    URLSession.shared.dataTask(with: url) { (data, response, error) in
                        if let error = error {
                            DispatchQueue.main.async {
                                completion(.failure(.other(error)))
                            }
                            return
                        }
                        
                        let response = response as! HTTPURLResponse
                        guard let data = data, response.statusCode == 200 else {
                            DispatchQueue.main.async {
                                completion(.failure(.serverError(response.statusCode)))
                            }
                            return
                        }
                        
                        do {
                            let serverResponse = try JSONDecoder().decode(ServerResponse<ImageInfo>.self, from: data)
                            DispatchQueue.main.async {
                                completion(.success(serverResponse.hits))
                            }
                        }
                        catch let decodingError {
                            DispatchQueue.main.async {
                                completion(.failure(.decodingError(decodingError)))
                            }
                        }
                        
                    }.resume()
                }
}
}
