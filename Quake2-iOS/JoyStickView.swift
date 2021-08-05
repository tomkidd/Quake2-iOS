// Copyright © 2020 Brad Howes. All rights reserved.

import UIKit
import CoreGraphics

/**
 A simple implementation of a joystick interface like those found on classic arcade games. This implementation detects
 and reports two values when the joystick moves:

 * angle: the direction the handle is pointing. Unit is degrees with 0° pointing up (north), and 90° pointing
 right (east).
 * displacement: how far from the view center the joystick is moved in the above direction. Unitless but
 is the ratio of distance moved from center over the radius of the joystick base. Always in range 0.0-1.0

 The view has several settable parameters that be used to configure a joystick's appearance and behavior:

 - monitor: an enumeration of type `JoyStickViewMonitorKind` that can hold a function to receive updates when the
 joystick's angle and/or displacement values change. Supports polar and cartesian (XY) reporting
 - movable: a boolean that when true lets the joystick move around in its parent's view when there joystick moves
 beyond displacement of 1.0.
 - movableBounds: a CGRect which limits where a movable joystick may travel
 - baseImage: a UIImage to use for the joystick's base
 - handleImage: a UIImage to use for the joystick's handle
 
 Additional documentation is available via the attribute names below.
 */
@IBDesignable public final class JoyStickView: UIView {

    /// Optional monitor which will receive updates as the joystick position changes. Supports polar and cartesian
    /// reporting. The function to call with a position report is held in the enumeration value.
    public var monitor: JoyStickViewMonitorKind = .none
    
    /// Optional block to be called upon a tap
    public var tappedBlock: (() -> Void)?
    
    /// Optional rectangular region that restricts where the handle may move. The region should be defined in
    /// this view's coordinates. For instance, to constrain the handle in the Y direction with a UIView of size 100x100,
    /// use `CGRect(x: 50, y: 0, width: 1, height: 100)`
    public var handleConstraint: CGRect? {
        didSet {
            switch handleConstraint {
            case .some(let hc):
                handleCenterClamper = { CGPoint(x: min(max($0.x, hc.minX), hc.maxX),
                                                y: min(max($0.y, hc.minY), hc.maxY)) }
            default:
                handleCenterClamper = { $0 }
            }
        }
    }

    /// The last-reported angle from the joystick handle. Unit is degrees, with 0° up (north) and 90° right (east).
    /// Note that this assumes that `angleRadians` was calculated with atan2(dx, dy) and that dy is positive when
    /// pointing down.
    public var angle: CGFloat { return displacement != 0.0 ? 180.0 - angleRadians * 180.0 / .pi : 0.0 }

    /// The last-reported displacement from the joystick handle. Dimensionless but is the ratio of movement over
    /// the radius of the joystick base. Always falls between 0.0 and 1.0
    public private(set) var displacement: CGFloat = 0.0

    /// If `true` the joystick will move around in the parant's view so that the joystick handle is always at a
    /// displacement of 1.0. This is the default mode of operation. Setting to `false` will keep the view fixed.
    @IBInspectable public var movable: Bool = false

    /// The original location of a movable joystick. Used to restore its position when user double-taps on it.
    public var movableCenter: CGPoint? = nil

    /// Optional rectangular region that restricts where the base may move. The region should be defined in the
    /// this view's coordinates.
    public var movableBounds: CGRect? {
        didSet {
            switch movableBounds {
            case .some(let mb):
                baseCenterClamper = { CGPoint(x: min(max($0.x, mb.minX), mb.maxX),
                                              y: min(max($0.y, mb.minY), mb.maxY)) }
            default:
                baseCenterClamper = { $0 }
            }
        }
    }

    /// The opacity of the base of the joystick. Note that this is different than the view's overall opacity
    /// setting. The end result will be a base image with an opacity of `baseAlpha` * `view.alpha`
    @IBInspectable public var baseAlpha: CGFloat {
        get {
            return baseImageView.alpha
        }
        set {
            baseImageView.alpha = newValue
        }
    }

    /// The opacity of the handle of the joystick. Note that this is different than the view's overall opacity setting.
    /// The end result will be a handle image with an opacity of `handleAlpha` * `view.alpha`
    @IBInspectable public var handleAlpha: CGFloat {
        get {
            return handleImageView.alpha
        }
        set {
            handleImageView.alpha = newValue
        }
    }

    /// The tintColor to apply to the handle. Changing it while joystick is visible will update the handle image.
    @IBInspectable public var handleTintColor: UIColor? = nil {
        didSet { generateHandleImage() }
    }

    /// Scaling factor to apply to the joystick handle. A value of 1.0 will result in no scaling of the image,
    /// however the default value is 0.85 due to historical reasons.
    @IBInspectable public var handleSizeRatio: CGFloat = 0.85 {
        didSet {
            scaleHandleImageView()
        }
    }

    /// Control how the handle image is generated. When this is `false` (default), a CIFilter will be used to tint
    /// the handle image with the `handleTintColor`. This results in a monochrome image of just one color, but with
    /// lighter and darker areas depending on the original image. When this is `true`, the handle image is just
    /// used as a mask, and all pixels with an alpha = 1.0 will be colored with the `handleTintColor` value.
    @IBInspectable public var colorFillHandleImage: Bool = false {
        didSet { generateHandleImage() }
    }

    /// Controls how far the handle can travel along the radius of the base. A value of 1.0 (default) will let the
    /// handle travel the full radius, with maximum travel leaving the center of the handle lying on the circumference
    /// of the base. A value greater than 1.0 will let the handle travel beyond the circumference of the base, while a
    /// value less than 1.0 will reduce the travel to values within the circumference. Note that regardless of this
    /// value, handle movements will always report displacement values between 0.0 and 1.0 inclusive.
    @IBInspectable public var travel: CGFloat = 1.0

    /// The image to use for the base of the joystick
    @IBInspectable public var baseImage: UIImage? {
        didSet { baseImageView.image = baseImage }
    }

    /// The image to use for the joystick handle
    @IBInspectable public var handleImage: UIImage? {
        didSet { generateHandleImage() }
    }

    /// Control whether view will recognize a double-tap gesture and move the joystick base to its original location
    /// when it happens. Note that this is only useful if `moveable` is true.
    @IBInspectable public var enableDoubleTapForFrameReset = true {
        didSet {
            if let dtgr = doubleTapGestureRecognizer {
                removeGestureRecognizer(dtgr)
                doubleTapGestureRecognizer = nil
            }
            if enableDoubleTapForFrameReset {
                installDoubleTapGestureRecognizer()
            }
        }
    }

    /// The max distance the handle may move in any direction, where the start is the center of the joystick base and
    /// the end is on the circumference of the base when travel is 1.0.
    private var radius: CGFloat { return self.bounds.size.width / 2.0 * travel }
    
    /// The image to use to show the base of the joystick
    private var baseImageView: UIImageView = UIImageView(image: nil)

    /// The image to use to show the handle of the joystick
    private var handleImageView: UIImageView = UIImageView(image: nil)

    /// Cache of the last joystick angle in radians
    private var angleRadians: CGFloat = 0.0

    /// Tap gesture recognizer for double-taps which will reset the joystick position
    private var tapGestureRecognizer: UITapGestureRecognizer?

    /// A filter for joystick base centers. Used to restrict base movements.
    private var baseCenterClamper: (CGPoint) -> CGPoint = { $0 }

    /// A filter for joystick handle centers. Used to restrict handle movements.
    private var handleCenterClamper: (CGPoint) -> CGPoint = { $0 }

    /// Tap gesture recognizer for detecting double-taps. Only present if `enableDoubleTapForFrameReset` is true
    private var doubleTapGestureRecognizer: UITapGestureRecognizer?
    
    /**
     Initialize new joystick view using the given frame.
     - parameter frame: the location and size of the joystick
     */
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    /**
     Initialize new joystick view from a file.
     - parameter coder: the source of the joystick configuration information
     */
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /**
     This is the appropriate place to configure our internal views as we have our own geometry.
     */
    public override func layoutSubviews() {
        super.layoutSubviews()
        initialize()
    }
}

// MARK: - Touch Handling

/**
 Main recognizer for movement
 
    We use a recognizer rather than the view's own touch handler methods as there is an iOS quirk
    that delays the touchesEnded method. This quirk doesn't apply to gesture recognizers.
 */
class JoyStickViewGestureRecognizer: UIGestureRecognizer {
    private var touch: UITouch?
    private var firstTimestamp: TimeInterval?
    private var lastTimestamp: TimeInterval?
    private var firstLocation: CGPoint?
    private var lastLocation: CGPoint?
    
    public var wasTap: Bool {
        get {
            if let start = firstTimestamp, let end = lastTimestamp, let startPoint = firstLocation, let lastPoint = lastLocation {
                return end - start < 0.1 && max(abs(startPoint.x-lastPoint.x), abs(startPoint.y-lastPoint.y)) < 2
            }
            return false
        }
    }
    
    /**
     A touch began in the joystick view
     - parameter touches: the set of UITouch instances, one for each touch event
     - parameter event: additional event info (ignored)
     */
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touch = touches.first
        firstTimestamp = touch?.timestamp
        firstLocation = touch?.location(in: nil)
        state = .began
    }
    
    /**
     An existing touch has moved.
     - parameter touches: the set of UITouch instances, one for each touch event
     - parameter event: additional event info (ignored)
     */
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastLocation = touch?.location(in: nil)
        state = .changed
    }

    /**
     An existing touch event has been cancelled (probably due to system event such as an alert). Move joystick to
     center of base.
     - parameter touches: the set of UITouch instances, one for each touch event (ignored)
     - parameter event: additional event info (ignored)
     */
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTimestamp = touch?.timestamp
        lastLocation = touch?.location(in: nil)
        state = .ended
    }

    /**
     User removed touch from display. Move joystick to center of base.
     - parameter touches: the set of UITouch instances, one for each touch event (ignored)
     - parameter event: additional event info (ignored)
     */
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTimestamp = touch?.timestamp
        lastLocation = touch?.location(in: nil)
        state = .ended
    }
    
    /**
     Clear state
     */
    public override func reset() {
        touch = nil
        firstTimestamp = nil
        lastTimestamp = nil
        firstLocation = nil
        lastLocation = nil
    }
    
    /**
     Get touch location
     - parameter view: the view in which to return location coordinates
     */
    public override func location(in view: UIView?) -> CGPoint {
        guard touch != nil else { return .zero }
        return touch!.location(in: view)
    }
}

extension JoyStickView {
    @objc private func gestureRecognizerChanged(recognizer: JoyStickViewGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            updateLocation(location: recognizer.location(in: superview!))
        } else if recognizer.state == .ended {
            homePosition()
            if recognizer.wasTap, let block = tappedBlock {
                block()
            }
        }
    }
    
    /**
     Reset our base to the initial location before the user moved it. By default, this will take place
     whenever the user double-taps on the joystick handle.
     */
    @objc public func resetFrame() {
        guard let movableCenter = self.movableCenter, displacement < 0.5 else { return }
        center = movableCenter
    }
}

// MARK: - Implementation Details

extension JoyStickView {
    
    /**
     Common initialization of view. Creates UIImageView instances for base and handle.
     */
    private func initialize() {
        baseImageView.frame = bounds
        addSubview(baseImageView)

        scaleHandleImageView()
        addSubview(handleImageView)

        let bundle = Bundle(for: JoyStickView.self)

        if self.baseImage == nil {
            if let baseImage = UIImage(named: "DefaultBase", in: bundle, compatibleWith: nil) {
                self.baseImage = baseImage
            }
        }

        baseImageView.image = baseImage

        if self.handleImage == nil {
            if let handleImage = UIImage(named: "DefaultHandle", in: bundle, compatibleWith: nil) {
                self.handleImage = handleImage
            }
        }
        
        generateHandleImage()
        
        addGestureRecognizer(JoyStickViewGestureRecognizer(target: self, action: #selector(gestureRecognizerChanged)))
        
        if enableDoubleTapForFrameReset {
            installDoubleTapGestureRecognizer()
        }
    }

    private func scaleHandleImageView() {
        let inset = (1.0 - handleSizeRatio) * bounds.width / 2.0
        handleImageView.frame = bounds.insetBy(dx: inset, dy: inset)
    }
    
    /**
     Install a UITapGestureRecognizer to detect and process double-tap activity on the joystick.
     */
    private func installDoubleTapGestureRecognizer() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(resetFrame))
        tapGestureRecognizer!.numberOfTapsRequired = 2
        addGestureRecognizer(tapGestureRecognizer!)
    }

    private func generateHandleImage() {
        if colorFillHandleImage {
            colorHandleImage()
        }
        else {
            tintHandleImage()
        }
    }
    
    /**
     Generate a handle image by applying the `handleTintColor` value to the handeImage
     */
    private func colorHandleImage() {
        guard let handleImage = self.handleImage else { return }
        if let handleTintColor = self.handleTintColor {
            let image = handleImage.withRenderingMode(.alwaysTemplate)
            handleImageView.image = image
            handleImageView.tintColor = handleTintColor
        }
        else {
            handleImageView.tintColor = nil
            handleImageView.image = handleImage
        }
    }
    
    private func tintHandleImage() {
        guard let handleImage = self.handleImage else { return }

        guard let handleTintColor = self.handleTintColor else {
            handleImageView.image = handleImage
            return
        }

        guard let inputImage = CIImage(image: handleImage) else {
            fatalError("failed to create input CIImage")
        }
        
        let filterConfig: [String:Any] = [kCIInputIntensityKey: 1.0,
                                          kCIInputColorKey: CIColor(color: handleTintColor),
                                          kCIInputImageKey: inputImage]
        #if swift(>=4.2)
        guard let filter = CIFilter(name: "CIColorMonochrome", parameters: filterConfig) else {
            fatalError("failed to create CIFilter CIColorMonochrome")
        }
        #else
        guard let filter = CIFilter(name: "CIColorMonochrome", withInputParameters: filterConfig) else {
            fatalError("failed to create CIFilter CIColorMonochrome")
        }
        #endif
        
        guard let outputImage = filter.outputImage else {
            fatalError("failed to obtain output CIImage")
        }
        
        handleImageView.image = UIImage(ciImage: outputImage)
    }

    /**
     Reset handle position so that it is in the center of the base.
     */
    private func homePosition() {
        handleImageView.center = bounds.mid
        reportPosition()
    }
    
    /**
     Update the location of the joystick based on the given touch location. Resulting behavior depends on `movable`
     setting.
     - parameter location: the current handle position. NOTE: in coordinates of the superview
     */
    private func updateLocation(location: CGPoint) {
        guard let superview = self.superview else { return }
        guard superview.bounds.contains(location) else { return }

        let delta = location - frame.mid
        let newDisplacement = delta.magnitude / radius

        // Calculate pointing angle used displacements. NOTE: using this ordering of dx, dy to atan2f to obtain
        // navigation angles where 0 is at top of clock dial and angle values increase in a clock-wise direction. This
        // also assumes that Y increases in the downward direction.
        //
        let newAngleRadians = atan2(delta.dx, delta.dy)

        if movable {
            if newDisplacement > 1.0 && repositionBase(location: location, angle: newAngleRadians) {
                repositionHandle(angle: newAngleRadians)
            }
            else {
                handleImageView.center = handleCenterClamper(bounds.mid + delta)
            }
        }
        else if newDisplacement > 1.0 {
            repositionHandle(angle: newAngleRadians)
        }
        else {
            handleImageView.center = handleCenterClamper(bounds.mid + delta)
        }

        reportPosition()
    }

    /**
     Report the current joystick values to any registered `monitor`.
     */
    private func reportPosition() {
        let delta = handleImageView.center - baseImageView.center
        let displacement = delta.magnitude2 == 0.0 ? 0.0 : delta.magnitude / radius
        let angleRadians = delta.magnitude2 == 0.0 ? 0.0 : atan2(delta.dx, delta.dy)

        self.displacement = displacement
        self.angleRadians = angleRadians
            
        switch monitor {
        case let .polar(monitor): monitor(JoyStickViewPolarReport(angle: self.angle, displacement: displacement))
        case let .xy(monitor): monitor(JoyStickViewXYReport(x: delta.dx, y: -delta.dy))
        case .none: break
        }
    }
    
    /**
     Move the base so that the handle displacement is <= 1.0 from the base. THe last step of this operation is
     a clamping of the base origin so that it stays within a configured boundary. Such clamping can result in
     a joystick handle whose displacement is > 1.0 from the base, so the caller should account for that by looking
     for a `true` return value.
    
     - parameter location: the current joystick handle center position
     - parameter angle: the angle the handle makes with the center of the base
     - returns: true if the base **cannot** move sufficiently to keep the displacement of the handle <= 1.0
     */
    private func repositionBase(location: CGPoint, angle: CGFloat) -> Bool {
        if movableCenter == nil {
            movableCenter = self.center
        }

        // Calculate point that should be on the circumference of the base image.
        //
        let end = CGVector(dx: sin(angle) * radius, dy: cos(angle) * radius)

        // Calculate the origin of our frame, working backwards from the given location, and move to it.
        //
        let desiredCenter = location - end //  - frame.size / 2.0
        self.center = baseCenterClamper(desiredCenter)
        return self.center != desiredCenter
    }

    /**
     Move the joystick handle so that the angle made up of the triangle from the base 12:00 position on its
     circumference, the base center and the joystick center is the given value.
    
     - parameter angle: the angle (radians) to conform to
     */
    private func repositionHandle(angle: CGFloat) {

        // Keep handle on the circumference of the base image
        //
        let x = sin(angle) * radius
        let y = cos(angle) * radius
        handleImageView.frame.origin = CGPoint(x: x + bounds.midX - handleImageView.bounds.size.width / 2.0,
                                               y: y + bounds.midY - handleImageView.bounds.size.height / 2.0)
        
        handleImageView.center = handleCenterClamper(handleImageView.center)
    }
}

/**
 Provide support for Obj-C monitors by wrapping a block in a closure that works with the Swift-only types.
 */
extension JoyStickView {

    @objc public func setPolarMonitor(_ block: @escaping (CGFloat, CGFloat) -> Void) {
        let bridge = {(report: JoyStickViewPolarReport) in block(report.angle, report.displacement) }
        monitor = .polar(monitor: bridge)
    }

    @objc public func setXYMonitor(_ block: @escaping (CGFloat, CGFloat) -> Void) {
        let bridge = {(report: JoyStickViewXYReport) in block(report.x, report.y) }
        monitor = .xy(monitor: bridge)
    }
}
