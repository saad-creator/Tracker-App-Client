//
//  ViewController.swift
//  Test Client Application
//
//  Created by Apple on 21/06/2022.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var textView: UITextView!
    
    var timerForFirebaseAPICall = Timer()
    
    private let database = Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        scheduledTimerForFirebaseAPI()
    }
    
    //MARK: - Firebase API work
    func scheduledTimerForFirebaseAPI() {
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timerForFirebaseAPICall = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.performAction), userInfo: nil, repeats: true)
    }
    
    @objc func performAction() {
        
        fetchDataFromFirebase()
    }
    
    func fetchDataFromFirebase() {
        
        database.child("Rider").observeSingleEvent(of: .value) { snapshot in
            
            guard let value = snapshot.value else {return}
            print(snapshot)

            if let value1 =  (value as AnyObject)["RiderDtnLat"] as? String {
                
                self.textView.text = "\(value1)"
            }
            
//            (value as AnyObject).child("RiderDtnLat").observeSingleEvent(of: .value) { snapshot2 in
//
//                guard let riderDestLat = snapshot2.value else {
//                    print("got No vaue for ")
//                    return}
//                self.textView.text = riderDestLat as? String
//            }
        }
    }
    
    @IBAction func refreshData(_sener: UIButton) {
        
        database.child("Rider").observeSingleEvent(of: .value) { snapshot in
            
            guard let value = snapshot.value else {return}
            self.textView.text = "\(value)"
        }
    }
}

