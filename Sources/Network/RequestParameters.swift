//
//  RequestParameters.swift
//
//
//  Created by Md Rezaul Karim on 12/28/24.
//

import Foundation

public enum RequestParameters {
    case body(_: [String: Any]?)
    case url(_: [String: String]?)
}
