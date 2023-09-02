//
//  AlertDelegate.swift
//  MovieQuiz
//
//  Created by mihail on 30.08.2023.
//

import Foundation

protocol AlertDelegate: AnyObject {
    func show(model: AlertModel?)
}
