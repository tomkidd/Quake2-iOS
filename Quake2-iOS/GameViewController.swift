//
//  GameViewController.swift
//  Quake2-iOS
//
//  Created by Tom Kidd on 1/26/19.
//

import UIKit

class GameViewController: UIViewController {
    
    var joysticksInitialized = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //    UIWindow *thisWindow = [[HedgewarsAppDelegate sharedAppDelegate] uiwindow];

        
//        var argv: [String?] = [ Bundle.main.resourcePath! + "/quake3", "+set", "com_basegame", "baseq3", "+name", defaults.string(forKey: "playerName")]
        
        #if os(iOS)
        
        let thisWindow = (AppDelegate.sharedAppDelegate() as! AppDelegate).uiwindow
        
        if !self.joysticksInitialized {
            
            let rect = thisWindow!.frame
            let size = CGSize(width: 100.0, height: 100.0)
            let joystick1Frame = CGRect(origin: CGPoint(x: 50.0,
                                                        y: (rect.height - size.height - 50.0)),
                                        size: size)
            let joystick1 = JoyStickView(frame: joystick1Frame)
            joystick1.delegate = self
            
            thisWindow?.addSubview(joystick1)
            
            joystick1.movable = false
            joystick1.alpha = 0.5
            joystick1.baseAlpha = 0.5 // let the background bleed thru the base
            joystick1.handleTintColor = UIColor.darkGray // Colorize the handle
            
            let fireButton = UIButton(frame: CGRect(x: rect.width - 155, y: rect.height - 90, width: 75, height: 75))
            fireButton.setTitle("FIRE", for: .normal)
            fireButton.setBackgroundImage(UIImage(named: "JoyStickBase")!, for: .normal)
            fireButton.addTarget(self, action: #selector(self.firePressed), for: .touchDown)
            fireButton.addTarget(self, action: #selector(self.fireReleased), for: .touchUpInside)
            fireButton.alpha = 0.5
            
            thisWindow!.addSubview(fireButton)
            
            let jumpButton = UIButton(frame: CGRect(x: rect.width - 90, y: rect.height - 135, width: 75, height: 75))
            jumpButton.setTitle("JUMP", for: .normal)
            jumpButton.setBackgroundImage(UIImage(named: "JoyStickBase")!, for: .normal)
            jumpButton.addTarget(self, action: #selector(self.jumpPressed), for: .touchDown)
            jumpButton.addTarget(self, action: #selector(self.jumpReleased), for: .touchUpInside)
            jumpButton.alpha = 0.5
            
            thisWindow!.rootViewController?.view.addSubview(jumpButton)
            
            self.joysticksInitialized = true
        }
        
        #endif
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Change `2.0` to the desired number of seconds.
            
            var argv: [String?] = [ Bundle.main.resourcePath! + "/quake2", "+map", "base1"];
            
            argv.append(nil)
            let argc:Int32 = Int32(argv.count - 1)
            var cargs = argv.map { $0.flatMap { UnsafeMutablePointer<Int8>(strdup($0)) } }

            
            Sys_Startup(argc, &cargs)

            for ptr in cargs { free(UnsafeMutablePointer(mutating: ptr)) }

        }

        // Do any additional setup after loading the view.
    }
    
    @objc func firePressed(sender: UIButton!) {
        Key_Event(133, qboolean(1), qboolean(1))
    }
    
    @objc func fireReleased(sender: UIButton!) {
        Key_Event(133, qboolean(0), qboolean(1))
    }
    
    @objc func jumpPressed(sender: UIButton!) {
        Key_Event(13, qboolean(1), qboolean(1))
    }
    
    @objc func jumpReleased(sender: UIButton!) {
        Key_Event(13, qboolean(0), qboolean(1))
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

extension GameViewController: JoystickDelegate {
    
    func handleJoyStickPosition(x: CGFloat, y: CGFloat) {
//        in_sidestepmove = Float(y) // misnamed but whatever
//        in_rollangle = Float(x)
    }
    
    func handleJoyStick(angle: CGFloat, displacement: CGFloat) {
        //        print("angle: \(angle) displacement: \(displacement)")
    }
    
}
