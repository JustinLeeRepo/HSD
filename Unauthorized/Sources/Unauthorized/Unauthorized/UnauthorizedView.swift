//
//  UnauthorizedView.swift
//  HSD
//
//  Created by Justin Lee on 8/25/25.
//

import Combine
import NetworkService
import SharedUI
import SwiftUI

struct UnauthorizedView: View {
    @Bindable var viewModel: UnauthorizedViewModel
    
    var body: some View {
        VStack {
            Button {
                viewModel.proceedToSignIn()
            } label: {
                Label("Sign in", systemImage: "at")
                
            }
            .inputStyling()
            
            Button {
                Task {
                    await viewModel.expressSignIn()
                }
            } label: {
                Label("Guest", systemImage: "person.slash")
            }
            .inputStyling()
            
            ErrorView(viewModel: viewModel.errorViewModel)
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
    }
}

#Preview {
    let unauthorizedEventPublisher = PassthroughSubject<UnauthorizedEvent, Never>()
    let viewModel = UnauthorizedViewModel(unauthorizedEventPublisher: unauthorizedEventPublisher, authService: AuthService())
    return UnauthorizedView(viewModel: viewModel)
}
