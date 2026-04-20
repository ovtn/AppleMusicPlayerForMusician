import XCTest
@testable import AppleMusicPlayer

final class DoubleExtensionsTests: XCTestCase {
    func testClampedWithinRange() {
        XCTAssertEqual(5.0.clamped(to: 0...10), 5.0)
    }

    func testClampedBelowMin() {
        XCTAssertEqual((-3.0).clamped(to: 0...10), 0.0)
    }

    func testClampedAboveMax() {
        XCTAssertEqual(15.0.clamped(to: 0...10), 10.0)
    }

    func testClampedAtLowerBoundary() {
        XCTAssertEqual(0.0.clamped(to: 0...10), 0.0)
    }

    func testClampedAtUpperBoundary() {
        XCTAssertEqual(10.0.clamped(to: 0...10), 10.0)
    }

    func testClampedNegativeRange() {
        XCTAssertEqual((-5.0).clamped(to: -10...(-1)), -5.0)
        XCTAssertEqual(0.0.clamped(to: -10...(-1)), -1.0)
    }
}
