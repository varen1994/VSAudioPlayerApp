//
//  ApiManager.swift
//  WebloomSolutionsSysTest
//
//  Created by Varender Singh on 17/08/20.
//  Copyright © 2020 Varender. All rights reserved.
//

import UIKit
import Alamofire
import SwiftMessages

class ApiManager: NSObject {

    static let shared = ApiManager()
    
    private override init() { }
    
    func getPlayListFromApi(_ completionHandler:@escaping (SongListModel?,String?)->Void)  {
        if Helper.isNetworkConnected() == false {
            completionHandler(nil,Constants.ErrorString.noInternet)
            return
        }
        
        guard let url = URL(string: Constants.URLS.getDataFromApi) else {
            completionHandler(nil,Constants.ErrorString.urlError)
            return
        }
        self.hitApiLocally(url: url, completionHandler)
    }
    
    private func hitApiLocally<T>(url:URL, _ completionHandler:@escaping (T?,String?)->Void) where T:Codable {
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let error = response.error {
                completionHandler(nil,error.localizedDescription)
            } else if let data = response.data {
                do {
                    let jsonDecoder = JSONDecoder.init()
                    let obj = try jsonDecoder.decode(T.self, from: data)
                    completionHandler(obj,nil)
                } catch {
                    completionHandler(nil,Constants.ErrorString.parsingError)
                }
            } else {
              completionHandler(nil,Constants.ErrorString.unknownError)
            }
        }
    }
    
    func downloadAudioFileFromModel(audioFile:WrapperSingleSong) {
        if Helper.isNetworkConnected() == false {
            SwiftMessages.show(view: Helper.createAlertWithMessage(stringMessage:Constants.ErrorString.noInternet))
            return
        }
        guard let urlAudio = URL(string: audioFile.singleObj?.url ?? "") else { return }
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        audioFile.isDownloading = true
        Alamofire.download(
            urlAudio,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: nil,
            to: destination).downloadProgress(closure: { (progress) in
                audioFile.progress = Float(progress.fractionCompleted)
            }).response(completionHandler: { (response) in
                if response.error != nil {
                    audioFile.isDownloaded = false
                } else {
                    audioFile.isDownloaded = true
                }
                audioFile.isDownloading = false
            })
    }
    
}
