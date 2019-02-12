//
//  SavedGameViewController.swift
//  Quake2-iOS
//
//  Created by Tom Kidd on 2/12/19.
//

import UIKit

class SavedGameViewController: UIViewController {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var loadingLabel: UILabel!

    @IBOutlet weak var savesList: UITableView!
    @IBOutlet weak var loadGameButton: UIButton!
    
    var selectedSavedGame = ""
    
    var saves = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        savesList.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        var gameDir = ""
        gameDir = "baseq2"
        
        // Mission Pack 1
        #if XATRIX
        gameDir = "xatrix"
        backgroundImage.image = UIImage(named: "quake2mp1background")
        loadingLabel.textColor = UIColor.white
        #endif
        
        // Mission Pack 2
        #if ROGUE
        gameDir = "rogue"
        backgroundImage.image = UIImage(named: "quake2mp2background")
        loadingLabel.textColor = UIColor(rgba: "FDDE8C")
        #endif

        let savesPath =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path + "/\(gameDir)/save"
        
        do {
            saves = try FileManager.default.contentsOfDirectory(atPath: savesPath)
            savesList.reloadData()
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoadGameSegue" {
            (segue.destination as! GameViewController).selectedSavedGame = selectedSavedGame
        }
    }
}

extension SavedGameViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSavedGame = saves[indexPath.row]
        loadGameButton.isHidden = false
    }
    
    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        #if os(iOS)
    //        return 100
    //        #endif
    //        #if os(tvOS)
    //        return 200
    //        #endif
    //    }
}

extension SavedGameViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        cell.textLabel?.text = saves[indexPath.row]//.replacingOccurrences(of: ".svg", with: "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return saves.count
    }
}
