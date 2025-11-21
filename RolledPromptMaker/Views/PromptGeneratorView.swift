import SwiftUI
import SwiftData
import AppKit

struct PromptGeneratorView: View {
    @Environment(\.modelContext) private var modelContext
    let template: Template
    @State private var fieldValues: [UUID: String] = [:]
    @State private var generatedPrompt: String = ""
    @State private var showingCopyAlert = false

    // 사용자 입력이 필요한 필드만 필터링 (fixed 타입 제외)
    private var inputFields: [TemplateField] {
        template.fields.filter { $0.type != .fixed }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 헤더
            HStack {
                Text(template.name)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()

            Divider()

            // 입력 필드들
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if inputFields.isEmpty {
                        VStack {
                            Text("입력 필드가 없습니다")
                                .foregroundColor(.secondary)
                            Text("모든 값이 자동으로 입력됩니다")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    } else {
                        ForEach(inputFields) { field in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(field.name)
                                    .font(.headline)

                                switch field.type {
                                case .text:
                                    TextEditor(text: binding(for: field.id))
                                        .frame(minHeight: 100)
                                        .padding(4)
                                        .background(Color(NSColor.textBackgroundColor))
                                        .cornerRadius(4)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 4)
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        )

                                case .link:
                                    TextField("URL을 입력하세요", text: binding(for: field.id))
                                        .textFieldStyle(.roundedBorder)

                                case .radio:
                                    Picker("", selection: binding(for: field.id)) {
                                        Text("선택하세요").tag("")
                                        ForEach(field.options, id: \.self) { option in
                                            Text(option).tag(option)
                                        }
                                    }
                                    .pickerStyle(.radioGroup)

                                case .fixed:
                                    EmptyView() // fixed 타입은 표시하지 않음
                                }
                            }
                        }
                    }
                }
                .padding()
            }

            Divider()

            // 생성 버튼
            HStack {
                Spacer()
                Button("생성 및 복사") {
                    generateAndCopy()
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
        }
        .alert("클립보드에 복사되었습니다", isPresented: $showingCopyAlert) {
            Button("확인", role: .cancel) {}
        }
    }

    private func binding(for fieldId: UUID) -> Binding<String> {
        Binding(
            get: { fieldValues[fieldId, default: ""] },
            set: { fieldValues[fieldId] = $0 }
        )
    }

    private func generateAndCopy() {
        var result = template.body

        // 템플릿 본문에서 {{변수명}} 형식을 찾아서 값으로 치환
        for field in template.fields {
            let placeholder = "{{\(field.name)}}"
            let value: String

            // fixed 타입이면 defaultValue 사용, 아니면 사용자 입력값 사용
            if field.type == .fixed {
                value = field.defaultValue
            } else {
                value = fieldValues[field.id, default: ""]
            }

            result = result.replacingOccurrences(of: placeholder, with: value)
        }

        generatedPrompt = result

        // 클립보드에 복사
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(result, forType: .string)

        // 히스토리에 저장
        let history = History(
            templateId: template.id,
            templateName: template.name,
            content: result
        )
        modelContext.insert(history)

        // 알림 표시
        showingCopyAlert = true

        // 필드 초기화 (사용자 입력 필드만)
        fieldValues.removeAll()
    }
}
