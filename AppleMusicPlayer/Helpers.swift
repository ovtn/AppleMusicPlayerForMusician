import Foundation

func formatTime(_ seconds: Double) -> String {
    let s = max(0, seconds)
    // 1e-6 epsilon compensates for IEEE 754 representation error (e.g. 65.3 * 10 = 652.9999...)
    let totalTenths = Int(s * 10 + 1e-6)
    let tenths = totalTenths % 10
    let totalSec = totalTenths / 10
    let sec = totalSec % 60
    let totalMin = totalSec / 60
    let m = totalMin % 60
    let h = totalMin / 60
    if h > 0 {
        return String(format: "%d:%02d:%02d.%d", h, m, sec, tenths)
    }
    return String(format: "%d:%02d.%d", m, sec, tenths)
}
