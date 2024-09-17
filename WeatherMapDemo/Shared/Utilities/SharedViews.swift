//
//  SharedViews.swift
//  WeatherMapDemo
//
//  Created by Arbab Nawaz on 9/13/24.
//

import SwiftUI


struct ErrorView: View {
    @State var error:  Error? = nil
    @Binding var show: Bool
    var body: some View {
        if let error = error {
            VStack {
                Text(error.localizedDescription)
                    .bold()
                Spacer().frame(height: 10)
                HStack {
                    Button("Dismiss") {
                        self.error = nil
                        show = false
                    }.buttonStyle(BorderedButtonStyle())
                }
            }
            .padding([.leading, .trailing], 20)
            .padding([.top, .bottom], 15)
            .background(Color.white)
            .foregroundColor(.black)
            .shadow(radius: 10, y: 5)
            .border(.green)

        }
    }
}

#Preview {
    struct ErrorPreview: View {
        @State var showError = true
        var body: some View {
            ErrorView(error: NSError(domain: "Invalid Url", code: -1, userInfo: nil), show: $showError)
        }
    }
    return ErrorPreview()
}
