//
//  PlayerView.swift
//  WebloomSolutionsSysTest
//
//  Created by Varender Singh on 17/08/20.
//  Copyright © 2020 Varender. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage


protocol PlayerViewProtocols:class {
    func changedTimerOfSlider(value:Float)
    func stopButtonClicked()
    func startButtonClicked()
    func showFullScreenSongPlaying()
}

class PlayerView: UIView {

    weak var delegate:PlayerViewProtocols?
    lazy var imageViewTrack = UIImageView()
    lazy var labelTrackName = UILabel()
    lazy var horizontalStackView = UILabel()
    lazy var slider = UISlider()
    lazy var labelCurrentTime = UILabel()
    lazy var labelMaxTime = UILabel()
    lazy var buttonStartStop = UIButton()
    lazy var stackView = UIStackView()
    var kvoTokenForAudioPlaying: NSKeyValueObservation?
    var kvoTokenForCurrentTime: NSKeyValueObservation?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpElementsOfView()
        self.setUpLayout()
        self.playerStateChangedObserver()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func removeFromSuperview() {
        self.kvoTokenForAudioPlaying = nil
        self.kvoTokenForCurrentTime = nil
        super.removeFromSuperview()
    }
    
    deinit {
       print("Player view dismissed")
    }
       
    func initializeWithModel(model:SingleSong,maxValue:CGFloat) {
           if let imageURL = model.thumbnail {
            imageViewTrack.sd_setImage(with: URL(string: imageURL)) { [weak self](image, error, cache, url) in
                if image == nil {
                    self?.imageViewTrack.image = UIImage(named: Constants.Images.headphones)
                }
            }
           }
           self.labelTrackName.text = model.name ?? "N/A"
           self.showCurrentTime(timePcent: 3.0, maxValue: maxValue)
    }
    
    func setUpLayout() {
        self.labelTrackName.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        self.backgroundColor = UIColor.white
      
        self.slider.value = 0.0
        self.slider.addTarget(self, action: #selector(self.sliderValueChanged), for: .valueChanged)
        self.buttonStartStop.addTarget(self, action: #selector(self.buttonStartStopClicked), for: .touchUpInside)
        self.labelMaxTime.font = UIFont.systemFont(ofSize: 13, weight: .ultraLight)
        self.labelCurrentTime.font = UIFont.systemFont(ofSize: 13, weight: .ultraLight)
        self.imageViewTrack.layer.cornerRadius = 10
        self.imageViewTrack.layer.masksToBounds = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedImage))
        imageViewTrack.isUserInteractionEnabled = true
        imageViewTrack.addGestureRecognizer(tapRecognizer)
    }
    
    func addShadowAroundView() {
        self.layer.cornerRadius = 10.0
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 10.0
        self.layer.shadowOpacity = 0.25
        self.layer.shadowPath = UIBezierPath(roundedRect: self.layer.bounds, cornerRadius: 10).cgPath
    }
    
    @objc func tappedImage() {
        if let delegate = delegate {
           delegate.showFullScreenSongPlaying()
        }
    }
    
    @objc func buttonStartStopClicked() {
        if AudioPlayer.shared.audioPlaying {
            self.delegate?.stopButtonClicked()
        } else {
            self.delegate?.startButtonClicked()
        }
    }
    
    func playerStateChangedObserver() {
        kvoTokenForAudioPlaying = AudioPlayer.shared.observe(\.audioPlaying, changeHandler: { (player, change) in
            self.buttonStartStop.fillDataInImageViewAccordingToPlayerState()
        })
        kvoTokenForCurrentTime = AudioPlayer.shared.observe(\.currentTime, options: .new, changeHandler: { (player, change) in
            self.slider.value = Float(player.currentTime)
            self.labelCurrentTime.text = Helper.convertTimeIntoString(time: CGFloat(player.currentTime))
        })
    }
    
    func setUpElementsOfView() {
        self.addSubview(self.imageViewTrack)
        imageViewTrack.snp.makeConstraints { (constraintMaker) in
            constraintMaker.top.leading.equalTo(10)
            constraintMaker.width.equalTo(80)
            constraintMaker.bottom.equalToSuperview().offset(-10)
        }
        self.addSubview(self.labelTrackName)
        self.labelTrackName.snp.makeConstraints { (constraintMaker) in
            constraintMaker.top.equalTo(10)
            constraintMaker.leading.equalTo(imageViewTrack.snp.trailing).offset(10)
            constraintMaker.trailing.equalToSuperview().offset(-10)
        }
        self.addSubview(self.slider)
        self.slider.snp.makeConstraints { (constraintMaker) in
            constraintMaker.centerY.equalToSuperview().offset(-4)
            constraintMaker.leading.equalTo(imageViewTrack.snp.trailing).offset(10)
            constraintMaker.trailing.equalToSuperview().offset(-10)
            constraintMaker.height.equalTo(5.0)
        }
        
        self.addSubview(self.labelCurrentTime)
        self.addSubview(self.labelMaxTime)
        self.addSubview(self.buttonStartStop)
       
        self.buttonStartStop.snp.makeConstraints { (constraintMaker) in
            constraintMaker.top.equalTo(self.slider.snp.bottom).offset(6)
            constraintMaker.centerX.equalTo(self.slider.snp.centerX)
            constraintMaker.width.equalTo(50)
            constraintMaker.height.equalTo(50)
        }
        self.labelCurrentTime.snp.makeConstraints { (constraintMaker) in
            constraintMaker.centerY.equalTo(self.buttonStartStop.snp.centerY)
            constraintMaker.leading.equalTo(self.slider.snp.leading)
            constraintMaker.width.equalTo(60)
        }
        self.labelMaxTime.snp.makeConstraints { (constraintMaker) in
            constraintMaker.centerY.equalTo(self.buttonStartStop.snp.centerY)
            constraintMaker.trailing.equalTo(self.slider.snp.trailing)
        }
        
    }
    
    func showCurrentTime(timePcent:CGFloat,maxValue:CGFloat) {
        self.slider.maximumValue = Float(maxValue)
        self.slider.setValue(Float(timePcent), animated: true)
        self.labelCurrentTime.text = Helper.convertTimeIntoString(time: timePcent)
        self.labelMaxTime.text = Helper.convertTimeIntoString(time: maxValue)
    }
    
    @objc func sliderValueChanged() {
        guard let delegate = self.delegate else { return }
        delegate.changedTimerOfSlider(value: self.slider.value)
    }
    
    
}
