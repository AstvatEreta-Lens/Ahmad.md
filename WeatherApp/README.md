# Weather App - SwiftUI + MVVM + Open-Meteo API

A beautiful and modern weather application built with SwiftUI using the MVVM architecture pattern. The app fetches real-time weather data from the Open-Meteo API and displays it with dynamic backgrounds that change based on weather conditions.

## Features

- 🌤️ **Real-time Weather Data**: Fetches current weather information using the Open-Meteo API
- 📍 **Location-based**: Automatically gets weather for your current location
- 🎨 **Dynamic Backgrounds**: Beautiful gradient backgrounds that change based on weather conditions
- 📱 **Modern UI**: Clean, intuitive SwiftUI interface with smooth animations
- 🏗️ **MVVM Architecture**: Well-structured code following MVVM pattern
- 🧪 **Comprehensive Testing**: Unit tests for both service layer and view model
- 🔄 **Pull to Refresh**: Easy weather data refresh functionality

## Screenshots

The app features different background gradients for various weather conditions:
- ☀️ Clear skies: Blue to yellow gradient
- 🌧️ Rain: Gray to blue gradient  
- ❄️ Snow: White to light blue gradient
- ⛈️ Thunderstorm: Dark to purple gradient
- 🌫️ Fog: Gray to white gradient

## Architecture

The project follows the **MVVM (Model-View-ViewModel)** pattern with clear separation of concerns:

```
WeatherApp/
├── Model/
│   ├── WeatherData.swift          # Data models for API response
│   └── WeatherCondition.swift     # Weather condition enum with UI properties
├── View/
│   └── ContentView.swift          # Main SwiftUI view
├── ViewModel/
│   └── WeatherViewModel.swift     # Business logic and state management
├── Service/
│   ├── WeatherService.swift       # Network service for API calls
│   └── LocationManager.swift      # Location services management
├── Tests/
│   ├── WeatherServiceTests.swift  # Unit tests for service layer
│   └── WeatherViewModelTests.swift # Unit tests for view model
└── WeatherApp.swift               # App entry point
```

## API Integration

The app uses the **Open-Meteo API**, which provides:
- Free weather data without API key requirements
- High-quality meteorological data
- Global coverage
- Real-time and forecast data

### API Endpoint
```
https://api.open-meteo.com/v1/forecast
```

### Weather Code Mapping
The app maps Open-Meteo weather codes to readable conditions:
- `0`: Clear
- `1-2`: Partly Cloudy  
- `3`: Cloudy
- `45,48`: Fog
- `51,53,55`: Drizzle
- `61,63,65`: Rain
- `71,73,75`: Snow
- `95,96,99`: Thunderstorm

## Requirements

- iOS 16.0+ / macOS 13.0+
- Xcode 15.0+
- Swift 5.9+

## Installation & Setup

1. **Clone the repository**
```bash
git clone <repository-url>
cd WeatherApp
```

2. **Open in Xcode**
```bash
open WeatherApp.xcodeproj
```

3. **Run the app**
   - Select your target device/simulator
   - Press `Cmd + R` to build and run

4. **Grant Location Permission**
   - When prompted, allow location access to get weather for your current location

## Testing

The project includes comprehensive unit tests for both the service layer and view model.

### Run Tests
```bash
# In Xcode
Cmd + U

# Or via command line
swift test
```

### Test Coverage
- **WeatherServiceTests**: Tests API calls, error handling, and data parsing
- **WeatherViewModelTests**: Tests business logic, state management, and data binding

## Usage

1. **Launch the app** - The app will automatically request location permission
2. **Allow location access** - Grant permission to get weather for your current location  
3. **View weather data** - See current temperature, conditions, and daily highs/lows
4. **Refresh data** - Tap the refresh button to update weather information
5. **Enjoy dynamic backgrounds** - Watch the background change based on weather conditions

## Key Components

### WeatherService
- Handles all network requests to Open-Meteo API
- Implements proper error handling
- Uses modern async/await patterns
- Includes comprehensive unit tests

### WeatherViewModel
- Manages app state and business logic
- Handles location permissions and requests
- Provides computed properties for UI binding
- Implements proper error handling and loading states

### ContentView
- Modern SwiftUI interface
- Dynamic background gradients
- Responsive design for different screen sizes
- Smooth animations and transitions

### LocationManager
- Handles Core Location integration
- Manages location permissions
- Provides real-time location updates

## Error Handling

The app includes robust error handling for:
- Network connectivity issues
- Location permission denied
- API response errors
- JSON parsing failures
- Invalid coordinates

## Future Enhancements

Potential features for future versions:
- 7-day weather forecast
- Weather alerts and notifications
- Multiple location support
- Weather maps integration
- Widget support
- Apple Watch companion app

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is open source and available under the [MIT License](LICENSE).

## Acknowledgments

- [Open-Meteo](https://open-meteo.com/) for providing free weather API
- Apple for SwiftUI framework and design guidelines
- Weather icons using SF Symbols

---

Built with ❤️ using SwiftUI and MVVM architecture