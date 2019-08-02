import UIKit

class CardViewController: UIViewController {

    @IBOutlet weak var handleArea: UIView!
    @IBOutlet weak var modalView: UIView!
    
    // Enum for card states
    enum CardState {
        case collapsed
        case expanded
    }
    
    // Variable determines the next state of the card expressing that the card starts and collapased
    var nextState:CardState {
        return cardVisible ? .collapsed : .expanded
    }
    
    // Variable for card view controller
    var cardViewController: CardViewController!
    var homeViewController: BaseViewController!
    
    // Variable for effects visual effect view
    var visualEffectView: UIVisualEffectView!
    
    // Starting and end card heights will be determined later
    var endCardHeight: CGFloat = 0
    var startCardHeight: CGFloat = 0
    
    // Current visible state of the card
    var cardVisible = false
    
    // Empty property animator array
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    func configure(parent: BaseViewController) {
        homeViewController = parent
        setupCard()
    }
    
    func setupCard() {
        // Setup starting and ending card height
        endCardHeight = 350
        startCardHeight = 1
        
        // Add Visual Effects View
        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = homeViewController.view.frame
        homeViewController.view.addSubview(visualEffectView)
        
        // Add CardViewController xib to the bottom of the screen, clipping bounds so that the corners can be rounded
        cardViewController = self
        self.view.frame = CGRect(x: 0, y: homeViewController.view.frame.height - startCardHeight, width: homeViewController.view.bounds.width, height: endCardHeight)
        self.view.clipsToBounds = true
        self.view.layer.cornerRadius = 30
        self.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        homeViewController.view.addSubview(self.view)
        
        // Add tap and pan recognizers
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(CardViewController.handleCardPan(recognizer:)))
        
        animateTransitionIfNeeded(state: nextState, duration: 1)
        self.handleArea.addGestureRecognizer(panGestureRecognizer)
    }
    
    // Handle pan gesture recognizer
    @objc
    func handleCardPan (recognizer:UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            // Start animation if pan begins
            startInteractiveTransition(state: nextState, duration: 0.9)
        case .changed:
            // Update the translation according to the percentage completed
            let translation = recognizer.translation(in: self.handleArea)
            var fractionComplete = translation.y / endCardHeight
            fractionComplete = cardVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            // End animation when pan ends
            continueInteractiveTransition()
        default:
            break
        }
    }
    
    // Animate transistion function
    func animateTransitionIfNeeded (state:CardState, duration:TimeInterval) {
        // Check if frame animator is empty
        if runningAnimations.isEmpty {
            // Create a UIViewPropertyAnimator depending on the state of the popover view
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    // If expanding set popover y to the ending height and blur background
                    self.view.frame.origin.y = self.homeViewController.view.frame.height - self.endCardHeight
                    self.visualEffectView.effect = UIBlurEffect(style: .dark)
                    self.visualEffectView.alpha = 0.4
                    
                case .collapsed:
                    // If collapsed set popover y to the starting height and remove background blur
                    self.view.frame.origin.y = self.homeViewController.view.frame.height - self.startCardHeight
                    self.visualEffectView.effect = nil
                }
            }
            
            // Complete animation frame
            frameAnimator.addCompletion { _ in
                self.cardVisible = !self.cardVisible
                self.runningAnimations.removeAll()
                
                if (state == .collapsed) {
                    self.view.removeFromSuperview()
                    self.visualEffectView.removeFromSuperview()
                }
            }
            
            // Start animation
            frameAnimator.startAnimation()
            
            // Append animation to running animations
            runningAnimations.append(frameAnimator)
        }
    }
    
    // Function to start interactive animations when view is dragged
    func startInteractiveTransition(state:CardState, duration:TimeInterval) {
        
        // If animation is empty start new animation
        if runningAnimations.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        
        // For each animation in runningAnimations
        for animator in runningAnimations {
            // Pause animation and update the progress to the fraction complete percentage
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
    // Funtion to update transition when view is dragged
    func updateInteractiveTransition(fractionCompleted:CGFloat) {
        // For each animation in runningAnimations
        for animator in runningAnimations {
            // Update the fraction complete value to the current progress
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
    
    // Function to continue an interactive transisiton
    func continueInteractiveTransition (){
        // For each animation in runningAnimations
        for animator in runningAnimations {
            // Continue the animation forwards or backwards
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
}
