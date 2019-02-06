//
//  OktaApiMock.swift
//  OktaAuthNative iOS Tests
//
//  Created by Ildar Abdullin on 2/5/19.
//

import Foundation
import OktaAuthNative

class OktaApiMock: OktaAPI {
    
    public init?(successCase: Bool, json: String?, resourceName: String?) {
        
        var jsonData: Data?
        if let resourceName = resourceName {
        
            let url = Bundle.init(for: OktaApiMock.self).url(forResource: resourceName, withExtension: nil)
            do {
                jsonData = try Data(contentsOf: url!)
            } catch {
                return nil
            }
        }
        
        if let json = json {

            jsonData = json.data(using: .utf8)
        }
        
        guard jsonData != nil else {
            return nil
        }
        
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        decoder.dateDecodingStrategy = .formatted(formatter)

        if successCase {
            let response: OktaAPISuccessResponse
            do {
                response = try decoder.decode(OktaAPISuccessResponse.self, from: jsonData!)
            } catch {
                return nil
            }
            
            result = OktaAPIRequest.Result.success(response)
        } else {
            let response: OktaAPIErrorResponse
            do {
                response = try decoder.decode(OktaAPIErrorResponse.self, from: jsonData!)
            } catch {
                return nil
            }
            
            result = OktaAPIRequest.Result.error(OktaError.serverRespondedWithError(response))
        }
        
        
        super.init(oktaDomain: URL(string: "https://dummy.url")!)
    }
    
    override public func primaryAuthentication(username: String?, password: String?, audience: String?, relayState: String?, multiOptionalFactorEnroll: Bool, warnBeforePasswordExpired: Bool, token: String?, deviceToken: String?, deviceFingerprint: String?, completion: ((OktaAPIRequest.Result) -> Void)?) {
        
        DispatchQueue.main.async {
            completion?(self.result)
        }
    }
    
    var json: String?
    var resourceName: String?
    private var result: OktaAPIRequest.Result
}