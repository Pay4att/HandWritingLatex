import Foundation

struct ObsidianService: Identifiable {
    let id: UUID
    let name: String
    let host: String?
    let port: Int

    var detailText: String {
        guard let host = host else {
            return "Resolving..."
        }
        return "\(host):\(port)"
    }
}

final class ObsidianServiceDiscovery: NSObject, ObservableObject {
    @Published private(set) var services: [ObsidianService] = []
    @Published private(set) var isSearching = false

    private var browser: NetServiceBrowser?
    private var serviceIDs: [ObjectIdentifier: UUID] = [:]

    func start() {
        guard browser == nil else { return }
        services.removeAll()

        let browser = NetServiceBrowser()
        browser.delegate = self
        browser.searchForServices(ofType: "_formula-ocr._tcp.", inDomain: "local.")
        self.browser = browser
        isSearching = true
    }

    func stop() {
        browser?.stop()
        browser = nil
        isSearching = false
        serviceIDs.removeAll()
    }

    func refresh() {
        stop()
        start()
    }

    private func upsert(service: NetService, host: String?) {
        let identifier = ObjectIdentifier(service)
        let id = serviceIDs[identifier] ?? UUID()
        serviceIDs[identifier] = id

        let cleanedHost = host.flatMap { cleanHostName($0) }
        let port = service.port

        if let index = services.firstIndex(where: { $0.id == id }) {
            services[index] = ObsidianService(
                id: id,
                name: service.name,
                host: cleanedHost,
                port: port
            )
        } else {
            services.append(
                ObsidianService(
                    id: id,
                    name: service.name,
                    host: cleanedHost,
                    port: port
                )
            )
        }
        services.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private func remove(service: NetService) {
        let identifier = ObjectIdentifier(service)
        guard let id = serviceIDs.removeValue(forKey: identifier) else { return }
        services.removeAll { $0.id == id }
    }

    private func cleanHostName(_ value: String) -> String {
        value.hasSuffix(".") ? String(value.dropLast()) : value
    }
}

extension ObsidianServiceDiscovery: NetServiceBrowserDelegate {
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        service.delegate = self
        upsert(service: service, host: nil)
        service.resolve(withTimeout: 5)
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        remove(service: service)
    }

    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        isSearching = false
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        isSearching = false
    }
}

extension ObsidianServiceDiscovery: NetServiceDelegate {
    func netServiceDidResolveAddress(_ sender: NetService) {
        upsert(service: sender, host: sender.hostName)
    }

    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        upsert(service: sender, host: nil)
    }
}
