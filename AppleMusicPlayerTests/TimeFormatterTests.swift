import XCTest
@testable import AppleMusicPlayer

final class TimeFormatterTests: XCTestCase {
    func testZero() {
        XCTAssertEqual(formatTime(0), "0:00.0")
    }

    func testNegativeClampedToZero() {
        XCTAssertEqual(formatTime(-5), "0:00.0")
    }

    func testUnderOneMinute() {
        XCTAssertEqual(formatTime(9.5), "0:09.5")
    }

    func testOverOneMinute() {
        XCTAssertEqual(formatTime(65.3), "1:05.3")
    }

    func testExactlyOneHour() {
        XCTAssertEqual(formatTime(3600), "1:00:00.0")
    }

    func testHoursMinutesSeconds() {
        XCTAssertEqual(formatTime(3661.5), "1:01:01.5")
    }

    func testTenthsTruncated() {
        XCTAssertEqual(formatTime(1.99), "0:01.9")
    }
}
