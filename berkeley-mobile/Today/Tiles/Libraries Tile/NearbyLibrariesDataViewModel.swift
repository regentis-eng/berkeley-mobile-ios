//
//  NearbyLibrariesDataViewModel.swift
//  berkeley-mobile
//
//  Created by Regentis on 8/10/26.
//  Copyright © 2026 ASUC OCTO. All rights reserved.
//

import CoreLocation
import Foundation
import Observation
import os

/// Surfaces the top three libraries nearest the user, fetched from the
/// Google Places Nearby Search API.
@MainActor
@Observable
class NearbyLibrariesDataViewModel {
    var libraries: [NearbyLibrary] = []
    var showNotAvailable = false

    @ObservationIgnored
    private let apiKey = Secrets.googlePlacesAPIKey
    @ObservationIgnored
    private let session = URLSession.shared
    /// Fallback location (UC Berkeley campus) when the user has not granted
    /// location access, so the tile can still surface nearby libraries.
    @ObservationIgnored
    private let berkeleyLocation = CLLocation(latitude: 37.8716, longitude: -122.2727)

    init() {
        Task {
            await fetchNearbyLibraries()
        }
    }

    func fetchNearbyLibraries() async {
        let location = BMLocationManager.shared.userLocation ?? berkeleyLocation

        guard let url = nearbySearchURL(for: location) else {
            Logger.nearbyLibrariesDataViewModel.error("Could not construct Google Places Nearby Search URL.")
            showNotAvailable = true
            return
        }

        do {
            let (data, _) = try await session.data(from: url)
            let response = try JSONDecoder().decode(GoogleNearbySearchResponse.self, from: data)
            let nearest = Array(response.results.prefix(3))
            libraries = nearest.map { place in
                let placeLocation = CLLocation(
                    latitude: place.geometry.location.lat,
                    longitude: place.geometry.location.lng
                )
                let distance = location.distance(from: placeLocation)
                let photoURL = place.photos?.first.flatMap { makePhotoURL(for: $0, maxWidth: 200) }
                return NearbyLibrary(
                    id: place.placeId,
                    name: place.name,
                    latitude: place.geometry.location.lat,
                    longitude: place.geometry.location.lng,
                    photoURL: photoURL,
                    distanceMeters: distance
                )
            }
            showNotAvailable = libraries.isEmpty
        } catch {
            Logger.nearbyLibrariesDataViewModel.error("Could not fetch nearby libraries: \(error.localizedDescription)")
            showNotAvailable = true
        }
    }

    // MARK: - URL Construction

    private func nearbySearchURL(for location: CLLocation) -> URL? {
        var components = URLComponents(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json")
        components?.queryItems = [
            URLQueryItem(name: "location", value: "\(location.coordinate.latitude),\(location.coordinate.longitude)"),
            URLQueryItem(name: "rankby", value: "distance"),
            URLQueryItem(name: "type", value: "library"),
            URLQueryItem(name: "key", value: apiKey)
        ]
        return components?.url
    }

    private func makePhotoURL(for photo: GooglePhoto, maxWidth: Int) -> URL? {
        var components = URLComponents(string: "https://maps.googleapis.com/maps/api/place/photo")
        components?.queryItems = [
            URLQueryItem(name: "maxwidth", value: String(maxWidth)),
            URLQueryItem(name: "photoreference", value: photo.photoReference),
            URLQueryItem(name: "key", value: apiKey)
        ]
        return components?.url
    }
}
