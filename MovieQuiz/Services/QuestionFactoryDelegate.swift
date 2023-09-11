//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by mihail on 29.08.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)

}
