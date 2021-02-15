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
    var toMiles = 10.0
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if listener != nil {
            listener.remove()
        }
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
        print("#1 for query in queries running \(queries.count) queries")
        
        for query in queries {
            listener = query.addSnapshotListener { (snap, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                
                snap?.documentChanges.forEach({ (change) in
                    let data = change.document.data()
                    let newItem = self.parseData(data: data)
                    print("change type: \(change.type.rawValue)  \(change.type.hashValue)")
                    switch change.type {
                        case .added:
                            self.documentAdded(change: change, newItem: newItem)
                        case .modified:
                            self.documentModified(change: change, item: newItem)
                        case .removed:
                            self.documentRemoved(change: change)
                    }
                })
                self.tableView.reloadData()
            }
        }
        print("1A tasks count \(tasks.count)")
    }
    
    func parseData(data: [String:Any]) -> (address: String, distance: String, id: String) {
        let center = CLLocationCoordinate2D(latitude: 33.9742268, longitude: -118.3947792)
        let lat = data["lat"] as? Double ?? 0
        let lng = data["lng"] as? Double ?? 0
        let ownerAddress = data["ownerAddress"] as? String ?? "no address"
        let id = data["id"] as? String ?? "no id"
        let coordinates = CLLocation(latitude: lat, longitude: lng)
        let centerPoint = CLLocation(latitude: center.latitude, longitude: center.longitude)
        let distance = GFUtils.distance(from: centerPoint, to: coordinates)
        toMiles = distance * 0.000621371
        let milesToString = String(format: "%.01f", toMiles)
        return (address: "\(ownerAddress)", distance: "\(milesToString) miles", id: id)
    }
    
    // add pickup didnt work
    func documentAdded(change: DocumentChange, newItem: (address: String, distance: String, id: String) ) {
    
        let newIndex = Int(change.newIndex)
        print("Added Doc: \(newIndex)  ownerAddress: \(newItem.address), distance: \(newItem.distance) id: \(newItem.id)")
        if toMiles <= miles[index] {
            tasks.append(newItem)
        }
    }
    
    func documentModified(change: DocumentChange, item: (address: String, distance: String, id: String)){
        print("\t*** Modified ***")
        let oldIndex = Int(change.oldIndex)
        let newIndex = Int(change.newIndex)
        if change.newIndex == change.oldIndex {
            let indexPath = IndexPath(item: newIndex, section: 0)
            tasks[newIndex] = item
            tableView.reloadRows(at: [indexPath], with: .left)
        } else {
            tasks.remove(at: oldIndex)
            tasks.insert(item, at: newIndex)
            let indexPathOld = IndexPath(item: oldIndex, section: 0)
            let indexPathNew = IndexPath(item: newIndex, section: 0)
            tableView.moveRow(at: indexPathOld, to: indexPathNew)
        }
    }
    
    func documentRemoved(change: DocumentChange){
        print("\t*** Removed ***")
        let oldIndex = Int(change.oldIndex)
        tasks.remove(at: oldIndex)
        let indexPath = IndexPath(item: oldIndex, section: 0)
        tableView.deleteRows(at: [indexPath], with: .automatic)
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

//                if ids.contains(id) {
//                    guard let index = ids.firstIndex(of: id) else { return }
//                    if index > 0 {
//                    print("\t------> found dupe id \(id) at index \(index - 1) and thats \(tasks[index - 1].id)")
//                    tasks[index - 1] = nextPickup
//                    }
//                } else {
//                    if toMiles <= miles[index] {
