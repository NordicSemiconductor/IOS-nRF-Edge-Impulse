//
//  GetDevicesRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 25/05/2021.
//

import Foundation

// MARK: - Request

extension HTTPRequest {
    static func getDevices(for project: Project, using apiToken: String) -> HTTPRequest? {
        var request = HTTPRequest(host: .EdgeImpulse, path: "/v1/api/\(project.id)/devices")
        let jwtValue = "jwt=" + apiToken
        request?.setMethod(.GET(header: ["cookie": jwtValue]))
        return request
    }
    
    static func getDevice(for project: Project, device: Device, using apiToken: String) -> HTTPRequest? {
        var request = HTTPRequest(host: .EdgeImpulse, path: "/v1/api/\(project.id)/device/\(device.id)")
        let jwtValue = "jwt=" + apiToken
        request?.setMethod(.GET(header: ["cookie": jwtValue]))
        return request
    }
}

// MARK: - Response

struct GetDeviceListResponse: APIResponse {
    let success: Bool
    let error: String?
    
    let devices: [RegisteredDevice]
}
