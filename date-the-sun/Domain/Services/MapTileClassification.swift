//
//  MapTileClassification.swift
//  date-the-sun
//
//  Created by Heryan Djaruma on 04/06/26.
//

import CoreML
import Vision
import UIKit

struct ClassificationResult {
    let identifier: String
    let confidence: Float
}

class MapTileClassification {
    // Loaded once and reused — each CoreML model can be 20-50 MB.
    private static let appleVNModel: VNCoreMLModel = {
        let ml = try! AMapsSatelliteClassifier400x400x20(configuration: .init()).model
        return try! VNCoreMLModel(for: ml)
    }()
    private static let googleVNModel: VNCoreMLModel = {
        let ml = try! GMapsPolygonClassifier400x400x20(configuration: .init()).model
        return try! VNCoreMLModel(for: ml)
    }()

    static func classify(lat: Double, lng: Double, isAppleMaps: Bool) async throws -> ClassificationResult? {
        /// Build URL
        var components = URLComponents(string: "https://date-the-sun-backend.vercel.app/snapshot/\(isAppleMaps ? "amaps" : "gmaps")")
        components?.queryItems = [
            .init(name: "lat", value: "\(lat)"),
            .init(name: "lng", value: "\(lng)")
        ]
        /// Fetch
        guard let url = components?.url else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let uiImage = UIImage(data: data),
              let cgImage = uiImage.cgImage else {
            throw URLError(.cannotDecodeContentData)
        }
        let vnModel = isAppleMaps ? appleVNModel : googleVNModel
        /// Run vision request
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNCoreMLRequest(model: vnModel) { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let results = request.results as? [VNClassificationObservation],
                      let top = results.first else {
                    continuation.resume(throwing: URLError(.cannotParseResponse))
                    return
                }
                continuation.resume(returning: ClassificationResult(identifier: top.identifier, confidence: top.confidence))
            }
            request.imageCropAndScaleOption = .centerCrop
            let handler = VNImageRequestHandler(cgImage: cgImage)
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
