import XCTest
import Combine
@testable import Hue

@available(iOS 13.0, macOS 10.15, *)
final class HueTests: XCTestCase {

    let hue = Hue(bridgeURL: "YOUR_HUE_HUB", username: "YOUR_HUE_USER_ID")
    
    var subscriptions = Set<AnyCancellable>()
    
    // MARK: Collection Tests
    
    func testLights() {
        test(with: hue.lights())
    }
    
    func testGroups() {
        test(with: hue.groups())
    }
    
    func testSchedules() {
        test(with: hue.schedules())
    }
    
    func testScenes() {
        test(with: hue.scenes())
    }
    
    func testSensors() {
        test(with: hue.sensors())
    }
    
    // MARK: Element Tests
    
    func testLight() {
        test(with: hue.light(id: "1"))
    }

    func testGroup() {
        test(with: hue.group(id: "1"))
    }
    
    func testScene() {
        test(with: hue.scene(id: "Vkj3pJUJwTIWp9T"))
    }

    // MARK: Utils
    
    private func test<T>(with publisher: AnyPublisher<T, Hue.Error>, _ completion: ((T) -> Void)? = nil) {
        let expect = self.expectation(description: "Lights are returned")
        
        publisher.sink(receiveCompletion: { result in
            if case .failure(let error) = result {
                if case .parsingFailure(let message) = error {
                    XCTFail(message)
                } else {
                    XCTFail(error.localizedDescription)
                }
            }
        }, receiveValue: { lights in
            expect.fulfill()
        }).store(in: &subscriptions)
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    // MARK: XCTest

    static var allTests = [
        ("testLights", testLights),
        ("testGroups", testGroups),
        ("testSchedules", testSchedules),
        ("testScenes", testScenes),
        ("testSensors", testSensors),
        
        ("testLight", testLight),
        ("testGroup", testGroup),
        ("testScene", testScene),
    ]
}
