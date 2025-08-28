//
//  SignInView.swift
//  HSD
//
//  Created by Justin Lee on 8/25/25.
//

import SwiftUI

struct SignInView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var viewModel: SignInViewModel
    
    var body: some View {
        VStack {
            fields
                .padding(.horizontal)
            
            Button {
                viewModel.proceed {
                    dismiss()
                }
            } label: {
                Text(viewModel.buttonTitle)
            }
            .inputStyling()
            .disabled(viewModel.isProceedButtonDisabled)
            
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
        .onDisappear {
            viewModel.clearUsername()
        }
    }
    
    
    
    @ViewBuilder
    private var fields: some View {
        TextField("Username", text: $viewModel.usernameText)
            .inputStyling()
            .autocorrectionDisabled()
            .overlay(alignment: .trailing) {
                HStack {
                    Spacer()
                    
                    Button {
                        viewModel.clearUsername()
                    } label: {
                        Image(systemName: "x.circle.fill")
                    }
                    .padding(.trailing)
                }
                .opacity(viewModel.isUsernameEmpty ? 0 : 1)
            }
        
        SecureField("Password", text: $viewModel.passwordText)
            .inputStyling()
            .overlay(alignment: .trailing) {
                HStack {
                    Spacer()
                    
                    Button {
                        viewModel.clearPassword()
                    } label: {
                        Image(systemName: "x.circle.fill")
                    }
                    .padding(.trailing)
                }
                .opacity(viewModel.isPasswordEmpty ? 0 : 1)
            }
    }
}

//TODO: move to extensions

struct InputStyling: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.regularMaterial)
            .clipShape(.capsule)
    }
}

extension View {
    func inputStyling() -> some View {
        modifier(InputStyling())
    }
}

#Preview {
    let model = SignInModel()
    let viewModel = SignInViewModel(model: model)
    return SignInView(viewModel: viewModel)
}
