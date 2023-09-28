//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by mihail on 23.09.2023.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    //MARK: - Privates Properties
    private let questionsAmount: Int = 10
    
    private var alertPresenterDelegate: AlertDelegate?
    private var currentQuestion: QuizQuestion?
    private var correctAnswer = 0
    private var statisticService: StatisticService?
    private var currentQuestionIndex: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    private weak var controllerUIView: MovieQuizViewController?
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    //MARK: - INIT
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        alertPresenterDelegate = AlertPresenter(delegate: self.viewController as? UIViewController)
        statisticService = StatisticServiceImpl()
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoading())
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    //MARK: - Public Methods
    //MARK: - Buttons yes/no
    func yesButtonClicked() {
        answerGiven(answer: true)
    }
    
    func noButtonClicked() {
        answerGiven(answer: false)
    }
    
    //MARK: - QuestionFactoryDelegate
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
        showNetworkError(message: error)
    }
        
    //MARK: - Privates methods
    //MARK: - CurrentIndex
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func restartGame() {
        currentQuestionIndex = 0
        correctAnswer = 0
        questionFactory?.requestNextQuestion()
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswer += 1
        }
    }

    
    //MARK: - Shows Methods
    private func showNetworkError(message: String) {
        let alertModel = AlertModel(title: "Ошибка",
                                    message: message,
                                    buttonText: "Попробовать ещё раз") { [weak self] in
            guard let self = self else { return }
            self.restartGame()
        }
        alertPresenterDelegate?.show(model: alertModel)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        viewController?.isEnabledButtons(false)
        didAnswer(isCorrectAnswer: isCorrect)
        viewController?.highlightImageBorder(isCorrect: isCorrect)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            //code that is called after a second
            self.showNextQuestionOrResults()
        }
    }
    
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
    
    //Show results or Question
    private func showNextQuestionOrResults(){
        if isLastQuestion() {
            showFinalResults()
        } else {
            viewController?.isEnabledButtons(false)
            viewController?.whileWaitDownloadingImage()
            switchToNextQuestion()
            viewController?.hideLoadingIndicator(false)
            questionFactory?.requestNextQuestion()
        }
    }
    
    //message data for show result
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

    private func answerGiven(answer: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = answer
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    //MARK: - Convert
     func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(),
                                             question: model.text,
                                             questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
}
