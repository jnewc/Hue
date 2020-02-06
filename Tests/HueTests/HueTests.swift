import XCTest
import Combine
@testable import Hue

@available(iOS 13.0, macOS 10.15, *)
final class HueTests: XCTestCase {

    let hue = Hue(bridgeURL: "YOUR_HUE_HUB", username: "YOUR_HUE_USER_ID")
    
    var subscriptions = Set<AnyCancellable>()
    
    // MARK: Collection Tests
    
    func testLights() {
        test(with: try! hue.lights())
    }
    
    func testGroups() {
        test(with: try! hue.groups())
    }
    
    func testSchedules() {
        test(with: try! hue.schedules())
    }
    
    func testScenes() {
        test(with: try! hue.scenes())
    }
    
    func testSensors() {
        test(with: try! hue.sensors())
    }
    
    // MARK: Element Tests
    
    func testLight() {
        test(with: try! hue.light(id: "1"))
    }

    func testGroup() {
        test(with: try! hue.group(id: "1"))
    }
    
    func testScene() {
        test(with: try! hue.scene(id: "Vkj3pJUJwTIWp9T"))
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
