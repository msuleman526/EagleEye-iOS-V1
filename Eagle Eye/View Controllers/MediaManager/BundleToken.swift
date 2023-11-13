
import Foundation

public final class BundleToken {
    static var bundle : Bundle = BundleToken.resourcesBundle
    
    static var resourcesBundle: Bundle {
        let podBundle = Bundle(for: BundleToken.self)
               let bundleURL = podBundle.bundleURL
               return Bundle(url: bundleURL)!
    }
}
