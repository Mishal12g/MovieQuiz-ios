//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by mihail on 08.09.2023.
//

import Foundation

struct NetworkClient {
    
    //MARK: PUBLIC METHODS
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                handler(.failure(error))
                return
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
                return
            }
            
            guard let data = data else { return }
            handler(.success(data))
        }
        
        task.resume()
    }
    
    
    //MARK: Enums
    private enum NetworkError: Error {
        case codeError
    }
}
