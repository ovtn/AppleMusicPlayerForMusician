import XCTest
@testable import AppleMusicPlayer

final class ABRepeatLogicTests: XCTestCase {
    var ab = ABRepeatLogic()

    override func setUp() {
        ab = ABRepeatLogic()
    }

    func testInitialState() {
        XCTAssertNil(ab.pointA)
        XCTAssertNil(ab.pointB)
        XCTAssertFalse(ab.isEnabled)
    }

    func testSetA() {
        ab.setA(at: 10)
        XCTAssertEqual(ab.pointA, 10)
        XCTAssertNil(ab.pointB)
    }

    func testSetB() {
        ab.setB(at: 20)
        XCTAssertNil(ab.pointA)
        XCTAssertEqual(ab.pointB, 20)
    }

    func testSetAAfterBIsValid() {
        ab.setB(at: 20)
        ab.setA(at: 10)
        XCTAssertEqual(ab.pointA, 10)
        XCTAssertEqual(ab.pointB, 20)
    }

    func testSetAClearsBWhenAIsAfterB() {
        ab.setB(at: 10)
        ab.setA(at: 20)
        XCTAssertEqual(ab.pointA, 20)
        XCTAssertNil(ab.pointB)
        XCTAssertFalse(ab.isEnabled)
    }

    func testSetBClearsAWhenBIsBeforeA() {
        ab.setA(at: 30)
        ab.setB(at: 10)
        XCTAssertNil(ab.pointA)
        XCTAssertEqual(ab.pointB, 10)
        XCTAssertFalse(ab.isEnabled)
    }

    func testSetBClearsAWhenBEqualsA() {
        ab.setA(at: 10)
        ab.setB(at: 10)
        XCTAssertNil(ab.pointA)
        XCTAssertEqual(ab.pointB, 10)
    }

    func testToggleEnablesAndReturnsA() {
        ab.setA(at: 5)
        ab.setB(at: 15)
        let seekTo = ab.toggle()
        XCTAssertTrue(ab.isEnabled)
        XCTAssertEqual(seekTo, 5)
    }

    func testToggleDisablesAndReturnsNil() {
        ab.setA(at: 5)
        ab.setB(at: 15)
        _ = ab.toggle()
        let seekTo = ab.toggle()
        XCTAssertFalse(ab.isEnabled)
        XCTAssertNil(seekTo)
    }

    func testToggleDoesNothingWithOnlyA() {
        ab.setA(at: 5)
        let seekTo = ab.toggle()
        XCTAssertFalse(ab.isEnabled)
        XCTAssertNil(seekTo)
    }

    func testToggleDoesNothingWithOnlyB() {
        ab.setB(at: 15)
        let seekTo = ab.toggle()
        XCTAssertFalse(ab.isEnabled)
        XCTAssertNil(seekTo)
    }

    func testClearResetsAll() {
        ab.setA(at: 5)
        ab.setB(at: 15)
        _ = ab.toggle()
        ab.clear()
        XCTAssertNil(ab.pointA)
        XCTAssertNil(ab.pointB)
        XCTAssertFalse(ab.isEnabled)
    }
}
