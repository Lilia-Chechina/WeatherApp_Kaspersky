import Foundation

struct CityModel: Codable {
    struct Location: Codable {
        let name: String
        let localtime: String
        let tz_id: String
    }
    
    struct Current: Codable {
        let temp_c: Double
        let condition: Condition
    }
    
    struct Condition: Codable {
        let text: String
        let icon: String
    }
    
    let location: Location
    let current: Current
}
