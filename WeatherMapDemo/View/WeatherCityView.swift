//
//  WeatherCityView.swift
//  WeatherMapDemo
//
//  Created by Arbab Nawaz on 9/12/24.
//

import SwiftUI

struct WeatherCityView: View {
    
    var result: WeatherCityViewModel
    
    var body: some View {
        HStack {
            AsyncImage (url: result.imageURL) { image in
                image.resizable()
            } placeholder: {
                Image(systemName: "exclamationmark.octagon.fill")
            }
            .frame(width: 100, height: 100)
            .background()
            .cornerRadius(8.0)
            .shadow(radius: 8.0, x: -1, y: -1)
            VStack(alignment: .leading) {
                Text(result.city)
                Text(result.wind)
                Text(result.primaryWeather)
            }
        }
        
    }
}

//#Preview {
//    WeatherCityView(result: WeatherCityViewModel(model: Mock().load(type: .weather)))
//}
