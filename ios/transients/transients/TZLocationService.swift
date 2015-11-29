import Foundation
import CoreLocation


class LocationService: NSObject, CLLocationManagerDelegate {
    class var sharedInstance: LocationService {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            
            static var instance: LocationService? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = LocationService()
        }
        return Static.instance!
    }
    
    var locationManager:CLLocationManager?
    var currentLocation:CLLocation?
    var driver_id:String?
    var currentHeading:CLHeading?
    
    override init() {
        super.init()
        self.locationManager = CLLocationManager()
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager?.distanceFilter = 200
        self.locationManager?.delegate = self
    }
    
    func startUpdatingLocation() {
        print("Starting Location Updates")
        self.locationManager?.requestWhenInUseAuthorization()
        self.locationManager?.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        print("Stop Location Updates")
        self.locationManager?.stopUpdatingLocation()
    }
    
    func startUpdatingHeading(){
        print("Starting Heading Updates")
        self.locationManager?.startUpdatingHeading()
    }
    
    func stopUpdatingHeading(){
        print("Stop Heading Updates")
        self.locationManager?.stopUpdatingHeading()
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let location: AnyObject? = (locations as NSArray).lastObject
        
        self.currentLocation = location as? CLLocation
        
        // use for real time update location
        // updateLocation(self.currentLocation)
        
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        if (error != nil) {
            print("Update Location Error : \(error.description)")
        }
    }
    
    func updateLocation(currentLocation:CLLocation){
        let lat = currentLocation.coordinate.latitude
        let lon = currentLocation.coordinate.longitude
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
        self.currentHeading = newHeading
    }
    
    
}
