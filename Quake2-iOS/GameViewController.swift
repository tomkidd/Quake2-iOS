//
//  GameViewController.swift
//  Quake2-iOS
//
//  Created by Tom Kidd on 1/26/19.
//

import UIKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //    UIWindow *thisWindow = [[HedgewarsAppDelegate sharedAppDelegate] uiwindow];

        var thisWindow = (AppDelegate.sharedAppDelegate() as! AppDelegate).uiwindow
        
//        var argv: [String?] = [ Bundle.main.resourcePath! + "/quake3", "+set", "com_basegame", "baseq3", "+name", defaults.string(forKey: "playerName")]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Change `2.0` to the desired number of seconds.
            
            var argv: [String?] = [ Bundle.main.resourcePath! + "/quake2", "+map", "base2"];
            
            argv.append(nil)
            let argc:Int32 = Int32(argv.count - 1)
            var cargs = argv.map { $0.flatMap { UnsafeMutablePointer<Int8>(strdup($0)) } }

            
            Sys_Startup(argc, &cargs)

            for ptr in cargs { free(UnsafeMutablePointer(mutating: ptr)) }
        }


        // Do any additional setup after loading the view.
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
