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
    
    //MARK: Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        questionLabel.text = nil
        previewImage.layer.cornerRadius = 20
        presenter = MovieQuizPresenter(viewController: self)
        showLoadingIndicator()
    }
    
    //statusBar - theme light
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
    
    //show question
    func show(quiz step: QuizStepViewModel) {
        isEnabledButtons(true)
        activityIndicator.isHidden = true
        indexLabel.text = step.questionNumber
        previewImage.image = step.image
        questionLabel.text = step.question
    }
    
    //show result on border image
    func highlightImageBorder(isCorrect: Bool) {
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        previewImage.layer.cornerRadius = 20
    }
    
    func hideBoarderImage() {
        previewImage.layer.borderWidth = 0
    }
    func whileWaitDownloadingImage() {
        previewImage.image = nil
        previewImage.layer.borderWidth = 0
    }
    
    //butons no/yes
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
