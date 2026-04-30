import Foundation

enum GenerationStatus: Equatable {
    case idle
    case generating(progress: Double, message: String)
    case completed
    case failed(String)
}
