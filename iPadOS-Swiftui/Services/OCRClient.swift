import Foundation

struct OCRResult {
    let latex: String
    let engine: String
}

enum OCRClientError: Error {
    case invalidResponse
    case serverError(Int)
}

struct OCRClient {
    let baseURL: URL

    func recognize(pngData: Data) async throws -> OCRResult {
        let url = baseURL.appendingPathComponent("ocr/formula")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = pngData
        request.setValue("image/png", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OCRClientError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw OCRClientError.serverError(httpResponse.statusCode)
        }

        let decoded = try JSONDecoder().decode(OCRResponse.self, from: data)
        return OCRResult(latex: decoded.latex, engine: decoded.engine ?? "paddle")
    }
}

private struct OCRResponse: Decodable {
    let latex: String
    let engine: String?
}
