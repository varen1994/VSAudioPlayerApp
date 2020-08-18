//
//  MusicPlayerCell.swift
//  WebloomSolutionsSysTest
//
//  Created by Varender Singh on 16/08/20.
//  Copyright © 2020 Varender. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage
import CircleProgressView

class MusicPlayerCell: UITableViewCell {

    lazy var imageViewAudio = UIImageView()
    lazy var labelTitle = UILabel()
    lazy var labelArtist = UILabel()
    lazy var stackView = UIStackView()
    lazy var categoryImage = UIImageView()
    lazy var labelCategoryName = UILabel()
    lazy var buttonDownload = UIButton()
    lazy var progressView = CircleProgressView()
    var object:WrapperSingleSong?
    var kvoToken: NSKeyValueObservation?
    var kvoTokenForInProgress: NSKeyValueObservation?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.progressView.centerFillColor = UIColor.white
        self.progressView.backgroundColor = UIColor.white
        self.progressView.trackFillColor = UIColor.blue
        self.progressView.trackWidth = 1.5
        self.progressView.isHidden = true
        self.buttonDownload.setImage(UIImage(named: Constants.Images.downloadIcon), for: .normal)
        self.buttonDownload.setTitle(nil, for: .normal)
        self.buttonDownload.isUserInteractionEnabled = true
        self.buttonDownload.tintColor = UIColor.black
        self.imageViewAudio.contentMode = .scaleAspectFill
        self.categoryImage.contentMode = .scaleAspectFit
        self.imageViewAudio.backgroundColor = UIColor.white
        self.labelTitle.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        self.labelArtist.font = UIFont.systemFont(ofSize: 13, weight: .thin)
        self.labelTitle.numberOfLines = 1
        self.labelCategoryName.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        self.createLayoutForTheElements()
        self.stackView.axis = .horizontal
        self.stackView.spacing = 10.0
        self.imageViewAudio.layer.cornerRadius = 10.0
        self.imageViewAudio.layer.masksToBounds = true
        self.buttonDownload.addTarget(self, action: #selector(self.downloadButtonClicked), for: .touchUpInside)
        self.imageViewAudio.image = UIImage(named: Constants.Images.headphones)
    }
    
    @objc func downloadButtonClicked() {
        ApiManager.shared.downloadAudioFileFromModel(audioFile: self.object!)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func fillDataWithModelResult(wrapperModel:WrapperSingleSong) {
        self.object = wrapperModel
        if wrapperModel.isDownloaded {
            self.buttonDownload.isHidden = true
        } else {
            self.buttonDownload.isHidden = false
        }
        guard let model = wrapperModel.singleObj else { return }
        if let imgaeUrl = model.thumbnail,imgaeUrl.count > 0 {
            self.imageViewAudio.sd_setImage(with: URL(string: imgaeUrl)) { (image, error, type, url) in
                if image == nil {
                    self.imageViewAudio.image = UIImage(named: Constants.Images.headphones)
                }
            }
        }
        self.labelTitle.text = model.name ?? ""
        self.labelArtist.text = model.artist ?? ""
        if let iconUrl = model.category?.icon {
           self.categoryImage.sd_setImage(with: URL(string: iconUrl), completed: nil)
        }
        self.labelCategoryName.text = model.category?.name ?? ""
    
        kvoTokenForInProgress = self.object?.observe(\.isDownloading, options: .new) { (song, value) in
            if wrapperModel.isDownloaded {
                self.buttonDownload.isHidden = true
                self.progressView.isHidden = true
            } else {
                self.buttonDownload.isHidden = wrapperModel.isDownloading
                self.progressView.isHidden = !wrapperModel.isDownloading
            }
        }
        
        kvoToken = self.object?.observe(\.progress, options: .new) { (song, value) in
            self.progressView.isHidden = false
            self.progressView.progress = Double(self.object?.progress ?? 0.0)
        }
    }
    
    func createLayoutForTheElements() {
        self.contentView.addSubview(self.imageViewAudio)
        self.imageViewAudio.snp.makeConstraints { (constraintMaker) in
            constraintMaker.leading.equalToSuperview().offset(20)
            constraintMaker.top.equalToSuperview().offset(10)
            constraintMaker.width.equalTo(80)
            constraintMaker.bottom.equalToSuperview().offset(-10)
        }
        
        self.contentView.addSubview(self.progressView)
        self.progressView.snp.makeConstraints { (constraintMaker) in
            constraintMaker.trailing.equalToSuperview().offset(-20)
            constraintMaker.top.equalToSuperview().offset(10)
            constraintMaker.width.equalTo(40)
            constraintMaker.height.equalTo(40)
        }
        
        
        self.contentView.addSubview(self.buttonDownload)
        self.buttonDownload.snp.makeConstraints { (constraintMaker) in
            constraintMaker.trailing.equalToSuperview().offset(-20)
            constraintMaker.top.equalToSuperview().offset(10)
            constraintMaker.width.equalTo(40)
        }
        
        
        self.contentView.addSubview(self.labelTitle)
        self.labelTitle.snp.makeConstraints { (constraintMaker) in
            constraintMaker.leading.equalTo(self.imageViewAudio.snp.trailing).offset(10)
            constraintMaker.trailing.equalTo(self.buttonDownload.snp.leading).offset(5)
            constraintMaker.top.equalToSuperview().offset(10)
        }
        self.contentView.addSubview(self.labelArtist)
        self.labelArtist.snp.makeConstraints { (constraintMaker) in
            constraintMaker.top.equalTo(self.labelTitle.snp.bottom).offset(5)
            constraintMaker.trailing.equalTo(self.buttonDownload.snp.leading).offset(5)
            constraintMaker.leading.equalTo(self.imageViewAudio.snp.trailing).offset(10)
        }
        
        self.stackView.backgroundColor = UIColor.red
        self.contentView.addSubview(self.stackView)
        self.stackView.snp.makeConstraints { (constraintMaker) in
            constraintMaker.top.equalTo(self.labelArtist.snp.bottom).offset(0)
            constraintMaker.trailing.equalToSuperview().offset(-10)
            constraintMaker.leading.equalTo(self.imageViewAudio.snp.trailing).offset(10)
            constraintMaker.bottom.equalToSuperview().offset(-10)
        }
        self.categoryImage.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        self.stackView.addArrangedSubview(self.categoryImage)
        self.stackView.addArrangedSubview(self.labelCategoryName)
        self.categoryImage.snp.makeConstraints { (constraintMaker) in
            constraintMaker.width.equalTo(35)
        }
        

    }
    
}
