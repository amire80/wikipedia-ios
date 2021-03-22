import UIKit

extension WMFAppViewController {

    // MARK: - Language Variant Migration Alerts
    
    @objc public func presentLanguageVariantAlerts(completion: @escaping () -> Void) {
        
        guard isInCorrectState else {
            completion()
            return
        }
        
        let savedLibraryVersion = UserDefaults.standard.integer(forKey: WMFLanguageVariantAlertsLibraryVersion)
        guard savedLibraryVersion < MWKDataStore.currentLibraryVersion else {
            completion()
            return
        }
        
        let languageCodesNeedingAlerts = self.dataStore.languageCodesNeedingVariantAlerts(since: savedLibraryVersion)
        
        if let firstCode = languageCodesNeedingAlerts.first {
            self.presentVariantAlert(for: firstCode, remainingCodes: Array(languageCodesNeedingAlerts.dropFirst()), completion: completion)
        } else {
            completion()
        }
        UserDefaults.standard.set(MWKDataStore.currentLibraryVersion, forKey: WMFLanguageVariantAlertsLibraryVersion)
    }
    
    private func presentVariantAlert(for languageCode: String, remainingCodes: [String], completion: @escaping () -> Void) {
        
        let primaryButtonTapHandler: ScrollableEducationPanelButtonTapHandler
        let secondaryButtonTapHandler: ScrollableEducationPanelButtonTapHandler?
                
        // If there are remaining codes
        if let nextCode = remainingCodes.first {
            
            // If more to show, primary button shows next variant alert
            primaryButtonTapHandler = { _ in
                self.dismiss(animated: true) {
                    self.presentVariantAlert(for: nextCode, remainingCodes: Array(remainingCodes.dropFirst()), completion: completion)
                }
            }
            // And no secondary button
            secondaryButtonTapHandler = nil
            
        } else {
            // If no more to show, primary button navigates to languge settings
            primaryButtonTapHandler = { _ in
                let userActivity = NSUserActivity.wmf_languageSettings()
                self.processUserActivity(userActivity, animated: true, completion: completion)
            }

            // And secondary button dismisses
            secondaryButtonTapHandler = { _ in
                self.dismiss(animated: true, completion: completion)
            }
        }
                
        let alert = LanguageVariantEducationalPanelViewController(primaryButtonTapHandler: primaryButtonTapHandler, secondaryButtonTapHandler: secondaryButtonTapHandler, dismissHandler: nil, theme: self.theme, languageCode: languageCode)
        self.present(alert, animated: true, completion: nil)
    }
    
    //don't present over modals or navigation stacks
    //the user is deep linking in these states and we don't want to interrupt them
    var isInCorrectState: Bool {
        
        guard let navigationController = navigationController else {
            return false
        }
        
        if presentedViewController == nil &&
            navigationController.viewControllers.count == 1 &&
            navigationController.viewControllers[0] is WMFAppViewController {
            return true
        }
        
        return false
    }

}
