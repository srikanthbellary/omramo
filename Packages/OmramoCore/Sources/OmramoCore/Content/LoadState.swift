import Foundation

/// Explicit screen state for anything that loads. Views switch over this so
/// loading, empty, failed and loaded never bleed into each other.
public enum LoadState<Value: Sendable & Equatable>: Equatable, Sendable {
    case idle
    case loading
    case empty
    case failed(LoadFailure)
    case loaded(Value)

    public var value: Value? {
        if case .loaded(let value) = self { return value }
        return nil
    }

    public var isIdle: Bool {
        if case .idle = self { return true }
        return false
    }

    public var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    public var failure: LoadFailure? {
        if case .failed(let failure) = self { return failure }
        return nil
    }
}

/// A user presentable failure. Wrapping the message keeps `LoadState`
/// `Equatable` without forcing every error type to be.
public struct LoadFailure: Error, Equatable, Sendable {
    public var message: String
    public var isRetryable: Bool

    public init(message: String, isRetryable: Bool = true) {
        self.message = message
        self.isRetryable = isRetryable
    }

    public init(_ error: Error) {
        if let contentError = error as? ContentError {
            message = contentError.userMessage
            switch contentError {
            case .missingResource, .unreadable, .unsupportedSchema, .unknownBook:
                isRetryable = false
            default:
                isRetryable = true
            }
        } else {
            message = "Something went wrong. Please try again."
            isRetryable = true
        }
    }
}
