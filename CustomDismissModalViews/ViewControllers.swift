//  Created by David Seek on 11/21/16.
//  Copyright © 2016 David Seek. All rights reserved.

import UIKit

class SourceController: UIViewController, UIViewControllerTransitioningDelegate {
    
    let interactor = Interactor()
    let transition = CATransition()
    
    @IBAction func present(_ sender: Any) {
        
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "VC2")
            as? DestinationController else {
                return
        }
        
        controller.transitioningDelegate = self
        controller.interactor = interactor
        
        transition(to: controller)
    }
    
    // MARK: - Private
    
    func transition(to controller: UIViewController) {
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window?.layer.add(transition, forKey: kCATransition)
        present(controller, animated: false)
    }
    
    // MARK: - Animation
    
    func animationController(
        forDismissed dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
            
            return DismissAnimator()
    }
    
    func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning? {
            
            return interactor.hasStarted
                ? interactor
                : nil
    }
}

class DestinationController: UIViewController {
    
    var interactor: Interactor? = nil
    let transition = CATransition()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let recognizer = UIScreenEdgePanGestureRecognizer(
            target: self,
            action: #selector(gesture))
        
        recognizer.edges = .left
        view.addGestureRecognizer(recognizer)
    }
    
    // MARK: - Private
    
    func transitionDismissal() {
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window?.layer.add(transition, forKey: nil)
        dismiss(animated: false)
    }
    
    @IBAction func dismiss(_ sender: Any) {
        transitionDismissal()
    }
    
    func gesture(_ sender: UIScreenEdgePanGestureRecognizer) {
        
        let percentThreshold: CGFloat = 0.3
        let translation = sender.translation(in: view)
        let fingerMovement = translation.x / view.bounds.width
        let rightMovement = fmaxf(Float(fingerMovement), 0.0)
        let rightMovementPercent = fminf(rightMovement, 1.0)
        let progress = CGFloat(rightMovementPercent)
        
        switch sender.state {
        case .began:
            
            interactor?.hasStarted = true
            dismiss(animated: true)
            
        case .changed:
            
            interactor?.shouldFinish = progress > percentThreshold
            interactor?.update(progress)
            
        case .cancelled:
            
            interactor?.hasStarted = false
            interactor?.cancel()
            
        case .ended:
            
            guard let interactor = interactor else { return }
            interactor.hasStarted = false
            interactor.shouldFinish
                ? interactor.finish()
                : interactor.cancel()
            
        default:
            break
        }
    }
}
