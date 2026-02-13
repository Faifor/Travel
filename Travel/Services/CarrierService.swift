//
//  CarrierService.swift
//  Travel
//
//  Created by Данила Спиридонов on 02.02.2026.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias CarrierResponse = Components.Schemas.CarrierResponse

protocol CarrierServiceProtocol {
    func getCarrierInfo(
        apikey: String,
        code: String,
        system: String?,
        lang: String?,
        format: String?
    ) async throws -> CarrierResponse
}

final class CarrierService: CarrierServiceProtocol {
    private let client: Client
    
    nonisolated init(client: Client) {
        self.client = client
    }
    
    func getCarrierInfo(
        apikey: String,
        code: String,
        system: String? = nil,
        lang: String? = nil,
        format: String? = nil
    ) async throws -> CarrierResponse {
        let response = try await client.getCarrierInfo(query: .init(
            apikey: apikey,
            code: code,
            system: system,
            lang: lang,
            format: format
        ))
        return try response.ok.body.json
    }
}
