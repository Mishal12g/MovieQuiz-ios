//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by mihail on 29.08.2023.
//

import UIKit

final class AlertPresenter {
    weak var delegate: UIViewController?
    
    init(delegate: UIViewController? = nil) {
        self.delegate = delegate
    }
}

extension AlertPresenter: AlertDelegate {
    
    
    func show(model: AlertModel?) {
        guard let model = model else { return }
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: model.buttonText, style: .default) {_ in
            model.completion()
        }
        
        alert.addAction(action)
        delegate?.present(alert, animated: true)
        
    }
    
    
}

