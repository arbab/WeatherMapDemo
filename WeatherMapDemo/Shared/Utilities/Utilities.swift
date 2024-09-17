//
//  Utilities.swift
//  WeatherMapDemo
//
//  Created by Arbab Nawaz on 9/13/24.
//

import Foundation

extension Array where Element: Error {
    func localizedErrorDescription() -> String {
        var localizedErrorDescription = ""
        for error in self {
            localizedErrorDescription += "\(error.localizedDescription)\n"
        }
        return localizedErrorDescription
    }
}
