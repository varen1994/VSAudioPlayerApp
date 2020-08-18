//
//  WrapperSingleSong.swift
//  WebloomSolutionsSysTest
//
//  Created by Varender Singh on 17/08/20.
//  Copyright © 2020 Varender. All rights reserved.
//

import UIKit

@objc class WrapperSingleSong: NSObject {
    var singleObj:SingleSong?
    @objc dynamic var isDownloading = false
    @objc dynamic var progress:Float = 0
    @objc dynamic var isDownloaded = false
    var filePath:String?
    
    init(singleObj:SingleSong) {
        self.singleObj = singleObj
        let tupple = Helper.checkIfTheSongHasAlreadyBeenDownloadedOrNot(singleSong: singleObj)
        self.isDownloaded = tupple.1
        self.filePath = tupple.0
    }
}
