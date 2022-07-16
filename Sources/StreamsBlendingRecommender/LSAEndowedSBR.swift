//
//  File.swift
//  
//
//  Created by Anton Antonov on 7/16/22.
//

import Foundation

class LSAEndowedSBR: AbstractSBR {

    
    //========================================================
    // Recommender objects
    //========================================================
    var Core : CoreSBR
    var LSA : LSATopicSBR
    
    //========================================================
    // Initializer
    //========================================================
    init(coreObj : CoreSBR, lsaObj : LSATopicSBR) {
        self.Core = coreObj
        self.LSA = lsaObj
    }

    //========================================================
    // Protocol adherences
    //========================================================
    func profile(items: [String], normalize: Bool, warn: Bool) -> [Dictionary<String, Double>.Element] {
        return self.Core.profile(items: items, normalize: normalize, warn: warn)
    }
    
    func profile(items: [String : Double], normalize: Bool, warn: Bool) -> [Dictionary<String, Double>.Element] {
        return self.Core.profile(items: items, normalize: normalize, warn: warn)
    }
    
    func recommend(items: [String], nrecs: Int, normSpec: String, normalize: Bool, warn: Bool) -> [Dictionary<String, Double>.Element] {
        return self.Core.recommend(items: items, normalize: normalize, warn: warn)
    }
    
    func recommend(items: [String : Double], nrecs: Int, normSpec: String, normalize: Bool, warn: Bool) -> [Dictionary<String, Double>.Element] {
        return self.Core.recommend(items: items, normalize: normalize, warn: warn)
    }
        
    
    //========================================================
    // Recommend by profile delegation
    //========================================================
    /// Recommend items for a consumption profile (that is a list or a mix of tags.)
    /// - Parameters:
    ///    - prof: A list or a mix of tags.
    ///    - nrecs: Number of recommendations.
    ///    - normalize: Should the recommendation scores be normalized or not?
    ///    - warn: Should warnings be issued or not?
    public func recommendByProfile( prof: [String],
                                    nrecs: Int = 10,
                                    normSpec: String,
                                    normalize: Bool = true,
                                    warn: Bool = true )
    -> [Dictionary<String, Double>.Element] {
        return self.Core.recommendByProfile(prof: prof,
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
                                    normSpec: String,
                                    normalize: Bool = true,
                                    warn: Bool = true )
    -> [Dictionary<String, Double>.Element] {
        return self.Core.recommendByProfile(prof: prof, nrecs: nrecs, normSpec: normSpec, normalize: normalize, warn: warn)
    }
    
    
    //========================================================
    // Recommend by profile and text
    //========================================================
    /// Recommend items for a consumption profile (that is a list or a mix of tags.)
    /// - Parameters:
    ///    - prof: A list or a mix of tags.
    ///    - nrecs: Number of recommendations.
    ///    - normalize: Should the recommendation scores be normalized or not?
    ///    - warn: Should warnings be issued or not?
    public func recommendByProfile( prof: [String],
                                    text: String,
                                    nrecs: Int = 10,
                                    normSpec: String = "euclidean",
                                    normalize: Bool = true,
                                    warn: Bool = true )
    -> [Dictionary<String, Double>.Element] {
        let profd =  Dictionary(uniqueKeysWithValues: zip(prof, [Double](repeating: 1.0, count: prof.count)))
        return recommendByProfile(prof: profd,
                                  text: text,
                                  nrecs: nrecs,
                                  normSpec: normSpec,
                                  normalize: normalize,
                                  warn: warn)
    }
    
    /// Recommend items for a consumption profile (that is a list or a mix of tags.)
    /// - Parameters:
    ///    - prof: A list or a mix of tags.
    ///    - text: Text to make recommendations with.
    ///    - nrecs: Number of recommendations.
    ///    - normalize: Should the recommendation scores be normalized or not?
    ///    - warn: Should warnings be issued or not?
    /// - Returns: An array of dictionary elements (items) sorted in descending order.
    public func recommendByProfile( prof: [String : Double],
                                    text: String,
                                    nrecs: Int = 10,
                                    normSpec: String = "euclidean",
                                    normalize: Bool = true,
                                    warn: Bool = true )
    -> [Dictionary<String, Double>.Element] {
        return []
    }
    
}
