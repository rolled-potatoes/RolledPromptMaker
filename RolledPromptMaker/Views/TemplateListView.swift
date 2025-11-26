import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct TemplateListView: View {
    @Environment(\.modelContext) private var modelContext
    let templates: [Template]
    @Binding var selectedTemplate: Template?
    @Binding var showingTemplateEditor: Bool
    @Binding var isEditMode: Bool
    @Binding var editingTemplate: Template?
    
    @State private var showingExportPicker = false
    @State private var showingImportPicker = false
    @State private var exportTemplate: Template?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 헤더
            HStack {
                Text("템플릿")
                    .font(.headline)
                    .padding(.leading, 8)
                Spacer()
                
                // Import 버튼
                Button(action: {
                    showingImportPicker = true
                }) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.title3)
                }
                .buttonStyle(.plain)
                .help("템플릿 가져오기")
                
                // 새 템플릿 추가 버튼
                Button(action: {
                    isEditMode = false
                    editingTemplate = nil
                    showingTemplateEditor = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
                .buttonStyle(.plain)
                .help("새 템플릿 추가")
            }
            .padding()

            Divider()

            // 템플릿 목록
            if templates.isEmpty {
                VStack {
                    Spacer()
                    Text("템플릿이 없습니다")
                        .foregroundColor(.secondary)
                    Text("+ 버튼을 눌러 새 템플릿을 만드세요")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                List(selection: $selectedTemplate) {
                    ForEach(templates) { template in
                        Button(action: {
                            selectedTemplate = template
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(template.name)
                                        .font(.headline)
                                    Text("\(template.fields.count)개 필드")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                if selectedTemplate?.id == template.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.vertical, 4)
                        .background(selectedTemplate?.id == template.id ? Color.accentColor.opacity(0.1) : Color.clear)
                        .cornerRadius(4)
                        .contextMenu {
                            Button("편집") {
                                isEditMode = true
                                editingTemplate = template
                                showingTemplateEditor = true
                            }
                            Button("내보내기") {
                                exportTemplate = template
                                showingExportPicker = true
                            }
                            Divider()
                            Button("삭제", role: .destructive) {
                                deleteTemplate(template)
                            }
                        }
                        .tag(template)
                    }
                }
                .listStyle(.sidebar)
            }
        }
        .frame(minWidth: 200, idealWidth: 250)
        .fileExporter(
            isPresented: $showingExportPicker,
            document: TemplateDocument(template: exportTemplate),
            contentType: .json,
            defaultFilename: "\(exportTemplate?.name ?? "template").json"
        ) { result in
            switch result {
            case .success(let url):
                print("템플릿 저장 성공: \(url)")
            case .failure(let error):
                print("템플릿 저장 실패: \(error)")
            }
        }
        .fileImporter(
            isPresented: $showingImportPicker,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                importTemplate(from: url)
            case .failure(let error):
                print("템플릿 불러오기 실패: \(error)")
            }
        }
    }

    private func deleteTemplate(_ template: Template) {
        modelContext.delete(template)
        if selectedTemplate?.id == template.id {
            selectedTemplate = nil
        }
    }
    
    private func importTemplate(from url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let exportableTemplate = try decoder.decode(ExportableTemplate.self, from: data)
            
            // 새로운 Template 생성하여 저장
            let newTemplate = Template.fromExportable(exportableTemplate)
            modelContext.insert(newTemplate)
            
            print("템플릿 가져오기 성공: \(newTemplate.name)")
        } catch {
            print("템플릿 가져오기 실패: \(error)")
        }
    }
}

// FileDocument 프로토콜을 구현한 템플릿 문서
struct TemplateDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    var template: Template?
    
    init(template: Template?) {
        self.template = template
    }
    
    init(configuration: ReadConfiguration) throws {
        // Import는 fileImporter로 처리하므로 여기서는 비워둠
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let template = template else {
            throw CocoaError(.fileWriteUnknown)
        }
        
        let exportable = template.toExportable()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(exportable)
        
        return FileWrapper(regularFileWithContents: data)
    }
}
