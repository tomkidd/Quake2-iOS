//
//  SDL2ViewController+Additions.swift
//  Quake2-iOS
//
//  Created by Tom Kidd on 1/28/19.
//

import UIKit

func applyJoystickCurve(position: CGFloat, range: CGFloat) -> Float {
    return Float(pow(position / range, 2) * range * (position < 0 ? -1 : 1))
}

extension SDL_uikitviewcontroller {
    
    // A method of getting around the fact that Swift extensions cannot have stored properties
    // https://medium.com/@valv0/computed-properties-and-extensions-a-pure-swift-approach-64733768112c
    struct Holder {
        static var _fireButton = UIButton()
        static var _jumpButton = UIButton()
        static var _leftJoystickView = JoyStickView(frame: .zero)
        static var _rightJoystickView = JoyStickView(frame: .zero)
        static var _tildeButton = UIButton()
        static var _expandButton = UIButton()
        static var _escapeButton = UIButton()
        static var _quickSaveButton: UIButton!
        static var _quickLoadButton: UIButton!
        static var _buttonStack = UIStackView(frame: .zero)
        static var _buttonStackExpanded = false
        static var _f1Button = UIButton()
        static var _prevWeaponButton = UIButton()
        static var _nextWeaponButton = UIButton()
     }

    var fireButton:UIButton {
        get {
            return Holder._fireButton
        }
        set(newValue) {
            Holder._fireButton = newValue
        }
    }
    
    var jumpButton:UIButton {
        get {
            return Holder._jumpButton
        }
        set(newValue) {
            Holder._jumpButton = newValue
        }
    }
    
    var leftJoystickView:JoyStickView {
        get {
            return Holder._leftJoystickView
        }
        set(newValue) {
            Holder._leftJoystickView = newValue
        }
    }
    
    var rightJoystickView:JoyStickView {
        get {
            return Holder._rightJoystickView
        }
        set(newValue) {
            Holder._rightJoystickView = newValue
        }
    }

    var tildeButton:UIButton {
        get {
            return Holder._tildeButton
        }
        set(newValue) {
            Holder._tildeButton = newValue
        }
    }

    var escapeButton:UIButton {
        get {
            return Holder._escapeButton
        }
        set(newValue) {
            Holder._escapeButton = newValue
        }
    }

    var expandButton:UIButton {
        get {
            return Holder._expandButton
        }
        set(newValue) {
            Holder._expandButton = newValue
        }
    }
    
    var quickLoadButton:UIButton {
        get {
            return Holder._quickLoadButton
        }
        set(newValue) {
            Holder._quickLoadButton = newValue
        }
    }
    
    var quickSaveButton:UIButton {
        get {
            return Holder._quickSaveButton
        }
        set(newValue) {
            Holder._quickSaveButton = newValue
        }
    }
    
    var buttonStack:UIStackView {
        get {
            return Holder._buttonStack
        }
        set(newValue) {
            Holder._buttonStack = newValue
        }
    }

    var buttonStackExpanded:Bool {
        get {
            return Holder._buttonStackExpanded
        }
        set(newValue) {
            Holder._buttonStackExpanded = newValue
        }
    }
    
    var f1Button:UIButton {
        get {
            return Holder._f1Button
        }
        set(newValue) {
            Holder._f1Button = newValue
        }
    }
    
    var prevWeaponButton:UIButton {
        get {
            return Holder._prevWeaponButton
        }
        set(newValue) {
            Holder._prevWeaponButton = newValue
        }
    }

    var nextWeaponButton:UIButton {
        get {
            return Holder._nextWeaponButton
        }
        set(newValue) {
            Holder._nextWeaponButton = newValue
        }
    }

    @objc func fireButton(rect: CGRect) -> UIButton {
        fireButton = UIButton(frame: CGRect(x: rect.width - 205, y: rect.height - 150, width: 50, height: 50))
        fireButton.setTitle("FIRE", for: .normal)
        fireButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        fireButton.setBackgroundImage(UIImage(named: "JoyStickBase")!, for: .normal)
        fireButton.addTarget(self, action: #selector(self.firePressed), for: .touchDown)
        fireButton.addTarget(self, action: #selector(self.fireReleased), for: .touchUpInside)
        fireButton.alpha = 0.5
        return fireButton
    }
    
    @objc func jumpButton(rect: CGRect) -> UIButton {
        jumpButton = UIButton(frame: CGRect(x: rect.width - 150, y: rect.height - 205, width: 50, height: 50))
        jumpButton.setTitle("JUMP", for: .normal)
        jumpButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        jumpButton.setBackgroundImage(UIImage(named: "JoyStickBase")!, for: .normal)
        jumpButton.addTarget(self, action: #selector(self.jumpPressed), for: .touchDown)
        jumpButton.addTarget(self, action: #selector(self.jumpReleased), for: .touchUpInside)
        jumpButton.alpha = 0.5
        return jumpButton
    }
    
    @objc func leftJoyStick(rect: CGRect) -> JoyStickView {
        let size = CGSize(width: 100.0, height: 100.0)
        let frame = CGRect(origin: CGPoint(x: 50.0,
                                           y: (rect.height - size.height - 50.0)),
                                    size: size)
        leftJoystickView = JoyStickView(frame: frame)
        leftJoystickView.monitor = .xy(monitor: { report in
            
            cl_joyscale.strafe = applyJoystickCurve(position: abs(report.x), range: size.width/2) * 5
            if report.x > 0 {
                Key_Event(Int32(Character("d").asciiValue!), qboolean(1), qboolean(1))
                Key_Event(Int32(Character("a").asciiValue!), qboolean(0), qboolean(1))
            } else if report.x < 0 {
                Key_Event(Int32(Character("d").asciiValue!), qboolean(0), qboolean(1))
                Key_Event(Int32(Character("a").asciiValue!), qboolean(1), qboolean(1))
            } else {
                cl_joyscale.strafe = 0
                Key_Event(Int32(Character("d").asciiValue!), qboolean(0), qboolean(1))
                Key_Event(Int32(Character("a").asciiValue!), qboolean(0), qboolean(1))
            }
            
            cl_joyscale.walk = applyJoystickCurve(position: abs(report.y), range: size.width/2) * 2
            if report.y > 0 {
                Key_Event(Int32(K_UPARROW.rawValue), qboolean(1), qboolean(1))
                Key_Event(Int32(K_DOWNARROW.rawValue), qboolean(0), qboolean(1))
            } else if report.y < 0 {
                Key_Event(Int32(K_UPARROW.rawValue), qboolean(0), qboolean(1))
                Key_Event(Int32(K_DOWNARROW.rawValue), qboolean(1), qboolean(1))
            } else {
                cl_joyscale.walk = 0
                Key_Event(Int32(K_UPARROW.rawValue), qboolean(0), qboolean(1))
                Key_Event(Int32(K_DOWNARROW.rawValue), qboolean(0), qboolean(1))
            }
        })
        
        leftJoystickView.movable = false
        leftJoystickView.alpha = 0.75
        leftJoystickView.baseAlpha = 0.25 // let the background bleed thru the base
        leftJoystickView.baseImage = UIImage(named: "JoyStickBase")
        leftJoystickView.handleImage = UIImage(named: "JoyStickHandle")
        return leftJoystickView
    }
    
    @objc func rightJoyStick(rect: CGRect) -> JoyStickView {
        let size = CGSize(width: 100.0, height: 100.0)
        let frame = CGRect(origin: CGPoint(x: (rect.width - size.width - 50.0),
                                           y: (rect.height - size.height - 50.0)),
                                    size: size)
        rightJoystickView = JoyStickView(frame: frame)
        rightJoystickView.monitor = .xy(monitor: { report in
            cl_joyscale.yaw = Float(applyJoystickCurve(position: report.x, range: size.width/2) * 0.1)
            cl_joyscale.pitch = Float(applyJoystickCurve(position: report.y, range: size.width/2) * 0.05)
        })
        
        rightJoystickView.tappedBlock = {
            Key_Event(Int32(K_CTRL.rawValue), qboolean(1), qboolean(1))
            Key_Event(Int32(K_CTRL.rawValue), qboolean(0), qboolean(1))
        }
        
        rightJoystickView.movable = false
        rightJoystickView.alpha = 0.75
        rightJoystickView.baseAlpha = 0.25 // let the background bleed thru the base
        rightJoystickView.baseImage = UIImage(named: "JoyStickBase")
        rightJoystickView.handleImage = UIImage(named: "JoyStickHandle")
        return rightJoystickView
    }
    
    @objc func buttonStack(rect: CGRect) -> UIStackView {
        
        
        expandButton = UIButton(type: .custom)
        expandButton.setTitle(" > ", for: .normal)
        expandButton.addTarget(self, action: #selector(self.expand), for: .touchUpInside)
        expandButton.sizeToFit()
        expandButton.alpha = 0.5
        expandButton.frame.size.width = 50

        tildeButton = UIButton(type: .custom)
        tildeButton.setTitle(" ~ ", for: .normal)
        tildeButton.addTarget(self, action: #selector(self.tildePressed), for: .touchDown)
        tildeButton.addTarget(self, action: #selector(self.tildeReleased), for: .touchUpInside)
        tildeButton.alpha = 0
        tildeButton.isHidden = true

        escapeButton = UIButton(type: .custom)
        escapeButton.setTitle(" ESC ", for: .normal)
        escapeButton.addTarget(self, action: #selector(self.escapePressed), for: .touchDown)
        escapeButton.addTarget(self, action: #selector(self.escapeReleased), for: .touchUpInside)
        escapeButton.layer.borderColor = UIColor.white.cgColor
        escapeButton.layer.borderWidth = CGFloat(1)
        escapeButton.alpha = 0
        escapeButton.isHidden = true

        quickSaveButton = UIButton(type: .custom)
        quickSaveButton.setTitle(" QS ", for: .normal)
        quickSaveButton.addTarget(self, action: #selector(self.quickSavePressed), for: .touchDown)
        quickSaveButton.addTarget(self, action: #selector(self.quickSaveReleased), for: .touchUpInside)
        quickSaveButton.layer.borderColor = UIColor.white.cgColor
        quickSaveButton.layer.borderWidth = CGFloat(1)
        quickSaveButton.alpha = 0
        quickSaveButton.isHidden = true

        quickLoadButton = UIButton(type: .custom)
        quickLoadButton.setTitle(" QL ", for: .normal)
        quickLoadButton.addTarget(self, action: #selector(self.quickLoadPressed), for: .touchDown)
        quickLoadButton.addTarget(self, action: #selector(self.quickLoadReleased), for: .touchUpInside)
        quickLoadButton.layer.borderColor = UIColor.white.cgColor
        quickLoadButton.layer.borderWidth = CGFloat(1)
        quickLoadButton.alpha = 0
        quickLoadButton.isHidden = true

        
//        buttonStack = UIStackView(frame: CGRect(x: 20, y: 20, width: 30, height: 300))
        buttonStack = UIStackView(frame: .zero)
        buttonStack.frame.origin = CGPoint(x: 50, y: 50)
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .horizontal
        buttonStack.spacing = 8.0
        buttonStack.alignment = .leading
        buttonStack.addArrangedSubview(expandButton)
//        buttonStack.addArrangedSubview(tildeButton)
        buttonStack.addArrangedSubview(escapeButton)
        buttonStack.addArrangedSubview(quickSaveButton)
        buttonStack.addArrangedSubview(quickLoadButton)

        return buttonStack
        
    }
    
    @objc func f1Button(rect: CGRect) -> UIButton {
        f1Button = UIButton(frame: CGRect(x: rect.width - 40, y: 10, width: 30, height: 30))
        f1Button.setTitle(" F1 ", for: .normal)
        f1Button.addTarget(self, action: #selector(self.f1Pressed), for: .touchDown)
        f1Button.addTarget(self, action: #selector(self.f1Released), for: .touchUpInside)
        f1Button.layer.borderColor = UIColor.white.cgColor
        f1Button.layer.borderWidth = CGFloat(1)
        f1Button.alpha = 0.5
        return f1Button
    }
    
    @objc func prevWeaponButton(rect: CGRect) -> UIButton {
        prevWeaponButton = UIButton(frame: CGRect(x: (rect.width / 3), y: rect.height/2, width: (rect.width / 3), height: rect.height/2))
        prevWeaponButton.addTarget(self, action: #selector(self.prevWeaponPressed), for: .touchDown)
        prevWeaponButton.addTarget(self, action: #selector(self.prevWeaponReleased), for: .touchUpInside)
        return prevWeaponButton
    }
    
    @objc func nextWeaponButton(rect: CGRect) -> UIButton {
        nextWeaponButton = UIButton(frame: CGRect(x: (rect.width / 3), y: 0, width: (rect.width / 3), height: rect.height/2))
        nextWeaponButton.addTarget(self, action: #selector(self.nextWeaponPressed), for: .touchDown)
        nextWeaponButton.addTarget(self, action: #selector(self.nextWeaponReleased), for: .touchUpInside)
        return nextWeaponButton
    }

    
    @objc func firePressed(sender: UIButton!) {
        Key_Event(Int32(K_CTRL.rawValue), qboolean(1), qboolean(1))
    }
    
    @objc func fireReleased(sender: UIButton!) {
        Key_Event(Int32(K_CTRL.rawValue), qboolean(0), qboolean(1))
    }
    
    @objc func jumpPressed(sender: UIButton!) {
        Key_Event(Int32(K_SPACE.rawValue), qboolean(1), qboolean(1))
    }
    
    @objc func jumpReleased(sender: UIButton!) {
        Key_Event(Int32(K_SPACE.rawValue), qboolean(0), qboolean(1))
    }
    
    @objc func tildePressed(sender: UIButton!) {
//        Key_Event(Int32(K_SPACE.rawValue), qboolean(1), qboolean(1))
    }
    
    @objc func tildeReleased(sender: UIButton!) {
//        Key_Event(Int32(K_SPACE.rawValue), qboolean(0), qboolean(1))
    }
    
    @objc func escapePressed(sender: UIButton!) {
        Key_Event(Int32(K_ESCAPE.rawValue), qboolean(1), qboolean(1))
    }
    
    @objc func escapeReleased(sender: UIButton!) {
        Key_Event(Int32(K_ESCAPE.rawValue), qboolean(0), qboolean(1))
    }
    
    @objc func quickSavePressed(sender: UIButton!) {
        Key_Event(Int32(K_F6.rawValue), qboolean(1), qboolean(1))
    }
    
    @objc func quickSaveReleased(sender: UIButton!) {
        Key_Event(Int32(K_F6.rawValue), qboolean(0), qboolean(1))
    }
    
    @objc func quickLoadPressed(sender: UIButton!) {
        Key_Event(Int32(K_F9.rawValue), qboolean(1), qboolean(1))
    }
    
    @objc func quickLoadReleased(sender: UIButton!) {
        Key_Event(Int32(K_F9.rawValue), qboolean(0), qboolean(1))
    }
    
    @objc func f1Pressed(sender: UIButton!) {
        Key_Event(Int32(K_F1.rawValue), qboolean(1), qboolean(1))
    }
    
    @objc func f1Released(sender: UIButton!) {
        Key_Event(Int32(K_F1.rawValue), qboolean(0), qboolean(1))
    }
    
    @objc func prevWeaponPressed(sender: UIButton!) {
        Key_Event(Int32(K_MWHEELDOWN.rawValue), qboolean(1), qboolean(1))
    }
    
    @objc func prevWeaponReleased(sender: UIButton!) {
        Key_Event(Int32(K_MWHEELDOWN.rawValue), qboolean(0), qboolean(1))
    }
    
    @objc func nextWeaponPressed(sender: UIButton!) {
        Key_Event(Int32(K_MWHEELUP.rawValue), qboolean(1), qboolean(1))
    }
    
    @objc func nextWeaponReleased(sender: UIButton!) {
        Key_Event(Int32(K_MWHEELUP.rawValue), qboolean(0), qboolean(1))
    }


    @objc func expand(_ sender: Any) {
        buttonStackExpanded = !buttonStackExpanded
        
        UIView.animate(withDuration: 0.5) {
            self.expandButton.setTitle(self.buttonStackExpanded ? " < " : " > ", for: .normal)
            self.expandButton.alpha = self.buttonStackExpanded ? 1 : 0.5
            self.escapeButton.isHidden = !self.buttonStackExpanded
            self.escapeButton.alpha = self.buttonStackExpanded ? 1 : 0
            self.tildeButton.isHidden = !self.buttonStackExpanded
            self.tildeButton.alpha = self.buttonStackExpanded ? 1 : 0
            self.quickLoadButton.isHidden = !self.buttonStackExpanded
            self.quickLoadButton.alpha = self.buttonStackExpanded ? 1 : 0
            self.quickSaveButton.isHidden = !self.buttonStackExpanded
            self.quickSaveButton.alpha = self.buttonStackExpanded ? 1 : 0
        }
        
    }
    
}
