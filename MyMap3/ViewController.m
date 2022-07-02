//
//  ViewController.m
//  MapKitTutorialDemo
//
//  Created by PPAM on 8/14/16.
//  Copyright © 2016 Nilesh. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "TopToast.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@end
CLLocationManager *locationManager;
CLGeocoder *geocoder;
int locationFetchCounter;

@implementation ViewController{
    double distance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        geocoder = [[CLGeocoder alloc] init];
    distance = 0;
    NSArray *name=[[NSArray alloc]initWithObjects:
                   @"Los Angles",
                   @"Sanfransisco",nil];
    
    NSMutableArray *arrCoordinateStr = [[NSMutableArray alloc] initWithCapacity:name.count];
    
    [arrCoordinateStr addObject:@"34.0207504,-118.69193"];
    [arrCoordinateStr addObject:@"37.757815,-122.5076406"];
    
    for(int i = 0; i < name.count; i++)
    {
        [self addPinWithTitle:name[i] AndCoordinate:arrCoordinateStr[i]];
    }

    CLLocationCoordinate2D losAngles = CLLocationCoordinate2DMake(34.0207504,-118.69193);
    
    [self.mapView setRegion: MKCoordinateRegionMakeWithDistance(losAngles, 2955000, 1805000)];

    [self.mapView setMapType: MKMapTypeStandard];

    // Do any additional setup after loading the view, typically from a nib.
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        [renderer setStrokeColor:[UIColor blueColor]];
        [renderer setLineWidth:3.0];
        return renderer;
    }
    return nil;
}

- (IBAction)doFetchCurrentLocation:(id)sender {
    locationFetchCounter = 0;

    // fetching current location start from here
    [locationManager startUpdatingLocation];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // this delegate method is constantly invoked every some miliseconds.
    // we only need to receive the first response, so we skip the others.
    if (locationFetchCounter > 0) return;
    locationFetchCounter++;

    // after we have current coordinates, we use this method to fetch the information data of fetched coordinate
    [geocoder reverseGeocodeLocation:[locations lastObject] completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks lastObject];

        NSString *street = placemark.thoroughfare;
        NSString *city = placemark.locality;
        NSString *posCode = placemark.postalCode;
        NSString *country = placemark.country;

        NSLog(@"we live in %@", country);

        // stopping locationManager from fetching again
        [locationManager stopUpdatingLocation];
    }];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"failed to fetch current location : %@", error);
}
#pragma mark - AddPin Method

-(void)addPinWithTitle:(NSString *)title AndCoordinate:(NSString *)strCoordinate
{
    MKPointAnnotation *mapPin = [[MKPointAnnotation alloc] init];
    strCoordinate = [strCoordinate stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSArray *components = [strCoordinate componentsSeparatedByString:@","];
    double latitude = [components[0] doubleValue];
    double longitude = [components[1] doubleValue];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    mapPin.title = title;
    mapPin.coordinate = coordinate;
    
    [self.mapView addAnnotation:mapPin];
    [self loadRoute];
}
- (IBAction)acion:(id)sender {
    [TopToast showToptoastWithText:@"聖地牙哥與洛杉磯路線" duration:2 height:64 backGroundColor:[UIColor blueColor] alpha:1.0];
 }
#pragma mark - Show Route Direction

-(void)loadRoute
{
    MKPlacemark *source = [[MKPlacemark alloc]initWithCoordinate:CLLocationCoordinate2DMake(34.0207504,-118.69193) addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil] ];
    
    MKMapItem *srcMapItem = [[MKMapItem alloc]initWithPlacemark:source];
    [srcMapItem setName:@""];
    
    MKPlacemark *destination = [[MKPlacemark alloc]initWithCoordinate:CLLocationCoordinate2DMake(37.757815,-122.5076406) addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil] ];
    
    MKMapItem *distMapItem = [[MKMapItem alloc]initWithPlacemark:destination];
    [distMapItem setName:@""];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
    [request setSource:srcMapItem];
    [request setDestination:distMapItem];
    [request setTransportType:MKDirectionsTransportTypeAutomobile];
    
    MKDirections *direction = [[MKDirections alloc]initWithRequest:request];
    
    [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        
        NSLog(@"response = %@",response);
        NSArray *arrRoutes = [response routes];
        [arrRoutes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            MKRoute *rout = obj;
            
            MKPolyline *line = [rout polyline];
            [self.mapView addOverlay:line];
            NSLog(@"Rout Name : %@",rout.name);
            NSLog(@"Total Distance (in Meters) :%f",rout.distance);
            
            NSArray *steps = [rout steps];
            
            NSLog(@"Total Steps : %lu",(unsigned long)[steps count]);
            
            [steps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSLog(@"Rout Instruction : %@",[obj instructions]);
                NSLog(@"Rout Distance : %f",[obj distance]);
                distance = distance +[obj distance];
                self.distanceLabel.text = [NSString stringWithFormat:@"The Total distance is %f",distance];
                
            }];
        }];
    }];
    
}
     @end
