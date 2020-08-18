//
//  PlayerViewController.swift
//  WebloomSolutionsSysTest
//
//  Created by Varender Singh on 17/08/20.
//  Copyright © 2020 Varender. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage

class PlayerViewController: UIViewController {

    lazy var imageOfTrack = UIImageView()
    lazy var titleLabel = UILabel()
    lazy var artistLabel = UILabel()
    lazy var sliderView = UISlider()
    lazy var currentTimeLabel = UILabel()
    lazy var maxTimeLabel = UILabel()
    lazy var startStopButton = UIButton()
    weak var delegate:PlayerViewProtocols?
    var kvoTokenForAudioPlaying: NSKeyValueObservation?
    var kvoTokenForCurrentTime: NSKeyValueObservation?
    var kvoTokenForMaxTime: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDataInView()
        playerStateChangedObserver()
        self.delegate = AudioPlayer.shared
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.kvoTokenForAudioPlaying = nil
        self.kvoTokenForCurrentTime = nil
        self.kvoTokenForMaxTime = nil
      //  AudioPlayer.shared.playerView?.delegate = AudioPlayer.shared
    }
    
    func playerStateChangedObserver() {
        kvoTokenForAudioPlaying = AudioPlayer.shared.observe(\.audioPlaying, changeHandler: { (player, change) in
            self.startStopButton.fillDataInImageViewAccordingToPlayerState()
        })
        kvoTokenForCurrentTime = AudioPlayer.shared.observe(\.currentTime, options: .new, changeHandler: { (player, change) in
            self.sliderView.value = Float(player.currentTime)
            self.currentTimeLabel.text = Helper.convertTimeIntoString(time: CGFloat(player.currentTime))
        })
        kvoTokenForMaxTime = AudioPlayer.shared.observe(\.currentTime, options: .init(), changeHandler: { (player, change) in
            self.sliderView.maximumValue = Float(player.maxTime)
            self.maxTimeLabel.text = Helper.convertTimeIntoString(time: CGFloat(player.maxTime))
        })
    }
    
    func setDataInView() {
        self.imageOfTrack.layer.cornerRadius = 20
        self.imageOfTrack.layer.masksToBounds = true
        self.sliderView.addTarget(self, action: #selector(self.sliderValueChanged), for: .valueChanged)
        self.startStopButton.fillDataInImageViewAccordingToPlayerState()
        self.imageOfTrack.contentMode = .scaleAspectFit
        self.titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        self.artistLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        if let model = AudioPlayer.shared.currentTrack {
            if let singleSong = model.singleObj {
                if let imageURL = singleSong.thumbnail,imageURL.count > 0 {
                    self.imageOfTrack.sd_setImage(with: URL(string: imageURL)) { (image, error, cache, url) in
                    if image == nil {
                      self.imageOfTrack.image = UIImage(named: Constants.Images.headphones)
                    }
                }
             }
                self.titleLabel.text = singleSong.name ?? ""
                self.artistLabel.text = singleSong.artist ?? ""
           }
        }
        self.startStopButton.addTarget(self, action: #selector(self.startStopButtonClicked), for: .touchUpInside)
    }
    
    @objc func startStopButtonClicked() {
        if AudioPlayer.shared.audioPlaying {
            self.delegate?.stopButtonClicked()
        } else {
            self.delegate?.startButtonClicked()
        }
    }
    
    @objc func sliderValueChanged() {
        guard let delegate = self.delegate else { return }
        delegate.changedTimerOfSlider(value: self.sliderView.value)
    }
    
    override func viewWillLayoutSubviews() {
        self.view.addSubview(self.imageOfTrack)
        imageOfTrack.snp.makeConstraints { (constraintMaker) in
            constraintMaker.leading.equalToSuperview().offset(20)
            constraintMaker.trailing.equalToSuperview().offset(-20)
            constraintMaker.top.equalToSuperview().offset(30)
            constraintMaker.height.equalTo(self.imageOfTrack.snp.width)
        }
        self.view.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { (constraintMaker) in
            constraintMaker.top.equalTo(imageOfTrack.snp.bottom).offset(15)
            constraintMaker.leading.equalToSuperview().offset(20)
            constraintMaker.trailing.equalToSuperview().offset(-20)
        }
        self.view.addSubview(self.artistLabel)
        self.artistLabel.snp.makeConstraints { (constraintMaker) in
            constraintMaker.top.equalTo(titleLabel.snp.bottom).offset(5)
            constraintMaker.leading.equalToSuperview().offset(20)
            constraintMaker.trailing.equalToSuperview().offset(-20)
        }
        
        self.view.addSubview(self.sliderView)
        self.sliderView.snp.makeConstraints { (constraintMaker) in
            constraintMaker.top.equalTo(artistLabel.snp.bottom).offset(15)
            constraintMaker.leading.equalToSuperview().offset(20)
            constraintMaker.trailing.equalToSuperview().offset(-20)
        }
        
        self.view.addSubview(self.currentTimeLabel)
        self.currentTimeLabel.snp.makeConstraints { (constraintMaker) in
            constraintMaker.top.equalTo(sliderView.snp.bottom).offset(10)
            constraintMaker.leading.equalTo(self.sliderView.snp.leading)
            constraintMaker.height.equalTo(40)
        }
        
        self.view.addSubview(self.startStopButton)
        self.startStopButton.snp.makeConstraints { (constraintMaker) in
            constraintMaker.top.equalTo(sliderView.snp.bottom).offset(10)
            constraintMaker.centerX.equalTo(sliderView.snp.centerX)
            constraintMaker.height.equalTo(40)
            constraintMaker.width.equalTo(40)
        }
        
        self.view.addSubview(self.maxTimeLabel)
        self.maxTimeLabel.snp.makeConstraints { (constraintMaker) in
            constraintMaker.top.equalTo(sliderView.snp.bottom).offset(10)
            constraintMaker.trailing.equalTo(self.sliderView.snp.trailing)
            constraintMaker.height.equalTo(40)
        }
        
    }
    
    deinit {
        print(String(describing: self) + "-------- Deallocated")
    }

}
