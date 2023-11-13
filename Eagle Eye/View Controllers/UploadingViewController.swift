//
//  UploadingViewController.swift
//  Eagle Eye
//
//  Created by Mohsin Sherin on 20/07/2023.
//  Copyright © 2023 DJI. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PromiseKit
import DJISDK

protocol BackFromUploadingDelegate {
    func deleteSelectedImages()
}

class UploadingViewController: UIViewController {

    @IBOutlet weak var projectNameLbl: UILabel!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var projectsTableView: UITableView!
    var allProjects:[Project] = []
    var selectProjectID = 10
    var delegate: BackFromUploadingDelegate?
    var selectedImages:[MediaFileModel] = []
    var currentDownloadIndex = 0
    var isUploading = false
    
    @IBOutlet weak var projectView: UIView!
    @IBOutlet weak var percentageLbl: UILabel!
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var uploadLbl: UILabel!
    @IBOutlet weak var alreadyUploadedLbl: UILabel!
    @IBOutlet weak var totalImgsLbl: UILabel!
    @IBOutlet weak var backBtn: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        selectProjectID = SessionUtils.getLatestProject()
        loadingView.isHidden = false
        projectsTableView.isHidden = true
        
        //Set Data
        self.totalImgsLbl.text = "\(self.selectedImages.count)"
        self.uploadLbl.text = "0/\(self.selectedImages.count)"
        progressBar.progress = 0
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onBackClick))
        backBtn.isUserInteractionEnabled = true
        backBtn.addGestureRecognizer(tapGestureRecognizer)
        self.percentageLbl.text = "0%"
        
        
        getAllProjects()
    }
    
    @IBAction func changeProjectClick(_ sender: Any) {
        self.projectView.isHidden = false
    }
    
    @IBAction func closeProjectsView(_ sender: Any) {
        self.projectView.isHidden = true
    }
    
    @objc func onBackClick(){
        if(isUploading == false){
            let alert = UIAlertController(title: "Uploading Process", message: "Are you sure you want to go back, Please verify the uploading process.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Back", style: .default) { _ in
                self.navigationController?.popViewController(animated: false)
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .default){ _ in
                alert.dismiss(animated: false)
            })
            
            self.present(alert, animated: true, completion: nil)
        }else
        {
            Toast.show(message: "Uploading in progress", controller: self)
        }
    }

    
    @IBAction func uploadBtnClick(_ sender: Any) {
        if(selectedImages.count == 0){
            Toast.show(message: "No Images are selected", controller: self)
        }else if(SessionUtils.getLatestProject() == 0){
            self.showPopup(message: "Please select project to upload images")
        }else{
            if(self.uploadBtn.titleLabel!.text! == "Upload" || self.uploadBtn.titleLabel!.text! == "Resume"){
                self.showCancelBtn()
                self.showPopup(message: "Uploading Started. Please wait.")
                firstly {
                    self.uploadMediaToServer(index: self.currentDownloadIndex) { (index, progress) in
                        self.currentDownloadIndex = index
                        let progress = Float(index)/Float(self.selectedImages.count)
                        self.percentageLbl.text = "\(Int(progress*100))%"
                        self.progressBar.progress = progress
                        self.uploadLbl.text = "\(index + 1)/\(self.selectedImages.count) uploading..."
                    }
                }.done { [self] in
                    self.showUploadBtn(message: "Upload")
                    self.showConfirmPopup()
                    self.uploadLbl.text = "\(self.currentDownloadIndex + 1)/\(self.selectedImages.count) completed."
                    self.progressBar.progress = 1
                    self.getAllProjects()
                }.catch { error in
                    self.selectedImages[self.currentDownloadIndex].djiMediaFile.stopFetchingFileData(completion: nil)
                    PhotoLibraryManager.cancelUploading()
                    self.showUploadBtn(message: "Resume")
                    self.uploadLbl.text = "Error on \(self.currentDownloadIndex + 1)/\(self.selectedImages.count)"
                    self.getAllProjects()
                    self.showPopup(message: "Uploading Failed.")
                }
            }else{
                self.selectedImages[self.currentDownloadIndex].djiMediaFile.stopFetchingFileData(completion: nil)
                PhotoLibraryManager.cancelUploading()
                self.showPopup(message: "Uploading Process is cancelled")
                self.showUploadBtn(message: "Resume")
                self.uploadLbl.text = "Cancelled on \(self.currentDownloadIndex + 1)/\(self.selectedImages.count)"
                self.getAllProjects()
            }
        }
    }
    
    func showConfirmPopup(){
        let alert = UIAlertController(title: "Uploading Completed", message: "Do you want to go back or go back and delete images from drone.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go Back", style: .default) { _ in
            self.navigationController?.popViewController(animated: false)
        })
        
        alert.addAction(UIAlertAction(title: "Go Back & Delete", style: .default){ _ in
            self.delegate?.deleteSelectedImages()
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showUploadBtn(message: String){
        self.isUploading = false
        self.uploadBtn.setTitle(message, for: .normal)
        self.uploadBtn.tintColor = UIColor(named: "empcolor")
    }
    
    func showCancelBtn(){
        self.isUploading = true
        self.uploadBtn.setTitle("Cancel", for: .normal)
        self.uploadBtn.tintColor = UIColor.red
    }
    
    func showPopup(message: String){
        let alertController = UIAlertController(title: "Uploading Images", message: message, preferredStyle: .alert)
                
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func uploadMediaToServer(index: Int = 0,
                       downLoadProgress: @escaping (_ index: Int, _ progress: CGFloat) -> Void) -> Promise<Void> {
        if index >= self.selectedImages.count {
            return Promise.value(())
        }
        let mediaFile = selectedImages[index].djiMediaFile
        
        return MediaFileManager.downLoadMediaFileForUploadOnServer(mediaFile) { (progress) in
            downLoadProgress(index, progress)
        }.then { _ in
            return self.uploadMediaToServer(index: index + 1, downLoadProgress: downLoadProgress)
        }
    }
    
    func getAllProjects(){
        loadingView.isHidden = false
        projectsTableView.isHidden = true
        
        do{
            let header = [
                "Accept": "text/json",
                "Authorization": "Bearer \(SessionUtils.getUserToken())"
            ]
            
            let resourceString = "\(Constants.API_LINK)api/project/all";
            
            Alamofire.request(resourceString, method: .post, parameters: nil, headers: header).responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let value):
                    if let httpURLResponse = response.response{
                        let response_code = httpURLResponse.statusCode;
                        if response_code == 200 {
                            print(value)
                            self.loadingView.isHidden = true
                            self.projectsTableView.isHidden = false
                            do{
                                let json = JSON(value)
                                let str = String(describing: json);
                                let jsonData = str.data(using: .utf8)
                                let decoder = JSONDecoder();
                                let res = try decoder.decode([Project].self, from: jsonData!)
                                self.allProjects = res
                                self.projectsTableView.reloadData()
                            } catch let error {
                                print(error.localizedDescription)
                            }
                        }else{
                            print(value)
                            self.loadingView.isHidden = true
                            self.projectsTableView.isHidden = false
                            Toast.show(message: "No Internet Connection/Server Issue", controller: self)
                        }
                    }
                case .failure(let error):
                    self.loadingView.isHidden = true
                    self.projectsTableView.isHidden = false
                    Toast.show(message: "There is Some Server Issue.", controller: self)
                    
                }
                
            })
        }
        
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

}

extension UploadingViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allProjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.projectsTableView.dequeueReusableCell(withIdentifier: "UploadingProjectCell", for: indexPath) as! UploadingProjectCell
        
        let project = allProjects[indexPath.row]
        var urlStr = Constants.IMAGE_URL
        urlStr = urlStr.replacingOccurrences(of: "[LAT]", with: "\(project.lat!)")
        urlStr = urlStr.replacingOccurrences(of: "[LNG]", with: "\(project.lng!)")
        
        let url = URL(string: urlStr)
        
        // Create a data task to download the image from the URL
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print("Error loading image: \(error!)")
                return
            }
            
            // Create an image object from the downloaded data
            let image = UIImage(data: data!)
            
            // Update the UI on the main thread
            DispatchQueue.main.async {
                cell.addressImageView.image = image
            }
        }.resume()
        
        cell.addressNameLbl.text = project.name
        cell.addressLbl.text = project.address
        
        if(project.id! == selectProjectID){
            cell.selectedImg.image = UIImage(systemName: "checkmark.circle")
            print("Total Images \(project.total_images!)")
            self.alreadyUploadedLbl.text = "\(project.total_images!)"
            self.projectNameLbl.text = "Selected Project: \(project.name!)"
        }else{
            cell.selectedImg.image = UIImage(systemName: "circle")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        let project = allProjects[index]
        self.selectProjectID = project.id!
        self.projectNameLbl.text = "Selected Project: \(project.name!)"
        SessionUtils.saveLatestProject(project: project)
        self.projectsTableView.reloadData()
    }
    
}


class UploadingProjectCell: UITableViewCell{
    
    @IBOutlet weak var selectedImg: UIImageView!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var addressNameLbl: UILabel!
    @IBOutlet weak var addressImageView: UIImageView!
}

