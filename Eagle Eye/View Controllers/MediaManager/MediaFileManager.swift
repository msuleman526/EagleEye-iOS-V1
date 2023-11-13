//
//  MediaFileManager.swift
//  DJIFileManager
//
//  Created by Hanson on 2018/9/6.
//  Copyright © 2018年 kiwi. All rights reserved.
//

import Foundation
import DJISDK
import PromiseKit
import Photos


enum MediaFileManagerError: LocalizedError {
    case cameraNotReady, fileTypeNotMatch, downloadCancel, createFileFail, unAuthorized
    
    var errorDescription: String? {
        switch self {
        case .cameraNotReady:
            return "camera is not ready"
        case .fileTypeNotMatch:
            return "dismatch file type"
        case .downloadCancel:
            return "download is canceled"
        case .createFileFail:
            return "fail to create file"
        case .unAuthorized:
            return "do not have right to access Photo Library"
        }
    }
}

class MediaFileManager {
    static func downloadVideo(mediaFile: DJIMediaFile,
                              downloadProgress: ((_ progress: CGFloat) -> Void)?) -> Promise<URL> {
        
        let rootPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] as String
        let filePath = rootPath + "/\(mediaFile.timeCreated)_\(mediaFile.fileName)"
        if FileManager.default.fileExists(atPath: filePath) {
            return Promise.value(URL(fileURLWithPath: filePath))
        }
        
        guard let camera = DJISDKManager.product()?.camera else {
            return Promise(error: MediaFileManagerError.cameraNotReady)
        }
        return checkPhotoLibraryAuthorization().then {
            camera.setMode(.mediaDownload)
        }.then {
            mediaFile.fetchFileData(dispatchQueue: .main) { progress in
                downloadProgress?(progress)
            }
        }.then { data -> Promise<URL>  in
            if FileManager.default.createFile(atPath: filePath, contents: data, attributes: nil) {
                return Promise.value(URL(fileURLWithPath: filePath))
            } else {
                return Promise(error: MediaFileManagerError.createFileFail)
            }
        }
    }
    
    static func downloadImage(mediaFile: DJIMediaFile,
                              downloadProgress: ((_ progress: CGFloat) -> Void)?) -> Promise<(Data, [String: Any]?)> {
        
        guard let camera = DJISDKManager.product()?.camera else {
            return Promise(error: MediaFileManagerError.cameraNotReady)
        }
        
        return checkPhotoLibraryAuthorization().then {
                camera.setMode(.mediaDownload)
        }.then {
            mediaFile.fetchFileData(dispatchQueue: .main) { progress in
                downloadProgress?(progress)
            }.then { imageData in
                let metadata = self.fetchMetadata(fileData: imageData)
                return Promise.value((imageData, metadata))
            }
        }
    }
    
    private static func fetchMetadata(fileData: Data) -> [String: Any]? {
        
        guard let imageSource = CGImageSourceCreateWithData(fileData as CFData, nil),
              let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else {
            return nil
        }
        
        return imageProperties
    }
    
    static func downloadMediaFile(_ mediaFile: DJIMediaFile,
                                  downloadProgress: ((_ progress: CGFloat) -> Void)?) -> Promise<Void> {
        let mediaType = mediaFile.mediaType
        if mediaType == .MP4 || mediaType == .MOV {
            return MediaFileManager.downloadVideo(mediaFile: mediaFile) { (progress) in
                downloadProgress?(progress)
            }.then { videoURL in
                PhotoLibraryManager.saveVideo(url: videoURL)
            }
        } else {
            return MediaFileManager.downloadImage(mediaFile: mediaFile) { (progress) in
                downloadProgress?(progress)
            }.then { (imageData, metadata) in
                PhotoLibraryManager.save(imageData: [imageData], metadataList: [metadata])
            }
        }
    }
    
    static func downLoadMediaFileForUploadOnServer(_ mediaFile: DJIMediaFile,
                                  downloadProgress: ((_ progress: CGFloat) -> Void)?) -> Promise<Void> {
        return MediaFileManager.downloadImage(mediaFile: mediaFile) { (progress) in
            downloadProgress?(progress)
        }.then { (imageData, metadata) in
            PhotoLibraryManager.uploadImageToServer(name: mediaFile.fileName, imageData: imageData, metadata: metadata!)
        }
    }
    
    static func getMediaFileCacheURL(mediaFile: DJIMediaFile) -> URL? {
        let rootPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] as String
        let filePath = rootPath + "/\(mediaFile.timeCreated)_\(mediaFile.fileName)"
        if FileManager.default.fileExists(atPath: filePath) {
            return URL(fileURLWithPath: filePath)
        } else {
            return nil
        }
    }
    
    private static func checkPhotoLibraryAuthorization() -> Promise<Void> {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .authorized {
            return Promise.value(())
        } else if status == .notDetermined {
            return PHPhotoLibrary.shared().requestPhotoLibrayAuthorization()
        } else {
            return Promise(error: MediaFileManagerError.unAuthorized)
        }
    }
}


