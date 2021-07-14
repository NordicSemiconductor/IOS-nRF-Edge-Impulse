//
//  SetModelTypeRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 14/7/21.
//

import Foundation

extension HTTPRequest {
    
    static func setOptimizationLevel(project: Project, classifier: DeploymentViewState.Classifier, using apiToken: String) -> HTTPRequest? {
        guard var httpRequest = HTTPRequest(host: .EdgeImpulse, path: "/v1/api/\(project.id)/training/keras/7"),
              let bodyData = try? JSONEncoder().encode(SetModelTypeRequestBody(classifier)) else {
            return nil
        }
        
        httpRequest.setMethod(.POST)
        let jwtValue = "jwt=" + apiToken
        httpRequest.setHeaders(["cookie": jwtValue, "Accept": "application/json", "Content-Type": "application/json"])
        httpRequest.setBody(bodyData)
        return httpRequest
    }
}

// MARK: - Body

fileprivate struct SetModelTypeRequestBody: Codable {
    
    let selectedModelType: String
    
    init(_ classifier: DeploymentViewState.Classifier) {
        self.selectedModelType = classifier.requestValue
    }
}

// MARK: - DeploymentViewState.Classifier

extension DeploymentViewState.Classifier {
    
    var requestValue: String {
        switch self {
        case .Quantized:
            return "int8"
        case .Unoptimized:
            return "float32"
        }
    }
}
