//
//  MediaManagerViewController.swift
//  DJISDKSwiftDemo
//
//  Created by Mohsin Sherin on 04/01/2023.
//  Copyright © 2023 DJI. All rights reserved.
//

import UIKit
import GSImageViewerController
import Photos

class MediaManagerViewController: UIViewController, DJICameraDelegate, DJIMediaManagerDelegate
{

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var popupView: UIView!
    
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var mediaManagerCollectionView: UICollectionView!
    
    var mediaManager: DJIMediaManager? = nil
    var mediaList:[DJIMediaFile]? = nil
    var selectedCellIndexPath: IndexPath? = nil
    
    var statusAlertView: UIAlertController?
    var selectedMedia : DJIMediaFile? = nil
    var previousOffset = UInt(0)
    var fileData:Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mediaList = [DJIMediaFile]()
        self.fileData = nil
        self.selectedMedia = nil
        self.previousOffset = 0
        imageView.isHidden = true
        popupView.isHidden = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        loading.isHidden = true
        loadingLabel.isHidden = true
        mediaManagerCollectionView.isHidden = true
        let optionCamera = fetchCamera()
        guard let camera = optionCamera else {
            print("Couldn't Get Camera")
            return
        }
        loading.isHidden = false
        loadingLabel.isHidden = false
        camera.delegate = self
        self.mediaManager = camera.mediaManager
        self.mediaManager?.delegate = self
        self.setCameraMode(cameraMode: .mediaDownload)
        self.loadMediaImages()
        
    }
    

    @IBAction func closePoupView(_ sender: Any) {
        self.imageView.isHidden = true
        self.popupView.isHidden = true
    }
    
    func updateMediaList(mediaListFileList:[DJIMediaFile]) {
        self.mediaList?.removeAll()
        self.mediaList?.append(contentsOf: mediaListFileList)

        if let mediaTaskScheduler = fetchCamera()?.mediaManager?.taskScheduler {
            mediaTaskScheduler.suspendAfterSingleFetchTaskFailure = false
            mediaTaskScheduler.resume(completion: nil)
            self.mediaList?.forEach({ (file:DJIMediaFile) in
                if file.thumbnail == nil {
                    let task = DJIFetchMediaTask(file: file, content: DJIFetchMediaTaskContent.thumbnail) {[weak self] (file: DJIMediaFile, content: DJIFetchMediaTaskContent, error: Error?) in
                        self?.mediaManagerCollectionView.reloadData()
                    }
                    mediaTaskScheduler.moveTask(toEnd: task)
                }
            })
            self.loading.isHidden = true
            self.loadingLabel.isHidden = true
            self.mediaManagerCollectionView.isHidden = false
        }
    }
    
    func loadMediaImages(){
        
        if(self.mediaManager?.sdCardFileListState == .syncing || self.mediaManager?.sdCardFileListState == .deleting){
            Toast.show(message: "SD Card is busy", controller: self)
        }else{
            self.mediaManager?.refreshFileList(of: .sdCard, withCompletion: {(error: Error?) in
                if error != nil {
                    //self?.needToSetMode = true
                    NSLog("Unable to fetch Media");
                }else{
                    if let mediaListFileList = self.mediaManager?.sdCardFileListSnapshot(){
                        self.updateMediaList(mediaListFileList: mediaListFileList)
                    }
                }
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let camera = fetchCamera() else {return}
        camera.exitPlayback(completion: { [weak self] (error: Error?) in
            if error != nil {
                NSLog("Error to Exit Playback");
            }
        })
        guard let cameraDelegate = camera.delegate else{
            return
        }
        
        if(cameraDelegate.isEqual(self)){
            camera.delegate = nil
            self.mediaManager?.delegate = nil
        }
    }
    
    @objc func closingPopup(){
        self.statusAlertView?.dismiss(animated: true)
        self.statusAlertView = nil
    }
    
    func closingImagePreviwerPopup(){
        self.popupView.isHidden = true
        self.imageView.isHidden = true
    }
    
    func openImageMedia (){
        guard self.selectedMedia != nil else{
            return
        }
        
        let isPhoto = self.selectedMedia?.mediaType == DJIMediaType.JPEG ||
        self.selectedMedia?.mediaType == DJIMediaType.TIFF
        print("Clicking")
        print(self.statusAlertView)
        if(self.statusAlertView == nil){
            
            let message = "Fetching Media Data \n 0.0"
            self.statusAlertView = UIAlertController(title: "Downloading", message: message, preferredStyle: .alert)

            self.statusAlertView!.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                self.selectedMedia?.stopFetchingFileData(completion: {[weak self] (error: Error?) in
                    self?.closingPopup()
                })
            }))
            present(self.statusAlertView!, animated: true, completion: nil)
        }
        
        self.selectedMedia?.fetchData(withOffset: previousOffset, update: DispatchQueue.main, update: {[weak self] (data: Data?, isCompleted: Bool, error: Error?) in
            if let error = error{
                self!.statusAlertView?.message = "Download Media Failed: \(error)"
            }else{
                if isPhoto{
                    if let data = data{
                        if(self?.fileData == nil){
                            self?.fileData = data
                        }else{
                            self?.fileData?.append(data)
                        }
                    }
                }
                if let data = data, let self = self{
                    self.previousOffset = self.previousOffset + UInt(data.count)
                }
                
                if let selectedFileSizeBytes = self?.selectedMedia?.fileSizeInBytes{
                    let progress = Float(self?.previousOffset ?? 0) * 100.0 / Float(selectedFileSizeBytes)
                    self?.statusAlertView?.message = String(format: "Downloading: %0.1f%%", progress)
                    if(isCompleted){
                        self?.closingPopup()
                        if(isPhoto){
                            self?.showPopup(data: self!.fileData!)
                        }
                    }
                }
            }

        })
        
    }
    
    
    @IBAction func downloadImage(_ sender: Any) {
        savePhotoWithData(data: self.fileData)
    }

    @IBAction func deletePicture(_ sender: Any) {
        
        if let currentMedia = self.mediaList?[selectedCellIndexPath!.row] {
            self.mediaManager?.delete([currentMedia], withCompletion: { [self]
                (failedFiles: [DJIMediaFile], error: Error?) in
                if let error = error{
                    self.statusAlertView = UIAlertController(title: "Delete Failed", message: "Delete media failed", preferredStyle: .alert)

                    self.statusAlertView!.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
                        self.selectedMedia?.stopFetchingFileData(completion: {[weak self] (error: Error?) in
                            self?.closingPopup()
                        })
                    }))
                    self.present(self.statusAlertView!, animated: true, completion: nil)
                }else{
                    self.statusAlertView = UIAlertController(title: "Downloaded", message: "Delete file successfully", preferredStyle: .alert)

                    self.statusAlertView!.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action: UIAlertAction!) in
                        self.selectedMedia?.stopFetchingFileData(completion: {[weak self] (error: Error?) in
                            self?.closingPopup()
                        })
                    }))
                    self.present(self.statusAlertView!, animated: true, completion: nil)
                    
                    self.mediaList?.remove(at: selectedCellIndexPath!.row)
                    var indexPaths: [IndexPath] = []
                    indexPaths.append(self.selectedCellIndexPath!)
                    self.mediaManagerCollectionView.deleteItems(at: indexPaths)
                    self.mediaManagerCollectionView.reloadData()
                    self.closingImagePreviwerPopup()
                }
            })
        }
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func openPicture(_ sender: Any) {
        self.showPhotoWithData(data: self.fileData)
    }
    
    func showPopup(data: Data?){
        if let data = data {
            self.popupView.isHidden = false
            self.imageView.isHidden = false
            self.imageView.image = UIImage(data: data)
        }else{
            Toast.show(message: "Not Image Data Fetched", controller: self)
        }
    }
    
    func showPhotoWithData(data: Data?){
        if let data = data {
            let imageInfo   = GSImageInfo(image: UIImage(data: data)!, imageMode: .aspectFit)
            let transitionInfo = GSTransitionInfo(fromView: self.mediaManagerCollectionView)
            let imageViewer    = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
            navigationController?.pushViewController(imageViewer, animated: true)
        }
    }
    
    func savePhotoWithData(data:Data?) {
        if let data = data {
            let tmpDir = NSTemporaryDirectory() as NSString
            let tmpImageFilePath = tmpDir.appendingPathComponent("tmpimage.jpg")
            let url = URL(fileURLWithPath:tmpImageFilePath)
            do {
                try data.write(to: url)
            } catch {
                print("failed to write data to file. Error: \(error)")
            }

            guard let imageURL = URL(string: tmpImageFilePath) else {
                print("Failed to load a filepath to save to")
                return
            }
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: imageURL)
            } completionHandler: { [weak self] (success:Bool, error: Error?) in
                self?.imageDidFinishSaving(error: error)
                print("success = \(success), error = \(error?.localizedDescription ?? "no")")
            }
        }
    }
    
    //TODO: test this- never called in previous tests...
    func imageDidFinishSaving(error:Error?) {
        var message = ""
        if let error = error {
            //Show message when save image failed
            message = "Save Image Failed! Error: \(error.localizedDescription)"
        } else {
            //Show message when save image successfully
            message = "Saved to Photo Album";
        }

        if self.statusAlertView == nil {
            DispatchQueue.main.async {
                self.statusAlertView = UIAlertController(title: "Download Media", message: message, preferredStyle: .alert)

                self.statusAlertView!.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (action: UIAlertAction!) in
                    self.selectedMedia?.stopFetchingFileData(completion: {[weak self] (error: Error?) in
                        self?.closingPopup()
                    })
                }))
                self.present(self.statusAlertView!, animated: true, completion: nil)
            }
        }
    }
    
    
    
}

extension MediaManagerViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaList?.count ?? 0
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = mediaManagerCollectionView.dequeueReusableCell(withReuseIdentifier: "media_cell", for: indexPath) as? MediaCell
        cell?.playBtn.isHidden = true
        cell?.mediaImage.layer.borderWidth = 1
        cell?.mediaImage.layer.masksToBounds = false
        cell?.mediaImage.layer.cornerRadius = 15
        cell?.mediaImage.clipsToBounds = true
        if let media = self.mediaList?[indexPath.row]{
            if let thumbnail = media.thumbnail{
                cell!.mediaImage?.image = thumbnail
            }else{
                cell!.mediaImage?.image = UIImage(named: "drone")
            }
            
            if(media.mediaType == .MP4 || media.mediaType == .MOV){
                cell?.playBtn.isHidden = false
            }
        }
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        self.selectedCellIndexPath = indexPath
        
        if let currentMedia = self.mediaList?[indexPath.row]{
            //if currentMedia !== self.selectedMedia{
                self.previousOffset = 0
                self.selectedMedia = currentMedia
                self.fileData = nil
                
                if(currentMedia.mediaType == .JPEG){
                    openImageMedia()
                }
                
            //}
        }
        collectionView.reloadData()
    }
    
    
}

extension MediaManagerViewController {
    fileprivate func fetchCamera() -> DJICamera? {
        guard let product = DJISDKManager.product() else {
            return nil
        }

        if product is DJIAircraft || product is DJIHandheld {
            return product.camera
        }
        return nil
    }

    fileprivate func setCameraMode(cameraMode: DJICameraMode = .shootPhoto) {
        var flatMode: DJIFlatCameraMode = .photoSingle
        let camera = self.fetchCamera()
        if camera?.isFlatCameraModeSupported() == true {
            NSLog("Flat camera mode detected")
            switch cameraMode {
            case .shootPhoto:
                flatMode = .photoSingle
            case .recordVideo:
                flatMode = .videoNormal
            default:
                flatMode = .photoSingle
            }
            
            if(cameraMode == .mediaDownload){
                camera?.enterPlayback(completion: { [weak self] (error: Error?) in
                    if error != nil {
                        NSLog("Error to Enter Playback");
                    }
                })
            }else{
                camera?.setFlatMode(flatMode, withCompletion: { [weak self] (error: Error?) in
                    if error != nil {
                        NSLog("Error set camera flat mode photo/video/Media");
                    }
                })
            }
        }else {
                camera?.setMode(cameraMode, withCompletion: {[weak self] (error: Error?) in
                    if error != nil {
                        NSLog("Error set mode photo/video/Media");
                    }
                })
        }
     }

}

class MediaCell: UICollectionViewCell{
    
    
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var mediaImage: UIImageView!
}
