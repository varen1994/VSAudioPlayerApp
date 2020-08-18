//
//  Helper.swift
//  WebloomSolutionsSysTest
//
//  Created by Varender Singh on 17/08/20.
//  Copyright © 2020 Varender. All rights reserved.
//

import UIKit
import Alamofire
import SwiftMessages

class Helper: NSObject {
    
    class func isNetworkConnected()->Bool {
       return NetworkReachabilityManager()?.isReachable ?? false
    }
    
    class func checkIfTheSongHasAlreadyBeenDownloadedOrNot(singleSong:SingleSong)->(String?,Bool) {
        guard let fileName = singleSong.url?.components(separatedBy: "/").last else {return (nil,false) }
        if let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let newPath = path + "/\(fileName)"
            return (newPath,FileManager.init().fileExists(atPath: newPath))
        }
        return (nil,false)
    }
    
    class func createNewPath(singleSong:SingleSong)->String? {
        guard let fileName = singleSong.url?.components(separatedBy: "/").last else {return nil }
          if let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
          let newPath = path + "/\(fileName)"
           return newPath
        }
        return nil
    }
    
    class func convertSingleSongObjectsToWrapperSingleSongs(singleSongs:[SingleSong])->[WrapperSingleSong] {
        return singleSongs.map { (obj) -> WrapperSingleSong in
            return WrapperSingleSong(singleObj: obj)
        }
    }
    
    class func createAlertWithMessage(stringMessage:String)->MessageView {
        let message = MessageView.viewFromNib(layout: .cardView)
        message.button?.isHidden = true
        message.titleLabel?.text = nil
        message.bodyLabel?.text = stringMessage
        message.configureTheme(.error)
        return message
    }
    
    class func convertTimeIntoString(time:CGFloat)->String {
       var minutes = Int(time/60)
       var hours = 0
       if minutes > 60 {
          minutes = minutes%60
          hours = minutes/60
       }
        let seconds = Int(Float(time).truncatingRemainder(dividingBy: 60.0))
       var time = ""
        if hours > 0 {
            if hours > 9 {
               time += "\(hours):"
            } else {
               time += "0\(hours):"
            }
        }
        
        if minutes > 9 {
            time += "\(minutes):"
         } else {
            time += "0\(minutes):"
        }
        
        if seconds > 9 {
            time += "\(seconds)"
         } else {
            time += "0\(seconds)"
        }
        return time
    }
    
}


extension UIButton {
    func fillDataInImageViewAccordingToPlayerState() {
        if AudioPlayer.shared.audioPlaying == false {
            self.setImage(UIImage(named: Constants.Images.playerPlay), for: .normal)
       } else {
            self.setImage(UIImage(named: Constants.Images.playerPause), for: .normal)
       }
    }
}
