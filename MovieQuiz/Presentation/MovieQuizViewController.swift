import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    //MARK: - IB Outlets
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var quistonLabel: UILabel!
    
    @IBOutlet private weak var previewImage: UIImageView!
    
    @IBOutlet private weak var yesButtonOutlet: UIButton!
    @IBOutlet private weak var noButtonOutlet: UIButton!
    
    //MARK: - Private Properties
    private var currentQuestionIndex = 0
    private var correctAnswer = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenterDelegate: AlertDelegate?
    private var movie: Movie?
    private var statisticService: StatisticService?
    
    //MARK: Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(delegate: self)
        alertPresenterDelegate = AlertPresenter(delegate: self)
        statisticService = StatisticServiceImpl()
        questionFactory?.requestNextQuestion()
        getMovieData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //IM Actions Methods
    @IBAction private func noButtonClicked(_ sender: Any) {
        answerGived(answer: false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        answerGived(answer: true)
    }
    
    //MARK: Public Methods
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    
    //MARK: - Privates Methods
    
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
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage(), quistion: model.text,
                                             quistionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        indexLabel.text = step.quistionNumber
        previewImage.image = step.image
        quistonLabel.text = step.quistion
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        noButtonOutlet.isEnabled.toggle()
        yesButtonOutlet.isEnabled.toggle()
        if isCorrect { correctAnswer += 1 }
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        previewImage.layer.cornerRadius = 20
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            // код, который мы хотим вызвать через 1 секунду
            self.showNextQuestionOrResults()
            self.noButtonOutlet.isEnabled.toggle()
            self.yesButtonOutlet.isEnabled.toggle()
        }
    }
    
    private func showNextQuestionOrResults(){
        if currentQuestionIndex == questionsAmount - 1 {
            showFinalResults()
        } else {
            previewImage.layer.borderWidth = 0
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showFinalResults() {
        statisticService?.store(correct: correctAnswer, total: questionsAmount)
        
        let alertModel = AlertModel(title: "Игра окончена!",
                                    message: makeResultMessage(),
                                    buttonText:"Сыграть еще раз") {[weak self] in
            guard let self = self else { return }
            self.currentQuestionIndex = 0
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
        
        let totalPlaysCountLine = "Количество сыгранных квизов \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswer)/\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)/\(bestGame.total)"
        + " \(bestGame.date.dateTimeString)"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))"
        let resultMessage = [
            currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine].joined(separator: "\n")

        return resultMessage
    }
    
    private func answerGived(answer: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = answer
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
