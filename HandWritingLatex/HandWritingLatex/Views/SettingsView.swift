import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppConfig.ocrBaseURLKey) private var ocrBaseURL: String = AppConfig.defaultOCRBaseURL
    @AppStorage(AppConfig.obsidianBaseURLKey) private var obsidianBaseURL: String = AppConfig.defaultObsidianBaseURL
    @StateObject private var discovery = ObsidianServiceDiscovery()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ocrSettingsCard
                    obsidianSettingsCard
                    discoveryCard
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
        .onAppear {
            discovery.start()
        }
        .onDisappear {
            discovery.stop()
        }
    }

    private var ocrSettingsCard: some View {
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

    private var obsidianSettingsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Obsidian insert server")
                .font(.headline)
            TextField("http://192.168.1.10:27123", text: $obsidianBaseURL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .keyboardType(.URL)
                .textFieldStyle(.roundedBorder)

            if !isValidObsidianURL {
                Text("Enter a full URL, for example http://192.168.1.10:27123")
                    .font(.caption)
                    .foregroundStyle(.red)
            } else {
                Text("This should point to the computer running Obsidian.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Button("Reset to default") {
                obsidianBaseURL = AppConfig.defaultObsidianBaseURL
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

    private var discoveryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Nearby Obsidian servers")
                    .font(.headline)
                Spacer()
                Button(discovery.isSearching ? "Searching..." : "Refresh") {
                    discovery.refresh()
                }
                .disabled(discovery.isSearching)
            }

            if discovery.services.isEmpty {
                Text("No devices found yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(discovery.services) { service in
                    Button(action: { select(service) }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(service.name)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                            Text(service.detailText)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.separator), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(service.host == nil)
                }
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), lineWidth: 1)
        )
    }

    private func select(_ service: ObsidianService) {
        guard let host = service.host else { return }
        obsidianBaseURL = "http://\(host):\(service.port)"
    }

    private var isValidURL: Bool {
        AppConfig.normalizedURL(from: ocrBaseURL) != nil
    }

    private var isValidObsidianURL: Bool {
        AppConfig.normalizedURL(from: obsidianBaseURL) != nil
    }
}
