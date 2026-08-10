//
//  ResourcesView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 2/5/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

import FactoryKit
import SwiftUI

struct ResourcesView: View {
    @InjectedObject(\.resourcesViewModel) private var resourcesViewModel

    @State private var tabSelectedValue = 0
    
    init() {
        // Use this if NavigationBarTitle is with Large Font
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : BMFont.bold(30)]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                BMTopBlobView(imageName: "BlobRight", xOffset: 30, width: 150, height: 150)
        
                VStack {
                    if resourcesViewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .controlSize(.large)
                    } else if resourcesViewModel.resourceCategories.isEmpty {
                        noResourcesAvailableView
                    } else {
                        BMSegmentedControlView(
                            tabNames: resourcesViewModel.resourceCategoryNames,
                            selectedTabIndex: $tabSelectedValue
                        )
                        .padding()
                        
                        TabView(selection: $tabSelectedValue) {
                            ForEach(Array(resourcesViewModel.resourceCategories.enumerated()), id: \.offset) { idx, category in
                                ResourcePageView(resourceSections: category.sections).tag(idx)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                    }
                    Spacer()
                }
                .navigationTitle("Resources")
            }
            .background(Color(BMColor.cardBackground))
            .presentAlert(alert: $resourcesViewModel.alert)
        }
    }
    
    private var noResourcesAvailableView: some View {
        BMContentUnavailableView(
                iconName: "exclamationmark.triangle",
                title: "No Resources Available",
                subtitle: "Try again later."
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .offset(y: -45)
    }
}


// MARK: - ResourcePageView

struct ResourcePageView: View {
    var resourceSections: [BMResourceSection]

    // Light, soft background colors so dark text stays readable on every cell.
    private static let gridColorPalette: [Color] = [
        Color(red: 0.85, green: 0.93, blue: 0.97),   // Light blue
        Color(red: 0.93, green: 0.88, blue: 0.78),   // Light beige
        Color(red: 0.86, green: 0.94, blue: 0.86),   // Light green
        Color(red: 0.95, green: 0.88, blue: 0.90),   // Light pink
        Color(red: 0.94, green: 0.94, blue: 0.78),   // Light yellow
        Color(red: 0.90, green: 0.90, blue: 0.96),   // Light lavender
        Color(red: 0.95, green: 0.90, blue: 0.82),   // Light peach
        Color(red: 0.82, green: 0.94, blue: 0.94)    // Light cyan
    ]

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private func color(for section: BMResourceSection) -> Color {
        // Deterministic but effectively "random" per title so each section gets a stable color.
        let titleHash = (section.title ?? "").hashValue
        let index = abs(titleHash) % Self.gridColorPalette.count
        return Self.gridColorPalette[index]
    }

    var body: some View {
        Group {
            if resourceSections.isEmpty {
                Text("No Content Available")
                    .bold()
                    .font(Font(BMFont.regular(30)))
                    .foregroundStyle(.secondary)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(resourceSections, id: \.self) { resourceSection in
                            ResourcesSectionGridCell(
                                title: resourceSection.title ?? "Untitled",
                                resources: resourceSection.resources,
                                backgroundColor: color(for: resourceSection)
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                }
                .background(Color(BMColor.cardBackground))
            }
        }
    }
}

// MARK: - ResourcesSectionGridCell

struct ResourcesSectionGridCell: View {
    let title: String
    let resources: [BMResource]
    let backgroundColor: Color

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(title)
                        .font(Font(BMFont.bold(18)))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(.gray)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(16)
            }

            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(resources, id: \.id) { resource in
                        ResourceItemView(resource: resource)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 10)
            }
        }
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }
}

#Preview {
    ResourcesView()
}
