import Foundation
import CryptoKit

enum CertificateFingerprints {
    static func describe(_ certificate: Data) -> String {
        func hex<D: Sequence>(_ digest: D) -> String where D.Element == UInt8 { digest.map { String(format: "%02X", $0) }.joined(separator: ":") }
        return "MD5: \(hex(Insecure.MD5.hash(data: certificate)))\nSHA-1: \(hex(Insecure.SHA1.hash(data: certificate)))\nSHA-256: \(hex(SHA256.hash(data: certificate)))"
    }
}
