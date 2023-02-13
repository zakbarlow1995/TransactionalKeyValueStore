import XCTest

class TransactionalKeyValueStoreUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUIExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let timeout: TimeInterval = 2
        let setButton = app.buttons["SET BUTTON"]
        XCTAssertTrue(setButton.waitForExistence(timeout: timeout))
        
        let setKeyTextField = app.textFields["SET KEY TEXTFIELD"]
        XCTAssertTrue(setKeyTextField.waitForExistence(timeout: timeout))
        
        let setValueTextField = app.textFields["SET VALUE TEXTFIELD"]
        XCTAssertTrue(setValueTextField.waitForExistence(timeout: timeout))
        
        let getKeyTextField = app.textFields["GET KEY TEXTFIELD"]
        XCTAssertTrue(getKeyTextField.waitForExistence(timeout: timeout))
        
        let getButton = app.buttons["GET BUTTON"]
        XCTAssertTrue(getButton.waitForExistence(timeout: timeout))
        
        let countValueTextField = app.textFields["COUNT VALUE TEXTFIELD"]
        XCTAssertTrue(countValueTextField.waitForExistence(timeout: timeout))
        
        let countButton = app.buttons["COUNT BUTTON"]
        XCTAssertTrue(countButton.waitForExistence(timeout: timeout))

        let beginButton = app.buttons["BEGIN BUTTON"]
        XCTAssertTrue(beginButton.waitForExistence(timeout: timeout))
        
        let commitButton = app.buttons["COMMIT BUTTON"]
        XCTAssertTrue(commitButton.waitForExistence(timeout: timeout))
        
        let rollbackButton = app.buttons["ROLLBACK BUTTON"]
        XCTAssertTrue(rollbackButton.waitForExistence(timeout: timeout))
        
        setKeyTextField.tap()
        setKeyTextField.typeText("foo")

        setValueTextField.tap()
        setValueTextField.typeText("bar")

        setButton.tap()
        
        getKeyTextField.tap()
        getKeyTextField.typeText("foo")
        
        getButton.tap()
        
        countValueTextField.tap()
        countValueTextField.typeText("foo")
        countButton.tap()
        
        countValueTextField.doubleTap()
        countValueTextField.typeText("bar")
        countButton.tap()
        
        beginButton.tap()
        
        setKeyTextField.doubleTap()
        setKeyTextField.typeText("bar")
        setButton.tap()
        
        countButton.tap()

        commitButton.tap()
        rollbackButton.tap()
        
        let consoleTextEditor = app.textViews["CONSOLE TEXT EDITOR"]
        XCTAssertTrue(consoleTextEditor.waitForExistence(timeout: timeout))

        let expected =
"""
> SET foo bar
> GET foo
bar
> COUNT foo
0
> COUNT bar
1
> BEGIN
> SET bar bar
> COUNT bar
2
> COMMIT
> ROLLBACK
no transaction

"""

        XCTAssertEqual(consoleTextEditor.value as? String, expected)
    }

//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
