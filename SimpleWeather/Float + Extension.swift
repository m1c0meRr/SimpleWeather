//
//  Float + Extension.swift
//  SimpleWeather
//
//  Created by Sergey Savinkov on 20.09.2023.
//

import UIKit

extension Float {
    func roundFloat(val: Int) -> Float {
        return Float(floor(pow(10.0, Float(val)) * self)/pow(10.0, Float(val)))
    }
    
    func kelvinToCelsius() -> Float {
        let kelvin: Float = 273.15
        let ketVal = self
        let celVal = ketVal - kelvin
        
        return celVal.roundFloat(val: 1)
    }
    
    
}
