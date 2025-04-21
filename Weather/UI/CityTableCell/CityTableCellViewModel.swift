import Foundation

public struct CityTableCellViewModel {
    
    let name: String?
    let temperature: String?
    let conditionText: String?
    let conditionIconURL: String?
    let timezoneID: String?
    
    init(cityModel: CityModel) {
        name = cityModel.location.name
        temperature = "\(cityModel.current.temp_c)℃"
        conditionText = cityModel.current.condition.text
        conditionIconURL = "https:\(cityModel.current.condition.icon)"
        timezoneID = cityModel.location.tz_id
    }
    
    var currentLocalTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale.current
        
        if let timezoneID = timezoneID,
           let timeZone = TimeZone(identifier: timezoneID) {
            formatter.timeZone = timeZone
        }
        
        return formatter.string(from: Date())
    }
}

