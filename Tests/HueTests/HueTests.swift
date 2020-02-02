import XCTest
@testable import Hue

final class HueTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Hue().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
