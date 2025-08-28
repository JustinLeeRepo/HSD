//
//  UnauthorizedView.swift
//  HSD
//
//  Created by Justin Lee on 8/25/25.
//

import SwiftUI
import Combine

struct UnauthorizedView: View {
    var viewModel: UnauthorizedViewModel
    
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
            
            if let error = viewModel.error {
                Text(error.localizedDescription)
                    .padding()
                    .font(.caption)
                    .foregroundStyle(.pink)
                    .opacity(viewModel.error == nil ? 0 : 1)
            }
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
    let viewModel = UnauthorizedViewModel(unauthorizedEventPublisher: unauthorizedEventPublisher)
    return UnauthorizedView(viewModel: viewModel)
}
