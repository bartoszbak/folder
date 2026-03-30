import Foundation
import UIKit
import LinkPresentation

@Observable
final class LinkFetcher {
    var isFetching = false
    var fetchedTitle: String?
    var fetchedDescription: String?
    var favicon: UIImage?
    
    private var currentTask: Task<Void, Never>?
    private var scheduledURL: String?
    
    func fetch(urlString: String) {
        guard let url = URL(string: urlString),
              url.scheme == "https" || url.scheme == "http" else { return }
        
        currentTask?.cancel()
        isFetching = true
        
        currentTask = Task { @MainActor in
            let provider = LPMetadataProvider()
            provider.shouldFetchSubresources = false
            
            if let meta = try? await provider.startFetchingMetadata(for: url) {
                self.fetchedTitle = meta.title
                
                // Extract description from the metadata
                if let url = meta.url {
                    self.fetchedDescription = url.absoluteString
                }
                
                // Try to load the icon
                if let iconProvider = meta.iconProvider {
                    iconProvider.loadObject(ofClass: UIImage.self) { obj, _ in
                        if let img = obj as? UIImage {
                            Task { @MainActor in
                                self.favicon = img
                            }
                        }
                    }
                }
            }
            
            self.isFetching = false
        }
    }
    
    /// Schedules a fetch with a small delay to avoid fetching on every keystroke.
    func schedule(urlString: String) {
        scheduledURL = urlString
        currentTask?.cancel()
        
        currentTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(500))
            
            guard !Task.isCancelled,
                  let scheduled = scheduledURL,
                  scheduled == urlString else { return }
            
            fetch(urlString: urlString)
        }
    }
    
    func reset() {
        currentTask?.cancel()
        currentTask = nil
        isFetching = false
        fetchedTitle = nil
        fetchedDescription = nil
        favicon = nil
        scheduledURL = nil
    }
}
