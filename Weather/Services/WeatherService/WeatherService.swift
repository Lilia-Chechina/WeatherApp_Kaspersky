import Foundation

enum WeatherError: Error {

    case networkError
    case decodingError
    case cityNotFound

}

typealias CityModelResult = Result<CityModel, WeatherError>
typealias CityModelCompletion = (CityModelResult) -> Void

protocol WeatherService: AnyObject {

    func getCurrentWeather(city: String, completion: @escaping CityModelCompletion)

}

final class WeatherServiceImpl: WeatherService {
    
    // You should implement WeatherService yourself
    // This service should be able to run requests without blocking main queue
    // Отсюда начинаю писать свой код:
    private let apiKey = "dc7066c1850e43aca7f101216251804"
    private let baseURL = "https://api.weatherapi.com/v1"
    
    func getCurrentWeather(city: String, completion: @escaping CityModelCompletion) {
        guard let url = URL(string: "\(baseURL)/current.json?key=\(apiKey)&q=\(city)") else {
            completion(.failure(.networkError))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                completion(.failure(.networkError))
                return
            }
            
            guard let data = data else {
                completion(.failure(.networkError))
                return
            }
            
            if let errorResponse = try? JSONDecoder().decode([String: ErrorResponse].self, from: data),
               errorResponse["error"] != nil {
                completion(.failure(.cityNotFound))
                return
            }
            
            do {
                let cityModel = try JSONDecoder().decode(CityModel.self, from: data)
                completion(.success(cityModel))
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    private struct ErrorResponse: Codable {
        let code: Int
        let message: String
    }
}
