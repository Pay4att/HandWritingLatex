import Foundation

enum ObsidianClientError: Error {
    case invalidResponse
    case serverError(Int)
}

struct ObsidianClient {
    let baseURL: URL

    func insert(latex: String) async throws {
        let url = baseURL.appendingPathComponent("insert")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(InsertPayload(latex: latex))

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ObsidianClientError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw ObsidianClientError.serverError(httpResponse.statusCode)
        }
    }
}

private struct InsertPayload: Encodable {
    let latex: String
}
