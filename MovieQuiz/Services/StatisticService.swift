//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by mihail on 02.09.2023.
//

import Foundation

protocol StatisticService {
    func store(correct count: Int, total amount: Int)
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: BestGame? { get }
}

final class StatisticServiceImpl {
    private let userDefaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let dateProvider: () -> Date
    
    
    init(userDefaults: UserDefaults = .standard,
         encoder: JSONEncoder = JSONEncoder(),
         decoder: JSONDecoder = JSONDecoder(),
         dateProvider: @escaping () -> Date = { Date() }
    ){
        self.userDefaults = userDefaults
        self.encoder = encoder
        self.decoder = decoder
        self.dateProvider = dateProvider
    }
}

extension StatisticServiceImpl: StatisticService {
    
    var totalAccuracy: Double {
         Double(correct) / Double(total) * 100
    }
    
    
    var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gameCount.rawValue)
        }
        
        set {
            userDefaults.set(newValue, forKey: Keys.gameCount.rawValue)
        }
    }
    
    var correct: Int {
        get {
            userDefaults.integer(forKey: Keys.correct.rawValue)
        }
        
        set {
            userDefaults.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    
    var total: Int {
        get {
            userDefaults.integer(forKey: Keys.total.rawValue)
        }
        
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    
    var bestGame: BestGame? {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
            let record = try? decoder.decode(BestGame.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            
            return record
            
            
        }
        
        set {
            guard let data = try? encoder.encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
   
    
    private enum Keys: String {
        case correct, total, bestGame, gameCount
    }
    
    func store(correct count: Int, total amount: Int) {
        self.correct += correct
        self.total += total
        self.gamesCount += 1
        let date = dateProvider()
        
        let current = BestGame(correct: correct, total: total, date: date)
        
       if let previosBestGame = bestGame {
           if current > previosBestGame {
               bestGame = current
           }
       } else {
           bestGame = current
       }
    }
}
