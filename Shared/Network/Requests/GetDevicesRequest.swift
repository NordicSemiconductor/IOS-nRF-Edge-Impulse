//
//  GetDevicesRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 25/05/2021.
//

import Foundation
import iOS_Common_Libraries

// MARK: - Request

extension HTTPRequest {
    
    static func getDevices(for project: Project, using apiToken: String) -> HTTPRequest? {
        var request = HTTPRequest(host: .EdgeImpulse, path: "/v1/api/\(project.id)/devices")
        let jwtValue = "jwt=" + apiToken
        request?.setMethod(.GET)
        request?.setHeaders(["cookie": jwtValue])
        return request
    }
    
    static func getDevice(for project: Project, deviceId: String, using apiToken: String) -> HTTPRequest? {
        var request = HTTPRequest(host: .EdgeImpulse, path: "/v1/api/\(project.id)/device/\(deviceId)")
        let jwtValue = "jwt=" + apiToken
        request?.setHeaders(["cookie": jwtValue])
        return request
    }
}

// MARK: - Response

struct GetDeviceListResponse: HTTPResponse {
    let success: Bool
    let error: String?
    
    let devices: [Device]
}

struct GetDeviceResponse: HTTPResponse {
    let success: Bool
    let error: String?
    
    let device: Device
}
