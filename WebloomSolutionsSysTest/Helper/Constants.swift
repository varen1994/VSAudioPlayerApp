//
//  Constants.swift
//  WebloomSolutionsSysTest
//
//  Created by Varender Singh on 17/08/20.
//  Copyright © 2020 Varender. All rights reserved.
//

import UIKit

class Constants: NSObject {
    
    static let baseURL = "https://run.mocky.io"
    
    struct URLS {
        static let getDataFromApi = Constants.baseURL + "/v3/4b4ef6d4-3242-4b82-ab34-d9200f716a48"
    }
    
    struct LabelTexts {
        static let searchPlaceHolder = "Search Track or Artist"
        static let noDataFound = "No Data Found"
    }
    
    struct ErrorString {
        static let noInternet = "No Internet Connection."
        static let unknownError = "Unknown error occured while fetching data. Please try again later."
        static let parsingError = "Error occured while parsing json."
        static let urlError = "URL is incorrect."
    }
    
    struct Images {
        static let playerPlay =  "PlayerPlay"
        static let playerPause =  "PlayerPause"
        static let downloadIcon = "DownloadIcon"
        static let headphones = "headphones"
    }
}
