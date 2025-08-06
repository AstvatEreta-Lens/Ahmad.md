import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WeatherViewModel()
    
    var body: some View {
        ZStack {
            // Dynamic Background
            viewModel.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    headerView
                    
                    // Main Weather Content
                    if viewModel.isLoading {
                        loadingView
                    } else if let errorMessage = viewModel.errorMessage {
                        errorView(errorMessage)
                    } else if viewModel.weatherResponse != nil {
                        weatherContentView
                    } else {
                        welcomeView
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.loadWeather()
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Weather App")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(viewModel.locationText)
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.top, 20)
    }
    
    // MARK: - Weather Content View
    private var weatherContentView: some View {
        VStack(spacing: 40) {
            // Main Weather Display
            VStack(spacing: 20) {
                // Weather Icon
                Image(systemName: viewModel.weatherIcon)
                    .font(.system(size: 120))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                
                // Temperature
                Text(viewModel.currentTemperature)
                    .font(.system(size: 72, weight: .thin))
                    .foregroundColor(.white)
                
                // Weather Condition
                Text(viewModel.currentCondition.rawValue)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
            }
            
            // Additional Info Card
            weatherInfoCard
            
            // Refresh Button
            refreshButton
        }
    }
    
    // MARK: - Weather Info Card
    private var weatherInfoCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Today's Weather")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            
            if let weather = viewModel.weatherResponse {
                HStack(spacing: 30) {
                    weatherInfoItem(
                        title: "High",
                        value: String(format: "%.0f°", weather.daily.temperature2mMax.first ?? 0),
                        icon: "thermometer.sun"
                    )
                    
                    weatherInfoItem(
                        title: "Low",
                        value: String(format: "%.0f°", weather.daily.temperature2mMin.first ?? 0),
                        icon: "thermometer.snowflake"
                    )
                    
                    weatherInfoItem(
                        title: "Condition",
                        value: viewModel.currentCondition.rawValue,
                        icon: viewModel.weatherIcon
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Weather Info Item
    private func weatherInfoItem(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Text(value)
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
            
            Text("Loading weather...")
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.top, 100)
    }
    
    // MARK: - Error View
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.white)
            
            Text("Oops!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(message)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                viewModel.loadWeather()
            }
            .buttonStyle(WeatherButtonStyle())
        }
        .padding(.top, 50)
    }
    
    // MARK: - Welcome View
    private var welcomeView: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.circle")
                .font(.system(size: 60))
                .foregroundColor(.white)
            
            Text("Welcome!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Tap the button below to get weather for your location.")
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Button("Get Weather") {
                viewModel.loadWeather()
            }
            .buttonStyle(WeatherButtonStyle())
        }
        .padding(.top, 50)
    }
    
    // MARK: - Refresh Button
    private var refreshButton: some View {
        Button(action: {
            viewModel.refreshWeather()
        }) {
            HStack {
                Image(systemName: "arrow.clockwise")
                Text("Refresh")
            }
            .font(.body)
            .fontWeight(.medium)
        }
        .buttonStyle(WeatherButtonStyle())
        .disabled(viewModel.isLoading)
    }
}

// MARK: - Custom Button Style
struct WeatherButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}