//
//  Setup Default Data.swift
//  GeoHash
//
//  Created by Warren Hansen on 1/31/21.
//

import Foundation
import Firebase
import FirebaseFirestore
import GeoFire

// Populate default firebase database
class SetUpDefault {
    
    let db = Firestore.firestore()
    
    func loadDefaultFirebae() {
        autoPopulatePickups(ownerFullName: "Jen Poyer", street: "1204 Mira Mar Ave", city: "Long Beach", state: "CA", zip: "90301")
        autoPopulatePickups(ownerFullName: "Tom Lazarevich", street: "7401 Sepluveda", city: "Los Angeles", state: "CA", zip: "90045")
        autoPopulatePickups(ownerFullName: "Clint Moran", street: "625 Fair Oaks", city: "Pasadena", state: "CA", zip: "91030")
        autoPopulatePickups(ownerFullName: "Jocko Wilnick", street: "1204 Mira Mar Ave", city: "San Diego", state: "CA", zip: "92101")
        autoPopulatePickups(ownerFullName: "Eric Cardera ", street: "1 Civic Center Plaza", city: "Irvine", state: "CA", zip: "92606")
        autoPopulatePickups(ownerFullName: "VODOO Donuts", street: "22 Sw 3rd Ave", city: "Portland", state: "OR", zip: "97204")
        autoPopulatePickups(ownerFullName: "Post Office WA", street: "5706 17th Ave NW", city: "Seattle", state: "WA", zip: "98107")
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
                print("Error setting up firebase database \(error.localizedDescription)")
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

    func deleteDataBase() {
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
