import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppConfig.ocrBaseURLKey) private var ocrBaseURL: String = AppConfig.defaultOCRBaseURL

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    settingsCard
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("OCR backend")
                .font(.headline)
            TextField("http://192.168.1.10:8000", text: $ocrBaseURL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .keyboardType(.URL)
                .textFieldStyle(.roundedBorder)

            if !isValidURL {
                Text("Enter a full URL, for example http://192.168.1.10:8000")
                    .font(.caption)
                    .foregroundStyle(.red)
            } else {
                Text("Use the machine running the OCR backend.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Button("Reset to default") {
                ocrBaseURL = AppConfig.defaultOCRBaseURL
            }
            .font(.subheadline)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), lineWidth: 1)
        )
    }

    private var isValidURL: Bool {
        AppConfig.normalizedURL(from: ocrBaseURL) != nil
    }
}
