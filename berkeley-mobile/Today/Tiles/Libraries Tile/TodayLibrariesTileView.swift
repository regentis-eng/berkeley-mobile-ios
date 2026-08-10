//
//  TodayLibrariesTileView.swift
//  berkeley-mobile
//
//  Created by Regentis on 8/10/26.
//  Copyright © 2026 ASUC OCTO. All rights reserved.
//

import FactoryKit
import SwiftUI

struct TodayLibrariesTileView: View {
    @InjectedObservable(\.nearbyLibrariesDataViewModel) private var viewModel

    private var shouldRedact: Bool {
        !viewModel.showNotAvailable && viewModel.libraries.isEmpty
    }

    var body: some View {
        Group {
            if viewModel.showNotAvailable {
                Text("Nearby libraries are not currently available.")
                    .font(.caption)
                    .foregroundStyle(.white)
            } else {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("Nearby Libraries")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "books.vertical")
                            .font(.callout)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.libraries) { library in
                            libraryRow(for: library)
                        }
                    }
                }
                .redacted(reason: shouldRedact ? .placeholder : [])
                .foregroundStyle(.white)
            }
        }
    }

    @ViewBuilder
    private func libraryRow(for library: NearbyLibrary) -> some View {
        HStack(spacing: 12) {
            AsyncImage(url: library.photoURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .empty:
                    Image(systemName: "books.vertical")
                        .font(.title3)
                case .failure:
                    Image(systemName: "books.vertical")
                        .font(.title3)
                @unknown default:
                    Image(systemName: "books.vertical")
                        .font(.title3)
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(.white.opacity(0.2)))

            VStack(alignment: .leading, spacing: 2) {
                Text(library.name)
                    .font(Font(BMFont.bold(15)))
                    .lineLimit(1)
                Text(formattedDistance(from: library.distanceMeters))
                    .font(.caption)
                    .opacity(0.85)
            }

            Spacer()
        }
    }

    // MARK: - Distance Formatting

    private func formattedDistance(from meters: Double) -> String {
        let measurement = Measurement(value: meters, unit: UnitLength.meters)
        let formatter = MeasurementFormatter()
        formatter.unitOptions = [.providedUnit]
        formatter.numberFormatter.maximumFractionDigits = 1
        formatter.numberFormatter.minimumFractionDigits = 0

        if meters < 1609.34 {
            let feet = measurement.converted(to: .feet)
            formatter.unitStyle = .short
            return formatter.string(from: feet)
        } else {
            let miles = measurement.converted(to: .miles)
            formatter.unitStyle = .medium
            return formatter.string(from: miles)
        }
    }
}

#Preview {
    TodayLibrariesTileView()
        .frame(width: 340, height: 280)
        .padding()
}
