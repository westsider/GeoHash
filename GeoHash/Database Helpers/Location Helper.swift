//
//  Location Helper.swift
//  GeoHash
//
//  Created by Warren Hansen on 1/31/21.
//

import Foundation
import GeoFire

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
