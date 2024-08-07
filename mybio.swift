import SwiftUI
import LocalAuthentication
import CoreLocation

class AppState: ObservableObject {
    @Published var isSignedUp = false
    @Published var isLoggedIn = false
    @Published var isBiometricRegistered = false
    @Published var hasCheckedInToday = false
    @Published var checkInDate: Date? = nil
    @Published var checkInLocation: CLLocation? = nil
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    func isLocationWithinOffice(location: CLLocation) -> Bool {
        // Office location coordinates
        let officeLocation = CLLocation(latitude: 37.7749, longitude: -122.4194) // Example coordinates
        let distance = location.distance(from: officeLocation)
        return distance < 100.0 // 100 meters threshold
    }
}

extension AppState {
    func registerBiometric(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Register your biometric for check-in/check-out"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
                DispatchQueue.main.async {
                    if success {
                        self.isBiometricRegistered = true
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
        } else {
            completion(false)
        }
    }
    
    func verifyBiometric(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to check in/out"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
                DispatchQueue.main.async {
                    completion(success)
                }
            }
        } else {
            completion(false)
        }
    }
}


struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            if !appState.isSignedUp {
                SignupView()
            } else if !appState.isLoggedIn {
                LoginView()
            } else {
                HomeView()
            }
        }
    }
}

struct SignupView: View {
    @EnvironmentObject var appState: AppState
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                appState.isSignedUp = true
            }) {
                Text("Sign Up")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                appState.isLoggedIn = true
            }) {
                Text("Log In")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var locationManager = LocationManager()
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack {
            Button(action: checkIn) {
                Text("Check-In")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Button(action: checkOut) {
                Text("Check-Out")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Notification"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    func checkIn() {
        if !appState.isBiometricRegistered {
            appState.registerBiometric { success in
                if success {
                    alertMessage = "Biometric registered successfully."
                } else {
                    alertMessage = "Failed to register biometric."
                }
                showAlert = true
            }
        } else {
            appState.verifyBiometric { success in
                if success {
                    if appState.hasCheckedInToday {
                        alertMessage = "You have already checked in today."
                    } else if let currentLocation = locationManager.currentLocation, locationManager.isLocationWithinOffice(location: currentLocation) {
                        appState.hasCheckedInToday = true
                        appState.checkInDate = Date()
                        alertMessage = "Check-in successful."
                    } else {
                        alertMessage = "You are not at the office location."
                    }
                } else {
                    alertMessage = "Biometric authentication failed."
                }
                showAlert = true
            }
        }
    }
    
    func checkOut() {
        if !appState.isBiometricRegistered {
            appState.registerBiometric { success in
                if success {
                    alertMessage = "Biometric registered successfully."
                } else {
                    alertMessage = "Failed to register biometric."
                }
                showAlert = true
            }
        } else {
            appState.verifyBiometric { success in
                if success {
                    if !appState.hasCheckedInToday {
                        alertMessage = "You have not checked in today."
                    } else {
                        appState.hasCheckedInToday = false
                        alertMessage = "Check-out successful."
                    }
                } else {
                    alertMessage = "Biometric authentication failed."
                }
                showAlert = true
            }
        }
    }

}
