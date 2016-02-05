import UIKit

protocol SecondAssembly {
    func iphoneModule(
        transitionsHandler: TransitionsHandler,
        title: String,
        withTimer: Bool,
        canShowModule1: Bool,
        transitionId: TransitionId,
        presentingTransitionsHandler: TransitionsHandler?,
        transitionsCoordinator: TransitionsCoordinator)
        -> (UIViewController, SecondModuleInput)
    
    func ipadModule(
        transitionsHandler: TransitionsHandler,
        title: String,
        withTimer: Bool,
        canShowModule1: Bool,
        transitionId: TransitionId,
        presentingTransitionsHandler: TransitionsHandler?,
        transitionsCoordinator: TransitionsCoordinator)
        -> (UIViewController, SecondModuleInput)
}