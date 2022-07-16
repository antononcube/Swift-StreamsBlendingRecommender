//
//  AbstractSBR.swift
//  
//
//  Created by Anton Antonov on 6/30/22.
//

import Foundation

protocol AbstractSBR {
    
    //========================================================
    //Profile
    //========================================================
    func profile( items: [String],
                  normalize: Bool,
                  warn: Bool )
    -> [Dictionary<String, Double>.Element]
    
    func profile( items: [String : Double],
                  normalize: Bool,
                  warn: Bool)
    -> [Dictionary<String, Double>.Element]
    
    //========================================================
    //Recommend
    //========================================================
    func recommend( items: [String],
                    nrecs: Int,
                    normalize: Bool,
                    warn: Bool )
    -> [Dictionary<String, Double>.Element]
    
    
    func recommend( items: [String : Double],
                    nrecs: Int,
                    normalize: Bool,
                    warn: Bool )
    -> [Dictionary<String, Double>.Element]
    
    //========================================================
    //Recommend by profile
    //========================================================
    func recommendByProfile( prof: [String],
                             nrecs: Int,
                             normSpec: String,
                             warn: Bool )
    -> [Dictionary<String, Double>.Element]
    
    
    func recommendByProfile( prof: [String : Double],
                             nrecs: Int,
                             normSpec: String,
                             normalize: Bool,
                             warn: Bool)
    -> [Dictionary<String, Double>.Element]
}
