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
         ownerGeoHash: String = ""
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
            "stripeConAcct" : pickUps.stripeConAcct
//            "lat" : pickUps.ownerLat,
//            "lgn" : pickUps.ownerLon,
//            "geohash" : pickUps.ownerGeoHash,
//            "l" : pickUps.geoPoint
        ]
        return data
    }
}

extension PickUps : Equatable {
    static func ==(lhs: PickUps, rhs : PickUps ) -> Bool {
        return lhs.date == rhs.date
    }
}
