//
//  SignOutView.swift
//
//
//  Created by Justin Lee on 9/23/25.
//

import DependencyContainer
import NetworkService
import SharedUI
import SwiftUI

struct SignOutView: View {
    
    var viewModel: SignOutViewModel
    
    var body: some View {
        VStack {
            Button {
                Task {
                    await viewModel.signOut()
                }
            } label: {
                Text("sign out")
            }
            
            ErrorView(viewModel: viewModel.errorViewModel)
        }
    }
}

#Preview {
    let mockService = MockAuthService()
    let viewModel = SignOutViewModel(authService: mockService)
    return SignOutView(viewModel: viewModel)
}
