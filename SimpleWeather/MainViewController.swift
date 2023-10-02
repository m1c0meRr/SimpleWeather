//
//  ViewController.swift
//  SimpleWeather
//
//  Created by Sergey Savinkov on 18.09.2023.
// 

import UIKit
import CoreLocation

class MainViewController: UIViewController {
    
    private let locationLabel: UILabel = {
        let label = UILabel()
//        label.text = "Moscow"
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 42, weight: .semibold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
//        label.text = "18 semp 2023"
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let temperatureLabel: UILabel = {
        let label = UILabel()
//        label.text = "10 C˚℃"
        label.textAlignment = .left
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 65, weight: .heavy)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let symbolImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "sun.haze")
        image.tintColor = .darkGray
        image.contentMode = .scaleToFill
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let minTempLabel: UILabel = {
        let label = UILabel()
//        label.text = "5 ℃"
        label.textAlignment = .left
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 25, weight: .regular)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let maxTempLabel: UILabel = {
        let label = UILabel()
//        label.text = "20 ℃"
        label.textAlignment = .left
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 25, weight: .medium)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let weatherNetwork = WeatherNetwork()
    
    private var locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    private var latitude: CLLocationDegrees!
    private var longitude: CLLocationDegrees!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        startUpdatingLocation()
//        setDelegates()
        setupConstraints()
    }
    
    private func setupViews() {
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise.circle"), style: .done, target: self, action: #selector(refreshButton)),
        UIBarButtonItem(image: UIImage(systemName: "location.north.circle"), style: .done, target: self, action: #selector(addButton))]
        
        view.backgroundColor = .lightGray
        
        view.addSubview(locationLabel)
        view.addSubview(timeLabel)
        view.addSubview(temperatureLabel)
        view.addSubview(symbolImage)
        
        view.addSubview(minTempLabel)
        view.addSubview(maxTempLabel)
    }
    
    //MARK: - @objc
    
    @objc func refreshButton() {
        let city = UserDefaults.standard.string(forKey: "City") ?? ""
        
        fetchCurrentLocation(city: city)
    }
    
    @objc func addButton() {
        let alertController = UIAlertController(title: "Add city", message: "", preferredStyle: .alert)
        
        alertController.addTextField { (textField: UITextField) in
            textField.placeholder = "Name city"
        }
        let action = UIAlertAction(title: "Add", style: .default) { alert in
            let textField = alertController.textFields![0] as UITextField
            let cityName = textField.text // передаем в функцию поиска города
            self.fetchCurrentLocation(city: cityName ?? "Moscow")
        }
        let cancel = UIAlertAction(title: "Cancel", style: .default)
        
        alertController.addAction(action)
        alertController.addAction(cancel)
        
        present(alertController, animated: true)
    }
    
    private func startUpdatingLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
        
    //MARK: - Fetch location
    
    private func fetchCoordinates(lat: String, lon: String) {
        weatherNetwork.fetchCurrentLocationWeather(lat: lat, lon: lon) { (weather) in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            let stringDate = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(weather.dt)))
            
            DispatchQueue.main.async {
                self.locationLabel.text = weather.name
                self.timeLabel.text = stringDate
                self.temperatureLabel.text = String(weather.main.temp.kelvinToCelsius()) + " ℃"
                self.minTempLabel.text = "Min: " + String(weather.main.temp_min.kelvinToCelsius()) + " ℃"
                self.maxTempLabel.text = "Max: " + String(weather.main.temp_max.kelvinToCelsius()) + " ℃"
                self.fetchImage(model: weather)
                
                UserDefaults.standard.set("\(weather.name ?? "")", forKey: "City")
            }
        }
    }
    
    private func fetchCurrentLocation(city: String) {
        weatherNetwork.fetchCurrentWeather(city: city) { (weather) in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            let stringDate = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(weather.dt)))
            
            DispatchQueue.main.async {
                self.locationLabel.text = weather.name
                self.timeLabel.text = stringDate
                self.temperatureLabel.text = String(weather.main.temp.kelvinToCelsius()) + " ℃"
                self.minTempLabel.text = "Min: " + String(weather.main.temp_min.kelvinToCelsius()) + " ℃"
                self.maxTempLabel.text = "Max: " + String(weather.main.temp_max.kelvinToCelsius()) + " ℃"
                self.fetchImage(model: weather)
                
                UserDefaults.standard.set("\(weather.name ?? "")", forKey: "City")
            }
        }
    }
    
    func fetchImage(model: CurrentModel) {
        guard let url = URL(string: "http://openweathermap.org/img/wn/\(model.weather[0].icon)@2x.png") else { return }
        
        weatherNetwork.requestImage(url: url) { [weak self] result in
            
            guard let self = self else { return }
            switch result {
            case .success(let data):
                let image = UIImage(data: data)
                self.symbolImage.image = image
            case .failure(let error):
                print("ОШИБКА", error)
            }
        }
    }
    
    
    //MARK: - setupConstraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            locationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            locationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            locationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            timeLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 5),
            timeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            timeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            temperatureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            temperatureLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            symbolImage.bottomAnchor.constraint(equalTo: temperatureLabel.topAnchor, constant: -5),
            symbolImage.centerXAnchor.constraint(equalTo: temperatureLabel.centerXAnchor),
            symbolImage.heightAnchor.constraint(equalToConstant: 50),
            symbolImage.widthAnchor.constraint(equalToConstant: 50),
            
            minTempLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 5),
            minTempLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            minTempLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            maxTempLabel.topAnchor.constraint(equalTo: minTempLabel.bottomAnchor, constant: 5),
            maxTempLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            maxTempLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
}

extension MainViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        manager.delegate = nil
        
        let location = locations[0].coordinate
        latitude = location.latitude
        longitude = location.longitude
        
        print("Location", location)
        print("Lon", longitude.description)
        print("Lat", latitude.description)
        
        fetchCoordinates(lat: latitude.description, lon: longitude.description)
    }
}


