//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//

import Foundation
import UIKit

/// Displays a VectorDrawable.
open class VectorView: UIView {
    
    private var drawableLayers: [CALayer] = [] {
        didSet {
            for layer in oldValue {
                layer.removeFromSuperlayer()
            }
            for drawableLayer in drawableLayers {
                layer.addSublayer(drawableLayer)
            }
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        updateLayers()
    }
    
    /// The drawable to display.
    open var drawable: VectorDrawable? {
        didSet {
            updateLayers()
            invalidateIntrinsicContentSize()
        }
    }
    
    var drawableSize: CGSize = .zero
    
    private func updateLayers() {
        if let drawable = drawable {
            drawableLayers = drawable.layerRepresentation(in: bounds)
            drawableSize = drawable.intrinsicSize
        } else {
            drawableLayers = []
            drawableSize = .zero
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        return drawableSize
    }
    
}


extension VectorDrawable {
    
    func layerRepresentation(in bounds: CGRect) -> [CALayer] {
        if bounds.width == 0.0 || bounds.height == 0.0 {
            // there is no point in showing anything for a view of size zero
            return []
        } else {
            let viewSpace = CGSize(width: bounds.width / viewPortWidth,
                                   height: bounds.height / viewPortHeight)
            return zip(layerConfigurations(),
                       createPaths(in: viewSpace))
                .map { (configuration, path) in
                    let layer = CAShapeLayer()
                    configuration(layer)
                    layer.path = path
                    layer.frame = bounds
                    return layer
            }
        }
    }
    
    var intrinsicSize: CGSize {
        return .init(width: baseWidth, height: baseHeight)
    }
    
}