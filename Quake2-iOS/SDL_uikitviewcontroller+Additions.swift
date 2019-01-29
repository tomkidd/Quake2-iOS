//
//  SDL2ViewController+Additions.swift
//  Quake2-iOS
//
//  Created by Tom Kidd on 1/28/19.
//

import UIKit

extension SDL_uikitviewcontroller {
    
    @objc func fireButton(rect: CGRect) -> UIButton {
        let fireButton = UIButton(frame: CGRect(x: rect.width - 155, y: rect.height - 90, width: 75, height: 75))
        fireButton.setTitle("FIRE", for: .normal)
        fireButton.setBackgroundImage(UIImage(named: "JoyStickBase")!, for: .normal)
        fireButton.addTarget(self, action: #selector(self.firePressed), for: .touchDown)
        fireButton.addTarget(self, action: #selector(self.fireReleased), for: .touchUpInside)
        fireButton.alpha = 0.5
        return fireButton
    }
    
    @objc func jumpButton(rect: CGRect) -> UIButton {
        let jumpButton = UIButton(frame: CGRect(x: rect.width - 90, y: rect.height - 135, width: 75, height: 75))
        jumpButton.setTitle("JUMP", for: .normal)
        jumpButton.setBackgroundImage(UIImage(named: "JoyStickBase")!, for: .normal)
        jumpButton.addTarget(self, action: #selector(self.jumpPressed), for: .touchDown)
        jumpButton.addTarget(self, action: #selector(self.jumpReleased), for: .touchUpInside)
        jumpButton.alpha = 0.5
        return jumpButton
    }
    
    @objc func joyStick(rect: CGRect) -> JoyStickView {
        let size = CGSize(width: 100.0, height: 100.0)
        let joystick1Frame = CGRect(origin: CGPoint(x: 50.0,
                                                    y: (rect.height - size.height - 50.0)),
                                    size: size)
        let joystick1 = JoyStickView(frame: joystick1Frame)
        joystick1.delegate = self
        
        joystick1.movable = false
        joystick1.alpha = 0.5
        joystick1.baseAlpha = 0.5 // let the background bleed thru the base
        joystick1.handleTintColor = UIColor.darkGray // Colorize the handle
        return joystick1
    }
    
    @objc func firePressed(sender: UIButton!) {
        Key_Event(137, qboolean(1), qboolean(1))
    }
    
    @objc func fireReleased(sender: UIButton!) {
        Key_Event(137, qboolean(0), qboolean(1))
    }
    
    @objc func jumpPressed(sender: UIButton!) {
        Key_Event(32, qboolean(1), qboolean(1))
    }
    
    @objc func jumpReleased(sender: UIButton!) {
        Key_Event(32, qboolean(0), qboolean(1))
    }

}

extension SDL_uikitviewcontroller: JoystickDelegate {
    
    func handleJoyStickPosition(x: CGFloat, y: CGFloat) {

        if y > 0 {
            cl_joyscale_y.0 = Int32(abs(y) * 60)
            Key_Event(132, qboolean(1), qboolean(1))
            Key_Event(133, qboolean(0), qboolean(1))
        } else if y < 0 {
            cl_joyscale_y.1 = Int32(abs(y) * 60)
            Key_Event(132, qboolean(0), qboolean(1))
            Key_Event(133, qboolean(1), qboolean(1))
        } else {
            cl_joyscale_y.0 = 0
            cl_joyscale_y.1 = 0
            Key_Event(132, qboolean(0), qboolean(1))
            Key_Event(133, qboolean(0), qboolean(1))
        }
        
        print("x: \(x)")
        
        cl_joyscale_x.0 = Int32(x * 20)        
    }
    
    func handleJoyStick(angle: CGFloat, displacement: CGFloat) {
        print("angle: \(angle) displacement: \(displacement)")
    }
    
}
