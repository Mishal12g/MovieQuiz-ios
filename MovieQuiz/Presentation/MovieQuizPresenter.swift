//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by mihail on 23.09.2023.
//

import UIKit

final class MovieQuizPresenter {
    
    //MARK: Public Property
    let questionsAmount: Int = 10
    
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    //MARK: Privaties Property
    private var currentQuestionIndex: Int = 0
    
    //MARK: Public Methods
    //MARK: Buttons yes/no
    func yesButtonClicked() {
        answerGiven(answer: true)
    }
    
    func noButtonClicked() {
        answerGiven(answer: false)
    }
    
    func answerGiven(answer: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = answer
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    //MARK: CurrentIndex
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    //MARK: Convert
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(),                                               question: model.text,
                                             questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
}
