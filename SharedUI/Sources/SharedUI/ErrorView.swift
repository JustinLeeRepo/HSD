//
//  ErrorView.swift
//  
//
//  Created by Justin Lee on 9/23/25.
//

import SwiftUI

@Observable
public class ErrorViewModel {
    public var error: Error?
    
    public init(error: Error? = nil) {
        self.error = error
    }
}

public struct ErrorView: View {
    var viewModel: ErrorViewModel
    
    public init(viewModel: ErrorViewModel) {
        self.viewModel = viewModel
    }
        
    public var body: some View {
        Text(viewModel.error?.localizedDescription ?? "")
            .padding()
            .font(.caption)
            .foregroundStyle(.pink)
            .opacity(viewModel.error == nil ? 0 : 1)
    }
}

public enum SampleError: Error {
    case errorRequired
}

#Preview {
    var error = SampleError.errorRequired
    let viewModel = ErrorViewModel(error: error)
    return ErrorView(viewModel: viewModel)
}

#Preview("No Error") {
    var error: Error? = nil
    let viewModel = ErrorViewModel(error: error)
    return ErrorView(viewModel: viewModel)
}
