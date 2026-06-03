//
//  TokenManager.swift
//  date-the-sun
//
//  Created by Heryan Djaruma on 03/06/26.
//

import Foundation

actor TokenManager {
    static let shared = TokenManager()
    
    private var cachedToken: String?
    private var expiresAt: Date?
    
    private let serverURL = "https://date-the-sun-backend.vercel.app/token"
    
    func validToken() async throws -> String {
        if let token = cachedToken,
           let expiry = expiresAt,
           expiry > Date.now.addingTimeInterval(5 * 60) {
            return token
        }
        
        return try await refreshToken()
    }
    
    private func refreshToken() async throws -> String {
        guard let url = URL(string: serverURL) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response  = try JSONDecoder().decode(TokenResponse.self, from: data)
        
        // Cache it
        cachedToken = response.token
        expiresAt   = Date(timeIntervalSince1970: response.expiresAt / 1000)
        
        return response.token
    }
    
    struct TokenResponse: Decodable {
        let token: String
        let expiresAt: Double
    }
}
