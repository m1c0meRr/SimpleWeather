//
//  WeatherNetwork.swift
//  SimpleWeather
//
//  Created by Sergey Savinkov on 18.09.2023.
//

import UIKit

class WeatherNetwork: NetworkProtocol {
    func fetchCurrentWeather(city: String, completion: @escaping (CurrentModel) -> ()) {
//        <#code#>
    }
    
    func fetchCurrentLocationWeather(lat: String, lon: String, completion: @escaping (CurrentModel) -> ()) {
        
        let apiUrl = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(API.apiKey)"
        guard let url = URL(string: apiUrl) else { fatalError() }
        let urlRequest = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data else { return }
            
            do {
                let currentModel = try JSONDecoder().decode(CurrentModel.self, from: data)
                completion(currentModel)
            } catch {
                print(error)
            }
        }
        .resume()
    }
}
