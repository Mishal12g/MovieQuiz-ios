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
    
    var questionFactory: QuestionFactoryProtocol?
    var currentQuestion: QuizQuestion?
    var alertPresenterDelegate: AlertDelegate?
    var correctAnswer = 0
    var statisticService: StatisticService?
    weak var viewController: MovieQuizViewController?

    
    //MARK: Privaties Property
    private var currentQuestionIndex: Int = 0
    
    //MARK: Public Methods
    //MARK: Show results or Question
    func showNextQuestionOrResults(){
        if isLastQuestion() {
            showFinalResults()
        } else {
            viewController?.isEnabledButtons(false)
            viewController?.waitLoadImage()
            switchToNextQuestion()
            viewController?.hideLoadingIndicator(false)
            questionFactory?.requestNextQuestion()
        }
    }
    
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
    
    //MARK: QuestionFactoryDelegat
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    //MARK: CurrentIndex
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswer = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswer += 1
        }
    }
    
    //MARK: Privaties Methods
    //MARK: Show Results
    private func showFinalResults() {
        statisticService?.store(correct: correctAnswer, total: questionsAmount)
        
        let alertModel = AlertModel(title: "Этот раунд окончен!",
                                    message: makeResultMessage(),
                                    buttonText:"Сыграть еще раз") {[weak self] in
            guard let self = self else { return }
            self.restartGame()
            self.questionFactory?.requestNextQuestion()
            self.viewController?.hideBoarderImage()
        }
        alertPresenterDelegate?.show(model: alertModel)
    }
    
    private func makeResultMessage() -> String {
        guard let statisticService = statisticService, let bestGame = statisticService.bestGame else {
            assertionFailure("error message")
            return ""
        }
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswer)/\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)/\(bestGame.total)"
        + " (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        let resultMessage = [
            currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine].joined(separator: "\n")
        
        return resultMessage
    }

    //MARK: Convert
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(),                                               question: model.text,
                                             questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
}
