//
//  BuildOnDeviceModelRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 7/7/21.
//

import Foundation

extension HTTPRequest {
    
    static func buildModel(project: Project, usingEONCompiler: Bool, classifier: DeploymentViewState.Classifier,
                           using apiToken: String) -> HTTPRequest? {
        let body = BuildOnDeviceModelRequestBody(isEONCompilerEnabled: usingEONCompiler, classifier: classifier)
        guard var httpRequest = HTTPRequest(host: .EdgeImpulse, path: "/v1/api/\(project.id)/jobs/build-ondevice-model",
                                            parameters: ["type": "nordic-thingy53"]),
              let bodyData = try? JSONEncoder().encode(body) else {
            return nil
        }
        
        httpRequest.setMethod(.POST)
        let jwtValue = "jwt=" + apiToken
        httpRequest.setHeaders(["cookie": jwtValue, "Accept": "application/json", "Content-Type": "application/json"])
        httpRequest.setBody(bodyData)
        return httpRequest
    }
}

// MARK: - Response

struct BuildOnDeviceModelRequestResponse: APIResponse {
    
    let id: Int
    let success: Bool
    let error: String?
}

// MARK: - Body

fileprivate struct BuildOnDeviceModelRequestBody: Codable {
    
    let engine: String
    let modelType: String
    
    init(isEONCompilerEnabled: Bool, classifier: DeploymentViewState.Classifier) {
        self.engine = isEONCompilerEnabled ? "tflite-eon" : "tflite"
        self.modelType = classifier.requestValue
    }
}

// MARK: - DeploymentViewState.Classifier

fileprivate extension DeploymentViewState.Classifier {
    
    var requestValue: String {
        switch self {
        case .Quantized:
            return "int8"
        case .Unoptimized:
            return "float32"
        }
    }
}
