import Foundation

// MARK: - Protocol

protocol LastSearchCitiesProvider {
    
    var lastSearchedCities: [String] { get }
    func addCity(_ city: String)
    func removeCity(_ city: String)
    
}

// MARK: - Implementation

final class LastSearchCitiesProviderImpl: LastSearchCitiesProvider {
    
    private let key = "LastSearchCities"
    
    var lastSearchedCities: [String] {
        UserDefaults.standard.stringArray(forKey: key) ?? []
    }
    
    func addCity(_ city: String) {
        var cities = lastSearchedCities.filter { $0.lowercased() != city.lowercased() }
        cities.insert(city, at: 0)
        UserDefaults.standard.setValue(cities, forKey: key)
    }
    
    func removeCity(_ city: String) {
        let cities = lastSearchedCities.filter { $0.lowercased() != city.lowercased() }
        UserDefaults.standard.setValue(cities, forKey: key)
    }
}
