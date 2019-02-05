//
//  GameViewController.swift
//  Quake2-iOS
//
//  Created by Tom Kidd on 1/26/19.
//

import UIKit

class GameViewController: UIViewController {
    
    var difficulty = -1
    var newgame = false

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var loadingLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Mission Pack 1
        #if XATRIX
        backgroundImage.image = UIImage(named: "quake2mp1background")
        loadingLabel.textColor = UIColor.white
        #endif
        
        // Mission Pack 2
        #if ROGUE
        backgroundImage.image = UIImage(named: "quake2mp2background")
        loadingLabel.textColor = UIColor(rgba: "FDDE8C")
        #endif
        
        let documentsDir = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).path
        
        Sys_SetHomeDir(documentsDir)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Change `2.0` to the desired number of seconds.
            
            var argv: [String?] = [ Bundle.main.resourcePath! + "/quake2"];
            
            if self.newgame {
                argv.append("+newgame")
            }
            
            if self.difficulty >= 0 {
                argv.append("+skill")
                argv.append("\(self.difficulty)")
            }
            
            // Mission Pack 1
            #if XATRIX
            argv.append("+set")
            argv.append("game")
            argv.append("xatrix")
            #endif
            
            // Mission Pack 2
            #if ROGUE
            argv.append("+set")
            argv.append("game")
            argv.append("rogue")
            #endif
            
            argv.append(nil)
            let argc:Int32 = Int32(argv.count - 1)
            var cargs = argv.map { $0.flatMap { UnsafeMutablePointer<Int8>(strdup($0)) } }
            
            Sys_Startup(argc, &cargs)

            for ptr in cargs { free(UnsafeMutablePointer(mutating: ptr)) }

        }
    }
    
    #if os(iOS)
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return .bottom
    }
    #endif
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
