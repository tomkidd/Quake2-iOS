// Copyright © 2020 Brad Howes. All rights reserved.

import CoreGraphics

/**
 JoyStickView handle position as X, Y deltas from the base center. Note that here a positive `y` indicates that the
 joystick handle is pushed upwards.
 */
public struct JoyStickViewXYReport {
    /// Delta X of handle from base center
    public let x: CGFloat
    /// Delta Y of handle from base center
    public let y: CGFloat

    /**
     Constructor of new XY report
    
     - parameter x: X offset from center of the base
     - parameter y: Y offset from center of the base (positive values towards up/north)
     */
    public init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }
 
    /// Convert this report into polar format
    public var polar: JoyStickViewPolarReport {
        return JoyStickViewPolarReport(angle: (180.0 - atan2(x, -y) * 180.0 / .pi), displacement: sqrt(x * x + y * y))
    }
}

/**
 JoyStickView handle position as angle/displacement values from the base center. Note that `angle` is given in degrees,
 with 0° pointing up (north) and 90° pointing right (east).
 */
public struct JoyStickViewPolarReport {
    /// Clockwise angle of the handle with respect to north/up of 0°.
    public let angle: CGFloat
    /// Distance from the center of the base
    public let displacement: CGFloat

    /**
     Constructor of new polar report
    
     - parameter angle: clockwise angle of the handle with respect to north/up of 0°.
     - parameter displacement: distance from the center of the base
     */
    public init(angle: CGFloat, displacement: CGFloat) {
        self.angle = angle
        self.displacement = displacement
    }
    
    /// Convert this report into XY format
    public var rectangular: JoyStickViewXYReport {
        let rads = angle * .pi / 180.0
        return JoyStickViewXYReport(x: sin(rads) * displacement, y: cos(rads) * displacement)
    }
}

/**
 Prototype of a monitor function that accepts a JoyStickViewXYReport.
 */
public typealias JoyStickViewXYMonitor = (_ value: JoyStickViewXYReport) -> Void

/**
 Prototype of a monitor function that accepts a JoyStickViewXYReport.
 */
public typealias JoyStickViewPolarMonitor = (_ value: JoyStickViewPolarReport) -> Void

/**
 Monitor kind. Determines the type of reporting that will be emitted from a JoyStickView instance.
 */
public enum JoyStickViewMonitorKind {
    
    /**
     Install monitor that accepts polar position change reports
     
     - parameter monitor: function that accepts a JoyStickViewPolarReport
     */
    case polar(monitor: JoyStickViewPolarMonitor)

    /**
     Install monitor that accepts cartesian (XY) position change reports
     
     - parameter monitor: function that accepts a JoyStickViewXYReport
     */
    case xy(monitor: JoyStickViewXYMonitor)
    
    /**
     No monitoring for a JoyStickView instance.
     */
    case none
}
