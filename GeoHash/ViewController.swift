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
    }
    
    @IBAction func clearDistanceFilter(_ sender: Any) {
    }
    
    @IBAction func filterOne(_ sender: Any) {
    }
    
    @IBAction func filterTwo(_ sender: Any) {
    }
    
    func deleteDocBy(uuid:String) {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let tradesRef = ref.child("pickups").child(uuid)
        tradesRef.removeValue { error, _ in
            if error != nil {
                print("Error deleteing post\n \(String(describing: error?.localizedDescription))")
            }
        }
    }
}

