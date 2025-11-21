import SwiftUI
import SwiftData

struct TemplateEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let template: Template?
    let isEditMode: Bool

    @State private var templateName: String = ""
    @State private var templateBody: String = ""
    @State private var fields: [TemplateField] = []
    @State private var showingAddField = false

    init(template: Template?, isEditMode: Bool) {
        self.template = template
        self.isEditMode = isEditMode

        if let template = template {
            _templateName = State(initialValue: template.name)
            _templateBody = State(initialValue: template.body)
            _fields = State(initialValue: template.fields)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            HStack {
                Text(isEditMode ? "템플릿 편집" : "새 템플릿")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("취소") {
                    dismiss()
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // 내용
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 템플릿 이름
                    VStack(alignment: .leading, spacing: 8) {
                        Text("템플릿 이름")
                            .font(.headline)
                        TextField("템플릿 이름을 입력하세요", text: $templateName)
                            .textFieldStyle(.roundedBorder)
                    }

                    // 프롬프트 본문
                    VStack(alignment: .leading, spacing: 8) {
                        Text("프롬프트 본문")
                            .font(.headline)
                        Text("변수는 {{변수명}} 형식으로 지정합니다")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $templateBody)
                            .frame(minHeight: 200)
                            .padding(4)
                            .background(Color(NSColor.textBackgroundColor))
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }

                    // 필드 정의
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("입력 필드")
                                .font(.headline)
                            Spacer()
                            Button(action: {
                                showingAddField = true
                            }) {
                                Label("필드 추가", systemImage: "plus.circle.fill")
                            }
                            .buttonStyle(.plain)
                        }

                        if fields.isEmpty {
                            Text("필드가 없습니다. '필드 추가' 버튼을 눌러 필드를 추가하세요.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        } else {
                            ForEach(Array(fields.enumerated()), id: \.element.id) { index, field in
                                FieldRow(
                                    field: field,
                                    onEdit: { editedField in
                                        fields[index] = editedField
                                    },
                                    onDelete: {
                                        fields.remove(at: index)
                                    }
                                )
                            }
                        }
                    }
                }
                .padding()
            }

            Divider()

            // 하단 버튼
            HStack {
                Spacer()
                Button("취소") {
                    dismiss()
                }
                .buttonStyle(.plain)

                Button(isEditMode ? "저장" : "생성") {
                    saveTemplate()
                }
                .buttonStyle(.borderedProminent)
                .disabled(templateName.isEmpty || templateBody.isEmpty)
            }
            .padding()
        }
        .frame(width: 600, height: 700)
        .sheet(isPresented: $showingAddField) {
            AddFieldView { newField in
                fields.append(newField)
            }
        }
    }

    private func saveTemplate() {
        if isEditMode, let template = template {
            // 편집 모드
            template.name = templateName
            template.body = templateBody
            template.fields = fields
        } else {
            // 생성 모드
            let newTemplate = Template(name: templateName, body: templateBody, fields: fields)
            modelContext.insert(newTemplate)
        }

        dismiss()
    }
}

struct FieldRow: View {
    let field: TemplateField
    let onEdit: (TemplateField) -> Void
    let onDelete: () -> Void

    @State private var showingEditSheet = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(field.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                HStack {
                    Text(field.type.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if field.type == .radio && !field.options.isEmpty {
                        Text("(\(field.options.joined(separator: ", ")))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else if field.type == .fixed && !field.defaultValue.isEmpty {
                        Text("(\(field.defaultValue.prefix(20))\(field.defaultValue.count > 20 ? "..." : ""))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            Button(action: {
                showingEditSheet = true
            }) {
                Image(systemName: "pencil")
            }
            .buttonStyle(.plain)

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .sheet(isPresented: $showingEditSheet) {
            AddFieldView(existingField: field) { editedField in
                onEdit(editedField)
            }
        }
    }
}

struct AddFieldView: View {
    @Environment(\.dismiss) private var dismiss

    let existingField: TemplateField?
    let onSave: (TemplateField) -> Void

    @State private var fieldName: String = ""
    @State private var fieldType: TemplateField.FieldType = .text
    @State private var radioOptions: [String] = [""]
    @State private var fixedValue: String = ""

    init(existingField: TemplateField? = nil, onSave: @escaping (TemplateField) -> Void) {
        self.existingField = existingField
        self.onSave = onSave

        if let field = existingField {
            _fieldName = State(initialValue: field.name)
            _fieldType = State(initialValue: field.type)
            _radioOptions = State(initialValue: field.options.isEmpty ? [""] : field.options)
            _fixedValue = State(initialValue: field.defaultValue)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 헤더
            HStack {
                Text(existingField == nil ? "필드 추가" : "필드 편집")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }

            // 필드 이름
            VStack(alignment: .leading, spacing: 8) {
                Text("필드 이름 (변수명)")
                    .font(.headline)
                TextField("예: context", text: $fieldName)
                    .textFieldStyle(.roundedBorder)
            }

            // 필드 타입
            VStack(alignment: .leading, spacing: 8) {
                Text("필드 타입")
                    .font(.headline)
                Picker("", selection: $fieldType) {
                    ForEach(TemplateField.FieldType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.radioGroup)
            }

            // Radio 옵션 (Radio 타입일 때만)
            if fieldType == .radio {
                VStack(alignment: .leading, spacing: 8) {
                    Text("선택 옵션")
                        .font(.headline)

                    ForEach(Array(radioOptions.enumerated()), id: \.offset) { index, option in
                        HStack {
                            TextField("옵션 \(index + 1)", text: Binding(
                                get: { radioOptions[index] },
                                set: { radioOptions[index] = $0 }
                            ))
                            .textFieldStyle(.roundedBorder)

                            Button(action: {
                                radioOptions.remove(at: index)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                            .disabled(radioOptions.count <= 1)
                        }
                    }

                    Button(action: {
                        radioOptions.append("")
                    }) {
                        Label("옵션 추가", systemImage: "plus.circle.fill")
                    }
                    .buttonStyle(.plain)
                }
            }

            // 고정값 (Fixed 타입일 때만)
            if fieldType == .fixed {
                VStack(alignment: .leading, spacing: 8) {
                    Text("고정값")
                        .font(.headline)
                    Text("이 값은 프롬프트 생성 시 자동으로 입력됩니다")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextEditor(text: $fixedValue)
                        .frame(minHeight: 100)
                        .padding(4)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
            }

            Spacer()

            // 버튼
            HStack {
                Spacer()
                Button("취소") {
                    dismiss()
                }
                .buttonStyle(.plain)

                Button("저장") {
                    let options = fieldType == .radio ? radioOptions.filter { !$0.isEmpty } : []
                    let defaultVal = fieldType == .fixed ? fixedValue : ""
                    let newField = TemplateField(
                        id: existingField?.id ?? UUID(),
                        name: fieldName,
                        type: fieldType,
                        options: options,
                        defaultValue: defaultVal
                    )
                    onSave(newField)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(fieldName.isEmpty ||
                         (fieldType == .radio && radioOptions.filter { !$0.isEmpty }.isEmpty) ||
                         (fieldType == .fixed && fixedValue.isEmpty))
            }
        }
        .padding()
        .frame(width: 400, height: 500)
    }
}
