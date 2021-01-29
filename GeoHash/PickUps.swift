//
//  PickUps.swift
//  GeoHash
//
//  Created by Warren Hansen on 1/29/21.
//

import Foundation
import Firebase
import FirebaseFirestore

struct PickUps: Decodable {
    var id: String
    var userUID: String
    var date: Date
    var notes: String
    var employeeUID: String? // needs to be an object
    var completed: Bool
    var employeeFullName: String?
    var emplyeeTotalPickUps: Int?
    var employeeImgUrl: String?
    var ownerImgUrl: String?
    var isRecurring: Bool
    var ownerAddress: String
    var ownerFullName: String
    var transferGroup: String
    var stripeConAcct: String
    var ownerLat: Double
    var ownerLon: Double
    var ownerGeoHash: String
    var geoPoint : String
    
    init(id: String = "",
         userUID: String = "",
         date: Date = Date(),
         notes: String = "",
         employeeUID: String? = nil,
         completed: Bool = false,
         employeeFullName: String? = nil,
         emplyeeTotalPickUps: Int? = nil,
         employeeImgUrl: String? = nil,
         ownerImgUrl: String? = nil,
         isRecurring: Bool = false,
         ownerAddress: String = "",
         ownerFullName: String = "",
         transferGroup: String = "",
         stripeConAcct: String = "",
         ownerLat: Double = 0.0,
         ownerLon: Double = 0.0,
         ownerGeoHash: String = "",
         geoPoint:  String = ""
    ) {
        self.id = id
        self.userUID = userUID
        self.date = date
        self.notes = notes
        self.employeeUID = employeeUID
        self.completed = completed
        self.employeeFullName = employeeFullName
        self.emplyeeTotalPickUps = emplyeeTotalPickUps
        self.employeeImgUrl = employeeImgUrl
        self.ownerImgUrl = ownerImgUrl
        self.isRecurring = isRecurring
        self.ownerAddress = ownerAddress
        self.ownerFullName = ownerFullName
        self.transferGroup = transferGroup
        self.stripeConAcct = stripeConAcct
        self.ownerLat = ownerLat
        self.ownerLon = ownerLon
        self.ownerGeoHash = ownerGeoHash
        self.geoPoint = geoPoint
    }
    
    init(data: [String : Any]) {
        id = data["id"] as? String ?? ""
        userUID = data["userUID"] as? String ?? ""
        if let stamp = data["date"] as? Timestamp  {
            date = stamp.dateValue()
        } else {
            // the fail is to add a date 2 years out in case this is a bug
            //MARK: - TODO:- Force unwrap
            date = data["date"] as? Date ?? Calendar.current.date(byAdding: .year, value: 2, to: Date())!
        }
        notes = data["notes"] as? String ?? ""
        employeeUID = data["employeeUID"] as? String ?? ""
        completed = data["completed"] as? Bool ?? false
        employeeFullName = data["employeeFullName"] as? String ?? ""
        emplyeeTotalPickUps = data["emplyeeTotalPickUps"] as? Int ?? 0
        employeeImgUrl = data["employeeImgUrl"] as? String ?? ""
        ownerImgUrl = data["ownerImgUrl"] as? String ?? ""
        isRecurring = data["isRecurring"] as? Bool ?? false
        ownerAddress = data["ownerAddress"] as? String ?? ""
        ownerFullName = data["ownerFullName"] as? String ?? ""
        transferGroup = data["transferGroup"] as? String ?? ""
        stripeConAcct = data["stripeConAcct"] as? String ?? ""
        ownerLat = data["lat"] as? Double ?? 0.0
        ownerLon = data["lgn"] as? Double ?? 0.0
        ownerGeoHash = data["geohash"] as? String ?? "no account"
        geoPoint = data["l"] as? String ?? "no account"
    }
    
    static func modelToData(pickUps: PickUps) -> [String: Any] {
        let data : [String: Any] = [
            "id"  : pickUps.id,
            "userUID" : pickUps.userUID,
            "date" : Timestamp(date: pickUps.date),
            "notes" : pickUps.notes,
            "employeeUID"  : pickUps.employeeUID ?? "",
            "completed"  : pickUps.completed,
            "employeeFullName" : pickUps.employeeFullName ?? "",
            "emplyeeTotalPickUps"  : pickUps.emplyeeTotalPickUps ?? "",
            "employeeImgUrl"  : pickUps.employeeImgUrl ?? "",
            "ownerImgUrl"  : pickUps.ownerImgUrl ?? "",
            "isRecurring" : pickUps.isRecurring,
            "ownerAddress" : pickUps.ownerAddress,
            "ownerFullName" : pickUps.ownerFullName,
            "transferGroup" : pickUps.transferGroup,
            "stripeConAcct" : pickUps.stripeConAcct,
            "lat" : pickUps.ownerLat,
            "lgn" : pickUps.ownerLon,
            "geohash" : pickUps.ownerGeoHash,
            "l" : pickUps.geoPoint
        ]
        return data
    }
}

extension PickUps : Equatable {
    static func ==(lhs: PickUps, rhs : PickUps ) -> Bool {
        return lhs.date == rhs.date
    }
    
    static func parseFireStorePickupfrom(dictionary: [String : Any], debug: Bool) -> [PickUps]? {
        var pickUps:[PickUps] = []
        guard let _querySnapshot =  dictionary["_querySnapshot"] as? NSDictionary else { return nil}
        if debug {
            print("_querySnapshot:\n\(_querySnapshot)")
            print("---------------------------------\n")
        }
        guard let docs = _querySnapshot["docs"] as? NSArray else { return nil}
        
        for  document in docs {
            if let pickUp = parseFirestoreJson(document: document as! NSDictionary, debug: debug) {
                if pickUp.employeeUID == "none" {
                    pickUps.append(pickUp)
                }
                
            }
        }
        return pickUps
    }
    
    static func parseFirestoreJson(document: NSDictionary, debug: Bool) -> PickUps?  {
        if debug { print("\n---------------------------------\n") }
        guard let allFeilds =  document["_fieldsProto"] as? NSDictionary  else { return nil }
        if debug {
            print("_fieldsProto:\n \(allFeilds)")
            print("---------------------------------\n")
            
            print("\n---------------------------------")
        }
        
        guard let ownerFullName =  allFeilds["ownerFullName"] as? NSDictionary  else { return nil }
        guard let ownerFullName2 =  ownerFullName["stringValue"] as? String  else { return nil }
        if debug { print("ownerFullName: \(ownerFullName2)") }
        
        guard let ownerAddress =  allFeilds["ownerAddress"] as? NSDictionary  else { return nil }
        guard let ownerAddress2 =  ownerAddress["stringValue"] as? String  else { return nil }
        if debug { print("ownerAddress: \(ownerAddress2)") }
        
        guard let date =  allFeilds["date"] as? NSDictionary  else { return nil }
        guard let timestampValue =  date["timestampValue"]   as? NSDictionary else { return nil }
        guard let seconds =  timestampValue["seconds"] as? NSMutableString else { return nil }
        let dblDate = seconds.doubleValue
        let strDate = DateHelp.convertTimestamp(serverTimestamp: dblDate)
        if debug { print("date: \(strDate)") }
        let dateSwift = DateHelp.convert1970toDate(serverTimestamp: dblDate)
        if debug { print("date swift: \(dateSwift)") }
        guard let ownerLat =  allFeilds["ownerLat"] as? NSDictionary  else { return nil }
        guard let ownerLat2 =  ownerLat["doubleValue"] as? Double  else { return nil }
        if debug { print("ownerLat: \(ownerLat2)") }
        
        guard let ownerLon =  allFeilds["ownerLon"] as? NSDictionary  else { return  nil}
        guard let ownerLon2 =  ownerLon["doubleValue"] as? Double  else { return  nil}
        if debug { print("ownerLon: \(ownerLon2)") }
       
        
        
        guard let ownerImgUrl =  allFeilds["ownerImgUrl"] as? NSDictionary  else { return  nil}
        guard let ownerImgUrl2 =  ownerImgUrl["stringValue"] as? String  else { return  nil}
        if debug { print("ownerImgUrl: \(ownerImgUrl2)") }
        
        guard let userUID =  allFeilds["userUID"] as? NSDictionary  else { return  nil}
        guard let userUID2 =  userUID["stringValue"] as? String  else { return nil }
        if debug { print("userUID: \(userUID2)") }
        
        guard let id =  allFeilds["id"] as? NSDictionary  else { return  nil}
        guard let id2 =  id["stringValue"] as? String  else { return  nil}
        if debug { print("id: \(id2)") }
        
        guard let notes =  allFeilds["notes"] as? NSDictionary  else { return  nil}
        guard let notes2 =  notes["stringValue"] as? String  else { return nil }
        if debug { print("notes: \(notes2)") }
        
        guard let employeeUID =  allFeilds["employeeUID"] as? NSDictionary  else { return nil }
        guard let employeeUID2 =  employeeUID["stringValue"] as? String  else { return nil }
        if debug { print("employeeUID: \(employeeUID2)") }
        
        guard let employeeFullName =  allFeilds["employeeFullName"] as? NSDictionary  else { return  nil}
        guard let employeeFullName2 =  employeeFullName["stringValue"] as? String  else { return  nil}
        if debug {  print("employeeFullName: \(employeeFullName2)") }
        
        guard let transferGroup =  allFeilds["transferGroup"] as? NSDictionary  else { return  nil}
        guard let transferGroup2 =  transferGroup["stringValue"] as? String  else { return  nil}
        if debug { print("transferGroup: \(transferGroup2)") }
        
        guard let ownerGeoHash =  allFeilds["g"] as? NSDictionary  else { return  nil}
        guard let ownerGeoHash2 =  ownerGeoHash["stringValue"] as? String  else { return  nil}
        if debug { print("ownerGeoHash: \(ownerGeoHash2)") }
        
        guard let geoPointValue =  allFeilds["l"] as? NSDictionary  else { return  nil}
        if debug { debugPrint(geoPointValue) }
        guard let geoPointValue2 =  geoPointValue["geoPointValue"] as? NSDictionary else { return nil }
        if debug { debugPrint(geoPointValue2) }
        guard let latitude =  geoPointValue2["latitude"] as? Double  else { return nil }
        if debug { print(latitude) }
        guard let longitude =  geoPointValue2["longitude"] as? Double  else { return  nil}
        if debug { print(longitude) }
        let geoPoint = "bullshot uneeded"
        if debug { print("geoPoint: \(geoPoint)") }
        if debug { print("---------------------------------\n") }
        let pickUp = PickUps(id: id2, userUID: userUID2, date: dateSwift, notes: notes2, employeeUID: employeeUID2, completed: false, employeeFullName: employeeFullName2, emplyeeTotalPickUps: nil, employeeImgUrl: nil, ownerImgUrl: ownerImgUrl2, isRecurring: false, ownerAddress: ownerAddress2, ownerFullName: ownerFullName2, transferGroup: transferGroup2, stripeConAcct: "", ownerLat: latitude, ownerLon: longitude, ownerGeoHash: ownerGeoHash2, geoPoint: geoPoint)
        if debug { debugPrint(pickUp) }
        return pickUp
    }
    
}



//class NetworkCall {
//
//    class func getGeoHashPickups(radius: Int, callback: @escaping (Dictionary<String, Any>) -> ()) {
//
//        let parameters : String   =  "lat=\(UserService.user.lat)&lon=\(UserService.user.lon)&radius=\(radius)"
//
//        guard let url = URL(string: "https://us-central1-dukie-dog.cloudfunctions.net/geoQueryWitningRadius") else { return }
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.httpBody = parameters.data(using: String.Encoding.utf8)
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//
//            guard let data = data else {
//                print("\(error.debugDescription)")
//                return
//            }
//
//            guard let json = (try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.fragmentsAllowed)) as? Dictionary<String, Any> else {
//                print("Big problems with json serialization")
//                return
//            }
//            print("\nJSON:")
//            print(json)
//            print("-------------------------------\n")
//            callback(json)
//        }
//        task.resume()
//    }
//}

