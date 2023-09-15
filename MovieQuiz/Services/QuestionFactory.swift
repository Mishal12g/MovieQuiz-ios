//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by mihail on 26.08.2023.
//

import UIKit

final class QuestionFactory: QuestionFactoryProtocol {
    
    //MARK: Privates Properties
    private var movies: [MostPopularMovie] = []
    private weak var delegate: QuestionFactoryDelegate?
    
    private let moviesLoader: MoviesLoading
    
    //MARK: Init
    init(delegate: QuestionFactoryDelegate,
         moviesLoader: MoviesLoading) {
        self.delegate = delegate
        self.moviesLoader = moviesLoader
    }
    
    //MARK: Public Methods
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    if mostPopularMovies.errorMessage != "" {
                        self.delegate?.didFailToLoadData(with: mostPopularMovies.errorMessage)
                    }
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                    
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error.localizedDescription)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
        }
            
            let rating = Float(movie.rating) ?? 0
            let text = "Рейтинг этого фильма больше чем 7?"
            let correctAnswer = rating > 7
            
            let question = QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}




//    private let questions: [QuizQuestion] =  [
//        QuizQuestion(image: "The Godfather",
//                     text: "Рейтинг этого фильма больше чем 6?",
//                     correctAnswer: true),
//        QuizQuestion(image: "The Dark Knight",
//                     text: "Рейтинг этого фильма больше чем 6?",
//                     correctAnswer: true),
//        QuizQuestion(image: "Kill Bill",
//                     text: "Рейтинг этого фильма больше чем 6?",
//                     correctAnswer: true),
//        QuizQuestion(image: "The Avengers",
//                     text: "Рейтинг этого фильма больше чем 6?",
//                     correctAnswer: true),
//        QuizQuestion(image: "Deadpool",
//                     text: "Рейтинг этого фильма больше чем 6?",
//                     correctAnswer: true),
//        QuizQuestion(image: "The Green Knight",
//                     text: "Рейтинг этого фильма больше чем 6?",
//                     correctAnswer: true),
//        QuizQuestion(image: "Old",
//                     text: "Рейтинг этого фильма больше чем 6?",
//                     correctAnswer: false),
//        QuizQuestion(image: "The Ice Age Adventures of Buck Wild",
//                     text: "Рейтинг этого фильма больше чем 6?",
//                     correctAnswer: false),
//        QuizQuestion(image: "Tesla",
//                     text: "Рейтинг этого фильма больше чем 6?",
//                     correctAnswer: false),
//        QuizQuestion(image: "Vivarium",
//                     text: "Рейтинг этого фильма больше чем 6?",
//                     correctAnswer: false),
//    ]
