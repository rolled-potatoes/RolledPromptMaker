import Foundation
import SwiftData

@Model
final class History: Hashable {
    var id: UUID
    var templateId: UUID
    var templateName: String
    var content: String
    var createdAt: Date

    init(id: UUID = UUID(), templateId: UUID, templateName: String, content: String) {
        self.id = id
        self.templateId = templateId
        self.templateName = templateName
        self.content = content
        self.createdAt = Date()
    }

    static func == (lhs: History, rhs: History) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
