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
    var profileNormSpec : String = "euclidean"
    
    //========================================================
    // Initializers
    //========================================================
    init(coreObj: CoreSBR, lsaObj: LSATopicSBR) {
        self.Core = coreObj
        self.LSA = lsaObj
        self.profileNormSpec = "euclidean"
    }
    
    init(coreObj: CoreSBR, lsaObj: LSATopicSBR, profileNormSpec: String) {
        self.Core = coreObj
        self.LSA = lsaObj
        self.profileNormSpec = profileNormSpec
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
    
    func recommend(items: [String], nrecs: Int, normSpec: String, warn: Bool) -> [Dictionary<String, Double>.Element] {
        return self.Core.recommend(items: items, normSpec: normSpec, warn: warn)
    }
    
    func recommend(items: [String : Double], nrecs: Int, normSpec: String, warn: Bool) -> [Dictionary<String, Double>.Element] {
        return self.Core.recommend(items: items, normSpec: normSpec, warn: warn)
    }
    
    
    //========================================================
    // Recommend by profile delegation
    //========================================================
    /// Recommend items for a consumption profile (that is a list or a mix of tags.)
    /// - Parameters:
    ///    - prof: A list or a mix of tags.
    ///    - nrecs: Number of recommendations.
    ///    - normSpec: Norm specification; one of ["none", "inf-norm", "one-norm", "euclidean"]
    ///    - warn: Should warnings be issued or not?
    public func recommendByProfile( prof: [String],
                                    nrecs: Int = 10,
                                    normSpec: String,
                                    warn: Bool = true )
    -> [Dictionary<String, Double>.Element] {
        return self.Core.recommendByProfile(prof: prof,
                                            nrecs: nrecs,
                                            normSpec: normSpec,
                                            warn: warn)
    }
    
    /// Recommend items for a consumption profile (that is a list or a mix of tags.)
    /// - Parameters:
    ///    - prof: A list or a mix of tags.
    ///    - nrecs: Number of recommendations.
    ///    - normSpec: Norm specification; one of ["none", "inf-norm", "one-norm", "euclidean"]
    ///    - warn: Should warnings be issued or not?
    /// - Returns: An array of dictionary elements (items) sorted in descending order.
    public func recommendByProfile( prof: [String : Double],
                                    nrecs: Int = 10,
                                    normSpec: String,
                                    warn: Bool = true )
    -> [Dictionary<String, Double>.Element] {
        return self.Core.recommendByProfile(prof: prof, nrecs: nrecs, normSpec: normSpec, warn: warn)
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
                                    normSpec: String = "max-norm",
                                    normalize: Bool = true,
                                    warn: Bool = true )
    -> [Dictionary<String, Double>.Element] {
        let profd = Dictionary(uniqueKeysWithValues: zip(prof, [Double](repeating: 1.0, count: prof.count)))
        return recommendByProfile(prof: profd,
                                  text: text,
                                  nrecs: nrecs,
                                  normSpec: normSpec,
                                  warn: warn)
    }
    
    /// Recommend items for a consumption profile (that is a list or a mix of tags.)
    /// - Parameters:
    ///    - prof: A list or a mix of tags.
    ///    - text: Text to make recommendations with.
    ///    - nrecs: Number of recommendations.
    ///    - normSpec: Norm specification; one of ["none", "inf-norm", "one-norm", "euclidean"]
    ///    - warn: Should warnings be issued or not?
    /// - Returns: An array of dictionary elements (items) sorted in descending order.
    public func recommendByProfile( prof: [String : Double],
                                    text: String,
                                    nrecs: Int = 10,
                                    normSpec: String = "max-norm",
                                    warn: Bool = true )
    -> [Dictionary<String, Double>.Element] {
        
        // Check
        if prof.count == 0 && text.count == 0 {
            print("Empty profile and text.")
            return []
        }
        
        // Make profile corresponding to the text
        var textProf : [String : Double] = [:]

        if text.count > 0 {
            
            // Represent by terms
            var textWordsProf : [String : Double ] = self.LSA.representByTerms(text)
            
            // Represent by topics
            var textTopicsProf : [String : Double ] = self.LSA.representByTerms(text)

            // Appropriate verifications have to be made for concatenating with 'Word:' and 'Topic:'.
            textWordsProf = Dictionary(uniqueKeysWithValues: zip(textWordsProf.keys.map({ "Word:" + $0 }), textWordsProf.values))
            textTopicsProf = Dictionary(uniqueKeysWithValues: zip(textTopicsProf.keys.map({ "Topic:" + $0 }), textTopicsProf.values))

            // Normalize each profile
            textWordsProf = Normalize(textWordsProf, self.profileNormSpec)
            textTopicsProf = Normalize(textTopicsProf, self.profileNormSpec)
            
            
            // Make the words-and-topics profile
            textProf = textWordsProf.merging(textTopicsProf, uniquingKeysWith: { (_, new) in new })
        }
        
        // Make the combined profile.
        // Note, the additional normalization arguments have to be surfaced to the signature.
        let profCombined: [String : Double] =
        Normalize( prof.count > 0 ? prof.merging(textProf, uniquingKeysWith: {(_, new) in new}) : textProf,
                   self.profileNormSpec)
        
        // Get recommendations
        return self.Core.recommendByProfile(prof: profCombined, nrecs: nrecs, normSpec: normSpec, warn: warn)
    }
    
}
