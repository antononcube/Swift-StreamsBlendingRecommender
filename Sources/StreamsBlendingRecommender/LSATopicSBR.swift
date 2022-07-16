//
//  File.swift
//  
//
//  Created by Anton Antonov on 7/15/22.
//

import Foundation
import SwiftCSV

class LSATopicSBR: CoreSBR {
    
    //========================================================
    // Data members
    //========================================================
    var lsaGlobalWeights: [String: Double] = [:]
    var stemRules: [String: String] = [:]
    
    
    
    //========================================================
    // Ingest a LSA matrix CSV file
    //========================================================
    /// Ingest LSA matrix CSV file.
    /// - Parameters:
    ///    - fileName: CSV file name.
    ///    - topicColumnName: The items column name.
    ///    - wordColumnName: The words column name.
    ///    - weightColumnName: The weights column name.
    ///    - make: Should the inverse indexes be made or not?
    ///    - sep: Separator of CSV fields.
    public func ingestLSAMatrixCSVFile(fileName: String,
                                       topicColumnName: String = "Topic",
                                       wordColumnName: String = "Word",
                                       weightColumnName: String = "Weight",
                                       make: Bool = false,
                                       sep: Character = ",") -> Bool {
        
        let res = IngestCSVFile(fileName : fileName,
                                mapper : ["Topic" : topicColumnName,
                                          "Word" : wordColumnName,
                                          "Weight" : weightColumnName],
                                sep :sep);
        
        if res.isEmpty { return false }
        
        for row in res {
            self.SMRMatrix.insert( [ "Item" : row[topicColumnName]!,
                                     "TagType" : "Word",
                                     "Value" : row[wordColumnName]!,
                                     "Weight" : row[weightColumnName]!],
                                   at: 0 )
        }
        
        self.itemInverseIndexes = [:]
        self.tagInverseIndexes = [:]
        
        if make {
            return self.makeTagInverseIndexes()
        }
        
        return true;
    }
    
    //========================================================
    // Ingest terms global weights
    //========================================================
    /// Global weights CSV file ingestion.
    /// - Parameters:
    ///    - fileName: CSV file name.
    ///    - wordColumnName: The words column name.
    ///    - weightColumnName: The weights column name.
    ///    - sep: Separator of CSV fields.
    public func ingestGlobalWeightsCSVFile(fileName: String,
                                           wordColumnName: String = "Word",
                                           weightColumnName: String = "Weight",
                                           make: Bool = false,
                                           sep: Character = ",") -> Bool {
        
        do {
            
            
            let csvFile: CSV = try CSV<Named>(url: URL(fileURLWithPath: fileName),
                                              delimiter: CSVDelimiter.character(sep),
                                              loadColumns: false)
            
            let rowsOrig: [[String : String]] = csvFile.rows
            
            let expectedColumnNames : Set<String> = Set([wordColumnName, weightColumnName])
            
            //Check that the file had expected column names
            if expectedColumnNames.intersection(rowsOrig[0].keys).count < expectedColumnNames.count {
                print("The ingested global weights CSV file does not have the expected column names: \(expectedColumnNames).")
                return false
            }
            
            for row in rowsOrig {
                self.globalWeights[row[wordColumnName]!] = Double(row[weightColumnName]!)
            }
            
            return true;
            
        } catch {
            // Catch errors from trying to load files
            print("Could not load or parse the file.")
            return false
        }
    }
    
    //========================================================
    // Ingest stemming rules
    //========================================================
    /// Global weights CSV file ingestion.
    /// - Parameters:
    ///    - fileName: CSV file name.
    ///    - wordColumnName: The words column name.
    ///    - weightColumnName: The weights column name.
    ///    - sep: Separator of CSV fields.
    public func ingestStemRulesCSVFile(fileName: String,
                                       wordColumnName: String = "Word",
                                       stemColumnName: String = "Stem",
                                       sep: Character = ",") -> Bool {
        
        do {
            
            
            let csvFile: CSV = try CSV<Named>(url: URL(fileURLWithPath: fileName),
                                              delimiter: CSVDelimiter.character(sep),
                                              loadColumns: false)
            
            let rowsOrig: [[String : String]] = csvFile.rows
            
            let expectedColumnNames : Set<String> = Set([wordColumnName, stemColumnName])
            
            //Check that the file had expected column names
            if expectedColumnNames.intersection(rowsOrig[0].keys).count < expectedColumnNames.count {
                print("The ingested stem rules CSV file does not have the expected column names: \(expectedColumnNames).")
                return false
            }
            
            for row in rowsOrig {
                self.stemRules[row[wordColumnName]!] = row[stemColumnName]!
            }
            
            return true;
            
        } catch {
            // Catch errors from trying to load files
            print("Could not load or parse the file.")
            return false
        }
    }
    
    
    //========================================================
    // Represent by terms
    //========================================================
    /// Represent text by terms.
    /// - Parameters:
    ///    - text: Text.
    ///    - sep: Text splitting argument of split: a string, a regex, or a list of strings or regexes.
    /// - Returns: A dictionary of weighted )terms.
    public func representByTerms(_ text: String, sep: Character = " ") -> [String : Double] {
        
        //Split into words
        let words = text.split(separator: sep).map({ $0.lowercased() })
        
        //Stem words
        let terms = words.map({ self.stemRules[$0] != nil ? self.stemRules[$0] : $0 })
        
        //Bag of words
        var bag : [String : Double] = terms.reduce(into: [:]) { b, t in b[t!, default: 0] += 1 }
        
        //Apply global weight
        for (t, w) in bag {
            bag[t] = w * self.lsaGlobalWeights[t, default: 1]
        }
        
        // Normalize
        bag = Normalize(bag)
        
        return bag
    }
    
    //========================================================
    // Represent by topics
    //========================================================
    /// Represent a text query by topics.
    /// - Parameters:
    ///    - text: Text.
    ///    - sep: Text splitting argument of split: a string, a regex, or a list of strings or regexes.
    ///    - normalize: Should the recommendation scores be normalized or not?
    ///    - warn: Should warnings be issued or not?
    /// - Returns: A dictionary of weighted topics.
    public func representByTopics(_ text: String,
                                  _ nrecs: Int = 12,
                                  sep: Character = " ",
                                  normalize: Bool = true,
                                  warn : Bool = true ) -> [String : Double] {
        
        //Get representation by terms
        let bag = self.representByTerms(text, sep: sep)
        
        //Recommend by profile
        var res = Dictionary(uniqueKeysWithValues: self.recommendByProfile(prof: bag, nrecs: nrecs, normalize: normalize, warn: warn))
        
        //Normalize
        if normalize {
            res = Normalize(res, "max-norm")
        } else {
            res = Normalize(res, "euclidean")
        }
        
        // Result
        return res
    }
    
    //========================================================
    // Recommend by free text
    //========================================================
    /// Recommend topics for a text query.
    /// - Parameters:
    ///    - text: Text.
    ///    - sep: Text splitting argument of split: a string, a regex, or a list of strings or regexes.
    ///    - normalize: Should the recommendation scores be normalized or not?
    ///    - warn: Should warnings be issued or not?
    /// - Returns: A dictionary of weighted topics.
    public func recommendByText(_ text: String,
                                _ nrecs: Int = 12,
                                sep: Character = " ",
                                normalize: Bool = true,
                                warn : Bool = true ) -> [String : Double] {
        
        let res = self.representByTopics(text, nrecs, sep: sep, normalize: normalize, warn: warn)
        
        return res.filter({ $0.value > 0 })
    }
}
