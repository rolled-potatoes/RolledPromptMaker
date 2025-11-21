import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Template.createdAt, order: .reverse) private var templates: [Template]
    @State private var selectedTemplate: Template?
    @State private var showingTemplateEditor = false
    @State private var isEditMode = false
    @State private var editingTemplate: Template?

    var body: some View {
        NavigationSplitView {
            // 좌측 패널: 템플릿 목록
            TemplateListView(
                templates: templates,
                selectedTemplate: $selectedTemplate,
                showingTemplateEditor: $showingTemplateEditor,
                isEditMode: $isEditMode,
                editingTemplate: $editingTemplate
            )
        } content: {
            // 중앙 패널: 프롬프트 생성기
            if let template = selectedTemplate {
                PromptGeneratorView(template: template)
            } else {
                VStack {
                    Image(systemName: "doc.text")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("템플릿을 선택하세요")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        } detail: {
            // 우측 패널: 결과 및 기록
            ResultHistoryView()
        }
        .sheet(isPresented: $showingTemplateEditor) {
            TemplateEditorView(
                template: isEditMode ? editingTemplate : nil,
                isEditMode: isEditMode
            )
        }
        .frame(minWidth: 1000, minHeight: 600)
    }
}
