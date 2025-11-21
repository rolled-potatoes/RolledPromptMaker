import SwiftUI
import SwiftData

struct TemplateListView: View {
    @Environment(\.modelContext) private var modelContext
    let templates: [Template]
    @Binding var selectedTemplate: Template?
    @Binding var showingTemplateEditor: Bool
    @Binding var isEditMode: Bool
    @Binding var editingTemplate: Template?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 헤더
            HStack {
                Text("템플릿")
                    .font(.headline)
                    .padding(.leading, 8)
                Spacer()
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
    }

    private func deleteTemplate(_ template: Template) {
        modelContext.delete(template)
        if selectedTemplate?.id == template.id {
            selectedTemplate = nil
        }
    }
}
