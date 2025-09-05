//
//  TransitView.swift
//  TransLinkdle
//
//  Created by Kobe Shen on 2025-08-26.
//

import SwiftUI

struct TransitView: View {
    var body: some View {
        Image(systemName: "arrow.up")
            .font(.system(size: 25, weight: .bold))
        Image(systemName: "arrow.down")
        Image(systemName: "checkmark")
        Image(systemName: "arrow.up.circle.fill")
        Image(systemName: "arrow.down.circle.fill")
        Image(systemName: "checkmark.circle.fill")
        if let img = UIImage(named: "Bus") {
            Image(uiImage: img)
                .resizable()
                .frame(width: 100, height: 100)
        } else {
            Text("Image not found")
        }
    }
}

#Preview {
    TransitView()
}
