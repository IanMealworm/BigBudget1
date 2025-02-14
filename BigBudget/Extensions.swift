import Foundation

extension URL {
    func excludedFromBackup(_ excluded: Bool) -> URL {
        var url = self
        do {
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = excluded
            try url.setResourceValues(resourceValues)
        } catch {
            print("Error setting resource values: \(error)")
        }
        return url
    }
} 