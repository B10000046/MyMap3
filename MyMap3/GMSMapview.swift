//
//  GMSMapView.swift
//  MyMap3
//
//  Created by Sie monyan on 2022/7/13.
//

import Foundation
import GoogleMaps
import GoogleMapsCore
import GoogleMapsBase
class GMSMapView: UIViewController, GMSMapViewDelegate {
    let strLat : String = "23.12453"
    let strLong : String = "120.53322"

    let strLat1 : String = "23.1232"
    let strLong2 : String = "120.53223"
    public enum NavigationType: String {

       case driving
       case transit
       case walking
     }
    
    
    @IBOutlet weak var map: GMSMapView!
    var camera:GMSCameraPosition = GMSCameraPosition.camera(withLatitude: 23.12, longitude: 120.34, zoom: 12)
    override func viewDidLoad() {
    let mapView = GMSMapView()
       let marker = GMSMarker()
        let camera = GMSCameraPosition.camera(withLatitude: 25.034012, longitude: 121.564461, zoom: 15.0)
        mapView.camera = camera!
        
        
       marker.position = CLLocationCoordinate2DMake(25.034012, 121.563461)
        marker.title = "標題1"
        marker.snippet = "副標題1"
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                    UIApplication.shared.openURL(URL(string:"https://www.google.com/maps/dir/?api=1&origin=Paris%2CFrance&destination=Cherbourg%2CFrance&travelmode=driving&waypoints=Versailles%2CFrance%7CChartres%2CFrance%7CLe+Mans%2CFrance%7CCaen%2CFrance")!)
            
                }
                else {
                    print("Can't use comgooglemaps://");
                }
        
    }
    
    
}
extension GMSMarker {
    convenience init(lat: Double, long: Double, title: String, map: GMSMapView) {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.image = UIImage(named: "parking-pin")
        
        self.init(position: CLLocationCoordinate2D(latitude: lat, longitude: long))
        self.title = title
        self.iconView = imageView
        self.tracksViewChanges = false
    }
}
