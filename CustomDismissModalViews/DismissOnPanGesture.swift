//  Created by David Seek on 11/21/16.
//  Copyright © 2016 David Seek. All rights reserved.

import UIKit

class DismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?)
        -> TimeInterval {
            
            return 0.6
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let sourceController = transitionContext.viewController(forKey: .from),
            let destinationController = transitionContext.viewController(forKey: .to) else {
                return
        }
        
        let screenBounds = UIScreen.main.bounds
        
        var xPosition = destinationController.view.bounds.origin.x - screenBounds.width
        let yPosition = destinationController.view.bounds.origin.y

        destinationController.view.alpha = 0.2
        destinationController.view.frame = CGRect(
            x: xPosition,
            y: yPosition,
            width: destinationController.view.bounds.width,
            height: destinationController.view.bounds.height)
        
        let containerView = transitionContext.containerView
        
        containerView.insertSubview(
            destinationController.view, belowSubview:
            sourceController.view)

        let bottomLeftCorner = CGPoint(x: screenBounds.width, y: 0)
        let finalFrame = CGRect(origin: bottomLeftCorner, size: screenBounds.size)
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
                
                sourceController.view.frame = finalFrame
                destinationController.view.alpha = 1
                
                xPosition = destinationController.view.bounds.origin.x
            
                destinationController.view.frame = CGRect(
                    x: xPosition,
                    y: yPosition,
                    width: destinationController.view.bounds.width,
                    height: destinationController.view.bounds.height)
                
            }, completion: { _ in
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
}
