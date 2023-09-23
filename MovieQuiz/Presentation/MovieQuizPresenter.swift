//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by mihail on 23.09.2023.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    //MARK: Public Property
    let questionsAmount: Int = 10
    
    var currentQuestion: QuizQuestion?
    var alertPresenterDelegate: AlertDelegate?
    var correctAnswer = 0
    var statisticService: StatisticService?
    
    //MARK: Privaties Property
    private var currentQuestionIndex: Int = 0
    private weak var viewController: MovieQuizViewController?
    private var questionFactory: QuestionFactoryProtocol?
    
    //MARK: INIT
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        alertPresenterDelegate = AlertPresenter(delegate: viewController)
        statisticService = StatisticServiceImpl()
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoading())
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
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
    
    //MARK: QuestionFactoryDelegate
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
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator(false)
        viewController?.isEnabledButtons(false)
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: String) {
        viewController?.showNetworkError(message: error)
    }
    
    //MARK: CurrentIndex
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswer = 0
        questionFactory?.requestNextQuestion()
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
