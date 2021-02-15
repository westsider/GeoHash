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

    var db : Firestore!
    var listener: ListenerRegistration!
    let setUp = SetUpDefault()
    var tasks:[(address: String, distance: String, id: String)] = []
    let miles:[Double] = [20,40,60,120,240,500,600,800,1000]
    var index = 0
    var ids = [""]
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var filterBttn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        getallDocs(radius: 2200000)
        index = miles.count - 1
        filterBttn.setTitle("\(miles[index]) miles", for: .normal)
        print("tasks count \(tasks.count)")
        refreshControl.addTarget(self, action:  #selector(sortArray), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func sortArray() {
    print("sorting")
        print("tasks count \(tasks.count)")
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    @IBAction func filterOne(_ sender: Any) {
        //getallDocs(radius: 10 * 1.60934)
        print("tasks count \(tasks.count)")
        //tableView.reloadData()
        setUp.autoPopulatePickups(ownerFullName: "Jen Poyer +", street: "1204 Mira Mar Ave", city: "Long Beach", state: "CA", zip: "90301")
    }
    
    // filter to 120 miles
    @IBAction func filterTwo(_ sender: Any) {
        ids.removeAll()
        index += 1
        if index > miles.count - 1 { index = 0}
        let convertMilesToMeters = (miles[index] * 1609.34)
        tasks.removeAll()
        
        getallDocs(radius: convertMilesToMeters)
        print("GETTING PICKUPS WITHIN \(miles[index]) miles \tFilter \(convertMilesToMeters) meters vs 1,200,200")
        filterBttn.setTitle("\(miles[index]) miles", for: .normal)
    }

    
    // Listener for firebase pickups. I have to filter the resutlts because it get called twice and I don lknpw why
    // MARK : - TODO - refactor wthout the tasks filter
    func getallDocs(radius: Double) {

        let center = CLLocationCoordinate2D(latitude: 33.9742268, longitude: -118.3947792)
        let radiusInKilometers: Double = radius
        let queryBounds = GFUtils.queryBounds(forLocation: center, withRadius: radiusInKilometers)
        let queries = queryBounds.compactMap { (any) -> Query? in
            guard let bound = any as? GFGeoQueryBounds else { return nil }
           
            return db.collection("pickups")
                .order(by: "geohash")
                .start(at: [bound.startValue])
                .end(at: [bound.endValue])
        }

        // Collect all the query results together into a single list
        func getDocumentsCompletion(snapshot: QuerySnapshot?, error: Error?) -> () {
            print("#3 getDocumentsCompletion - tasks count \(tasks.count)")
            guard let documents = snapshot?.documents else {
                print("Unable to fetch snapshot data. \(String(describing: error))")
                return
            }
            
            for document in documents {
                let lat = document.data()["lat"] as? Double ?? 0
                let lng = document.data()["lng"] as? Double ?? 0
                let ownerAddress = document.data()["ownerAddress"] as? String ?? "no address"
                let id = document.data()["id"] as? String ?? "no id"
                let coordinates = CLLocation(latitude: lat, longitude: lng)
                let centerPoint = CLLocation(latitude: center.latitude, longitude: center.longitude)

                // We have to filter out a few false positives due to GeoHash accuracy, but
                // most will match
                let distance = GFUtils.distance(from: centerPoint, to: coordinates)
                let toMiles = distance * 0.000621371
                let milesToString = String(format: "%.01f", toMiles)
                print("ownerAddress: \(ownerAddress), distance: \(milesToString) \tlat: \(lat), lng: \(lng) id: \(id)")
                
                // when i delete a document or add adoc
                
                // looking for duplicate entries
                let nextPickup = (address: "\(ownerAddress)", distance: "\(milesToString) miles", id: id)
                print("checking id: \(id) with id list of \(ids.count)")
                if ids.contains(id) {
                    guard let index = ids.firstIndex(of: id) else { return }
                    print("\t------> found dupe id \(id) at index \(index - 1) and thats \(tasks[index - 1].id)")
                    tasks[index - 1] = nextPickup
                } else {
                    if toMiles <= miles[index] {
                        tasks.append(nextPickup)
                    }
                }
                ids.append(id)
                if tasks.count > 0 {
                    tableView.reloadData()
                }
            }
            tableView.reloadData()
        }

        // After all callbacks have executed, matchingDocs contains the result. Note that this
        // sample does not demonstrate how to wait on all callbacks to complete.
        print("#1 for query in queries")
        tasks.removeAll()
        print("running \(queries.count) queries")
        for query in queries {
            
            query.addSnapshotListener { (snap, error) in
                
                if let error = error {
                    print(error.localizedDescription)
                }
                guard let documents = snap?.documents else {
                    print("Unable to fetch snapshot data. \(String(describing: error))")
                    return
                }
                
                print("#2 *** Updated 2 ***  listener found \(documents.count)")
                query.getDocuments(completion: getDocumentsCompletion)
            }
            
        }
        print("1A tasks count \(tasks.count)")
    }
    
}

extension ViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? UITableViewCell {
            cell.textLabel?.text  = tasks[indexPath.row].distance
            cell.detailTextLabel?.text = tasks[indexPath.row].address
            return cell
        }
        return UITableViewCell()
    }
    
    
}
