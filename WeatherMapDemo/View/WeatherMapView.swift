//
//  ContentView.swift
//  WeatherMapDemo
//
//  Created by Arbab Nawaz on 9/12/24.
//

import SwiftUI
//import CoreLocation
//import CoreLocationUI

struct WeatherMapView: View {
    @ObservedObject var coordinator: WeatherMapViewCoordinator
    @StateObject var locationManager = LocationManager()
    @State var showError: Bool = false

    var body: some View {
        return NavigationStack (path: $coordinator.path) {
            VStack {
                Group {
                    HStack {
                        VStack {
                            Text("Hello there!!\n") +
                            Text("Welcome back!").bold().foregroundColor(.pink)  +
                            Text("Will ").italic().foregroundColor(.orange)
                        }.font(.headline)
                        Spacer()
                        if let location = locationManager.location {
                            Text("Your location:\n__\(location.latitude), \(location.longitude)__")
                        }
                    }.padding([.leading, .trailing],10)
                    WeatherView(viewModel: coordinator.viewModel)
                }
            }
            .overlay {
                if showError {
                    VStack {
                        ErrorView(error: coordinator.viewModel.error, show: $showError)
                            .frame(maxHeight: 150)
                        Spacer()
                    }.transition(.move(edge: .top))
                }
            }
            .transition(.move(edge: .top))

            .navigationTitle("Weather Demo")
            .navigationBarTitleDisplayMode(.large)
        }
        .animation(.default, value: showError)
        .onAppear(perform: {
            print("Fetching user location")
            let cityName = UserDefaults.standard.string(forKey: "CityName")
            // Send to get the weather for the last saved cityName 
                coordinator.viewModel.searchText = cityName ?? ""
            Task { await coordinator.viewModel.loadData() }
            // Still go ahead to find the current city Name
            locationManager.requestAuthorization()
        })
        .onReceive(coordinator.viewModel.$error) { newVal in
            showError = newVal != nil
        }
        .onChange(of: locationManager.cityName) { oldValue, newValue in
            print("Got user city")
            let cityName = UserDefaults.standard.string(forKey: "CityName")
            if newValue != cityName {
                // Store and send to fetch the new weather data for the city
                print(" user city changed from the last time")
                UserDefaults.standard.set(newValue, forKey: "CityName")
                coordinator.viewModel.searchText = newValue ?? ""
                Task { await coordinator.viewModel.loadData() }
            }
        }
//        .alert(NSError(domain: "Invalid Url", code: -1, userInfo: nil).description, isPresented: $showError) {
//            ErrorView(error: NSError(domain: "Invalid Url", code: -1, userInfo: nil), show: $showError)
//        }
    }
}



struct WeatherView: View {
    @ObservedObject var viewModel: WeatherMapViewModel
    var body: some View {
        VStack {
            HStack {
                CustomTextField(placeholder: "Search", text: $viewModel.searchText)
                    .accessibilityIdentifier(AccessiblityIdentifiers.WeatherView.searchTextField)
                    .textFieldStyle(.roundedBorder)
                    .foregroundColor(.red)
                    .autocapitalization(.words)
                    .padding([.leading, .trailing], 7 )
                    .padding([.top, .bottom], 8 )
                    .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.green, lineWidth: 2)
                    )
                    .onAppear(perform: {
                        UITextField.appearance().clearButtonMode = .whileEditing
                    })
                    .buttonBorderShape(.capsule)

                Button {
                    Task { await viewModel.loadData() }
                } label: {
                    Text ("Search")
                        .bold()
                        .foregroundColor(.black)
                        .padding(10)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .opacity(viewModel.isLoading ? 0.5: 1.0)
                        .background(.white)
                        .cornerRadius(10)
                }.disabled(viewModel.isLoading)
                .accessibilityIdentifier(AccessiblityIdentifiers.WeatherView.searchButton)
                .fixedSize()
            }
            .padding(5)
            if viewModel.isLoading {
                ProgressView {
                    Text("Loading")
                        .foregroundColor(.green)
                        .bold()
                } 
                .padding(/*@START_MENU_TOKEN@*/EdgeInsets()/*@END_MENU_TOKEN@*/)
                .progressViewStyle(.circular)
                .tint(.green)
            }
            List {
                ForEach(viewModel.results, id: \.id) { result in
                    WeatherCityView(result: WeatherCityViewModel(model: result))
                        .listRowBackground(Color.green)
                }
            }
            .listStyle(.insetGrouped)
        }
        .onKeyPress(action: { keyPress in
            print("""
                New key event:
                Key: \(keyPress.characters)
                Modifiers: \(keyPress.modifiers)
                Phase: \(keyPress.phase)
                Debug description: \(keyPress.debugDescription)
            """)
            if keyPress.key == .return {
                Task { await viewModel.loadData() }
            }
            return .ignored
        })
    }
}

#Preview {
    WeatherMapView(coordinator: WeatherMapViewCoordinator())
}

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    
    @State private var width = CGFloat.zero
    @State private var labelWidth = CGFloat.zero
    
    var body: some View {
        TextField(placeholder, text: $text)
            .foregroundColor(.gray)
            .font(.system(size: 20))
            .padding(EdgeInsets(top: 15, leading: 10, bottom: 15, trailing: 10))
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .trim(from: 0, to: 0.55)
                        .stroke(.gray, lineWidth: 1)
                    RoundedRectangle(cornerRadius: 5)
                        .trim(from: 0.565 + (0.44 * (labelWidth / width)), to: 1)
                        .stroke(.gray, lineWidth: 1)
                    Text(placeholder)
                        .foregroundColor(.gray)
                        .overlay( GeometryReader { geo in Color.clear.onAppear { labelWidth = geo.size.width }})
                        .padding(2)
                        .font(.caption)
                        .frame(maxWidth: .infinity,
                               maxHeight: .infinity,
                               alignment: .topLeading)
                        .offset(x: 20, y: -10)
                    
                }
            }
            .overlay( GeometryReader { geo in Color.clear.onAppear { width = geo.size.width }})
            .onChange(of: width) { _,_ in
                print("Width: ", width)
            }
            .onChange(of: labelWidth) { _,_ in
                print("labelWidth: ", labelWidth)
            }
    }
}



extension CustomTextField {
    func modify<T: View>(@ViewBuilder _ modifier: (Self) -> T) -> some View {
        return modifier(self)
    }

    
}


struct TextInputField: View {
    let placeHolder: String
    @Binding var textValue: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            Text(placeHolder)
                .foregroundColor(Color(.placeholderText))
                .offset(y: textValue.isEmpty ? 0 : -25)
                .scaleEffect(textValue.isEmpty ? 1: 0.8, anchor: .leading)
            TextField("", text: $textValue)
        }
        .padding(.top, textValue.isEmpty ? 0 : 15)
        .frame(height: 52)
        .padding(.horizontal, 16)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(lineWidth: 1).foregroundColor(.gray))
        .animation(.default, value: textValue)
    }
}
