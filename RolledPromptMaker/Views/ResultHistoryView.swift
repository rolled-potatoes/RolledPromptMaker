import SwiftUI
import SwiftData
import AppKit

struct ResultHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \History.createdAt, order: .reverse) private var histories: [History]
    @State private var selectedTab = 0
    @State private var selectedHistory: History?
    @State private var showingCopyAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 헤더
            HStack {
                Text("결과 및 기록")
                    .font(.headline)
                    .padding(.leading, 8)
                Spacer()
            }
            .padding()

            Divider()

            // 탭
            Picker("", selection: $selectedTab) {
                Text("기록").tag(0)
                Text("결과").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()

            Divider()

            // 내용
            if selectedTab == 0 {
                // 기록 탭
                historyList
            } else {
                // 결과 탭
                resultView
            }
        }
        .frame(minWidth: 300, idealWidth: 400)
        .alert("클립보드에 복사되었습니다", isPresented: $showingCopyAlert) {
            Button("확인", role: .cancel) {}
        }
    }

    private var historyList: some View {
        Group {
            if histories.isEmpty {
                VStack {
                    Spacer()
                    Text("기록이 없습니다")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                List(selection: $selectedHistory) {
                    ForEach(histories) { history in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(history.templateName)
                                    .font(.headline)
                                Spacer()
                            }
                            Text(formatDate(history.createdAt))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(history.content)
                                .font(.caption)
                                .lineLimit(2)
                                .foregroundColor(.secondary)
                        }
                        .contentShape(Rectangle())
                        .contextMenu {
                            Button("복사") {
                                copyToClipboard(history.content)
                            }
                            Button("삭제", role: .destructive) {
                                deleteHistory(history)
                            }
                        }
                        .tag(history)
                    }
                }
                .listStyle(.inset)
            }
        }
    }

    private var resultView: some View {
        Group {
            if let history = selectedHistory {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(history.templateName)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Text(formatDate(history.createdAt))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button("복사") {
                                copyToClipboard(history.content)
                            }
                            .buttonStyle(.borderedProminent)
                        }

                        Divider()

                        Text(history.content)
                            .textSelection(.enabled)
                    }
                    .padding()
                }
            } else {
                VStack {
                    Spacer()
                    Text("기록을 선택하세요")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }

    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        showingCopyAlert = true
    }

    private func deleteHistory(_ history: History) {
        modelContext.delete(history)
        if selectedHistory?.id == history.id {
            selectedHistory = nil
        }
    }
}
