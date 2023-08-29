//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by mihail on 29.08.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {               // 1
    func didReceiveNextQuestion(question: QuizQuestion?)    // 2
}

