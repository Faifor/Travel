//
//  NetworkService.swift
//  Travel
//
//  Created by Данила Спиридонов on 05.02.2026.
//

import Foundation
import Network
import SwiftUI
import Combine

final class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private var probeWorkItem: DispatchWorkItem?
    
    @Published var isConnected = true
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let isNowConnected = path.status == .satisfied
                self?.isConnected = isNowConnected
                if isNowConnected == false {
                    self?.scheduleProbe()
                } else {
                    self?.probeWorkItem?.cancel()
                    self?.probeWorkItem = nil
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
    
    private func scheduleProbe() {
        probeWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            guard let url = URL(string: "https://clients3.google.com/generate_204") else {
                return
            }
            let config = URLSessionConfiguration.ephemeral
            config.timeoutIntervalForRequest = 2
            config.timeoutIntervalForResource = 3
            let session = URLSession(configuration: config)
            let task = session.dataTask(with: url) { _, response, error in
                DispatchQueue.main.async {
                    if let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) {
                        self.isConnected = true
                        self.probeWorkItem = nil
                    } else if error != nil {
                        if self.isConnected == false {
                            self.rescheduleProbe()
                        }
                    } else {
                        if self.isConnected == false {
                            self.rescheduleProbe()
                        }
                    }
                }
            }
            task.resume()
        }
        probeWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: work)
    }
    
    private func rescheduleProbe() {
        guard probeWorkItem == nil else { return }
        scheduleProbe()
    }
}
