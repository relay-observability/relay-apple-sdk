import Foundation

public enum FileWriteFailureReason: String, Sendable {
    case noCurrentFile = "No current file available"
    case fileCreationFailed = "File creation failed"
    case insufficientDiskSpace = "Insufficient disk space"
    case permissionDenied = "Permission denied"
    case ioError = "I/O error"
    case serializationError = "Serialization error"
    case unknown = "Unknown error"
    
    public init(error: Error) {
        if let writerError = error as? FileDiskWriter.Error {
            switch writerError {
            case .noCurrentFile:
                self = .noCurrentFile
                return
            case .fileCreationFailed:
                self = .fileCreationFailed
                return
            }
        }
        
        if let nsError = error as NSError?, nsError.domain == NSCocoaErrorDomain {
            if nsError.code == NSFileWriteNoPermissionError || nsError.code == NSFileReadNoPermissionError {
                self = .permissionDenied
                return
            }
            if nsError.code == NSFileWriteOutOfSpaceError {
                self = .insufficientDiskSpace
                return
            }
            if nsError.code == NSFileReadUnknownError || nsError.code == NSFileWriteUnknownError {
                self = .ioError
                return
            }
        }
        
        if error is EncodingError || error is DecodingError {
            self = .serializationError
            return
        }
        
        self = .unknown
    }
}
