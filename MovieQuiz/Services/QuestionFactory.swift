//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by mihail on 26.08.2023.
//

import UIKit

final class QuestionFactory: QuestionFactoryProtocol {
    
    //MARK: - Privates Properties
    private let questionsNums: [Float] = [8.3, 6.6, 7, 9, 8.4, 8, 6.8, 9.3, 7.1, 6.3, 8.4, 8.9, 7.4, 8.2]
    private var movies: [MostPopularMovie] = []
    
    private weak var delegate: QuestionFactoryDelegate?
    
    private let moviesLoader: MoviesLoading
    
    //MARK: - Init
    init(delegate: QuestionFactoryDelegate,
         moviesLoader: MoviesLoading) {
        self.delegate = delegate
        self.moviesLoader = moviesLoader
    }
    
    //MARK: - Public Methods
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
            let indexQuestionRating = questionsNums[(0..<questionsNums.count).randomElement() ?? 0]
            let isMoreOrLessCounter = (0...1).randomElement()
            let isMoreOrLess = isMoreOrLessCounter == 0 ? "больше" : "меньше"
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.didFailToLoadData(with: "Failed to load image, maybe there is a problem with the internet")
                    return
            }
            }
            
            let rating = Float(movie.rating) ?? 0
            let text = "Рейтинг этого фильма \(isMoreOrLess) чем \(indexQuestionRating)?"
            let correctAnswer = isMoreOrLess == "меньше" ? rating < indexQuestionRating : rating > indexQuestionRating
            
            let question = QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
