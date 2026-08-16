import UIKit

struct Recommendation: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let detailText: String
    let borderColor: UIColor
}
