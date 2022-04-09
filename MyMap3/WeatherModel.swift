

import Foundation

struct WeatherModel: Decodable {
    
    let localObservationDateTime: String
    let epochTime: TimeInterval
    let weatherText: String
    let isDayTime: Bool
    
    struct Temperature: Decodable {
        struct Metric: Decodable {
            let value: Double
            let unit: String
            let unitType: Int
            private enum CodingKeys: String, CodingKey {
                case value = "Value"
                case unit = "Unit"
                case unitType = "UnitType"
            }
            ///Users/siemonyan/Desktop/GeoCoder3/GeoCoder3/SwiftUIKivaLoanApp.swift:13:9: Generic parameter 'Content' could not be inferred
        }
        let metric: Metric
        private enum CodingKeys: String, CodingKey {
            case metric = "Metric"
        }
    }
    let temperature: Temperature
    let mobileLink: URL
    let link: URL
    private enum CodingKeys: String, CodingKey {
        case localObservationDateTime = "LocalObservationDateTime"
        case epochTime = "EpochTime"
        case weatherText = "WeatherText"
        case isDayTime = "IsDayTime"
        case temperature = "Temperature"
        case mobileLink = "MobileLink"
        case link = "Link"
    }
}
