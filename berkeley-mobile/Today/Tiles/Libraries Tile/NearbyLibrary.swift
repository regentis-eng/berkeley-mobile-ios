//
//  NearbyLibrary.swift
//  berkeley-mobile
//
//  Created by Regentis on 8/10/26.
//  Copyright © 2026 ASUC OCTO. All rights reserved.
//

import Foundation

/// A library discovered near the user via the Google Places Nearby Search API.
struct NearbyLibrary: Identifiable, Equatable {
    /// The Google Places `place_id`.
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    /// A Google Places Photo URL for the place, when available.
    let photoURL: URL?
    /// Distance from the user, in meters.
    let distanceMeters: Double
}

// MARK: - Google Places Nearby Search Decoding

struct GoogleNearbySearchResponse: Decodable {
    let results: [GooglePlace]
}

struct GooglePlace: Decodable {
    let placeId: String
    let name: String
    let geometry: GoogleGeometry
    let photos: [GooglePhoto]?

    enum CodingKeys: String, CodingKey {
        case placeId = "place_id"
        case name
        case geometry
        case photos
    }
}

struct GoogleGeometry: Decodable {
    let location: GoogleLocation
}

struct GoogleLocation: Decodable {
    let lat: Double
    let lng: Double
}

struct GooglePhoto: Decodable {
    let photoReference: String
    let height: Int
    let width: Int

    enum CodingKeys: String, CodingKey {
        case photoReference = "photo_reference"
        case height
        case width
    }
}
