import SwiftUI
import MapKit
import Foundation
import CoreLocation

struct Overview: Identifiable {
    let id = UUID()
    let date: String
    let headline: String
    let rows: [OverviewRow]
}

struct OverviewRow: Identifiable {
    let id = UUID()
    let showImage: Bool
    let image: Image
    let text: String
}

struct Credits: Identifiable {
    let id = UUID()
    let text: String
    let link: String
}

struct Texte {
    var startPage: String
    let creditsHeader: String
    let homepageForst: String
    var welcomeHeader: String
    let appMainTitle: String
    let appSubTitle: String
    let appDate: String
}

struct KerweLocation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let opening: String
    let homepage: String
    let description: String
    let image: Image
    let imageColor: Color
    /*
    init(name: String, coordinate: CLLocationCoordinate2D, opening: String,homepage:String,description: String, image:Image,imageColor:Color) {
        self.name = name
        self.coordinate = coordinate
        self.opening = opening
        self.homepage = homepage
        self.description = description
        self.image = image
        self.imageColor = imageColor
    }
     */
}

// set the default location in preview Modes
let defaultLocation = KerweLocation(name: "Zum Schockelgaul", coordinate: CLLocationCoordinate2D(latitude: 49.428064, longitude: 8.188584), opening: "Do-Mo 17:00", homepage: "www.zum-schockelgaul.de", description: "Cordon bleu. Pfälzer Spezialitäten. Forster Weine.",image: Image(systemName: "1.square.fill"),imageColor: .green)

/// Helper class for current User position on Map
final class LocationManager: NSObject, ObservableObject {
    @Published var location: CLLocation?
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        // Publish new location to UI
      //  print(location.coordinate)
        if regionInitiated == false {
            DispatchQueue.main.async {
                self.location = location
            }    
        }
      }
}

extension MKCoordinateRegion {    
    static func forstRegion() -> MKCoordinateRegion {
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 49.428064, longitude:  8.188584), latitudinalMeters: 750, longitudinalMeters: 750)
      //  MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 53.428064, longitude:  9.188584), latitudinalMeters: 750, longitudinalMeters: 750)
        
    }
    
    func getBinding() -> Binding<MKCoordinateRegion>? {
        return Binding<MKCoordinateRegion>(.constant(self))
    }
}

var regionInitiated = false
var initialLocation = MKCoordinateRegion.forstRegion()
let displayCloseButton = false

// Colordefinitions
let forstColor = Color(uiColor: UIColor.hexStringToUIColor(hex: "#3b7c45"))
let headerColor = Color.white
let standColor = forstColor
let restaurantColor = Color(uiColor: UIColor.hexStringToUIColor(hex: "#3b7c45"))
let infoColor = Color.blue
let mealsColor = Color(uiColor: UIColor.hexStringToUIColor(hex: "#8BA259"))

// Fontdefinitions
let headerFont = Font.custom("TimesNewRomanPS-BoldMT", size:24.0)//Font.custom("Rockwell-Regular", size:22.0)
let introFont:Font = .body//Font.custom("HelveticaNeue", size:17.0)//Font.custom("Rockwell-Regular", size:18.0)
let timeFont:Font = Font.custom("HelveticaNeue-Thin", size:17.0)

