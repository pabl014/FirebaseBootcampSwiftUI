//
//  RootView.swift
//  FirebaseBootcampSwiftUI
//
//  Created by Paweł Rudnik on 05/05/2024.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationStack {
            AuthenticationView()
        }
    }
}

#Preview {
    RootView()
}
