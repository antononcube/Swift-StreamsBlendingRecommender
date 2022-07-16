//
//  File.swift
//  
//
//  Created by Anton Antonov on 7/16/22.
//

import Foundation

class CompositeSBR: AbstractSBR {
    
    
    //========================================================
    // Attributes
    //========================================================
    var objects: [String : AbstractSBR] = [:]
    
    var weights: [String : Double] = [:]
    
    //========================================================
    // Fill in weights
    //========================================================
    public func fillInWeights() {
        // This is not needed since we can do the call:
        // self.weights[k, default: 1.0]
        
        // Make sure all recommender objects have weights
        for (k, _) in self.objects {
            if self.weights[k] == nil { self.weights[k] = 1 }
        }
    }
    
    //========================================================
    // Profile
    //========================================================
    public func profile( items: [String],
                         normalize: Bool,
                         warn: Bool )
    -> [Dictionary<String, Double>.Element] {
        let itemsd = Dictionary(uniqueKeysWithValues: zip(items, [Double](repeating: 1.0, count: items.count)))
        return profile(items: itemsd, normalize: normalize, warn: warn)
    }
    
    public func profile( items: [String : Double],
                         normalize: Bool,
                         warn: Bool)
    -> [Dictionary<String, Double>.Element] {
        // For each SBR object find profile and
        // merge those profiles
        
        var resMix : [String : Double] = [:]
        
        for (k, sbr) in self.objects {
            // SBR-leaf profile
            let prof = Dictionary(uniqueKeysWithValues: sbr.profile(items: items, normalize: normalize, warn: warn))
            // Merge into grand-profile
            resMix.merge(prof.mapValues({ $0 * self.weights[k, default: 1.0] }), uniquingKeysWith: { $0 + $1 })
        }
        
        // Convert to list of pairs and reverse sort
        let res = resMix.sorted(by: { (e1, e2) in e1.value > e2.value })
        
        return res
    }
    
    //========================================================
    // Recommend by history
    //========================================================
    // This repeated code of CoreSBR. It can be in an abstract class
    // but I prefer CoreSBR to be more self-contained.
    /// Recommend items for a consumption history.
    ///  - Parameters:
    ///    - items: A  list of items or an item-to-weight dictionary.
    ///    - nrecs: Number of recommendations.
    ///    - normalize: Should the recommendation scores be normalized or not?
    ///    - warn: Should warnings be issued or not?
    /// - Returns: An array of dictionary elements (items) sorted in descending order.
    public func recommend( items: [String],
                           nrecs: Int = 10,
                           normSpec: String = "max-norm",
                           normalize: Bool = true,
                           warn: Bool = true )
    -> [Dictionary<String, Double>.Element] {
        let itemsd =  Dictionary(uniqueKeysWithValues: zip(items, [Double](repeating: 1.0, count: items.count)))
        return recommend(items: itemsd,
                         nrecs: nrecs,
                         normSpec: normSpec,
                         normalize: normalize,
                         warn: warn)
    }
    
    
    public func recommend( items: [String : Double],
                           nrecs: Int = 10,
                           normSpec: String = "max-norm",
                           normalize: Bool = true,
                           warn: Bool = true )
    -> [Dictionary<String, Double>.Element] {
        
        // It is not fast, but it is just easy to compute the profile and call recommendByProfile.
        let res = profile(items: items, normalize: normalize, warn: warn)
        
        return recommendByProfile(prof: Dictionary(uniqueKeysWithValues: res),
                                  nrecs: nrecs,
                                  normSpec: normSpec,
                                  normalize: normalize,
                                  warn: warn)
    }
    
    //========================================================
    // Recommend by profile
    //========================================================
    /// Recommend items for a consumption profile (that is a list or a mix of tags.)
    /// - Parameters:
    ///    - prof: A list or a mix of tags.
    ///    - nrecs: Number of recommendations.
    ///    - normalize: Should the recommendation scores be normalized or not?
    ///    - warn: Should warnings be issued or not?
    public func recommendByProfile( prof: [String],
                                    nrecs: Int = 10,
                                    normSpec: String = "none",
                                    normalize: Bool = true,
                                    warn: Bool = true )
    -> [Dictionary<String, Double>.Element] {
        let profd =  Dictionary(uniqueKeysWithValues: zip(prof, [Double](repeating: 1.0, count: prof.count)))
        return recommendByProfile(prof: profd,
                                  nrecs: nrecs,
                                  normSpec: normSpec,
                                  normalize: normalize,
                                  warn: warn)
    }
    
    /// Recommend items for a consumption profile (that is a list or a mix of tags.)
    /// - Parameters:
    ///    - prof: A list or a mix of tags.
    ///    - nrecs: Number of recommendations.
    ///    - normalize: Should the recommendation scores be normalized or not?
    ///    - warn: Should warnings be issued or not?
    /// - Returns: An array of dictionary elements (items) sorted in descending order.
    public func recommendByProfile( prof: [String : Double],
                                    nrecs: Int = 10,
                                    normSpec: String = "none",
                                    normalize: Bool = true,
                                    warn: Bool = true )
    -> [Dictionary<String, Double>.Element] {
        
        
        // Weights fill-in. Not needed!
        //fillInWeights()
        
        // Get recommendations from each object
        var recs : [String : [String : Double]] = [:]
        recs = self.objects.mapValues({
            Dictionary(uniqueKeysWithValues: $0.recommendByProfile(prof: prof,
                                                                   nrecs: nrecs,
                                                                   normSpec: normSpec,
                                                                   normalize: false,
                                                                   warn: false))
        })
        
        // Normalize each result by norm spec
        if normSpec.lowercased() != "none" {
            recs = recs.mapValues({ Normalize($0, normSpec) })
        }
        
        // Merge the recommendations
        var resMix : [String : Double] = [:]
        
        for (k, v) in recs {
            resMix.merge(v.mapValues({ $0 * self.weights[k, default: 1.0] }), uniquingKeysWith: { $0 + $1 })
        }
        
        // Normalize
        if normalize {
            resMix = Normalize(resMix, "max-norm")
        }
        
        // Convert to list of pairs and reverse sort
        let res = resMix.sorted(by: { (e1, e2) in e1.value > e2.value })
        
        // Result
        return res
        
    }
    
}
