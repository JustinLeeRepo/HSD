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
    }
}

#Preview {
    let unauthorizedEventPublisher = PassthroughSubject<UnauthorizedEvent, Never>()
    let viewModel = UnauthorizedViewModel(unauthorizedEventPublisher: unauthorizedEventPublisher)
    return UnauthorizedView(viewModel: viewModel)
}
