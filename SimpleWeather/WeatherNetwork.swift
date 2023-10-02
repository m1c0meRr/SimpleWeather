//
//  WeatherNetwork.swift
//  SimpleWeather
//
//  Created by Sergey Savinkov on 18.09.2023.
//

import UIKit

class WeatherNetwork: NetworkProtocol {
    func requestImage(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        
        URLSession.shared.dataTask(with: url) { (data, responce, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else { return }
                completion(.success(data))
            }
        }
        .resume()
    }
    
    func fetchCurrentWeather(city: String, completion: @escaping (CurrentModel) -> Void) {
        
        let formatCity = city.replacingOccurrences(of: " ", with: "+")
        
        let apiURL = "https://api.openweathermap.org/data/2.5/weather?q=\(formatCity)&appid=\(API.apiKey)&lang=ru"
        
        guard let url = URL(string: apiURL) else { fatalError() }
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
    
    func fetchCurrentLocationWeather(lat: String, lon: String, completion: @escaping (CurrentModel) -> ()) {
        
        let apiUrl = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(API.apiKey)&lang=ru"
        
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
