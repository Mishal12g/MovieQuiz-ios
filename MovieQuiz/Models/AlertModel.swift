//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by mihail on 29.08.2023.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let action: (() -> Void)? = nil
}
