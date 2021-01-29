//
//  ViewController.swift
//  GeoHash
//
//  Created by Warren Hansen on 1/29/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import GeoFire

class ViewController: UIViewController {

    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }


    @IBAction func clearDatabase(_ sender: Any) {
        db.collection("pickups").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let id = document.documentID
                    print("\(id) => \(document.data())")
                    self.deleteDocBy(uuid: id)
                }
            }
        }
        
    }
    
    @IBAction func loadPickups(_ sender: Any) {
        autoPopulatePickups(ownerFullName: "Jen Poyer", street: "1204 Mira Mar Ave", city: "Long Beach", state: "CA", zip: "90301")
        autoPopulatePickups(ownerFullName: "Tom Lazarevich", street: "7401 Sepluveda", city: "Los Angeles", state: "CA", zip: "90045")
        autoPopulatePickups(ownerFullName: "Clint Moran", street: "625 Fair Oaks", city: "Pasadena", state: "CA", zip: "91030")
        autoPopulatePickups(ownerFullName: "Jocko Wilnick", street: "1204 Mira Mar Ave", city: "2920 Zoo Drive", state: "CA", zip: "92101")
        autoPopulatePickups(ownerFullName: "Eric Cardera ", street: "1 Civic Center Plaza", city: "Irvine", state: "CA", zip: "92606")
        autoPopulatePickups(ownerFullName: "VODOO Donuts", street: "22 Sw 3rd Ave", city: "Portland", state: "OR", zip: "97204")
    }
    
    func autoPopulatePickups( ownerFullName:String, street: String, city: String, state: String, zip: String) {

        let address = "\(street), \(city) \(state) \(zip)"
        let id = UUID().uuidString
        var locatn: (Lat: Double, Lon: Double, Geo: String) = (0.0,0.0,"")
        let fulAddress = "\(street) \t\(city), \(state) \t\(zip)"
        LocationFire.getCoordFrom(address: fulAddress, zip: zip, debug: false) { (coordinates) in
            guard let lat = coordinates?.Lat, let lon = coordinates?.Lon, let geo = coordinates?.Geo else { return }
            locatn.Lat = lat
            locatn.Lon = lon
            locatn.Geo = geo
        
            let pickup =  PickUps(id: id, userUID: id, date: Date(), notes: "A note.", employeeUID: "NA", completed: false, employeeFullName: nil, emplyeeTotalPickUps: nil, employeeImgUrl: nil, ownerImgUrl: nil, isRecurring: false, ownerAddress: address, ownerFullName: "", transferGroup: "NA", stripeConAcct: "NA", ownerLat:  locatn.Lat, ownerLon: locatn.Lon, ownerGeoHash: "NA")
            self.createFirestorePickUp(pickUp: pickup)
        }
    }
    
    func createFirestorePickUp(pickUp: PickUps) {
        let newPickupRef = Firestore.firestore().collection("pickups").document(pickUp.id)
        print("have fs ref for new pickups \(newPickupRef.documentID)")
        let data = PickUps.modelToData(pickUps: pickUp)
        print("have data \(data)")
        print(data.debugDescription)

        newPickupRef.setData(data) { (error) in
            if let error = error {
                Auth.auth().handleFireAuthError(error: error, vc: self)
                return
            }
            print("created firestore pickup doc for \(pickUp.date)nnow segue")
            self.updateGeoHash(pickUp: pickUp)
        }
    }
    func updateGeoHash(pickUp: PickUps) {
        let location = CLLocationCoordinate2D(latitude: pickUp.ownerLat, longitude: pickUp.ownerLon)
        let hash = GFUtils.geoHash(forLocation: location)
        let documentData: [String: Any] = [
            "geohash": hash,
            "lat": pickUp.ownerLat,
            "lng":  pickUp.ownerLon
        ]

        let londonRef = db.collection("pickups").document(pickUp.id)
        londonRef.updateData(documentData) { error in
            if let error = error {
                print("We had an error updating geohash \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func clearDistanceFilter(_ sender: Any) {
    }
    
    @IBAction func filterOne(_ sender: Any) {
    }
    
    @IBAction func filterTwo(_ sender: Any) {
    }
    
    func deleteDocBy(uuid:String) {
        db.collection("pickups").document(uuid).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("\(uuid) successfully removed!")
            }
        }
    }
}



class LocationFire {
    
   // let response: (Lat: CLLocationDegrees?, Lon: CLLocationDegrees?, Geo: String?)
    
    class func getCoordFrom(address: String, zip: String, debug: Bool, callback: @escaping ((Lat: CLLocationDegrees?, Lon: CLLocationDegrees?, Geo: String?)?) -> ()) {
        CLGeocoder().geocodeAddressString(address, completionHandler: { placemarks, error in
            if (error != nil) {
                print("error getting placemarks")
                return
            }
            let answer = decodePlaceMarks(placemarks: placemarks)
           
            if answer.Lat == 0.0 {
                print("get gps coord from zip")
                CLGeocoder().geocodeAddressString(zip, completionHandler: { placemarks, error in
                    if (error != nil) {
                        return
                    }
                    let answerZip = decodePlaceMarks(placemarks: placemarks)
                    callback(answerZip)
                })
            } else {
                print("got gps coord from address")
                callback(answer)
            }
        })
    }
    
    class func decodePlaceMarks(placemarks: [CLPlacemark]?) -> (Lat: CLLocationDegrees?, Lon: CLLocationDegrees?, Geo: String?) {
        var answer: (Lat: CLLocationDegrees?, Lon: CLLocationDegrees?, Geo: String?)
        let debug = true
        if let placemark = placemarks?[0],
            let lat = placemark.location?.coordinate.latitude,
            let lon = placemark.location?.coordinate.longitude {
            // prior call to get geohash
              // let geoHash = Geohash.encode(latitude: lat, longitude: lon, length: 10)
            // new call to firestore utils
            let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let geoHash = GFUtils.geoHash(forLocation: location)
            if debug {
                let lats = String(format: "%.04f", lat)
                let lons = String(format: "%.04f", lon)
                let name = placemark.name!
                let country = placemark.country!
                let region = placemark.administrativeArea!
                print("\(lats),\(lons)\n\(name),\(region) \(country) GeoHash: \(geoHash)")
            }
            answer = (placemark.location?.coordinate.latitude, placemark.location?.coordinate.longitude, geoHash )
        }
        return answer
    }
}
