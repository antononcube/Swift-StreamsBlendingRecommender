//
//  Normalizers.swift
//  
//
//  Created by Anton Antonov on 7/2/22.
//

import Foundation

//========================================================
// Norm
//========================================================

public func Norm(_ mix: [String : Double], _ spec: String = "euclidean") -> Double {
    return Norm( [Double]( mix.values ), spec)
}

public func Norm(_ vec: [Double], _ spec: String = "euclidean") -> Double {
    
    switch spec {

    case let x where Set(["max-norm", "inf-norm", "inf", "infinity"]).contains(x):
        
        return (vec.map { abs($0) }).max()!

    case let x where Set(["one-norm", "one", "sum"]).contains(x):
        
        var sum: Double = 0.0
        for i in 0..<vec.count {
            sum += abs(vec[i])
        }
        return sum

    case let x where Set(["euclidean", "cosine", "two-norm", "two"]).contains(x):
        
        var sum : Double = 0.0
        for i in 0..<vec.count {
            sum += pow(vec[i], 2.0)
        }
        return sqrt(sum)
        
    default:
        
        print("Unknown norm specification '$spec'.")
        return 0
    }
}

//========================================================
// Normalize
//========================================================
public func Normalize(_ mix: [String : Double], _ spec: String = "euclidean") -> [String : Double] {
    if spec == "none" {
        return mix
    } else {
        let n: Double = Norm(mix, spec)
        
        if n == 0 { return mix }
        
        return mix.mapValues { $0 / n }
    }
}

public func Normalize(_ vec: [Double], _ spec: String = "euclidean") -> [Double] {
    if spec == "none" {
        return vec
    } else {
        let n = Norm(vec, spec)
        
        if n == 0 { return vec }
        
        return vec.map { $0 / n }
    }
}
