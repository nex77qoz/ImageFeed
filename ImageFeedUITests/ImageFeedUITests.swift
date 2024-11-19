//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Максим Бабкин on 19.11.2024.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
    let app = XCUIApplication()
    
    func testAuth() throws {
        let app = XCUIApplication()
        app.buttons["Войти"].tap()
        
        let webViewsQuery = app.webViews.webViews.webViews
        sleep(3)
        
        webViewsQuery/*@START_MENU_TOKEN@*/.textFields["Email address"]/*[[".otherElements[\"Connect ImageFeed + Unsplash | Unsplash\"].textFields[\"Email address\"]",".textFields[\"Email address\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        webViewsQuery/*@START_MENU_TOKEN@*/.textFields["Email address"]/*[[".otherElements[\"Connect ImageFeed + Unsplash | Unsplash\"].textFields[\"Email address\"]",".textFields[\"Email address\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.typeText("<email>")
        
        sleep(3)
        
        webViewsQuery/*@START_MENU_TOKEN@*/.secureTextFields["Password"]/*[[".otherElements[\"Connect ImageFeed + Unsplash | Unsplash\"].secureTextFields[\"Password\"]",".secureTextFields[\"Password\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        webViewsQuery/*@START_MENU_TOKEN@*/.secureTextFields["Password"]/*[[".otherElements[\"Connect ImageFeed + Unsplash | Unsplash\"].secureTextFields[\"Password\"]",".secureTextFields[\"Password\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.typeText("<password>")
        webViewsQuery/*@START_MENU_TOKEN@*/.buttons["Login"]/*[[".otherElements[\"Connect ImageFeed + Unsplash | Unsplash\"].buttons[\"Login\"]",".buttons[\"Login\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    func testList() throws {
                
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        sleep(2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
   
        cellToLike.buttons["No Active"].tap()
        sleep(2)
        cellToLike.buttons["Active"].tap()
        
        sleep(2)
        
        cellToLike.tap()
        
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        // Zoom in
        image.pinch(withScale: 3, velocity: 1) // zoom in
        // Zoom out
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["Backward"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
       
        XCTAssertTrue(app.staticTexts["Maxim Babkin"].exists)
        XCTAssertTrue(app.staticTexts["@nex77qoz"].exists)
        
        app.buttons["Exit"].tap()
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
}
