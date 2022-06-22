//
//  RiderTrackerVC.swift
//  Test Client Application
//
//  Created by Apple on 21/06/2022.
//

import UIKit
import GoogleMaps
import FirebaseDatabase

class RiderTrackerVC: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var map: GMSMapView!
    
    //MARK: - Properties
    var previousMarkers = [GMSMarker]()
    
    var riderLat = ""
    var riderLong = ""
    var riderSrcLat = ""
    var riderSrcLong = ""
    var riderDestLat = ""
    var riderDestLong = ""
    var pointsForPath = ""
    
    var timerForFirebaseAPICall = Timer()
    
    let database = Database.database().reference()
    
    var oldPolyLines = [GMSPolyline]()
    
    //MARK: - Built-In functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scheduledTimerForFirebaseAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchDataFromFirebase()
    }
    
    //MARK: - Firebase API work
    func scheduledTimerForFirebaseAPI() {
        // Scheduling timer to Call the function "performAction" with the interval of 10 seconds
        timerForFirebaseAPICall = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.performAction), userInfo: nil, repeats: true)
    }
    
    @objc func performAction() {
        
        fetchDataFromFirebase()
    }
    
    func fetchDataFromFirebase() {
        
        database.child("Rider").observeSingleEvent(of: .value) { snapshot in
            
            guard let value = snapshot.value else {return}
            
            if let riderLatValue =  (value as AnyObject)["RiderLat"] as? String, let riderLongValue =  (value as AnyObject)["RiderLong"] as? String, let riderSrcLatValue =  (value as AnyObject)["RiderSrcLat"] as? String, let riderSrcLongValue =  (value as AnyObject)["RiderSrcLong"] as? String, let riderDestLatValue =  (value as AnyObject)["RiderDtnLat"] as? String, let riderDestLongValue =  (value as AnyObject)["RiderDtnLong"] as? String, let pointsValue =  (value as AnyObject)["points"] as? String  {
                
                self.riderLat = riderLatValue
                self.riderLong = riderLongValue
                self.riderSrcLat = riderSrcLatValue
                self.riderSrcLong = riderSrcLongValue
                self.riderDestLat = riderDestLatValue
                self.riderDestLong = riderDestLongValue
                self.pointsForPath = pointsValue
                self.AddMarkers()
                self.addPolyline()
            }
        }
    }
    
    func AddMarkers() {
        
        let sourceLocationMarker = GMSMarker()
        sourceLocationMarker.icon = UIImage(named: "")
        sourceLocationMarker.title = "Resautant"
        sourceLocationMarker.appearAnimation = .pop
        sourceLocationMarker.position = CLLocationCoordinate2D(latitude: Double(riderSrcLat)!, longitude: Double(riderSrcLong)!)
        
        DispatchQueue.main.async {
            sourceLocationMarker.map = self.map
        }
        
        let destinationLocationMarker = GMSMarker()
        destinationLocationMarker.icon = UIImage(named: "")
        destinationLocationMarker.title = "Drop Off Location"
        destinationLocationMarker.appearAnimation = .pop
        destinationLocationMarker.position = CLLocationCoordinate2D(latitude: Double(riderDestLat)!, longitude: Double(riderDestLong)!)
        
        DispatchQueue.main.async {
            destinationLocationMarker.map = self.map
        }
        
        let currentLocationMarker = GMSMarker()
        currentLocationMarker.icon = UIImage(named: "motorbike")
        currentLocationMarker.isDraggable = true
        currentLocationMarker.appearAnimation = .pop
        currentLocationMarker.position = CLLocationCoordinate2D(latitude: Double(riderLat)!, longitude: Double(riderLong)!)
        
        if self.previousMarkers.count > 0 {
            for marker in self.previousMarkers {
                marker.map?.clear()
            }
        }
        self.previousMarkers.append(currentLocationMarker)
        
        DispatchQueue.main.async {
            currentLocationMarker.map = self.map
        }
    }
    
    func addPolyline() {
        
        let path = GMSPath.init(fromEncodedPath: pointsForPath)
        let polyline = GMSPolyline.init(path: path)
        polyline.strokeColor = .systemBlue
        polyline.strokeWidth = 5
        
        if self.oldPolyLines.count > 0 {
            for polyline in self.oldPolyLines {
                polyline.map = nil
            }
        }
        self.oldPolyLines.append(polyline)
        polyline.map = self.map
        
        DispatchQueue.main.async {
            
            if self.map != nil && path != nil {
                
                let bounds = GMSCoordinateBounds(path: path!)
                self.map!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))
            }
        }
    }
}
