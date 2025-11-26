import Foundation
import SwiftData

@Model
final class Template: Hashable {
    var id: UUID
    var name: String
    var body: String
    var fieldsData: Data // JSON으로 인코딩된 필드 정보
    var createdAt: Date

    init(id: UUID = UUID(), name: String, body: String, fields: [TemplateField]) {
        self.id = id
        self.name = name
        self.body = body
        self.fieldsData = (try? JSONEncoder().encode(fields)) ?? Data()
        self.createdAt = Date()
    }

    var fields: [TemplateField] {
        get {
            (try? JSONDecoder().decode([TemplateField].self, from: fieldsData)) ?? []
        }
        set {
            fieldsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    static func == (lhs: Template, rhs: Template) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Export/Import를 위한 변환 메서드
    func toExportable() -> ExportableTemplate {
        ExportableTemplate(
            id: id,
            name: name,
            body: body,
            fields: fields,
            createdAt: createdAt
        )
    }
    
    static func fromExportable(_ exportable: ExportableTemplate) -> Template {
        Template(
            id: exportable.id,
            name: exportable.name,
            body: exportable.body,
            fields: exportable.fields
        )
    }
}

// Export/Import를 위한 Codable 구조체
struct ExportableTemplate: Codable, Identifiable {
    var id: UUID
    var name: String
    var body: String
    var fields: [TemplateField]
    var createdAt: Date
}

struct TemplateField: Codable, Identifiable {
    var id: UUID
    var name: String
    var type: FieldType
    var options: [String] // Radio 타입일 때 사용
    var defaultValue: String // Fixed 타입일 때 사용

    init(id: UUID = UUID(), name: String, type: FieldType, options: [String] = [], defaultValue: String = "") {
        self.id = id
        self.name = name
        self.type = type
        self.options = options
        self.defaultValue = defaultValue
    }

    enum FieldType: String, Codable, CaseIterable {
        case text = "text"
        case link = "link"
        case radio = "radio"
        case fixed = "fixed"

        var displayName: String {
            switch self {
            case .text: return "텍스트"
            case .link: return "링크"
            case .radio: return "라디오"
            case .fixed: return "고정값"
            }
        }
    }
}
