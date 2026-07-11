import XCTest
@testable import AppleMusicPlayer

@MainActor
final class MusicControllerABTests: XCTestCase {
    var c: MusicController!

    override func setUp() {
        c = MusicController.shared
        c.clearAB()
        c.playbackTime = 0
    }

    // MARK: - setPointA

    func testSetARecordsCurrentTime() {
        c.playbackTime = 10
        c.setPointA()
        XCTAssertEqual(c.pointA, 10)
    }

    func testSetAAlwaysClearsBEvenWhenBIsAhead() {
        c.playbackTime = 10; c.setPointA()
        c.playbackTime = 20; c.setPointB()
        XCTAssertNotNil(c.pointB)

        c.playbackTime = 15; c.setPointA()

        XCTAssertEqual(c.pointA, 15)
        XCTAssertNil(c.pointB)
        XCTAssertFalse(c.isABRepeatEnabled)
    }

    func testSetADisablesLoop() {
        c.playbackTime = 5;  c.setPointA()
        c.playbackTime = 15; c.setPointB()
        XCTAssertTrue(c.isABRepeatEnabled)

        c.playbackTime = 5; c.setPointA()
        XCTAssertFalse(c.isABRepeatEnabled)
    }

    // MARK: - setPointB

    func testSetBAutoEnablesLoopWhenAIsSet() {
        c.playbackTime = 5;  c.setPointA()
        c.playbackTime = 15; c.setPointB()
        XCTAssertEqual(c.pointA, 5)
        XCTAssertEqual(c.pointB, 15)
        XCTAssertTrue(c.isABRepeatEnabled)
    }

    func testSetBDoesNotAutoEnableLoopWhenOneShotIsActive() {
        // Normal flow: set A→B (loop auto-enables), switch to one shot,
        // then re-set A and B — loop must remain off.
        c.playbackTime = 5;  c.setPointA()
        c.playbackTime = 15; c.setPointB()   // loop=true
        c.toggleOneShot()                     // oneShot=true, loop=false
        c.playbackTime = 5;  c.setPointA()   // clears B
        c.playbackTime = 20; c.setPointB()   // oneShot still on → loop must stay false

        XCTAssertFalse(c.isABRepeatEnabled)
        XCTAssertTrue(c.isOneShotEnabled)
    }

    func testSetBClearsAWhenBIsBeforeA() {
        c.playbackTime = 30; c.setPointA()
        c.playbackTime = 10; c.setPointB()
        XCTAssertNil(c.pointA)
        XCTAssertEqual(c.pointB, 10)
        XCTAssertFalse(c.isABRepeatEnabled)
    }

    func testSetBClearsAWhenBEqualsA() {
        c.playbackTime = 10; c.setPointA()
        c.playbackTime = 10; c.setPointB()
        XCTAssertNil(c.pointA)
        XCTAssertEqual(c.pointB, 10)
        XCTAssertFalse(c.isABRepeatEnabled)
    }

    func testSetBWithoutADoesNotEnableLoop() {
        c.playbackTime = 15; c.setPointB()
        XCTAssertFalse(c.isABRepeatEnabled)
    }

    // MARK: - clearAB

    func testClearResetsAllState() {
        c.playbackTime = 5;  c.setPointA()
        c.playbackTime = 15; c.setPointB()
        c.clearAB()
        XCTAssertNil(c.pointA)
        XCTAssertNil(c.pointB)
        XCTAssertFalse(c.isABRepeatEnabled)
        XCTAssertFalse(c.isOneShotEnabled)
    }
}
