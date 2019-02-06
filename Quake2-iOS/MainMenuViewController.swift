//
//  MainMenuViewController.swift
//  Quake2-iOS
//
//  Created by Tom Kidd on 1/26/19.
//

import UIKit

class MainMenuViewController: UIViewController {

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitle1: UILabel!
    @IBOutlet weak var subtitle2: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Mission Pack 1
        #if XATRIX
        backgroundImage.image = UIImage(named: "quake2mp1background")
        titleLabel.textColor = UIColor.white
        subtitle1.textColor = UIColor.white
        subtitle1.isHidden = false
        subtitle2.textColor = UIColor.white
        subtitle2.isHidden = false
        subtitle2.text = "the reckoning"
        #endif
        
        // Mission Pack 2
        #if ROGUE
        backgroundImage.image = UIImage(named: "quake2mp2background")
        titleLabel.textColor = UIColor(rgba: "FDDE8C")
        subtitle1.textColor = UIColor(rgba: "FDDE8C")
        subtitle1.isHidden = false
        subtitle2.textColor = UIColor(rgba: "FDDE8C")
        subtitle2.isHidden = false
        subtitle2.text = "ground zero"
        #endif

        // Do any additional setup after loading the view.
    }
    
    @IBAction func exitToMainMenu(segue: UIStoryboardSegue) {
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
