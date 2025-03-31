//
//  File.swift
//  Relay
//
//  Created by Caleb Davis on 3/31/25.
//

import Foundation

protocol DataCompressor {
    func compress(_ data: Data) throws -> Data
    func decompress(_ data: Data) throws -> Data
}

struct GzipCompressor: DataCompressor {
    func compress(_ data: Data) throws -> Data {
        try data.gzipped()
    }

    func decompress(_ data: Data) throws -> Data {
        try data.gunzipped()
    }
}
