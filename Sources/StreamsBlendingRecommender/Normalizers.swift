//
//  File.swift
//  
//
//  Created by Anton Antonov on 7/2/22.
//

import Foundation

//========================================================
// Norm
//========================================================

public func norm(_ mix: [String : Double], _ spec: String = "euclidean") -> Double {
    return norm( [Double]( mix.values ), spec)
}

public func norm(_ vec: [Double], _ spec: String = "euclidean") -> Double {
    
    switch spec {

    case "inf-norm":
        
        return (vec.map { abs($0) }).max()!

    case "one-norm":
        
        var sum: Double = 0.0
        for i in 0..<vec.count {
            sum += abs(vec[i])
        }
        return sum

    case "euclidean":
        
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
public func normalize(_ mix: [String : Double], _ spec: String = "euclidean") -> [String : Double] {
    if spec == "none" {
        return mix
    } else {
        let n: Double = norm(mix, spec)
        
        if n == 0 { return mix }
        
        return mix.mapValues { $0 / n }
    }
}

public func normalize(_ vec: [Double], _ spec: String = "euclidean") -> [Double] {
    if spec == "none" {
        return vec
    } else {
        let n = norm(vec, spec)
        
        if n == 0 { return vec }
        
        return vec.map { $0 / n }
    }
}
