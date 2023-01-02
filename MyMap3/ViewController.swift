import UIKit
import MapKit
import CoreLocation
import CoreImage
import CoreMotion
import SwiftUI
import WebKit
import SQLite3
import CoreBluetooth
import AVFoundation
import Foundation
import CoreData
import iAd
import LocalAuthentication
import PXGoogleDirections
import GoogleMaps
@objcMembers class ViewController: UIViewController, CLLocationManagerDelegate,WKUIDelegate, MKMapViewDelegate,NSURLConnectionDataDelegate,UITableViewDataSource,AVSpeechSynthesizerDelegate, UITableViewDelegate, UNUserNotificationCenterDelegate,CBCentralManagerDelegate,CBPeripheralDelegate,BLEManagerDelegate{
    var  myCentralManager:CBCentralManager!
        var  myPeripheral:CBPeripheral!
        var writeCharacteristic:CBCharacteristic!
    func bleManagerDidConnect(_ manager: BLEManagable) {
        self.temperatureLabel.textColor = UIColor.blue
    }
    
    
    private struct Weak<T: AnyObject> {
        weak var object: T?
    }
    
    private var delegates: [Weak<AnyObject>] = []
        fileprivate func bleDelegates() -> [BLEManagerDelegate] {
            return delegates.flatMap { $0.object as? BLEManagerDelegate }
        }
    func bleManagerDidConnect(_ manager: BLEManagable,receivedDataString dataString: String) {
        self.temperatureLabel.textColor = UIColor.blue
        self.temperatureLabel.text = dataString + "℃"
    }
    
    func bleManagerDidDisconnect(_ manager: BLEManagable) {
        self.temperatureLabel.textColor = UIColor.red
    }
    
    func bleManager(_ manager: BLEManagable, receivedDataString dataString: String) {
        self.temperatureLabel.text = dataString + "℃"
        temperatureLabel.font = UIFont(name:"Zapfino", size:20)
        print("temp:"+dataString + "℃")
     
    }
    func informDelegatesDidReceiveData(manager: BLEManager, dataString: String) {
            for delegate in self.bleDelegates() {
                DispatchQueue.main.async {
                    delegate.bleManager(manager, receivedDataString: dataString)
                    self.temperatureLabel.text = dataString + "℃"
                }
            }
        
        }
    var bleManager:BLEManagable = BLEManager()
    var titleLabel : UILabel!
    var statusLabel : UILabel!
    let IRTemperatureServiceUUID = CBUUID(string: "F000AA00-0451-4000-B000-000000000000")
    let IRTemperatureDataUUID   = CBUUID(string: "F000AA01-0451-4000-B000-000000000000")
    let IRTemperatureConfigUUID = CBUUID(string: "F000AA02-0451-4000-B000-000000000000")
    @IBOutlet weak var temperatureLabel: UILabel!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bleManager.addDelegate(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        bleManager.removeDelegate(self)
    }

    var annotation: MKPointAnnotation?
    var locationManager: CLLocationManager!
    @IBOutlet weak var locationLabel: UILabel!
    let pizzaPin = UIImage(named: "pizza pin")
       let crossHairs = UIImage(named: "crosshairs")
    let newPin = MKPointAnnotation()
    var timer = Timer()
    let chicagoCoordinate = CLLocationCoordinate2DMake(41.8832301, -87.6278121)
        let initialCoordinate = CLLocationCoordinate2DMake(41.9180474,-87.661767)
   @IBOutlet var outputTextView: UITextView!
    
    let captureSession = AVCaptureSession()
    let myDataQueue = DispatchQueue(label: "DataQueue",
                                    qos: .userInitiated,
                                    attributes: .concurrent,
                                    autoreleaseFrequency: .workItem,
                                    target: nil)
    let apiKey2 = "ZEJtsYY2yTKTa8tUQ9TfMI1Jl7e6JfD5"
    var restaurantNames = ["teaha","CaffeLatte","Espresso","Americano"]
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var restaurantIsFavorites = Array(repeating: false, count: 21)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "Hello")
    private static var kivaLoanURL = "https://api.kivaws.org/v1/loans/newest.json"
    var userLocation: CLLocation?
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "datacell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,for:indexPath)
        tableView.dataSource=self
        cell.textLabel?.text = restaurantNames[indexPath.row]
        cell.imageView?.image = UIImage(named:"Americano")
        
        return cell
    }
    let directionsAPI = PXGoogleDirections(apiKey: "ZEJtsYY2yTKTa8tUQ9TfMI1Jl7e6JfD5",
        from: PXLocation.coordinateLocation(CLLocationCoordinate2DMake(37.331690, -122.030762)),
        to: PXLocation.specificLocation("Googleplex", "Mountain View", "United States"))
   // var chartView: LineChartView!
    let url = URL(string: "https://api.kivaws.org/v1/loans/newest.json")!
    var db :OpaquePointer? = nil
    var statement :OpaquePointer? = nil
    var myLocationManager :CLLocationManager!
    @IBOutlet var myMapView :MKMapView!
    private var destination:[MKPointAnnotation] = []
    @IBOutlet var restaurantImageView:UIImageView!
    @IBOutlet var imageView: UIImageView?
    var routeSteps = [MKRoute.Step]()
    private var currentRoute: MKRoute?
    var placemarkLongitude = 120.534
    var placemarkLatitude = 23.15
    private var previousLocation:[MKPointAnnotation] = []
    private var newLocation:[MKPointAnnotation] = []
    var managerB:CBCentralManager!
    var peripheralB:CBPeripheral!
    var addMarkerRepeat = [Int](repeating: 20, count:2)
    var seconds=0.0
    var distance=0.0
    var _locationManager=CLLocationManager()
    let login_url = "https://www.kaleidosblog.com/tutorial/login/api/Login"
        let checksession_url = "https://www.kaleidosblog.com/tutorial/login/api/CheckSession"
    var login_session:String = ""
    private static var kivaLoanURL1 = "https://api.kivaws.org/v1/loans/newest.json"
    let decoder = JSONDecoder()
    let request:MKDirections.Request = MKDirections.Request()
    let uuidService = CBUUID(string: "25AE1441-05D3-4C5B-8281-93D4E07420CF")
        let uuidCharForRead = CBUUID(string: "25AE1442-05D3-4C5B-8281-93D4E07420CF")
        let uuidCharForWrite = CBUUID(string: "25AE1443-05D3-4C5B-8281-93D4E07420CF")
        let uuidCharForIndicate = CBUUID(string: "25AE1444-05D3-4C5B-8281-93D4E07420CF")

        var bleCentral: CBCentralManager!
        var connectedPeripheral: CBPeripheral?
    enum BLELifecycleState: String {
           case bluetoothNotReady
           case disconnected
           case scanning
           case connecting
           case connectedDiscovering
           case connected
       }
    
    //BLE
    var centralManager:CBCentralManager!
    var sensorTagPeripheral:CBCentralManager!
    var restaurant2: Restaurant!
    let lm = CLLocationManager()
    let sessionConfiguration = URLSessionConfiguration.default
    let DBFILE_NAME = "NoteList.sqlite3"
    var periperalManager:CBPeripheralManager!
    let C001_CHARACTZERISZTIC = "C001"
    var result:String = ""
        
        var lable:UILabel!
    let checkInAction = UIAlertAction(title:"Check in",style:.default,handler: {
        (action:UIAlertAction!)->Void in
    })
    var db2 :SQLiteConnect? = nil
    let sqliteURL: URL = {
            do {
                return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("db.sqlite")
            } catch {
                fatalError("Error getting file URL from document directory.")
            }
        }()
    @IBAction func myLocation(_ sender:UIButton){
        let location = myMapView.userLocation
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
        myMapView.setRegion(region, animated: true)
    }
    private var bluefruitPeripheral: CBPeripheral!
    var location : CLLocationManager!; //座標管理元件
    var status = CLLocationManager.authorizationStatus()
    var backFacingCamera:AVCaptureDevice?
    var frontFacingCamera:AVCaptureDevice?
    var currentDevice:AVCaptureDevice?
    var lifecycleState = BLELifecycleState.bluetoothNotReady {
            didSet {
                guard lifecycleState != oldValue else { return }
                print("state = \(lifecycleState)")
                if oldValue == .connected {
                  
                }
            }
        }
    private var txCharacteristic: CBCharacteristic!
    private var rxCharacteristic: CBCharacteristic!
    
    let channels = ["awesomeChannel"]
    let BEAN_NAME = "Robu"
    let BEAN_SCRATCH_UUID =
      CBUUID(string: "a495ff21-c5b1-4b44-b512-1370f02d74de")
    let BEAN_SERVICE_UUID =
      CBUUID(string: "a495ff20-c5b1-4b44-b512-1370f02d74de")
    @IBOutlet weak var weatherLabel: UILabel!
  //  @IBOutlet weak var routeMap: MKMapView!
    var manager = CLLocationManager()
    var completion:((CLLocation)->Void)?
    public func getUserLocation(completion:@escaping ((CLLocation)-> Void)){
        self.completion = completion
        manager.requestWhenInUseAuthorization()
        manager.delegate = self
        manager.startUpdatingLocation()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        var thread1:Thread?
        thread1=Thread(target: self, selector:#selector(ViewController.thread1ToDo), object: nil)
        thread1?.start()
        var locationManager: CLLocationManager!
        let mm = CMMotionManager()
        let device = UIDevice.current
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.delegate = self
        navigationItem.title = "牧場地圖"
        deliveryOverlay(pastureName:"Connie's Pizza",radius: 5000)
        deliveryOverlayFly(pastureName: "飛牛牧場", radius: 5000)
        deliveryOverlayChian(pastureName: "千巧谷牧場", radius: 5000)
        deliveryOverlayResua(pastureName: "瑞穗牧場", radius: 5000)
        deliveryOverlayHuya(pastureName: "禾野牧場", radius: 5000)
        deliveryOverlayJuyan(pastureName: "久源牧場", radius: 5000)
        deliveryOverlayGreenIn(pastureName: "綠盈牧場", radius: 5000)
        deliveryOverlayWuFon(pastureName: "五峰牧場", radius: 5000)
        if device.isProximityMonitoringEnabled{
            let nc = NotificationCenter.default
            nc.addObserver(self,
                           selector: #selector(proximityStateChanged(_:)),
                           name:NSNotification.Name.MKAnnotationCalloutInfoDidChange,
                           object:nil)
        }else{
            print("此裝置沒有接近感測器")
        }
        var txCharacteristic: CBCharacteristic!
        var rxCharacteristic: CBCharacteristic!
        let centerCoordinate = CLLocationCoordinate2D(latitude: 23.14, longitude: 120.53)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        myMapView.setRegion(region, animated: false)
        for randCoordinate in makeRandomCoordinates(in: region) {
            let annotation = MapItem(coordinate: randCoordinate)
            myMapView.addAnnotation(annotation)
        }
        let dst:String = NSHomeDirectory()+"/Documents/Personal.db"
        if sqlite3_open(dst,&db) !=  SQLITE_OK {
            print("can not open db")
        }else{
            let sql = "select * from Contacts"
            sqlite3_prepare_v2(db, (sql as NSString).utf8String, -1, &statement, nil)
            while sqlite3_step(statement)==SQLITE_ROW{
                let id = sqlite3_column_int(statement, 0)
                let name = String(cString: sqlite3_column_text(statement, 1))
                let age = sqlite3_column_int(statement, 2)
                let address = String(cString: sqlite3_column_text(statement, 3))
                print("contact.id:\(id) name:\(name) age:\(age) address:\(address)")
                self.view.showToast(text:"contact.id:\(id) name:\(name) age:\(age) address:\(address)" )
                UIApplication.shared.keyWindow?.showToast(text:"contact.id:\(id) name:\(name) age:\(age) address:\(address)")
                }
            sqlite3_finalize(statement)
            }
        centralManager = CBCentralManager(delegate: self, queue: nil)
        directionsAPI.calculateDirections({ response in
         switch response {
          case let .error(_, error):
           // Oops, something bad happened, see the error object for more information
           break
          case let .success(request, routes):
           // Do your work with the routes object array here
             
           break
         }
        })
        createTable()
        queryOneData()
        zoomToRegion()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest   //user位置追蹤精確程度，設置成最精確位置
        manager.activityType = .automotiveNavigation        //設定使用者的位置模式，手機會去依照不同設定做不同的電力控制
        manager.startUpdatingLocation()
        if status == .notDetermined || status == .denied || status == .authorizedWhenInUse {
               manager.requestAlwaysAuthorization()
               manager.requestWhenInUseAuthorization()
           }
        manager.startUpdatingLocation()
        manager.startUpdatingHeading()
        let sqlitePath = sqliteURL.path
               print(sqlitePath)
               db2 = SQLiteConnect(path: sqlitePath)
               if let mydb = db2 {
                   // create table
                   let _ = mydb.createTable("students", columnsInfo: [
                       "id integer primary key autoincrement",
                       "name text",
                       "height double"])
                   let _ = mydb.insert("students",
                                       rowInfo: ["name":"'DRAM'","height":"550"])
                   let statement = mydb.fetch("students", cond: "1 == 1", order: nil)
                   while sqlite3_step(statement) == SQLITE_ROW{
                       let id = sqlite3_column_int(statement, 0)
                       let name = String(cString: sqlite3_column_text(statement, 1))
                       let height = sqlite3_column_double(statement, 2)
                       print("\(id). \(name) 價位： \(height)")
                   }
                   sqlite3_finalize(statement)
                   let _ = mydb.update(
                       "students",
                       cond: "id = 2",
                       rowInfo: ["name":"'RAM'","height":"500"])
                   let _ = mydb.delete("students", cond: "id = 5")
        }
        if(UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
          UIApplication.shared.openURL(URL(string:
            "comgooglemaps://?center=40.765819,-73.975866&zoom=14&views=traffic")!)
        } else {
          print("Can't use comgooglemaps://");
        }
        let testURL = URL(string: "comgooglemaps-x-callback://")!
        if UIApplication.shared.canOpenURL(testURL) {
          let directionsRequest = "comgooglemaps-x-callback://" +
            "?daddr=John+F.+Kennedy+International+Airport,+Van+Wyck+Expressway,+Jamaica,+New+York" +
            "&x-success=sourceapp://?resume=true&x-source=AirApp"

          let directionsURL = URL(string: directionsRequest)!
        UIApplication.shared.openURL(directionsURL)
            myMapView.register(
                MapItemAnnotationView.self,
                forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
            myMapView.register(
                ClusterAnnotationView.self,
                forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
            open(scheme: "omgooglemaps://?saddr=Google+Inc,+8th+Avenue,+New+York,+NY&daddr=John+F.+Kennedy+International+Airport,+Van+Wyck+Expressway,+Jamaica,+New+York&directionsmode=transit")
        } else {
          NSLog("Can't use comgooglemaps-x-callback:// on this device.")
        }
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        let url5 = URL(string: "https://foodprint.ws/j_spring_security_check")!
        var request5 = URLRequest(url: url5)
        request5.httpMethod = "POST"
        request5.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let urlStr = "https://itunes.apple.com/search?term=swift&media=music"
        if let url = URL(string: urlStr) {
            URLSession.shared.dataTask(with: url) { data, response , error in
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                if let data = data {
                    do {
                        let searchResponse = try decoder.decode(SearchResponse.self, from: data)
                        print(searchResponse.results)
                    } catch {
                        print(error)
                    }
                } else {
                    print("error")
                }
            }.resume()
        }
        
   activateProximitySensor()
        managerB = CBCentralManager(delegate: self, queue: nil)
   let text = "你好,雲端農業送貨系統"
        if let language = NSLinguisticTagger.dominantLanguage(for: text) {
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: language) //use the detected language
            let synth = AVSpeechSynthesizer()
            synth.speak(utterance)
        } else {
            print("Unknown language")
        }
        
        let url = URL(string: "https://reqres.in/api/users?page=1")!
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data,
               let content = String(data: data, encoding: .utf8) {
                print(content)
            }
        }.resume()
        var dataArray = [Int] ()
        let url7 = URL(string: "https://reqres.in/api/users/3")!
        var request4 = URLRequest(url: url7)
        request4.httpMethod = "delete"
        URLSession.shared.dataTask(with: request4) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse.statusCode)
            }
        }.resume()
        let session = URLSession(configuration: .default)
        let url2 = URL(string: "https://reqres.in/api/users?page=1")!
        let request6 = URLRequest(url: url2)
        URLSession.shared.dataTask(with: request6) { data, response, error in
            if let data = data,
               let content = String(data: data, encoding: .utf8) {
                print(content)
            }
        }.resume()
        let string = "Welcome to cloud logistic System"
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)
        myUtterance = AVSpeechUtterance(string: "Hello World")
                myUtterance.rate = 0.3
        synth.speak(myUtterance)
        func zoomToRegion() {
            let location = CLLocationCoordinate2D(latitude: 13.03297, longitude: 80.26518)
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 5000.0, longitudinalMeters: 7000.0)
            myMapView.setRegion(region, animated: true)
        }
        func deliveryOverlay(pastureName:String, radius:CLLocationDistance){
            let center = CLLocationCoordinate2D(latitude: 23.692046147786932, longitude: 120.53154473204215)
            let circle = MKCircle(center: center, radius: radius)
            myMapView.addOverlay(circle)
        }
        func deliveryOverlayGreenIn(pastureName:String, radius:CLLocationDistance){
            let center = CLLocationCoordinate2D(latitude: 23.25, longitude: 120.31)
            let circle = MKCircle(center: center, radius: radius)
            myMapView.addOverlay(circle)
        }
        func Yunhu(pastureName:String, radius:CLLocationDistance){
            let center = CLLocationCoordinate2D(latitude: 23.808921,  longitude: 120.397142)
            let circle = MKCircle(center: center, radius: radius)
            myMapView.addOverlay(circle)
        }
        func deliveryOverlayWuFon(pastureName:String, radius:CLLocationDistance){
            let center = CLLocationCoordinate2D(latitude: 23.775291,  longitude: 121.003418)
            let circle = MKCircle(center: center, radius: radius)
            myMapView.addOverlay(circle)
        }
        
        func deliveryOverlayJuyan(pastureName:String, radius:CLLocationDistance){
            let center = CLLocationCoordinate2D(latitude: 23.754179,  longitude: 120.238075)
            let circle = MKCircle(center: center, radius: radius)
            myMapView.addOverlay(circle)
        }
        
        func deliveryOverlayHuya(pastureName:String, radius:CLLocationDistance){
            let center = CLLocationCoordinate2D(latitude: 23.870594, longitude: 120.413424)
            let circle = MKCircle(center: center, radius: radius)
            myMapView.addOverlay(circle)
        }
        func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
                print("didFailWithError: \(error.description)")
                let errorAlert = UIAlertView(title: "Error", message: "Failed to Get Your Location", delegate: nil, cancelButtonTitle: "Ok")
                errorAlert.show()
            }
        func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
            let newLocation = locations.last as! CLLocation
                print("current position: \(newLocation.coordinate.longitude) , \(newLocation.coordinate.latitude)")
            }
        
        func deliveryOverlayResua(pastureName:String, radius:CLLocationDistance){
            let center1 = CLLocationCoordinate2D(latitude: 23.5, longitude: 121.4)
            let circle1 = MKCircle(center: center1, radius: radius)
            myMapView.addOverlay(circle1)
        }
        func deliveryOverlayFly(pastureName:String, radius:CLLocationDistance){
            let center2 = CLLocationCoordinate2D(latitude: 24.478058, longitude: 120.724436)
            let circle2 = MKCircle(center: center2, radius: radius)
            myMapView.addOverlay(circle2)
        }
        func deliveryOverlayChian(pastureName:String, radius:CLLocationDistance){
            let center3 = CLLocationCoordinate2D(latitude: 23.752324, longitude: 120.357767)
            let circle3 = MKCircle(center: center3, radius: radius)
            myMapView.addOverlay(circle3)
        }
        func makeRandomCoordinates(_ number: Int = 1000, in region: MKCoordinateRegion) -> [CLLocationCoordinate2D] {
            let minLat = region.center.latitude - (region.span.latitudeDelta * 2)
            let maxLat = region.center.latitude + (region.span.latitudeDelta * 2)
            
            let minLon = region.center.longitude - (region.span.longitudeDelta)
            let maxLon = region.center.longitude + (region.span.longitudeDelta)
            
            let adjusted: [Int] = [minLat, maxLat, minLon, maxLon].map { Int($0 * 10000) }
            let latDelta = adjusted[1] - adjusted[0]
            let lonDelta = abs(adjusted[3] - adjusted[2])
            
            var coordinates = [CLLocationCoordinate2D]()
            for _ in 0...number {
                let latRand = Int(arc4random_uniform(UInt32(latDelta)))
                let lonRand = Int(arc4random_uniform(UInt32(lonDelta))) * -1
                
                let lat: Double = minLat + (Double(latRand) / 10000.0)
                let lon: Double = minLon - (Double(lonRand) / 10000.0)
                
                coordinates.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
            }
            
            return coordinates
        }
        func open(scheme: String) {
                if let url = URL(string: scheme) {
                   if #available(iOS 10, *) {
                       UIApplication.shared.open(url, options: [:],
                       completionHandler: {
                          (success) in
                          print("Open \(scheme): \(success)")
                        })
                     } else {
                          let success = UIApplication.shared.openURL(url)
                          print("Open \(scheme): \(success)")
                 }
             }
           }
        func readLocalFile(forName name: String) -> Data? {
            do {
                if let bundlePath = Bundle.main.path(forResource: name,
                                                     ofType: "json"),
                    let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                    return jsonData
                }
            } catch {
                print(error)
            }
            return nil
        }
        func createTable() {
            let createTableString = """
                                    CREATE TABLE Contacts(
                                    Id INT PRIMARY KEY NOT NULL,
                                    Name CHAR(255),
                                    age Int,
                                    address CHAR(255));
                                    """
            var createTableStatement: OpaquePointer?
            if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
                if sqlite3_step(createTableStatement) == SQLITE_DONE {
                    print( "成功创建表")
                } else {
                    print( "未成功创建表")
                }
            } else {
                    
            }
           sqlite3_finalize(createTableStatement)
        }
        func getDirection(){
            guard let location = locationManager.location?.coordinate else{
                return
            }
            let request = createDirectionRequest(from: location)
            let direction = MKDirections(request: request)
            
            directions.calculate { response, error in
                guard let response = response else{return}
                for route in response.routes{
                    self.myMapView.addOverlay(route.polyline)
                    self.myMapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                }}}
        func centralManagerDidUpdateState(_ central: CBCentralManager) {
          
           switch central.state {
                case .poweredOff:
                    print("Is Powered Off.")
                case .poweredOn:
                    print("Is Powered On.")
                    startScanning()
                case .unsupported:
                    print("Is Unsupported.")
                case .unauthorized:
                print("Is Unauthorized.")
                case .unknown:
                    print("Unknown")
                case .resetting:
                    print("Resetting")
                @unknown default:
                  print("Error")
                }
        }
        func openDatabase() -> OpaquePointer? {
            var dbPath = "/Users/siemonyan/Desktop/GeoCoder3/GeoCoder3"
            var db: OpaquePointer?
            if sqlite3_open(dbPath, &db) == SQLITE_OK {
                print("成功打开数据库，路径：\(dbPath)")
                return db
            } else {
                print( "打开数据库失败")
                return nil
            }
        }
        let request2 = MKLocalSearch.Request()
        request2.naturalLanguageQuery = "牧場"
        request2.region = myMapView.region
        let search = MKLocalSearch(request:request2)
        search.start{(response,error) in
            guard error == nil else{
                return
            }
            guard response != nil else{
                return
            }
            for item in (response?.mapItems)!{
                self.myMapView.addAnnotation(item.placemark)
                
            }
        }
        
        let urlString2 = URL(string: "https://reqres.in/api/users/3")  // Making the URL
        if let url = urlString2 {
           let task = URLSession.shared.dataTask(with: url) {
              (data, response, error) in // Creating the URL Session.
              if error != nil {
                 // Checking if error exist.
                 print(error)
              } else {
                 if let usableData = data {
                    // Checking if data exist.
                    print(usableData)
                    // printing Data.
                 }
              }
           }
            task.resume()
        }
        let queue = DispatchQueue.global()
        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self
        myLocationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        myLocationManager.requestAlwaysAuthorization()
        myLocationManager.startUpdatingLocation()
        myLocationManager.startUpdatingHeading()
        let fullSize = UIScreen.main.bounds.size
        myMapView = MKMapView(frame: CGRect(x: 0, y: 20, width: fullSize.width, height: fullSize.height - 20))//
        myMapView.showsUserLocation = true
        myMapView.delegate = self
        myMapView.mapType = .mutedStandard
        myMapView.isPitchEnabled = true
        myMapView.userTrackingMode = .follow//效果:不带方向的追踪,显示用户的位置,并且会跟随用户移动
        myMapView.showsUserLocation = true
        myMapView.userTrackingMode = .follow
        myMapView.isZoomEnabled = true
        callAPI()
        callWeatherAPI()
        
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.delegate = self;
        let center = UNUserNotificationCenter.current()
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoringVisits()
        var restaurantNames = ["teaha","CaffeLatte","Espresso","Americano"]
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return restaurantNames.count
        }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cellIdentifier = "datacell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,for:indexPath)
            cell.textLabel?.text = restaurantNames[indexPath.row]
            return cell
        }
        weak var routeMap: MKMapView!
        var currentTransportType = MKDirectionsTransportType.automobile
        var peripheralManager : CBPeripheralManager!
        let latDelta = 0.05
        let longDelta = 0.05
        let currentLocationSpan:MKCoordinateSpan = MKCoordinateSpan.init(latitudeDelta: latDelta, longitudeDelta: longDelta)
        let sourceLocation = CLLocationCoordinate2D(latitude: 23.15, longitude: 120.53)
        let destinationLocation = CLLocationCoordinate2D(latitude:23.25 , longitude: 120.31)
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        let sourceAnnotation = MKPointAnnotation()
            sourceAnnotation.title = "合野牧場"
        if let location = sourcePlacemark.location {
                  sourceAnnotation.coordinate = location.coordinate
        }
        let destinationAnnotation = MKPointAnnotation()
              destinationAnnotation.title = "綠盈農場"
              
        if let location = destinationPlacemark.location {
              destinationAnnotation.coordinate = location.coordinate
        }
        self.myMapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
               directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate{
            (response,error)-> Void in
            guard let response = response else {
                            if let error = error {
                                print("Error: \(error)")
                            }
                            
                            return
                        }
            let route = response.routes[0]
            self.myMapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
       }
        let sourceLocation2 = CLLocationCoordinate2D(latitude: 25.033671, longitude: 121.564427)
        let destinationLocation2 = CLLocationCoordinate2D(latitude: 22.42, longitude: 120.21)
   
        let sourcePlacemark2 = MKPlacemark(coordinate: sourceLocation2, addressDictionary: nil)
        let destinationPlacemark2 = MKPlacemark(coordinate: destinationLocation2, addressDictionary: nil)
        let sourceMapItem2 = MKMapItem(placemark: sourcePlacemark2)
        let destinationMapItem2 = MKMapItem(placemark: destinationPlacemark2)
        let sourceAnnotation2 = MKPointAnnotation()
        sourceAnnotation2.title = "Taipei City"

        if let location = sourcePlacemark2.location {
          sourceAnnotation2.coordinate = location.coordinate
      }
      let destinationAnnotation2 = MKPointAnnotation()
      destinationAnnotation2.title = "Empire State Building"
      
      if let location = destinationPlacemark2.location {
          destinationAnnotation2.coordinate = location.coordinate
      }
   self.myMapView.showAnnotations([sourceAnnotation2,destinationAnnotation2], animated: true )
   let directionRequest2 = MKDirections.Request()
   directionRequest2.source = sourceMapItem2
   directionRequest2.destination = destinationMapItem2
   directionRequest2.transportType = .automobile
      
   let directions2 = MKDirections(request: directionRequest2)
   directions2.calculate{
    (response2,error)-> Void in
    guard let response2 = response2 else {
                    if let error = error {
                        print("Error: \(error)")
                    }
                    
                    return
                }
    let route2 = response2.routes[0]
    self.myMapView.addOverlay((route2.polyline), level: MKOverlayLevel.aboveRoads)
   }
          location = CLLocationManager();
          location.delegate = self;
          location.requestWhenInUseAuthorization();
          location.startUpdatingLocation();
          location.distanceFilter = CLLocationDistance(10);
        let center2:CLLocation = CLLocation(latitude: 25.05, longitude: 121.515)
        let currentRegion = MKCoordinateRegion(center: center2.coordinate, span: currentLocationSpan)
        myMapView.setRegion(currentRegion, animated: true)
        var annView = myMapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView
        self.view.addSubview(myMapView)
        var points3 = [CLLocationCoordinate2D]()
        var objectAnnotation = MKPointAnnotation()
        var location = CLLocation(latitude:22.999034,longitude:120.212868)
        var region2 = MKCoordinateRegion(center:location.coordinate,latitudinalMeters:300,longitudinalMeters: 300)
        objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = CLLocation(latitude: 24.441304, longitude: 120.74123).coordinate
        objectAnnotation.title = "飛牛牧場"
        objectAnnotation.subtitle = "地址|35750苗栗縣通霄鎮南和里166號"
        myMapView.addAnnotation(objectAnnotation)
        objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = CLLocation(latitude: 23.760679, longitude: 120.365768).coordinate
        objectAnnotation.title = "千巧谷牧場"
        objectAnnotation.subtitle = "地址|637雲林縣崙背鄉東興路182之32號"
        myMapView.bounds = CGRect(x:400,y:400,width: 400,height: 600)
        myMapView.addAnnotation(objectAnnotation)
        if(objectAnnotation.title)!=="飛牛牧場"{
           annView!.pinTintColor = UIColor.green
        }
        lm.delegate = self
        lm.startUpdatingHeading()
        var points2 = [CLLocationCoordinate2D]()
        points2.append(CLLocationCoordinate2D(latitude:23.76 , longitude:120.3657646 ))
        points2.append(CLLocationCoordinate2D(latitude: 23.7606595, longitude: 120.4))
        points2.append(CLLocationCoordinate2D(latitude: 23.755, longitude: 120.43))
        points2.append(CLLocationCoordinate2D(latitude: 23.77, longitude: 120.3))
         let polygon2 = MKPolygon(coordinates: &points2, count: points2.count)
         myMapView.addOverlay(polygon2)
         myMapView.setCenter(points2[0],animated:false)
         myMapView.setCenter(points2[1], animated: false)
        
        points3.append(CLLocationCoordinate2D(latitude:23.76 , longitude:120.3657646 ))
        points3.append(CLLocationCoordinate2D(latitude: 23.7606595, longitude: 120.4))
        myMapView.addOverlay(polygon2)
        myMapView.setCenter(points2[0],animated:false)
        myMapView.showsCompass = true
        myMapView.showsScale = true
        myMapView.showsTraffic = true
        myMapView.showsUserLocation = true
        myMapView.mapType = .mutedStandard
        myMapView.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
        myMapView.userTrackingMode = MKUserTrackingMode.followWithHeading
        _ = locationManager
        let item = MKUserTrackingBarButtonItem(mapView: myMapView)
        navigationItem.leftBarButtonItem = item
        
        var status3 = CLLocationManager.authorizationStatus()
        if status3 == .notDetermined || status == .denied || status == .authorizedWhenInUse {
               locationManager.requestAlwaysAuthorization()
               locationManager.requestWhenInUseAuthorization()
           }
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        let request3 = MKLocalSearch.Request()
        request3.naturalLanguageQuery = "牧場"
        request3.region = myMapView.region
        let search2 = MKLocalSearch(request:request3)
        search2.start{(response,error) in
            guard error == nil else{
                return
            }
            guard response != nil else{
                return
            }
            for item in (response?.mapItems)!{
                self.myMapView.addAnnotation(item.placemark)
            }
        }
        self.myMapView.isPitchEnabled = true
        print("present location : (newLocation.coordinate.latitude), (newLocation.coordinate.longitude)")
        let url4:NSURL! = NSURL(string: "http://www.hangge.com")
        myMapView.delegate = self
        if #available(iOS 9.0, *) {
            myMapView.showsCompass = true
            myMapView.showsScale = true
            myMapView.showsTraffic = true
        }
        
        //创建请求对象
        let urlRequest:NSURLRequest = NSURLRequest(url: url4! as URL)
        //响应对象
        var response:URLResponse?
        do{
            //发送请求
            let data:NSData? = try NSURLConnection.sendSynchronousRequest(urlRequest as URLRequest,
                                                                          returning: &response) as NSData
            let str = NSString(data: data! as Data, encoding: String.Encoding.utf8.rawValue)
              print(str)
        }catch let error as NSError{
              //打印错误消息
              print(error.code)
              print(error.description)
        }
        
         checkLocationService()
        deliveryOverlay(pastureName: "Connie's Pizza",radius: 5000)
        deliveryOverlayFly(pastureName: "飛牛牧場",radius: 5000)
        deliveryOverlayChian(pastureName: "千巧谷牧場", radius: 5000)
        deliveryOverlayResua(pastureName: "瑞穗牧場", radius: 5000)
        deliveryOverlayHuya(pastureName: "禾野牧場", radius: 5000)
        deliveryOverlayJuyan(pastureName: "久源牧場", radius: 5000)
        deliveryOverlayGreenIn(pastureName: "綠盈牧場", radius: 5000)
        deliveryOverlayWuFon(pastureName: "五峰牧場", radius: 5000)
        getDirection()
        //設定座標
        let flycow = CLLocationCoordinate2D(latitude:24.441304,longitude: 120.74123)
        let yuansin = CLLocationCoordinate2D(latitude:24.429672,longitude:120.738737)
        let chien = CLLocationCoordinate2D(latitude:23.45384,longitude:120.21568)
        let pA = MKPlacemark(coordinate: flycow, addressDictionary: nil)
        let pB = MKPlacemark(coordinate: yuansin, addressDictionary: nil)
        let pC = MKPlacemark(coordinate: chien, addressDictionary: nil)
        let miA = MKMapItem(placemark: pA)
        miA.name = "飛牛牧場"
        let miB = MKMapItem(placemark: pB)
        miB.name = "永興休閒農場"
        let miC = MKMapItem(placemark: pC)
        miC.name = "千巧谷休閒農場"
        let routes = [miA,miC]
        let options = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
       
        let urlString3 = URL(string: "api.openweathermap.org/data/2.5/forecast?id=524901&APPID=1111111111")  // Making the URL
        if let url = urlString3 {
           let task = URLSession.shared.dataTask(with: url) {
              (data, response, error) in // Creating the URL Session.
              if error != nil {
                 // Checking if error exist.
                print(error!)
                
              } else {
                 if let usableData = data {
                    print(usableData)
                   
                 }
              }
           }
            task.resume()
        }
        MKMapItem.openMaps(with:routes,launchOptions: options)
        let urlString4 = URL(string: "api.openweathermap.org/data/2.5/forecast?id=524901&APPID=1111111111")  // Making the URL
        if let url = urlString4 {
           let task = URLSession.shared.dataTask(with: url) {
              (data, response, error) in // Creating the URL Session.
              if error != nil {
                 print(error)
              } else {
                 if let usableData = data {
                    print(usableData)
                 }
              }
           }
            task.resume()
        }
    }
    func render(_ location: CLLocation){
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        myMapView.setRegion(region, animated: true)
    }
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Something Else"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            let string = "Detacted Device shacking"
            let utterance = AVSpeechUtterance(string: string)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")

            let synth = AVSpeechSynthesizer()
            synth.speak(utterance)
           
            myUtterance = AVSpeechUtterance(string: "Hello World")
                    myUtterance.rate = 0.3
            synth.speak(myUtterance)
        }
    }
    func activateProximitySensor() {
        let device = UIDevice.current
        device.isProximityMonitoringEnabled = true
        if device.isProximityMonitoringEnabled {
            NotificationCenter.default.addObserver(self, selector: #selector(proximityChanged(notification:)), name: NSNotification.Name(rawValue: "UIDeviceProximityStateDidChangeNotification"), object: device)
        }
    }
   
    func proximityChanged(notification: NSNotification) {
        var i=0
        if let device = notification.object as? UIDevice {
            print("\(device) detected!")
            self.view.showToast(text: "接近裝置")
            i+=1
        }
        }
    @objc func thread1ToDo(sender:AnyObject?){
        for i in 1...100{
            print("I'm thread1-- \(i)")
            //加入當前標記
            var nSize = 10000
            while nSize > 1 {
                // loop body
             nSize = (nSize + 1) / 2
             DispatchQueue.main.async { [self] in
                 for index in 1...nSize {
                    
                 }
            }}
        }
    }
    func addAnnotations(coords: [CLLocation]){
            for coord in coords{
                let CLLCoordType = CLLocationCoordinate2D(latitude: coord.coordinate.latitude,
                                                          longitude: coord.coordinate.longitude);
                let anno = MKPointAnnotation();
                anno.coordinate = CLLCoordType;
                myMapView.addAnnotation(anno);
            }
    }
    
    private func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil;
        }else{
            let pinIdent = "Pin";
            var pinView: MKPinAnnotationView;
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: pinIdent) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation;
                pinView = dequeuedView;
            }else{
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinIdent);
            }
            return pinView;
        }
    }
    func showRoute(_ response: MKDirections.Response) {

        for route in response.routes {

            myMapView.addOverlay(route.polyline,
                    level: MKOverlayLevel.aboveRoads)
            for step in route.steps {
                print(step.instructions)
            }
        }
        if let coordinate = userLocation?.coordinate{
            let region2 =
            MKCoordinateRegion(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
            myMapView.setRegion(region2, animated: true)
        }
    }
    private func callWeatherAPI() {
        // 根據網站的 Request tab info 我們拼出請求的網址
        let url = URL(string: "https://dataservice.accuweather.com/currentconditions/v1/315078?apikey=\(apiKey2)&language=zh-Tw")!
        // 將網址組成一個 URLRequest
        var request = URLRequest(url: url)
        
        // 設置請求的方法為 GET
        request.httpMethod = "GET"
        let session = URLSession.shared
     
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            guard let data = data else {
                return
            }
            do {
                // 使用 JSONDecoder 去解開 data
                let weatherModel = try JSONDecoder().decode([WeatherModel].self, from: data)
                print(weatherModel)
                DispatchQueue.main.async {
            
                    let tmp = weatherModel.first?.temperature.metric.value ?? -1
               }
            } catch {
                print(error)
            }
    })
        dataTask.resume()
    }
    func webServiceConnect( nameSpace:String, urlStr:String, method:String){
            //soap的配置
            let soapMsg:String = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"+"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"+"<soap:Body>\n"+"<"+method+" xmlns=\""+nameSpace+"\">\n"+"<byProvinceName>"+"北京"+"</byProvinceName>\n"+"</"+method+">\n"+"</soap:Body>\n"+"</soap:Envelope>\n"
            
            let soapMsg2:NSString = soapMsg as NSString
            //接口的转换为url
            let url:URL = URL.init(string:urlStr)!
            //计算出soap所有的长度，配置头使用
            let msgLength:NSString = NSString.init(format: "%i", soapMsg2.length)
            //创建request请求，把请求需要的参数配置
            var request:URLRequest = NSMutableURLRequest.init() as URLRequest
            //请求的参数配置，不用修改
            request.timeoutInterval = 10
            request.cachePolicy = .reloadIgnoringLocalCacheData
            request.url = url
            request.httpMethod = "POST"
            //请求头的配置
            request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.addValue(msgLength as String, forHTTPHeaderField: "Content-Length")
            request.httpBody = soapMsg.data(using: String.Encoding.utf8)
            //soapAction的配置
            let soapActionStr:String = nameSpace + method
            request.addValue(soapActionStr, forHTTPHeaderField: "SOAPAction")
            let session:URLSession = URLSession.shared
            let task:URLSessionDataTask = session.dataTask(with: request as URLRequest , completionHandler: {( data, respond, error) -> Void in
                
                if (error != nil){
                    
                    print("error is coming")
                }else{
                    //结果输出
                    let result:NSString = NSString.init(data: data!, encoding: String.Encoding.utf8.rawValue)!
                    print("result=\(result),\n adress=\(String(describing: request.url))")
                }
            })
            task.resume()
    }
 
    func peripheralManager(_ peripheral: CBPeripheralManager) {
        guard peripheral.state == .poweredOn else{
            print(peripheral.state.rawValue)
            return
        }
        var service:CBMutableService
        var characteristic:CBMutableCharacteristic
        var charArray = [CBCharacteristic]()
        var charDictionary = [String: CBMutableCharacteristic]()
        service = CBMutableService(type: CBUUID(string:"A001_SERVICE"), primary: true)
        characteristic = CBMutableCharacteristic(type: CBUUID(string: "A001_SERVICES"), properties: [.notifyEncryptionRequired,.write,.read], value: nil, permissions: [.writeEncryptionRequired,.readEncryptionRequired])
        charArray.append(characteristic)
        service.characteristics = charArray
        
        periperalManager.add(service)
    }
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake{
            print("裝置搖晃中")
            self.view.showToast(text: "裝置搖晃中\n\n")
            let text = "偵測裝置搖晃"
            if let language = NSLinguisticTagger.dominantLanguage(for: text) {
               let utterance = AVSpeechUtterance(string: text)
                utterance.voice = AVSpeechSynthesisVoice(language: language) //use the detected language
            let synth = AVSpeechSynthesizer()
                synth.speak(utterance)
            } else {
                print("Unknown language")
            }
            let string = "Detected device shacking"
            let utterance = AVSpeechUtterance(string: string)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            let synth = AVSpeechSynthesizer()
            synth.speak(utterance)
            var nSize = 10000
            while nSize > 1 {
                // loop body
             nSize = (nSize + 1) / 2
             DispatchQueue.main.async { [self] in
                for index in 1...nSize {
                     myMapView.addAnnotation(newPin)
                }
            }}
            
      }}
      @objc func proximityStateChanged(_ sender:NSNotification){
        let device = UIDevice.current
        if device.proximityState{
            print("物體接近")
        }else{
            print("物體遠離")
        }
     }
     func createDirectionRequest(from coordinate:CLLocationCoordinate2D)->MKDirections.Request{
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destinationLocation = MKPlacemark(coordinate: coordinate)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = .transit
        request.requestsAlternateRoutes = true
        return request
    }
    func getJSONData(completed: @escaping () -> ()) {
        if let filepath = Bundle.main.path(forResource: "weather", ofType: "json") {
            if let data = try? String(contentsOf: URL(fileURLWithPath: filepath)) {
              // I must assign json to weatherData here
                DispatchQueue.main.async {
                    completed()
                }
            }
        } else {
            print("file not found")
        }
    }
   func getDirection(){
        guard let location = locationManager.location?.coordinate else{
            return
        }
        let request = createDirectionRequest(from: location)
        let directions = MKDirections(request:request)
        
        let callActionHandler = {
            (action:UIAlertAction!)->Void in
            let alertMessage = UIAlertController(title:"Service Unavalable",message:"sorry,the call feature is not avalable yet",preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title:"ok",style:.default,handler:nil))
            self.present(alertMessage, animated: true, completion: nil)
        }
   }
    func queryOneData() {
        let queryString = "SELECT * FROM Contacts WHERE Id == 1;"
        var queryStatement: OpaquePointer?
        //第一步
        if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
            //第二步
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                //第三步
                let id = sqlite3_column_int(queryStatement, 0)
                
                let queryResultName = sqlite3_column_text(queryStatement, 1)
                let name = String(cString: queryResultName!)
                let age = sqlite3_column_int(queryStatement, 2)
                let address = sqlite3_column_double(queryStatement, 3)
                print( "id: \(id), name: \(name), age: \(age), address: \(address)")
                
                let alertController = UIAlertController(
                    title: "id: \(id), name: \(name), age: \(age), address: \(address)", message: "", preferredStyle: .alert
                )
                let alertAction = UIAlertAction(title: "id: \(id), name: \(name), age: \(age), address: \(address)", style: .default, handler: nil)
                alertController.addAction(alertAction)
                present(alertController, animated: true, completion: nil)
                
                let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "id: \(id), name: \(name), age: \(age), address: \(address)", style: UIAlertAction.Style.default, handler: nil))
                present(alert, animated: true, completion: nil)
            } else {
                print("error")
            }
            
        }
        //第四步
        sqlite3_finalize(queryStatement)
    }
     func prepareForSeque(seque:UIStoryboardSegue,sender:AnyObject?){
          if seque.identifier == "showSteps"{
            let destinationController = seque.destination as! UINavigationController
            let routeTableViewController = destinationController.childViewControllerForPointerLock?.isFirstResponder as! ViewController
            if let steps = currentRoute?.steps as? [MKRoute.Step]{
                routeTableViewController.routeSteps = steps
            }
        }
    }
     func setup() {
            myMapView.delegate = self
            showCircle(coordinate: initialCoordinate,
                       radius: 5000)
        }
        func showCircle(coordinate: CLLocationCoordinate2D,
                        radius: CLLocationDistance) {
            let circle = MKCircle(center: coordinate,
                                  radius: radius)
            myMapView.addOverlay(circle)
        }
    func fetchLatestLoans(){
        guard let loanUrl = URL(string:Self.kivaLoanURL) else{
            return
        }
        let request = URLRequest(url: loanUrl)
        let task = URLSession.shared.dataTask(with: request,completionHandler: {(data,response,error)->Void in
            if let error = error{
                print(error)
                return
            }
            
            if let data = data{
                DispatchQueue.main.async {
                    self.loans = self.parseJsonData(data:data)
                }
            }
        })
        task.resume()
    }
    @Published var loans:[Loan] = []
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var location = "Paris,France"
        if CLLocationManager.authorizationStatus() == .notDetermined {
            myLocationManager.requestWhenInUseAuthorization()
            myLocationManager.startUpdatingLocation()
            
        }
     
        else if CLLocationManager.authorizationStatus() == .denied {
            let alertController = UIAlertController( title: "定位權限已關閉", message: "如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確認", style: .default, handler:nil)
            alertController.addAction(okAction)
            self.present( alertController, animated: true, completion: nil)
        }
        else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            // 開始定位自身位置
            myLocationManager.startUpdatingLocation()
        }
    }
    func parseJsonData(data:Data)->[Loan]{
        let decoder = JSONDecoder()
        
        do{
            let loanStore = try!decoder.decode(LoanStore.self, from: data)
            self.loans = loanStore.loans
        }catch{
            print(error)
        }
        return loans
    }
    func setUpLocationManager(){
        myLocationManager.delegate = self
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    func checkLocationServices()
    {
        if CLLocationManager.locationServicesEnabled(){
            setUpLocationManager()
            checkLocationAuthorization()
        }else{}
    }
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
    func centralManagerDidUpdateState(_ central: CBCentralManager){
        switch central.state{
        case CBManagerState.poweredOn:
            print("藍芽開啟")
            self.temperatureLabel.textColor = UIColor.systemBlue
            
        case CBManagerState.unauthorized:
            print("沒有藍芽功能")
        case CBManagerState.poweredOff:
            print("藍芽關閉")
            self.temperatureLabel.textColor = UIColor.red
        default:
            print("未知狀態")
            
        }
        central.scanForPeripherals(withServices: nil, options: nil)
    }
    func centralManager(_central:CBCentralManager,didDiscover peripheral:CBPeripheral,advertismentData:[String:Any],rssi RSSI:NSNumber){
        if let name = peripheral.name{
            print(name)
        }
   }
   func showAlert(title: String, message: String, buttonTitle: String) {
            let alert = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: buttonTitle, style: .default, handler: { (action) in
            })
            alert.addAction(okAction)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
    }
    private func addAnotation(){
        let appleParkAnnotation = MKPointAnnotation()
        appleParkAnnotation.title = "Apple Park"
        appleParkAnnotation.coordinate = CLLocationCoordinate2D(latitude:37.332072300,longitude:-122.11130300)
        let ortegapartAnnotation = MKPointAnnotation()
        ortegapartAnnotation.title = "Ortega Park"
        ortegapartAnnotation.coordinate = CLLocationCoordinate2D(latitude:37.362226,longitude:-122.023617)
        destination.append(appleParkAnnotation)
        destination.append(ortegapartAnnotation)
        
        myMapView.addAnnotation(appleParkAnnotation)
        myMapView.addAnnotation(ortegapartAnnotation)
    }
    func showRoute2(_ response: MKDirections.Response) {
        
        for route in response.routes {
            
            myMapView.addOverlay(route.polyline,
                         level: MKOverlayLevel.aboveRoads)
            
            for step in route.steps {
                print(step.instructions)
            }
        }
        
        if let coordinate = userLocation?.coordinate {
            _ =
                MKCoordinateRegion(center: coordinate,
                                   latitudinalMeters: 2000, longitudinalMeters: 2000)
         }
    }
    func mapView(_ mapView: MKMapView, rendererFor
                    overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        
       if overlay.isKind(of: MKCircle.self){
              let circleRenderer = MKCircleRenderer(overlay: overlay)
         
//           circleRenderer.strokeColor = UIColor.yellow
              circleRenderer.lineWidth = 1
              return circleRenderer
          }
        renderer.strokeColor = UIColor.orange
        renderer.lineWidth = 5.0
        return renderer
    }
    public func constructRoute(userLocation: CLLocationCoordinate2D){
        let directionsRequest = MKDirections.Request()
        directionsRequest.source = MKMapItem(placemark:MKPlacemark(coordinate: userLocation))
        directionsRequest.destination = MKMapItem(placemark:MKPlacemark(coordinate:destination[0].coordinate))
        directionsRequest.transportType = .automobile
        let directions = MKDirections(request:directionsRequest)
        directions.calculate{[weak self](directionsResponse,error)in
            guard let strongSelf = self else{return}
            if let error = error{
                print(error.localizedDescription)
            }else if let response = directionsResponse,response.routes.count>0{
                strongSelf.currentRoute =  response.routes[0]
                let route = directionsResponse!.routes[0] as! MKRoute
                
                strongSelf.myMapView.removeOverlays((self?.myMapView.overlays)!)
                strongSelf.myMapView.addOverlay(route.polyline,level:MKOverlayLevel.aboveRoads)
                strongSelf.currentRoute = route
                
                strongSelf.myMapView.addOverlay(response.routes[0].polyline)
                strongSelf.myMapView.setVisibleMapRect(response.routes[0].polyline.boundingMapRect, animated: true)
                let rect = route.polyline.boundingMapRect
                self?.myMapView.setRegion(MKCoordinateRegion(rect), animated: true)
            }
        }
    }
    func checkLocationAuthorization(){
        switch CLLocationManager.authorizationStatus(){
        case .authorizedWhenInUse:
            myMapView.showsUserLocation = true
            break
        case .notDetermined:
            myLocationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .denied:
            break
        case .authorizedAlways:
            break
        
        @unknown default:
            break
        }
    }
    func getCenterLocation() -> CLLocation{
        let latitude = myMapView.centerCoordinate.latitude
        let longitude = myMapView.centerCoordinate.longitude
        return CLLocation(latitude:latitude,longitude:longitude)
    }
    func checkLocationService(){
        if CLLocationManager.locationServicesEnabled(){
            setUpLocationManager()
        }
    }
    func mapView(_mapView:MKMapView,rendererFor overlay:MKOverlay)->MKOverlayRenderer{
        let renderer = MKPolygonRenderer(overlay:overlay)
        renderer.strokeColor = UIColor.systemBlue
        renderer.lineWidth = 3.0
        if overlay is MKPolygon{
            renderer.fillColor = UIColor.red.withAlphaComponent(0.2)
            renderer.strokeColor = UIColor.red.withAlphaComponent(0.7)
            
            renderer.lineWidth = 3
        }
        return renderer
    }
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.orange
            renderer.lineWidth = 4.0
        
            return renderer
   }
   func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyPin"
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        // 重複使用地圖標註
        var annotationView:MKPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        }
        if(annotation.title)! == "行天宮"{
            annotationView!.pinTintColor = UIColor.blue
        }
        if(annotation.title)! == "艋舺公園"{
            annotationView!.pinTintColor = UIColor.blue
        }
        if(annotation.title)! == "好想工作室"{
            annotationView!.pinTintColor = UIColor.blue
        }
        if(annotation.title)! == "飛牛牧場"{
            annotationView!.pinTintColor = UIColor.blue
        }
        if(annotation.title)! == "千巧谷牧場"{
            annotationView!.pinTintColor = UIColor.blue
        }
        let leftIconView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 33, height: 33))
        leftIconView.image = UIImage(named: "posatelier")
        annotationView?.leftCalloutAccessoryView = leftIconView
        let button = UIButton(type: .detailDisclosure) as UIButton
        annotationView?.rightCalloutAccessoryView = button
        return annotationView
    }
    func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

      UNUserNotificationCenter.current().delegate = self

      UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { (granted, err) in
        DispatchQueue.main.async() {
          UIApplication.shared.registerForRemoteNotifications()
        }
      }

      return true
    }
    private func mapView(mapView: MKMapView!, viewForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
           if (overlay is MKPolyline) {
               let pr = MKPolylineRenderer(overlay: overlay)
               pr.strokeColor = UIColor.blue.withAlphaComponent(0.5)
               pr.lineWidth = 4
               return pr
           }
          
           return nil
   }
   func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool,didUpdateLocations locations: [CLLocation]!) {
        print("物流車移動中")
         myMapView.removeAnnotation(newPin)

             let location = locations.last! as CLLocation

             let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
             let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

             //set region on the map
         myMapView.setRegion(region, animated: true)

             newPin.coordinate = location.coordinate
         myMapView.addAnnotation(newPin)
         
         
    }
    var dataArray = [Int] ()
    func createPath(sourceLocation : CLLocationCoordinate2D, destinationLocation : CLLocationCoordinate2D,didUpdateLocations locations: [CLLocation]!) {
            let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
            let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
            
            
            let sourceMapItem = MKMapItem(placemark: sourcePlaceMark)
            let destinationItem = MKMapItem(placemark: destinationPlaceMark)
            
            
            let sourceAnotation = MKPointAnnotation()
            sourceAnotation.title = "Delhi"
            sourceAnotation.subtitle = "The Capital of INIDA"
            if let location = sourcePlaceMark.location {
                sourceAnotation.coordinate = location.coordinate
            }
            
            let destinationAnotation = MKPointAnnotation()
            destinationAnotation.title = "Gurugram"
            destinationAnotation.subtitle = "The HUB of IT Industries"
            if let location = destinationPlaceMark.location {
                destinationAnotation.coordinate = location.coordinate
            }
            
            self.myMapView.showAnnotations([sourceAnotation, destinationAnotation], animated: true)
            let directionRequest = MKDirections.Request()
            directionRequest.source = sourceMapItem
            directionRequest.destination = destinationItem
            directionRequest.transportType = .automobile
            
            let direction = MKDirections(request: directionRequest)
            direction.calculate { (response, error) in
                guard let response = response else {
                    if let error = error {
                        print("ERROR FOUND : \(error.localizedDescription)")
                    }
                    return
                }
                
                let route = response.routes[0]
                self.myMapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
                
                let rect = route.polyline.boundingMapRect
                
                self.myMapView.setRegion(MKCoordinateRegion(rect), animated: true)
                
            }
        myMapView.addAnnotation(newPin)

                 let location = locations.last! as CLLocation
                 let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                 let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

                 //set region on the map
             myMapView.setRegion(region, animated: true)

                 newPin.coordinate = location.coordinate
             myMapView.addAnnotation(newPin)
     }
     func mapViewDidFinishLoadingMap(_ mapView: MKMapView,didUpdateLocations locations: [CLLocation]!) {
        print("載入地圖完成時")
       
    }
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        myMapView.centerCoordinate = userLocation.location!.coordinate
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("點擊大頭針的說明")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
     func determineMyCurrentLocation(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
    }
    //Current location 8:13
    func locationManager(_ manager:CLLocationManager,didUpdateLocations locations:[CLLocation]){
        let userLocation:CLLocation = locations[0] as CLLocation
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        let myLocation: CLLocation = locations[0] as CLLocation
        let myLatitude: String = String(format: "%f", myLocation.coordinate.latitude)
        let myLongitude: String = String(format:"%f", myLocation.coordinate.longitude)
        self.myMapView.showToast(text: myLatitude+myLatitude)
        
        
        let location = locations.last! as CLLocation
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        newPin.coordinate = userLocation.coordinate
        myMapView.addAnnotation(newPin)
          //於當前位置加入標記->Thread
        myDataQueue.async(flags: .barrier) {
                var nSize = 10000
                while nSize > 1 {
                    // loop body
                 nSize = (nSize + 1) / 2
                 DispatchQueue.main.async { [self] in
                    for index in 1...nSize {
                         print("\(index)：\(index * 5)")
                         myMapView.addAnnotation(newPin)
                        let myLocation: CLLocation = locations[0] as CLLocation
                        let myLatitude: String = String(format: "%f", myLocation.coordinate.latitude)
                        let myLongitude: String = String(format:"%f", myLocation.coordinate.longitude)
                        Timer.scheduledTimer(withTimeInterval: TimeInterval(1), repeats: true,block: {(timer:Timer)-> Void in
                            self.view.showToast(text: myLatitude+myLongitude)

                        })
                        
                    //    self.view.showToast(text: myLongitude)
                    }
                     
                    myMapView.addAnnotation(newPin)
                    print("add an annotation.")
                  }
            }
            DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(2)) {
                DispatchQueue.main.async { [self] in
                    self.myMapView.addAnnotation(newPin)
                    
                    Timer.scheduledTimer(withTimeInterval: TimeInterval(1), repeats: true,block: {(timer:Timer)-> Void in
                        self.view.showToast(text: myLatitude+myLongitude)

                    })
                                        
                    
                    print("add an annotation2.")
                }
            }
        }
        var sp = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentationDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
        //迴圈出力取得路徑
                for file in sp {
                    print(file)
                }
        //設定路徑
        var url: NSURL = NSURL(fileURLWithPath: "/Users/siemonyan/Desktop/MyMap3/data.txt")
        //定義可變資料變數
                var data = NSMutableData()
        data.append("user latitude = 23.691961990356518 user longitude = 120.53171341184672".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
        data.append("user latitude = 23.691961990356518 user longitude = 120.53171341184672".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
        data.append("user latitude = 23.691961990356518 user longitude = 120.53171341184672".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
                //用data寫檔案
        data.write(toFile: url.path!, atomically: true)
        if let readData = NSData(contentsOfFile: url.path!) {
                    //如果內容存在 則用readData建立文字列
                   
                } else {
                    //nil的話，輸出空
                    print("Null")
                }
        let annotations = getMapAnnotations()
        
        var points: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
        
        for annotation in annotations {
            points.append(annotation.coordinate)
        }
        let polyline = MKPolyline(coordinates: &points, count: points.count)
        
        myMapView.addOverlay(polyline)
        guard let location = locations.first else{
            return
        }
        completion?(location)
        manager.stopUpdatingLocation()
           // user location
           let userLatitude = self.manager.location?.coordinate.latitude //THIS RETURNS A VALUE
           let userLongitude = self.manager.location?.coordinate.longitude //THIS RETURNS A VALUE
           print("User Location is ", userLatitude, ", " ,userLongitude)
           let eventLatitude = self.placemarkLatitude // THIS RETURNS 0.0
           let eventLongitude = self.placemarkLongitude // THIS RETURNS 0.0
           print("Event Location is ", eventLatitude, ", " ,eventLongitude)
           let eventLocation = CLLocation(latitude: eventLatitude, longitude: eventLongitude)
        
            
           //Measuring my distance to my buddy's (in km)
        let distance = userLocation.distance(from: eventLocation) / 1000

             //Display the result in km
             print("The distance to event is ", distance)

             if (distance > 100) {

                 print("the distance is greater than 100 km")
             }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,advertisementData: [String : Any], rssi RSSI: NSNumber) {

        bluefruitPeripheral = peripheral

        bluefruitPeripheral.delegate = self

        print("Peripheral Discovered: \(peripheral)")
          print("Peripheral name: \(peripheral.name)")
        print ("Advertisement Data : \(advertisementData)")
            
        centralManager?.stopScan()
       }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        let value = String(data: characteristic.value!, encoding: .ascii)!

           print("Wrote characteristic value: " + value + "; for characterisitc: " + characteristic.uuid.description)
   }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,didWriteValueFor myCharacteristic: CBCharacteristic, error: Error?) {

        // find your characteristic in service.characteristics
        peripheral.setNotifyValue(true, for: myCharacteristic)
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
       
        peripheral.delegate = myMapView as! CBPeripheralDelegate
                peripheral.discoverServices(nil)
            

                //set the manager's delegate view to parent so it can call relevant disconnect methods
        manager.delegate = myMapView as! CLLocationManagerDelegate
      

                if let navController = self.navigationController {
                    navController.popViewController(animated: true)
                }

                print("Connected to " +  peripheral.name!)
       bluefruitPeripheral.discoverServices([CBUUIDs.BLEService_UUID])
    }
 

        
        func peripheral(_ peripheral: CBPeripheral,
                        didUpdateNotificationStateFor characteristic: CBCharacteristic,
                        error: Error?) {
            guard error == nil else {
                print("didUpdateNotificationState error\n\(String(describing: error))")
                lifecycleState = .connected
                return
            }

            if characteristic.uuid == uuidCharForIndicate {
                let info = characteristic.isNotifying ? "Subscribed" : "Not subscribed"
               
                print(info)
            }
            lifecycleState = .connected
        }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            print("*******************************************************")

            if ((error) != nil) {
                print("Error discovering services: \(error!.localizedDescription)")
                return
            }
            guard let services = peripheral.services else {
                return
            }
            //We need to discover the all characteristic
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
            print("Discovered Services: \(services)")
        }
    
    //MARK:- Zoom to region
    func zoomToRegion() {
        
        let location = CLLocationCoordinate2D(latitude: 13.03297, longitude: 80.26518)
        
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 5000.0, longitudinalMeters: 7000.0)
        
        myMapView.setRegion(region, animated: true)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
        {
            print("Error \(error)")
        }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
      let radius = 5000
       print("點擊大頭針")
        let center1 = CLLocationCoordinate2D(latitude: 23.5, longitude: 121.4)
        let circle1 = MKCircle(center: center1, radius: CLLocationDistance(radius))
        myMapView.addOverlay(circle1)
        let text = "選擇牧場"
        if let language = NSLinguisticTagger.dominantLanguage(for: text) {

            //we now know the language of the text
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: language) //use the detected language
            let synth = AVSpeechSynthesizer()
            synth.speak(utterance)
        } else {
            print("Unknown language")
        }
        let currentSpan = myMapView.region.span
        let zoomSpan = MKCoordinateSpan(latitudeDelta: currentSpan.latitudeDelta / 2.0, longitudeDelta: currentSpan.longitudeDelta / 2.0)
        let zoomCoordinate = view.annotation?.coordinate ?? myMapView.region.center
        let zoomed = MKCoordinateRegion(center: zoomCoordinate, span: zoomSpan)
        myMapView.setRegion(zoomed, animated: true)
        
        if let url = URL(string: "https://www.sencha.com/grid/demo/modern/#/rendering-and-scrolling/live-data-grid") {
                if UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            }
    }
    let kmlFileName = "Allowed area"
    let kmlFileType="kml"
    var polygonView:MKPolygonRenderer!
    var polygonCoordinatePoints:[CLLocationCoordinate2D] = []
    var shopName:[String] = []
    var shopCity:[String] = []
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
      print("取消點擊大頭針")
    }
    func getMapAnnotations() -> [Station] {
        var annotations:Array = [Station]()
        
        //load plist file
        
        var stations: NSArray?
        if let path = Bundle.main.path(forResource: "stations", ofType: "plist") {
            stations = NSArray(contentsOfFile: path)
        }
        if let items = stations {
            for item in items {
                let lat = (item as AnyObject).value(forKey: "lat") as! NSNumber
                let long = (item as AnyObject).value(forKey: "long")as! NSNumber
                let annotation = Station(latitude: Double(lat), longitude: Double(long))
                annotation.title = (item as AnyObject).value(forKey: "title") as? String
                annotations.append(annotation)
            }
        }
        
        return annotations
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation],newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
           print("定位到了")
        let newLocation = locations.last! as CLLocation
            print("current position: \(newLocation.coordinate.longitude) , \(newLocation.coordinate.latitude)")
            let message = "{\"lat\":\(newLocation.coordinate.latitude),\"lng\":\(newLocation.coordinate.longitude), \"alt\": \(newLocation.altitude)}"
    
    }
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral,a: String!, advertisementData: [String : AnyObject], RSSI: NSNumber) {
            if (peripheral.name == a){
                self.bluefruitPeripheral = peripheral
                self.bluefruitPeripheral.delegate = self
                centralManager?.stopScan()
                bleCentral?.connect(self.bluefruitPeripheral, options: nil)
                self.performSegue(withIdentifier: "ConnectionSegue", sender: nil)
            }
            else{
               
            }
        }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
           let conten = UNMutableNotificationContent()
           conten.title = "已進入區域"
           conten.body = "已進入區域"
           conten.sound = .default
           let request = UNNotificationRequest(identifier: "big", content: conten, trigger: nil)
           UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
       }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
            let conten = UNMutableNotificationContent()
            conten.title = "已離開"
            conten.body = "已離開"
            conten.sound = .default
            let request = UNNotificationRequest(identifier: "back", content: conten, trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            print("Peripheral Is Powered On.")
        case .unsupported:
            print("Peripheral Is Unsupported.")
        case .unauthorized:
        print("Peripheral Is Unauthorized.")
        case .unknown:
            print("Peripheral Unknown")
        case .resetting:
            print("Peripheral Resetting")
        case .poweredOff:
          print("Peripheral Is Powered Off.")
        @unknown default:
          print("Error")
        }
      }
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
           peripheral.delegate = self
           peripheral.discoverServices(nil)

       }
 
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
            print("----didUpdateValueForCharacteristic---")
            
            if  characteristic.uuid.uuidString == "2AF0"  {
                let data:Data = characteristic.value!
                print(data)
                let  d  = Array(UnsafeBufferPointer(start: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count), count: data.count))
                print(d)
                
          
                
               
                
            }
        }
    /**
         <#设置特征为正在监听，读取数据#>
         
         - parameter peripheral:     <#peripheral description#>
         - parameter characteristic: <#characteristic description#>
         - parameter error:          <#error description#>
         */
        
        func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
            print("-----didUpdateNotificationStateForCharacteristic-----")
            if (error != nil) {
                print(error?.code);
            }
            //Notification has started
            if(characteristic.isNotifying){
                peripheral.readValue(for: characteristic);
                print(characteristic.uuid.uuidString);
            }
        }
    private func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
          print("didWriteValueForCharacteristic")
       }
    
    
    func setupData() {
            // 1. 檢查系統是否能夠監視 region
            if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                
                // 2.準備 region 會用到的相關屬性
                let title = "Lorrenzillo's"
                let coordinate = CLLocationCoordinate2DMake(23.69,120.53)
                let regionRadius = 100.0
                // 3. 設置 region 的相關屬性
                let region = CLCircularRegion(center: CLLocationCoordinate2D(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude),
                    radius: regionRadius,
                    identifier: title)
                locationManager.startMonitoring(for: region)
            }
        }
  
    func mapView(_mapView:MKMapView,ViewFor annotation:MKAnnotation)->MKAnnotationView?{
        if let temp = annotation as? MyAnnotation{
        var myView = myMapView.dequeueReusableAnnotationView(withIdentifier: "Pins") as?MKMarkerAnnotationView
        if myView == nil{
            myView = MKMarkerAnnotationView(annotation: temp, reuseIdentifier: "Pins")
            myView?.markerTintColor = UIColor.green
            myView?.glyphText = "TEST"
            myView?.glyphTintColor = UIColor.black
            myView?.titleVisibility = .adaptive
            myView?.subtitleVisibility = .visible
        }
            
        return myView
    }
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            
            if overlay is MKPolyline {
                polylineRenderer.strokeColor = UIColor.blue
                polylineRenderer.lineWidth = 5

            }
            return polylineRenderer
        }
        func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
            let newLocation = locations.last as! CLLocation
            print("current position: \(newLocation.coordinate.longitude) , \(newLocation.coordinate.latitude)")
            let message = "{\"lat\":\(newLocation.coordinate.latitude),\"lng\":\(newLocation.coordinate.longitude), \"alt\": \(newLocation.altitude)}"
            
          
        }
        
        func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
            if overlay.isKind(of: MKCircle.self){
                let circleRenderer = MKCircleRenderer(overlay: overlay)
                circleRenderer.fillColor = UIColor.blue.withAlphaComponent(0.1)
                circleRenderer.strokeColor = UIColor.yellow
                circleRenderer.lineWidth = 1
                return circleRenderer
            }
                return MKOverlayRenderer(overlay: overlay)
            }

        func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!){
            //drawing path or route covered
            if let oldLocationNew = oldLocation as CLLocation?{
                 let oldCoordinates = oldLocationNew.coordinate
                 let newCoordinates = newLocation.coordinate
                 var area = [oldCoordinates, newCoordinates]
                let polyline = MKPolyline(coordinates: &area, count: area.count)
                
                myMapView.addOverlay(polyline)
             }
        }
        //function to add annotation to map view
        func createPolyline(mapView: MKMapView) {
            let point1 = CLLocationCoordinate2DMake(-73.761105, 41.017791);
            let point2 = CLLocationCoordinate2DMake(-73.760701, 41.019348);
            let point3 = CLLocationCoordinate2DMake(-73.757201, 41.019267);
            let point4 = CLLocationCoordinate2DMake(-73.757482, 41.016375);
            let point5 = CLLocationCoordinate2DMake(-73.761105, 41.017791);
            
            let points: [CLLocationCoordinate2D]
            points = [point1, point2, point3, point4, point5]
            
            let geodesic = MKGeodesicPolyline(coordinates: points, count: 5)
            myMapView.addOverlay(geodesic)
            
            UIView.animate(withDuration: 1.5, animations: { () -> Void in
                let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                let region1 = MKCoordinateRegion(center: point1, span: span)
                self.myMapView.setRegion(region1, animated: true)
            })
        }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 印出目前所在位置座標
           let location = locations.last! as CLLocation

           let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
           let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

           //set region on the map
           myMapView.setRegion(region, animated: true)

           newPin.coordinate = location.coordinate
        for item in addMarkerRepeat{
           myMapView.addAnnotation(newPin)
            print(item)
        }
        
    }
        func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
         
        self.statusLabel.text = "Connected"
         
            if characteristic.uuid == IRTemperatureDataUUID {
        // Convert NSData to array of signed 16 bit values
        let dataBytes = characteristic.value
                let dataLength = dataBytes!.count
                var dataArray = (count: dataLength, repeatedValue: 0)
               
         
        // Element 1 of the array will be ambient temperature raw value
      let ambientTemperature = Double(dataArray.1)/128
         
        // Display on the temp label
        self.temperatureLabel.text = String(format: "%.2f", ambientTemperature)
                print("溫度")
                print(ambientTemperature)
        }
        }
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer!{
            if (overlay is MKPolyline) {
                let pr = MKPolylineRenderer(overlay: overlay)
                pr.strokeColor = UIColor.red
                pr.lineWidth = 5
                return pr
            }
            if let circleOverlay = overlay as? MKCircle {
                       let circleRenderer = MKCircleRenderer(overlay: circleOverlay)
                       circleRenderer.fillColor = .black
                       circleRenderer.alpha = 0.1

                       return circleRenderer
                   }
            return nil
        }
        // MARK: - MKMapViewDelegate methods
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "MyPin"
            
            if annotation.isKind(of: MKUserLocation.self) {
                return nil
            }
            
            // Reuse the annotation if possible
            var annotationView: MKAnnotationView?
            
            if #available(iOS 11.0, *) {
                var markerAnnotationView: MKMarkerAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                
                if markerAnnotationView == nil {
                    markerAnnotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    markerAnnotationView?.canShowCallout = true
                }
                
                markerAnnotationView?.glyphText = "😋"
                markerAnnotationView?.markerTintColor = UIColor.orange
            
                annotationView = markerAnnotationView
                
            } else {
                
                var pinAnnotationView: MKPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
                
                if pinAnnotationView == nil {
                    pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    pinAnnotationView?.canShowCallout = true
                    pinAnnotationView?.pinTintColor = UIColor.orange
                }
                
                annotationView = pinAnnotationView
            }
            
            let leftIconView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 53, height: 53))
            leftIconView.image = UIImage(named: "posatelier")
            annotationView?.leftCalloutAccessoryView = leftIconView
                
            return annotationView
        }
        enum SerializationError: Error {
            case missing(String)
        }
        struct Acronym {
            let id: Int
            let short: String
            let long: String
        }
        typealias JSONDictionary = [String : Any]
        return nil

    }
}

    private func callAPI() {
       let apiKey2 = "ZEJtsYY2yTKTa8tUQ9TfMI1Jl7e6JfD5"
       let url = URL(string: "https://dataservice.accuweather.com/currentconditions/v1/315078?apikey=\(apiKey2)&language=zh-Tw")!
       var request = URLRequest(url: url)
       request.httpMethod = "GET"
       let session = URLSession.shared
       let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
           guard let data = data else {
               return
           }
           do {
               DispatchQueue.main.async {}
               
           } catch {
               print(error)
           }
       })
       dataTask.resume()
        
    
}

struct Resource<Model> {
    let url: URL
    let parse: (Data) throws -> Model
}
struct UpdateUserBody: Encodable {
    let name: String
    let job: String
}
struct UpdateUserResponse: Decodable {
    let name: String
    let job: String
}
extension Resource {
    init(url: URL, parseJSON: @escaping (Any) throws -> Model) {
        self.url = url
        self.parse = { data in
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            return try parseJSON(json)
        }
    }
}
struct CreateSCMPBody: Encodable {
    let ArticleNum: String
    let name: String
    let id: String
    let brandName:String
    let number:Int
    let manufacture:String
 
    let unit:String
    let warehouseNumber:Int
}
struct CreateUserResponse: Decodable {
    let name: String
    let job: String
    let id: String
}
struct Meme {
   let id: Int
   let image: URL
   let caption: String
   let category: String
}
struct StoreItem: Codable {
   let artistName: String
   let trackName: String
   let collectionName: String?
   let previewUrl: URL
   let artworkUrl100: URL
   let trackPrice: Double?
   let releaseDate: Date
   let isStreamable: Bool?
}
struct SearchResponse: Codable {
   let resultCount: Int
   let results: [StoreItem]
}
extension Meme: Codable { }
struct Loan:Codable{
    var name:String
    var country:String
    var use:String
    var amount:Int
    
    enum CodingKeys:String,CodingKey{
        case name
        case country = "location"
        case use
        case amount = "loan_amount"
    }
    enum LocationKeys:String,CodingKey{
        case contry
    }
}
struct CoffeeData: Decodable {
     var name: String
     var city: String
 }
struct LoanStore:Codable{
    var loans:[Loan]
}
// MARK: BLEManagerDelegate

extension UIView{
    func showToast(text: String){
        self.hideToast()
        let toastLb = UILabel()
        toastLb.numberOfLines = 0
        toastLb.lineBreakMode = .byWordWrapping
        toastLb.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLb.textColor = UIColor.white
        toastLb.layer.cornerRadius = 10.0
        toastLb.textAlignment = .center
        toastLb.tintColor = .orange
        toastLb.font = UIFont.systemFont(ofSize: 15.0)
        toastLb.text = text
        toastLb.layer.masksToBounds = true
        toastLb.tag = 9999//tag：hideToast實用來判斷要remove哪個label
        
        let maxSize = CGSize(width: self.bounds.width - 40, height: self.bounds.height)
        var expectedSize = toastLb.sizeThatFits(maxSize)
        var lbWidth = maxSize.width
        var lbHeight = maxSize.height
        if maxSize.width >= expectedSize.width{
            lbWidth = expectedSize.width
        }
        if maxSize.height >= expectedSize.height{
            lbHeight = expectedSize.height
        }
        expectedSize = CGSize(width: lbWidth, height: lbHeight)
        toastLb.frame = CGRect(x: ((self.bounds.size.width)/2) - ((expectedSize.width + 20)/2), y: self.bounds.height - expectedSize.height - 40 - 20, width: expectedSize.width + 20, height: expectedSize.height + 20)
        self.addSubview(toastLb)
        
        UIView.animate(withDuration: 1.5, delay: 1.5, animations: {
            toastLb.alpha = 0.0
        }) { (complete) in
            toastLb.removeFromSuperview()
        }
    }
    
    func hideToast(){
        for view in self.subviews{
            if view is UILabel , view.tag == 9999{
                view.removeFromSuperview()
            }
        }
    }
}

enum Result<Model> {
    case success(Model)
    case failure(Error)
}
 
final class Webservice {
    func load<Model>(resource: Resource<Model>, completion: @escaping (Result<Model>) -> Void) {
        URLSession.shared.dataTask(with: resource.url) { (data, _, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            } else {
                if let data = data {
                    do {
                        let result = try resource.parse(data)
                        DispatchQueue.main.async {
                            completion(.success(result))
                        }
                    } catch let error {
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                }
            }
        }.resume()
    }
}
struct City: Codable {
  let name: String
}

struct List: Codable {
  let main: Main
  let weather: [Weather]
  let dtTxt: String

  enum CodingKeys: String, CodingKey {
    case main, weather
    case dtTxt = "dt_txt"
  }
}

 struct Main: Codable {
    let temp: Double
 }

 struct Weather: Codable {
    let main, description: String
 }
struct User2: Codable {
  let id: Int
  let userName: String
  let age: Int?

  // Generated automatically by the compiler if not specified
  private enum CodingKeys: String, CodingKey {
    case id
    case userName = "user_name"
    case age
  }
  
  // Generated automatically by the compiler if not specified
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: . id)
    try container.encode(userName, forKey: . userName)
    try container.encode(age, forKey: . age)
  }

 // Generated automatically by the compiler if not specified
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(Int.self, forKey: .id)
    userName = try container.decode(String.self, forKey: .userName)
    age = try container.decode(Int.self, forKey: .age)
  }
}
struct PLNWaypointCoordinate {
    var latitude: Double = 0.0
    var longitude: Double = 0.0

    init(coordinateString: String) {
        self.latitude = convertCoordinate(string: coordinateString.components(separatedBy: ",")[0])
        self.longitude = convertCoordinate(string: coordinateString.components(separatedBy: ",")[1])
    }
    private func convertCoordinate(string: String) -> Double {
        var separatedCoordinate = string.split(separator: " ").map(String.init)

        let direction = separatedCoordinate[0].components(separatedBy: CharacterSet.letters.inverted).first
        let degrees = Double(separatedCoordinate[0].components(separatedBy: CharacterSet.decimalDigits.inverted)[1])
        let minutes = Double(separatedCoordinate[1].components(separatedBy: CharacterSet.decimalDigits.inverted)[0])
        let seconds = Double(separatedCoordinate[2].components(separatedBy: CharacterSet.decimalDigits.inverted)[0])
        let userLatitude = Double(separatedCoordinate[3].components(separatedBy: CharacterSet.decimalDigits.inverted)[0])
        let userLongitude = Double(separatedCoordinate[4].components(separatedBy: CharacterSet.decimalDigits.inverted)[0])
        return convert(degrees: degrees!, minutes: minutes!, seconds: seconds!, direction: direction!)
   }
    public class ToastManager {
        // 单例
        public static let shared = ToastManager()
        // 默认样式
        public var style = ToastStyle()
        
        // 是否支持点击消失隐藏toast，默认是true
        public var isTapToDismissEnabled = true
        // 是否按照点击先后展示，还是立即展示出来
        public var isQueueEnabled = false
        // showToast 展示时间
        public var duration: TimeInterval = 3.0
        // 展示位置 ：默认是底部
        public var position: ToastPosition = .bottom
        
    }
    private func convert(degrees: Double, minutes: Double, seconds: Double, direction: String) -> Double {
        let sign = (direction == "W" || direction == "S") ? -1.0 : 1.0
        return (degrees + (minutes + seconds/60.0)/60.0) * sign
    }
}
extension UIView{
   func showToast2(text: String){
        let toastLb = UILabel()
        toastLb.numberOfLines = 0
        toastLb.lineBreakMode = .byWordWrapping
        toastLb.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLb.textColor = UIColor.white
        toastLb.layer.cornerRadius = 10.0
        toastLb.textAlignment = .center
        toastLb.font = UIFont.systemFont(ofSize: 15.0)
        toastLb.text = text
        toastLb.layer.masksToBounds = true
  }
}

extension UILabel
{
    private struct AssociatedKeys {
        static var padding = UIEdgeInsets()
    }
    
    var padding: UIEdgeInsets? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.padding) as? UIEdgeInsets
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.padding, newValue as UIEdgeInsets?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }}}}
extension AppDelegate: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
    let clLocation = CLLocation(latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude)
  }
}

extension MKPointAnnotation {
    var mapItem: MKMapItem {
        let placemark = MKPlacemark(coordinate: self.coordinate)
        return MKMapItem(placemark: placemark)
}}
public extension UIView {
    func makeToast(_ message: String?, duration: TimeInterval = ToastManager.shared.duration, position: ToastPosition = ToastManager.shared.position, title: String? = nil, image: UIImage? = nil, style: ToastStyle = ToastManager.shared.style, completion: ((_ didTap: Bool) -> Void)? = nil) {
    }
}
final class MapItem: NSObject, MKAnnotation {
    enum ItemType: UInt32 {
        case green = 0
        case orange = 1
        
        var image: UIImage {
            switch self {
            case .green:
                return #imageLiteral(resourceName: "annotation")
            case .orange:
                return #imageLiteral(resourceName: "annotation_orange")
            }
        }
    }
    
    let coordinate: CLLocationCoordinate2D
    let itemType: ItemType
    var image: UIImage { return itemType.image }
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self.itemType = ItemType(rawValue: arc4random_uniform(2)) ?? .green
    }
}
final class MapItemAnnotationView: MKAnnotationView {
    
    override var annotation: MKAnnotation? {
        didSet {
            guard let mapItem = annotation as? MapItem else { return }
            
            clusteringIdentifier = "MapItem"
            image = mapItem.image
        }
    }
}
final class ClusterAnnotationView: MKAnnotationView {
    
    override var annotation: MKAnnotation? {
        didSet {
            guard let cluster = annotation as? MKClusterAnnotation else { return }
            displayPriority = .defaultHigh
            
            let rect = CGRect(x: 0, y: 0, width: 40, height: 40)
         
        }
    }
}

extension Sequence where Element == MKAnnotation {
    var orangeCount: Int {
        return self
            .flatMap { $0 as? MapItem }
            .filter { $0.itemType == .orange }
            .count
    }
}
extension String {
    func drawForCluster(in rect: CGRect) {
        let attributes = [ NSAttributedString.Key.foregroundColor: UIColor.black,
                           NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)]
        let textSize = self.size(withAttributes: attributes)
        let textRect = CGRect(x: (rect.width / 2) - (textSize.width / 2),
                              y: (rect.height / 2) - (textSize.height / 2),
                              width: textSize.width,
                              height: textSize.height)
        
        self.draw(in: textRect, withAttributes: attributes)
    }
}
extension UIViewController {

    func showToast(message : String, font: UIFont,latlng:String) {

    let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    toastLabel.textColor = UIColor.white
    toastLabel.font = font
    toastLabel.textAlignment = .center;
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10;
    toastLabel.clipsToBounds  =  true
    self.view.addSubview(toastLabel)
    UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
         toastLabel.alpha = 0.0
    }, completion: {(isCompleted) in
        toastLabel.removeFromSuperview()
    })
} }
extension String {
    ///16进制字符串转Data
    func hexData() -> Data? {
        var data = Data(capacity: count / 2)
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSMakeRange(0, utf16.count)) { match, flags, stop in
            let byteString = (self as NSString).substring(with: match!.range)
            var num = UInt8(byteString, radix: 16)!
            data.append(&num, count: 1)
        }
        guard data.count > 0 else { return nil }
        return data
    }
    func utf8Data()-> Data? {
        return self.data(using: .utf8)
    }
}
extension Data {
    ///Data转16进制字符串
    func hexString() -> String {
        return map { String(format: "%02x", $0) }.joined(separator: "").uppercased()
    }
}

var centralManager: CBCentralManager!
struct CBUUIDs{

    static let kBLEService_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e"
    static let kBLE_Characteristic_uuid_Tx = "6e400002-b5a3-f393-e0a9-e50e24dcca9e"
    static let kBLE_Characteristic_uuid_Rx = "6e400003-b5a3-f393-e0a9-e50e24dcca9e"

    static let BLEService_UUID = CBUUID(string: kBLEService_UUID)
    static let BLE_Characteristic_uuid_Tx = CBUUID(string: kBLE_Characteristic_uuid_Tx)//(Property = Write without response)
    static let BLE_Characteristic_uuid_Rx = CBUUID(string: kBLE_Characteristic_uuid_Rx)// (Property = Read/Notify)

}
func startScanning() -> Void {
  // Start Scanning
  centralManager?.scanForPeripherals(withServices: [CBUUIDs.BLEService_UUID])
}
