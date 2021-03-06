import Foundation

/// Аниматор, показывающий UIPopoverController, с UIViewController'ом, обернутым в UINavigationController.
/// Также выполняет обратный переход
public class PopoverNavigationTransitionsAnimator: TransitionsAnimator
{
    public var shouldAnimate = true
    
    // MARK: - Init
    public init() {}
    
    // MARK: - TransitionsAnimator
    public func animatePerformingTransition(animationContext context: PopoverNavigationPresentationAnimationContext)
    {
        switch context.transitionStyle {
        case .PopoverFromBarButtonItem(let buttonItem):
            context.popoverController.presentPopoverFromBarButtonItem(
                buttonItem,
                permittedArrowDirections: .Any,
                animated: shouldAnimate
            )
            
        case .PopoverFromView(let sourceView, let sourceRect):
            context.popoverController.presentPopoverFromRect(
                sourceRect,
                inView: sourceView,
                permittedArrowDirections: .Any,
                animated: shouldAnimate
            )
        }
        
        // только так можно отключить кнопки на navigation bar'е из которого, вызвали поповер
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            context.popoverController.passthroughViews = nil
        })
        
        shouldAnimate = true
    }
    
    public func animateUndoingTransition(animationContext context: PopoverNavigationDismissalAnimationContext)
    {
        context.popoverController.dismissPopoverAnimated(
            shouldAnimate
        )
        
        shouldAnimate = true
    }
}