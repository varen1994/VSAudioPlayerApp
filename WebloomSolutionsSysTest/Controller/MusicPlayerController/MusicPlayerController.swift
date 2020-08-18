//
//  ViewController.swift
//  WebloomSolutionsSysTest
//
//  Created by Varender Singh on 16/08/20.
//  Copyright © 2020 Varender. All rights reserved.
//

import UIKit
import SwiftMessages
import SnapKit

class MusicPlayerController: UIViewController {

    lazy var activityIndictor:UIActivityIndicatorView = {
        let activityIndictor = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        activityIndictor.hidesWhenStopped = true
        activityIndictor.center = self.view.center
        return activityIndictor
    }()
    
    lazy var refreshControl:UIRefreshControl = {
       let refreshControl = UIRefreshControl(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        refreshControl.tintColor = UIColor.systemBlue
        return refreshControl
    }()
    lazy var searchBar = UISearchBar()
    lazy var tableView = UITableView()
    var model:SongListModel?
    var tracksToShowInTable:[WrapperSingleSong]?  {
           didSet {
               if (tracksToShowInTable?.count ?? 0) == 0 {
                   self.showNoDataFound()
               } else {
                   self.showTheDataFoundInResults()
               }
           }
    }
    var allTracks:[WrapperSingleSong]?
    
    // MARK:- METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpSearchBar()
        self.setUpTableView()
        self.createLayoutForViews()
        self.registerForCells()
        self.initialSetupOfTableView()
        self.getDataFromApi(false)
        self.addRefreshControl()
    }
    
    func setUpTableView() {
        self.tableView.keyboardDismissMode = .onDrag
    }
    
    func setUpSearchBar() {
        self.searchBar.placeholder = Constants.LabelTexts.searchPlaceHolder
        self.searchBar.barStyle = .default
        self.searchBar.showsCancelButton = true
        self.searchBar.searchBarStyle = .minimal
        self.searchBar.delegate = self
        self.searchBar.backgroundColor = UIColor.white
    }
    
    func addRefreshControl() {
        self.tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(pullToRefreshData), for: .valueChanged)
    }
    
    @objc func pullToRefreshData() {
        getDataFromApi(true)
    }
    
    func showNoDataFound() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.layer.frame.width, height: 300))
        let label = UILabel(frame: .zero)
        label.center = view.center
        label.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        label.text = Constants.LabelTexts.noDataFound
        view.addSubview(label)
        label.snp.makeConstraints { (constraintMaker) in
            constraintMaker.center.equalToSuperview()
        }
        label.textColor = UIColor.black
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableHeaderView = view
        self.tableView.reloadData()
    }
    
    func  showTheDataFoundInResults() {
        self.tableView.separatorStyle = .singleLine
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.layer.frame.width, height: 0))
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.layer.frame.width, height: 120))
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
    }
    
    func getDataFromApi(_ fromRefreshControl:Bool) {
        if fromRefreshControl == false {
            self.view.addSubview(self.activityIndictor)
            self.activityIndictor.startAnimating()
        }
        ApiManager.shared.getPlayListFromApi { [weak self] (model, error) in
            DispatchQueue.main.async {
                if fromRefreshControl {
                    self?.refreshControl.endRefreshing()
                } else {
                     self?.activityIndictor.stopAnimating()
                }
                if let error = error {
                    SwiftMessages.show(view: Helper.createAlertWithMessage(stringMessage:error))
                    if (self?.tracksToShowInTable?.count ?? 0) == 0 {
                        self?.showNoDataFound()
                    }
                } else {
                    self?.model = model
                    let list = Helper.convertSingleSongObjectsToWrapperSingleSongs(singleSongs: model?.results ?? [])
                    if self?.searchBar.text?.count == 0 {
                      self?.tracksToShowInTable = list
                    } else if let searchText = self?.searchBar.text {
                        self?.tracksToShowInTable = list.filter({($0.singleObj?.artist?.lowercased().contains(searchText.lowercased()) ?? false) || ($0.singleObj?.name?.lowercased().contains(searchText.lowercased()) ?? false)}) ?? []
                    }
                    self?.allTracks = list
                }
            }
        }
    }
    
    func initialSetupOfTableView() {
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
    }
    
    func registerForCells() {
        self.tableView.register(MusicPlayerCell.nib(), forCellReuseIdentifier: MusicPlayerCell.nibName())
    }
    
    func createLayoutForViews() {
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.searchBar)
        self.searchBar.snp.makeConstraints { (constraintMaker) in
            constraintMaker.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            constraintMaker.leading.equalTo(10)
            constraintMaker.trailing.equalTo(-10)
            constraintMaker.height.equalTo(40)
        }
        self.tableView.snp.makeConstraints { (constraintMaker) in
            constraintMaker.top.equalTo(self.searchBar.snp.bottom).offset(10)
            constraintMaker.width.equalTo(self.view.layer.frame.width)
            constraintMaker.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK:- UITableViewDelegate, UITableViewDataSource
extension MusicPlayerController:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let results = tracksToShowInTable else { return 0 }
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MusicPlayerCell.nibName(), for: indexPath) as? MusicPlayerCell, let singleSong = tracksToShowInTable?[indexPath.row] else { return UITableViewCell() }
        if let songPlaying = AudioPlayer.shared.currentTrack, (songPlaying.singleObj?.id ?? -1) == (singleSong.singleObj?.id ?? 0) {
            cell.contentView.backgroundColor = UIColor.blue.withAlphaComponent(0.15)
        } else {
            cell.contentView.backgroundColor = UIColor.white
        }
        cell.fillDataWithModelResult(wrapperModel: singleSong)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let singleSong = tracksToShowInTable?[indexPath.row] else  { return }
        if Helper.isNetworkConnected() == false && singleSong.isDownloaded == false {
            SwiftMessages.show(view:Helper.createAlertWithMessage(stringMessage: Constants.ErrorString.noInternet))
            return
        }
        if let currentPlaying = AudioPlayer.shared.currentTrack,((currentPlaying.singleObj?.id ?? 0) != (singleSong.singleObj?.id ?? -1)) {
            AudioPlayer.shared.playNewSong(singleSongModel: singleSong)
        } else if  AudioPlayer.shared.audioPlaying == false {
            AudioPlayer.shared.playNewSong(singleSongModel: singleSong)
        }
        self.tableView.reloadData()
    }
    
}

// MARK:- UISearchBarDelegate
extension MusicPlayerController:UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        self.tracksToShowInTable = self.allTracks
        self.searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count != 0 {
            self.tracksToShowInTable = self.allTracks?.filter({($0.singleObj?.artist?.lowercased().contains(searchText.lowercased()) ?? false) || ($0.singleObj?.name?.lowercased().contains(searchText.lowercased()) ?? false)}) ?? []
        } else {
            self.tracksToShowInTable = self.allTracks
        }
    }
}
