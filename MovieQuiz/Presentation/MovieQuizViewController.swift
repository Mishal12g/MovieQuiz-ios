import UIKit

final class MovieQuizViewController: UIViewController {
    
    //MARK: - IB Outlets
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var previewImage: UIImageView!
    @IBOutlet private weak var yesButtonOutlet: UIButton!
    @IBOutlet private weak var noButtonOutlet: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Private Properties
    private var presenter: MovieQuizPresenter!
    private var movie: Movie?
    
    //MARK: Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        previewImage.layer.cornerRadius = 20
        presenter = MovieQuizPresenter(viewController: self)
        showLoadingIndicator()
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
    
    //MARK: - Privaties Methods
    func showNetworkError(message: String) {
        let alertModel = AlertModel(title: "Ошибка",
                                    message: message,
                                    buttonText: "Попробовать ещё раз") { [weak self] in
            guard let self = self else { return }
            self.presenter.restartGame()
        }
        presenter.alertPresenterDelegate?.show(model: alertModel)
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
        presenter.didAnswer(isCorrectAnswer: isCorrect)
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        previewImage.layer.cornerRadius = 20
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            // код, который мы хотим вызвать через 1 секунду
            self.presenter.showNextQuestionOrResults()
        }
    }
    
    //MARK: helper methods
    func hideBoarderImage() {
        previewImage.layer.borderWidth = 0
    }
    func waitLoadImage() {
        previewImage.image = nil
        previewImage.layer.borderWidth = 0
    }
    
    func isEnabledButtons(_ isEnabled: Bool) {
        noButtonOutlet.isEnabled = isEnabled
        yesButtonOutlet.isEnabled = isEnabled
    }
    
    func showLoadingIndicator() {
        self.activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator(_ hide: Bool) {
        activityIndicator.isHidden = hide
    }
}
