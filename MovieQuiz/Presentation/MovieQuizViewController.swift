import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    //MARK: - IB Outlets
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var previewImage: UIImageView!
    @IBOutlet private weak var yesButtonOutlet: UIButton!
    @IBOutlet private weak var noButtonOutlet: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Private Properties
    private let presenter = MovieQuizPresenter()
    private var correctAnswer = 0
    private var questionFactory: QuestionFactoryProtocol?
//    private var currentQuestion: QuizQuestion?
    private var alertPresenterDelegate: AlertDelegate?
    private var movie: Movie?
    private var statisticService: StatisticService?
    
    //MARK: Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        previewImage.layer.cornerRadius = 20
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoading())
        alertPresenterDelegate = AlertPresenter(delegate: self)
        statisticService = StatisticServiceImpl()
        showLoadingIndicator()
        questionFactory?.loadData()
        presenter.viewController = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: Actions Methods
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
    }
    
    //MARK: Public Methods
    //MARK: Delegats
    func didLoadDataFromServer() {
        hideLoadingIndicator(false)
        isEnabledButtons(false)
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: String) {
        showNetworkError(message: error)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }

    //MARK: - Privaties Methods
    private func showNetworkError(message: String) {
        let alertModel = AlertModel(title: "Ошибка",
                                    message: message,
                                    buttonText: "Попробовать ещё раз") { [weak self] in
            guard let self = self else { return }
            self.presenter.resetQuestionIndex()
            self.correctAnswer = 0
            self.questionFactory?.loadData()
            self.questionFactory?.requestNextQuestion()
            
        }
        alertPresenterDelegate?.show(model: alertModel)
    }
    
    //MARK: Get Data
    private func getMovieData() {
        let fileManager = FileManager.default
        var documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "inception.json"
        
        documentsURL.appendPathComponent(fileName)
        
        let jsonString = try? String(contentsOf: documentsURL)
        movie = getMovie(from: jsonString ?? "")
    }
    
    private func getMovie(from jsonString: String) -> Movie? {
        guard let data = jsonString.data(using: .utf8) else { return nil}
        do {
            let movie = try JSONDecoder().decode(Movie.self, from: data)
            return movie
        } catch {
            print("Failed to parse: \(jsonString)")
            return nil
        }
    }
    
    
    //MARK: Show Result
    func show(quiz step: QuizStepViewModel) {
        isEnabledButtons(true)
        activityIndicator.isHidden = true
        indexLabel.text = step.questionNumber
        previewImage.image = step.image
        questionLabel.text = step.question
    }
    
    func showAnswerResult(isCorrect: Bool) {
        isEnabledButtons(false)
        if isCorrect { correctAnswer += 1 }
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        previewImage.layer.cornerRadius = 20
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            // код, который мы хотим вызвать через 1 секунду
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults(){
        if presenter.isLastQuestion() {
            showFinalResults()
        } else {
            isEnabledButtons(false)
            previewImage.layer.borderWidth = 0
            presenter.switchToNextQuestion()
            previewImage.image = nil
            hideLoadingIndicator(false)
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showFinalResults() {
        statisticService?.store(correct: correctAnswer, total: presenter.questionsAmount)
        
        let alertModel = AlertModel(title: "Этот раунд окончен!",
                                    message: makeResultMessage(),
                                    buttonText:"Сыграть еще раз") {[weak self] in
            guard let self = self else { return }
            self.presenter.resetQuestionIndex()
            self.correctAnswer = 0
            self.questionFactory?.requestNextQuestion()
            self.previewImage.layer.borderWidth = 0
        }
        alertPresenterDelegate?.show(model: alertModel)
    }
    
    private func makeResultMessage() -> String {
        guard let statisticService = statisticService, let bestGame = statisticService.bestGame else {
            assertionFailure("error message")
            return ""
        }
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswer)/\(presenter.questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)/\(bestGame.total)"
        + " (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        let resultMessage = [
            currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine].joined(separator: "\n")
        
        return resultMessage
    }

    //MARK: helper methods
    private func isEnabledButtons(_ isEnabled: Bool) {
        noButtonOutlet.isEnabled = isEnabled
        yesButtonOutlet.isEnabled = isEnabled
    }
    
    private func showLoadingIndicator() {
            self.activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator(_ hide: Bool) {
        activityIndicator.isHidden = hide
    }
}
