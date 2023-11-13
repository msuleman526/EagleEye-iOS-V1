//
//  PhotoLibrayManager.swift
//  DJIFileManager
//
//  Created by Hanson on 2018/9/3.
//

import UIKit
import Photos
import Alamofire
import PromiseKit
import MobileCoreServices

class PhotoLibraryManager {
    
    static var uploadRequest: UploadRequest?
    static var shouldCancelUpload = false
    
    static func isAuthorized() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        return status == .authorized || status == .notDetermined
    }
    
    /// fetch album, create one if not exist
    static func fetchAlbum(name: String) -> Promise<PHAssetCollection> {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", name)
        let assetCollections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        if let assetCollection = assetCollections.firstObject {
            return Promise.value(assetCollection)
        } else {
            return PHPhotoLibrary.shared().performChanges {
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
            }.then {
                fetchAlbum(name: name)
            }
        }
    }
    
    static func save(imageData: [Data], albumName: String = "DJIFileManager") -> Promise<Void> {
        return fetchAlbum(name: albumName).then { assetCollection in
            PHPhotoLibrary.shared().performChanges {
                for data in imageData {
                    let image = UIImage(data: data) ?? UIImage()
                    let changeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    if let assetPlaceholder = changeRequest.placeholderForCreatedAsset
                     , let albumChangeRequset = PHAssetCollectionChangeRequest(for: assetCollection) {
                        albumChangeRequset.addAssets([assetPlaceholder] as NSArray)
                    }
                }
            }
        }
    }
    
    static func save(imageData: [Data], metadataList: [[String: Any]?], albumName: String = "DJIFileManager") -> Promise<Void> {
        return fetchAlbum(name: albumName).then { assetCollection in
            PHPhotoLibrary.shared().performChanges {
                var placeholder: PHObjectPlaceholder?
                for (index, data) in imageData.enumerated() {
                    var changeRequest: PHAssetChangeRequest
                    
                    // Include metadata if available
                    if let metadata = metadataList[index] {
                        let newImageData = Utils.mergeImageData(imageData: data, with: metadata as NSDictionary)
                        changeRequest = PHAssetCreationRequest.forAsset()
                        (changeRequest as! PHAssetCreationRequest).addResource(with: .photo, data: newImageData as Data, options: nil)
                    }else{
                        changeRequest = PHAssetChangeRequest.creationRequestForAsset(from: UIImage(data: data)!)
                    }
                    
                    
                    guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection),
                        let photoPlaceholder = changeRequest.placeholderForCreatedAsset else { return }

                    placeholder = photoPlaceholder
                    let fastEnumeration = NSArray(array: [photoPlaceholder] as [PHObjectPlaceholder])
                    albumChangeRequest.addAssets(fastEnumeration)
                }
            }
                
        }
    }

    
    static func uploadImageToServer(name: String, imageData: Data, metadata: [String: Any]) -> Promise<Void> {
        // Create a Promise that will resolve when the file has been sent successfully
        let newImageData = Utils.mergeImageData(imageData: imageData, with: metadata as NSDictionary)
        self.shouldCancelUpload = false
        return Promise<Void> { seal in
            
            let token = "Bearer \(SessionUtils.getUserToken())"
            let url = "\(Constants.API_LINK)api/project/upload/image/\(SessionUtils.getLatestProject())"
            print(token)
            print(url)
            
            let headers: HTTPHeaders = [
                "Accept": "json",
                "Authorization": token
            ]
            
            
            // Construct the API endpoint URL
            guard let url = URL(string: url) else {
                seal.reject("Invalid End Point" as! Error)
                return
            }
            
            //for data in imageData {
                // Use Alamofire to upload the file data to the API endpoint
                Alamofire.upload(multipartFormData: { multipartFormData in
                    multipartFormData.append(imageData, withName: "image", fileName: name, mimeType: "image/jpeg")
                }, to: url, method: .post, headers: headers) { result in
                    switch result {
                    case .success(let uploadRequest, _, _):
                        // Assign the upload request to the property for reference
                        self.uploadRequest = uploadRequest
                        // The upload request was successful, so start the request and wait for it to finish
                        uploadRequest.responseJSON { response in
                            if self.shouldCancelUpload {
                                // The request was canceled, handle the cancellation
                                print("Upload canceled.")
                                seal.reject(PMKError.cancelled)
                            } else if let error = response.error {
                                // The request failed, so reject the Promise with the error
                                print("Error On Api \(error.localizedDescription)")
                                seal.reject(error)
                            } else {
                                print("Full fill \(response)")
                                // The request succeeded, so resolve the Promise
                                seal.fulfill(())
                            }
                        }
                        
                    case .failure(let error):
                        print("Error on Api \(error.localizedDescription)")
                        seal.reject(error)
                    }
                }
           // }
            
        }
    }
    
    static func cancelUploading(){
        PhotoLibraryManager.shouldCancelUpload = true
        PhotoLibraryManager.uploadRequest?.cancel()
    }
    
    
    static func saveVideo(url: URL, albumName: String = "DJIFileManager") -> Promise<Void> {
        return fetchAlbum(name: albumName).then { assetCollection in
            PHPhotoLibrary.shared().performChanges {
                let changeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                if let assetPlaceholder = changeRequest?.placeholderForCreatedAsset
                 , let albumChangeRequset = PHAssetCollectionChangeRequest(for: assetCollection) {
                    albumChangeRequset.addAssets([assetPlaceholder] as NSArray)
                }
            }
        }
    }
    
}

extension PHPhotoLibrary {
    
    func performChanges(_ changeBlock: @escaping () -> Void) -> Promise<Void> {
        return Promise { seal in
            performChanges(changeBlock, completionHandler: { (result, error) in
                if result {
                    seal.fulfill(())
                } else {
                    seal.reject(error ?? PMKError.emptySequence)
                }
            })
        }
    }
    
    func requestPhotoLibrayAuthorization() -> Promise<Void> {
        return Promise { seal in
            PHPhotoLibrary.requestAuthorization { (authorizationStatus) in
                if authorizationStatus == .authorized {
                    seal.fulfill(())
                } else {
                    seal.reject(MediaFileManagerError.unAuthorized)
                }
            }
        }
    }
    
}
