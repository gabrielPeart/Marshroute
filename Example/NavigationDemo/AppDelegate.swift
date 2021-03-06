import UIKit
import Marshroute

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate
{
    var window: UIWindow?
    
    // Auxiliary window to show touch marker (even over `UIPopoverController`).
    // It should be created lazily, because `UIKit` works incorrenctly
    // if you create two `UIWindow`s at `application(_:didFinishLaunchingWithOptions:)`
    private lazy var touchCursorDrawingWindow: UIWindow? = {
        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        window.userInteractionEnabled = false
        window.windowLevel = UIWindowLevelStatusBar
        window.backgroundColor = .clearColor()
        window.hidden = false
        window.rootViewController = self.window?.rootViewController
        
        return window
    }()
    
    private var touchCursorDrawer: TouchCursorDrawerImpl?
    
    private var touchCursorDrawingWindowProvider: (() -> (UIWindow?)) {
        return { [weak self] in
            return self?.touchCursorDrawingWindow
        }
    }
    
    private var touchEventObserver: TouchEventObserver?

    private var rootTransitionsHandler: ContainingTransitionsHandler?
    
    private var rootTransitionsHandlerProvider: (() -> (ContainingTransitionsHandler?)) {
        return { [weak self] in
            return self?.rootTransitionsHandler
        }
    }
    
    // MARK: - UIApplicationDelegate
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        // Init `Marshroute` stack
        let marshrouteSetupService = MarshrouteSetupServiceImpl()
        
        let applicationModuleSeed = ApplicationModuleSeedProvider().applicationModuleSeed(
            marshrouteSetupService: marshrouteSetupService
        )
        
        // Init service factory
        let serviceFactory = ServiceFactoryImpl(
            topViewControllerFinder: applicationModuleSeed.marshrouteStack.topViewControllerFinder,
            rootTransitionsHandlerProvider: rootTransitionsHandlerProvider,
            transitionsMarker: applicationModuleSeed.marshrouteStack.transitionsMarker,
            transitionsTracker: applicationModuleSeed.marshrouteStack.transitionsTracker,
            transitionsCoordinatorDelegateHolder: applicationModuleSeed.marshrouteStack.transitionsCoordinatorDelegateHolder
        )
        
        // Init assemly factory
        let assemblyFactory = AssemblyFactoryImpl(
            serviceFactory: serviceFactory
        )
        
        let applicationModule: ApplicationModule
            
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            applicationModule = assemblyFactory.applicationAssembly().ipadModule(moduleSeed: applicationModuleSeed)
        } else {
            applicationModule = assemblyFactory.applicationAssembly().module(moduleSeed: applicationModuleSeed)
        }
        
        rootTransitionsHandler = applicationModule.transitionsHandler
        
        // Main application window, which shares delivered touch events with its `touchEventForwarder`
        let touchEventSharingWindow = TouchEventSharingWindow(frame: UIScreen.mainScreen().bounds)
        touchEventSharingWindow.rootViewController = applicationModule.viewController
        touchEventSharingWindow.touchEventForwarder = serviceFactory.touchEventForwarder()
        
        // Object for drawing temporary red markers in places where user touches the screen
        let touchCursorDrawer = TouchCursorDrawerImpl(windowProvider: touchCursorDrawingWindowProvider)
        self.touchCursorDrawer = touchCursorDrawer
        
        let touchEventObserver = serviceFactory.touchEventObserver()
        touchEventObserver.addListener(touchCursorDrawer)
        self.touchEventObserver = touchEventObserver
        
        window = touchEventSharingWindow
        window?.makeKeyAndVisible()

        return true
    }
}