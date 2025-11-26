import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Template.createdAt, order: .reverse) private var templates: [Template]
    @State private var selectedTemplate: Template?
    @State private var showingTemplateEditor = false
    @State private var isEditMode = false
    @State private var editingTemplate: Template?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // 좌측 패널: 템플릿 목록
            TemplateListView(
                templates: templates,
                selectedTemplate: $selectedTemplate,
                showingTemplateEditor: $showingTemplateEditor,
                isEditMode: $isEditMode,
                editingTemplate: $editingTemplate
            )
            .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 400)
        } content: {
            // 중앙 패널: 프롬프트 생성기
            Group {
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
            }
            .navigationSplitViewColumnWidth(min: 400, ideal: 525, max: .infinity)
        } detail: {
            // 우측 패널: 결과 및 기록
            ResultHistoryView()
                .navigationSplitViewColumnWidth(min: 250, ideal: 225, max: 500)
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
