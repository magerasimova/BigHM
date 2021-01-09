//
//  DetailViewController.swift
//  BigHM
//
//  Created by Майя Герасимова on 06.12.2020.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var downloadsLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    
    @IBOutlet weak var idLabel: UILabel!
    var tags = ""
    var images: UIImage!
    var likes: Int!
    var downloads: Int!
    var views: Int!
    var id: Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        // Do any additional setup after loading the view.
    }
    private func configure() {
        tagLabel.text = "tags: \(tags)"
        image.image = images
        //likesLabel.text = String(likes)
        downloadsLabel.text = String(downloads)
        viewsLabel.text = String(views)
        idLabel.text = String(id)
    }

}
