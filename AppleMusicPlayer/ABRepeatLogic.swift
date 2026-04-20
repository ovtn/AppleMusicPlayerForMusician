import Foundation

struct ABRepeatLogic {
    var pointA: Double? = nil
    var pointB: Double? = nil
    var isEnabled: Bool = false

    mutating func setA(at time: Double) {
        pointA = time
        if let b = pointB, b <= time {
            pointB = nil
            isEnabled = false
        }
    }

    mutating func setB(at time: Double) {
        pointB = time
        if let a = pointA, a >= time {
            pointA = nil
            isEnabled = false
        }
    }

    /// Toggles repeat. Returns pointA if repeat was just enabled (caller should seek there).
    mutating func toggle() -> Double? {
        guard pointA != nil, pointB != nil else { return nil }
        isEnabled.toggle()
        return isEnabled ? pointA : nil
    }

    mutating func clear() {
        pointA = nil
        pointB = nil
        isEnabled = false
    }
}
