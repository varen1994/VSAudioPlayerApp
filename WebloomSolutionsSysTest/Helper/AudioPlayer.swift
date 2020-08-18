//
//  AudioPlayer.swift
//  WebloomSolutionsSysTest
//
//  Created by Varender Singh on 17/08/20.
//  Copyright © 2020 Varender. All rights reserved.
//

import UIKit
import AVFoundation


protocol AudioPlayerDelegateToCustomNC:class {
    func clickedOnImageOfPlayingSong()
}

@objc class AudioPlayer: NSObject {
    weak var delegate:AudioPlayerDelegateToCustomNC?
    static let shared = AudioPlayer()
    var avPlayer:AVPlayer?
    var currentTrack:WrapperSingleSong?
    lazy var playerView:PlayerView? = {
        let playerView = PlayerView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height-110, width: 340, height: 100))
        playerView.delegate = self
        return playerView
    }()
    var timer:Timer?
    @objc dynamic var audioPlaying = false
    @objc dynamic var maxTime:Double = 0.0
    @objc dynamic var currentTime:Double = 0.0
    
    
    // MARK:- ---------------- METHODS -----------------
    private override init() {
        super.init()
        avPlayer = AVPlayer()
        NotificationCenter.default.addObserver(self, selector: #selector(self.audioPlayerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func playNewSong(singleSongModel:WrapperSingleSong) {
        self.playerView?.slider.setValue(0, animated: false)
        if self.currentTrack == nil {
            if let window =  UIApplication.shared.windows.first {
                playerView?.center.x = UIScreen.main.bounds.width/2
                window.addSubview(self.playerView!)
            }
            playerView?.snp.makeConstraints({ (constraintMaker) in
                constraintMaker.bottom.equalTo(-30)
                constraintMaker.leading.equalTo(30)
                constraintMaker.trailing.equalTo(-30)
                constraintMaker.height.equalTo(100)
            })
            playerView?.addShadowAroundView()
        }
        
        var url:URL?
        if singleSongModel.isDownloaded == false {
           url = URL(string: singleSongModel.singleObj?.url ?? "")
        } else if let localPath = singleSongModel.filePath {
            url = URL(fileURLWithPath: localPath)
        }
        guard let newURL = url else { return }
        let playerItem = AVPlayerItem(url: newURL)
        self.avPlayer = AVPlayer(playerItem: playerItem)
        self.startPlayingTrack()
        self.currentTrack = singleSongModel
        maxTime = playerItem.asset.duration.seconds
        if let singleSong = singleSongModel.singleObj {
            self.playerView?.initializeWithModel(model: singleSong,maxValue: CGFloat(maxTime))
        }
    }
    
    func createTimer() {
         timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.observeValueOfAudio), userInfo: nil, repeats: true)
    }
    
    @objc func observeValueOfAudio() {
        if let playerTime = self.avPlayer?.currentItem?.currentTime() {
            self.currentTime = playerTime.seconds 
        }
    }
    
    func startPlayingTrack() {
        self.createTimer()
        self.audioPlaying = true
        self.avPlayer?.play()
    }
    
    func stopPlayingTrack() {
        self.audioPlaying = false
        self.avPlayer?.pause()
        timer?.invalidate()
    }
    
    @objc func audioPlayerDidFinishPlaying() {
        self.stopPlayingTrack()
        self.playerView?.slider.value = Float(self.maxTime ?? 0.0)
    }
}

extension AudioPlayer:PlayerViewProtocols {
   
    func showFullScreenSongPlaying() {
        if let delegate = self.delegate {
            delegate.clickedOnImageOfPlayingSong()
        }
    }
   
    func changedTimerOfSlider(value: Float) {
        if let audioPlayer = self.avPlayer {
            audioPlayer.seek(to: CMTimeMakeWithSeconds(Float64(value), preferredTimescale: 600))
            self.startPlayingTrack()
        }
    }
    
    func stopButtonClicked() {
        self.stopPlayingTrack()
    }
    
    func startButtonClicked() {
        if self.playerView?.slider.value == self.playerView?.slider.maximumValue {
            guard let currentPlaying = self.currentTrack else { return }
            self.playNewSong(singleSongModel: currentPlaying)
        } else {
           self.startPlayingTrack()
        }
    }
}
