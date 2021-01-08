//
//  ImageViewController.swift
//  BigHM
//
//  Created by Майя Герасимова on 06.12.2020.
//

import UIKit

class ImageViewController: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView!
    private var activityIndicator = UIActivityIndicatorView()
    
    @IBOutlet weak var searchWord: UITextField!

    private var images: [UIImage?] = []
    private var imagesInfo = [ImageInfo]()
    
    private let spacing: CGFloat = 5
    private let numberOfItemsPerRow: CGFloat = 2
    
    //MARK:- Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        //loadImages(word: ["default"])
        getCachedImages()
    }
    
    private func configure() {
        collectionView.delegate = self
        collectionView.dataSource = self
        setupSpinner()
    }
    
    @IBAction func buttomTouch(_ sender: Any){
        let wordFirst = searchWord.text!
        let word = wordFirst.components(separatedBy: " ")
        loadImages(word: word)
    }
    
    private func setupSpinner() {
            activityIndicator.hidesWhenStopped = true
            activityIndicator.style = .large
            activityIndicator.color = .red
            activityIndicator.frame = collectionView.bounds
            activityIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            collectionView.addSubview(activityIndicator)
        }

    
    
    private func loadImages(word: [String]) {
        images.removeAll()
        self.collectionView.reloadSections(IndexSet(arrayLiteral: 0))
        activityIndicator.startAnimating()
        NetworkService.shared.fetchImages(word: word) { (result) in
            self.activityIndicator.stopAnimating()
            switch result {
            case let .failure(error):
                print(error)
                
            case let .success(imagesInfo):
                self.imagesInfo = imagesInfo
                self.images = Array(repeating: nil, count: imagesInfo.count)
                self.collectionView.reloadSections(IndexSet(arrayLiteral: 0))
            }
        }
    }
    
    private func getCachedImages() {
        CacheManager.shared.getCachedImages {
            (images) in
            self.images = images
            self.collectionView.reloadSections(IndexSet(arrayLiteral: 0))
        }
    }
    
    private func loadImage(for cell: ImageCell, at index: Int) {
        if let image = images[index]{
            cell.configure(with: image)
            return
        }
        let info = imagesInfo[index]
        NetworkService.shared.loadImage(from: info.webformatURL) { (image) in
            if index < self.images.count {
                self.images[index] = image
                CacheManager.shared.cacheImage(image, with: info.id)
                cell.configure(with: self.images[index])
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSecondVC"{
            guard let secondVC = segue.destination as? DetailViewController,
            //let tags = sender as? String
            let detail = sender as? Detail?,
            let image = detail?.image as? UIImage,
            let tag = detail?.tag,
            //let likes = detail?.likes,
            let downloads = detail?.downloads,
            let views = detail?.views
            else{
                fatalError("Incorrect data passed")
            }
            //secondVC.tags = tags
            //secondVC.likes = likes
            secondVC.downloads = downloads
            secondVC.views = views
            secondVC.images = image
            secondVC.tags = tag
        }
    }
    
}


//MARK:- Data Source & Delegate
extension ImageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as? ImageCell else {
            fatalError("Invalid Cell Kind")
        }
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 2

        loadImage(for: cell, at: indexPath.row)
        
        return cell
    }
}


//MARK:- Flow Layout and secondVS
extension ImageViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let rawWidth = view.bounds.width - spacing * (numberOfItemsPerRow - 1) - 2 * spacing

        let cellWidth = rawWidth / numberOfItemsPerRow

        return CGSize(width: cellWidth, height: cellWidth)

    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        var details: [Detail] = []
        let tags = imagesInfo[indexPath.row].tags
        let image = images[indexPath.row]
        let likes = imagesInfo[indexPath.row].Likes
        let downloads = imagesInfo[indexPath.row].downloads
        let views = imagesInfo[indexPath.row].views
        details.append(Detail(tag: tags, image: image, likes: likes, downloads: downloads, views: views))
        //let image = images[indexPath.row]
        //performSegue(withIdentifier: "ShowSecondVC", sender: tags)
        performSegue(withIdentifier: "ShowSecondVC", sender: details[0])
}

}
