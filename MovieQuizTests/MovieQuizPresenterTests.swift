//
//  MovieQuizPresenter.swift
//  MovieQuizTests
//
//  Created by mihail on 25.09.2023.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func show(quiz step: MovieQuiz.QuizStepViewModel) {
            
    }
    
    func highlightImageBorder(isCorrect: Bool) {
            
    }
    
    func showLoadingIndicator() {
            
    }
    
    func hideLoadingIndicator(_ hide: Bool) {
            
    }
    
    func isEnabledButtons(_ isEnabled: Bool) {
            
    }
    
    func whileWaitDownloadingImage() {
            
    }
    
    func hideBoarderImage() {
            
    }
    
    
    
    
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvert() throws {
        let viewController = MovieQuizViewControllerMock()
        let presenter = MovieQuizPresenter(viewController: viewController)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question text", correctAnswer: true)
        let viewModel = presenter.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
    
}
