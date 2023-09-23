//
//  File.swift
//  MovieQuizTests
//
//  Created by mihail on 16.09.2023.
//

import XCTest
@testable import MovieQuiz

final class ArrayTests: XCTestCase {
    
    func testGetValueInRange() {
        //Given
        let array = [1, 2, 3, 1, 4]
        
        //When
        let value = array[safe: 2]
        
        //Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 3)
    }
    
    func testGetValueOutOfRange() {
        //Given
        let array = [1, 2, 3, 1, 4]
        
        //When
        let value = array[safe: 5]
        
        //Then
        XCTAssertNil(value)
    }
}
