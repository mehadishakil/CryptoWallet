// RLP.swift
//
//import Foundation
//import BigInt
//
//func rlpEncode(_ input: Any) -> Data {
//    if let s = input as? String {
//        return rlpEncode(Data(hex: s.stripHexPrefix()))
//    } else if let d = input as? Data {
//        return rlpEncodeData(d)
//    } else if let i = input as? BigUInt {
//        return rlpEncodeData(i.serialize())
//    } else if let arr = input as? [Any] {
//        return rlpEncodeList(arr)
//    }
//    return Data()
//}
//
//private func rlpEncodeData(_ data: Data) -> Data {
//    if data.count == 1 && data[0] < 0x80 {
//        return data
//    } else if data.count < 56 {
//        return Data([0x80 + UInt8(data.count)]) + data
//    } else {
//        let lenB = lengthPrefix(for: data.count)
//        return Data([0xb7 + UInt8(lenB.count)]) + lenB + data
//    }
//}
//
//private func rlpEncodeList(_ list: [Any]) -> Data {
//    let enc = list.reduce(Data()) { $0 + rlpEncode($1) }
//    if enc.count < 56 {
//        return Data([0xc0 + UInt8(enc.count)]) + enc
//    } else {
//        let lenB = lengthPrefix(for: enc.count)
//        return Data([0xf7 + UInt8(lenB.count)]) + lenB + enc
//    }
//}
//
//private func lengthPrefix(for length: Int) -> Data {
//    var len = length, bytes = [UInt8]()
//    while len > 0 {
//        bytes.insert(UInt8(len & 0xff), at: 0)
//        len >>= 8
//    }
//    return Data(bytes)
//}

// RLP.swift

import Foundation
import BigInt

func rlpEncode(_ input: Any) -> Data {
    if let s = input as? String {
        return rlpEncode(Data(hex: s.stripHexPrefix()))
    } else if let d = input as? Data {
        return rlpEncodeData(d)
    } else if let i = input as? BigUInt {
        // Handle BigUInt properly
        if i == 0 {
            return rlpEncodeData(Data())
        } else {
            return rlpEncodeData(i.serialize())
        }
    } else if let i = input as? Int {
        return rlpEncode(BigUInt(i))
    } else if let i = input as? UInt {
        return rlpEncode(BigUInt(i))
    } else if let arr = input as? [Any] {
        return rlpEncodeList(arr)
    }
    return Data()
}

private func rlpEncodeData(_ data: Data) -> Data {
    if data.isEmpty {
        return Data([0x80])
    } else if data.count == 1 && data[0] < 0x80 {
        return data
    } else if data.count < 56 {
        return Data([0x80 + UInt8(data.count)]) + data
    } else {
        let lenB = lengthPrefix(for: data.count)
        return Data([0xb7 + UInt8(lenB.count)]) + lenB + data
    }
}

private func rlpEncodeList(_ list: [Any]) -> Data {
    let enc = list.reduce(Data()) { $0 + rlpEncode($1) }
    if enc.count < 56 {
        return Data([0xc0 + UInt8(enc.count)]) + enc
    } else {
        let lenB = lengthPrefix(for: enc.count)
        return Data([0xf7 + UInt8(lenB.count)]) + lenB + enc
    }
}

private func lengthPrefix(for length: Int) -> Data {
    var len = length
    var bytes = [UInt8]()
    
    if len == 0 {
        return Data([0])
    }
    
    while len > 0 {
        bytes.insert(UInt8(len & 0xff), at: 0)
        len >>= 8
    }
    return Data(bytes)
}
