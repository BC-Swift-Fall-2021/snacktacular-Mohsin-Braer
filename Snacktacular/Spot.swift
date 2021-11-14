//
//  Spot.swift
//  Snacktacular
//
//  Created by Mohsin Braer on 11/2/21.
//

import Foundation
import Firebase
import MapKit

class Spot: NSObject, MKAnnotation {
    var name: String
    var address: String
    var coordinate: CLLocationCoordinate2D
    var averageRating: Double
    var numberOfReviews: Int
    var postUserID: String
    var documentID: String
    
    init(name: String, address: String, coordinate: CLLocationCoordinate2D,  averageRating: Double, numberOfReviews: Int, postUserID: String, documentID: String){
        self.name = name;
        self.address = address;
        self.coordinate = coordinate
        self.averageRating = averageRating;
        self.numberOfReviews = numberOfReviews;
        self.postUserID = postUserID;
        self.documentID = documentID;
    }
    
    var dictionary: [String: Any]{
        return ["name": name, "address": address, "latitude": latitude, "longitude": longitude, "averageRating": averageRating, "numberOfReviews": numberOfReviews, "postingUserID": postUserID]
    }
    var title: String?{
        return name
    }
    
    var subtitle: String? {
        return address
    }
    
    var latitude: CLLocationDegrees{
        return coordinate.latitude
    }
    
    var longitude: CLLocationDegrees{
        return coordinate.longitude
    }
    
    var location: CLLocation{
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    convenience override init(){
        self.init(name: "", address: "", coordinate: CLLocationCoordinate2D(), averageRating: 0.0, numberOfReviews: 0, postUserID: "", documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let name = dictionary["name"] as! String? ?? ""
        let address = dictionary["address"] as! Double? ?? 0.0
        let latitude =dictionary["latitude"] as! Double? ?? 0.0
        let longitude =dictionary["longitude"] as! Double? ?? 0.0
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let averageRating = dictionary["averageRating"] as! Double? ?? 0.0
        let numberOfReviews = dictionary["numberOfReviews"] as! Int? ?? 0
        let postUserID = dictionary["postUserID"] as! String? ?? ""

        self.init(name: name, address: address, coordinate: coordinate, averageRating: averageRating, numberOfReviews: numberOfReviews, postUserID: postUserID, documentID: "")
    }
    
    func saveData(completion: @escaping (Bool) -> ()){
        let db = Firestore.firestore()
        //Grab User ID
        guard let postingUserID = Auth.auth().currentUser?.uid else{
            print("ERROR: Could not save data because invalid postingUserID")
            return completion(false)
        }
        self.postUserID = postUserID
        //Create dictionary
        let dataToSave: [String: Any] = self.dictionary
        if self.documentID == "" {
            var ref: DocumentReference? = nil
            ref = db.collection("spots").addDocument(data: dataToSave){ (error) in
                guard error == nil else{
                    print("ERROR: adding document \(error!.localizedDescription)")
                    return completion(false)
                }
                self.documentID = ref!.documentID
                print("Added Document: \(self.documentID)")
                completion(true)
            }
        } else{
            let ref = db.collection("spots").document(self.documentID)
            ref.setData(dataToSave) {(error) in
                print("ERROR: Updating document \(error!.localizedDescription)")
                return completion(false)
            }
            print("Updated Document: \(self.documentID)")
            completion(true)
        }
        
    }
    
    
}
