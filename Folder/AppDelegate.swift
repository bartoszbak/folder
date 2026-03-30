import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        handleEventsForBackgroundURLSession identifier: String,
        completionHandler: @escaping () -> Void
    ) {
        if identifier == MediaUploadSession.sessionIdentifier {
            MediaUploadSession.shared.backgroundCompletionHandler = completionHandler
        }
    }
}
