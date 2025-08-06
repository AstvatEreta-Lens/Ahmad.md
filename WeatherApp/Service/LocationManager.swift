import Foundation
import CoreLocation

// MARK: - Location Manager Protocol
protocol LocationManagerProtocol: ObservableObject {
    var currentLocation: CLLocationCoordinate2D? { get }
    var authorizationStatus: CLAuthorizationStatus { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    
    func requestLocation()
}

// MARK: - Location Manager Implementation
class LocationManager: NSObject, LocationManagerProtocol, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestLocation() {
        errorMessage = nil
        isLoading = true
        
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            errorMessage = "Location access denied. Please enable location services in Settings."
            isLoading = false
        @unknown default:
            errorMessage = "Unknown location authorization status."
            isLoading = false
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        isLoading = false
        guard let location = locations.first else {
            errorMessage = "Unable to get current location."
            return
        }
        
        currentLocation = location.coordinate
        errorMessage = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLoading = false
        errorMessage = "Failed to get location: \(error.localizedDescription)"
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            errorMessage = "Location access denied. Please enable location services in Settings."
            isLoading = false
        case .notDetermined:
            break
        @unknown default:
            errorMessage = "Unknown location authorization status."
            isLoading = false
        }
    }
}