//
//  NetworkProtocol.swift
//  SimpleWeather
//
//  Created by Sergey Savinkov on 18.09.2023.
//

import UIKit

protocol NetworkProtocol {
    func fetchCurrentWeather(city: String, completion: @escaping(CurrentModel) -> ())
    func fetchCurrentLocationWeather(lat: String, lon: String, completion: @escaping(CurrentModel) -> ())
    func requestImage(url: URL, completion: @escaping (Result<Data, Error>) -> Void)
}
