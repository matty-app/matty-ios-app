import Foundation

extension Date {
    
    var yearsFromNow: Int {
        return Calendar.current.dateComponents([.year], from: .now, to: self).year ?? 0
    }
    
    var daysFromNow: Int {
        return Calendar.current.dateComponents([.day], from: .now, to: self).day ?? 0
    }
    
    var hoursFromNow: Int {
        return Calendar.current.dateComponents([.hour], from: .now, to: self).hour ?? 0
    }
    
    var minutesFromNow: Int {
        return Calendar.current.dateComponents([.minute], from: .now, to: self).minute ?? 0
    }
    
    var secondsFromNow: Int {
        return Calendar.current.dateComponents([.second], from: .now, to: self).second ?? 0
    }
    
    func adding(hours: Int) -> Date {
        return Calendar.current.date(byAdding: .hour, value: hours, to: self) ?? self
    }
}
