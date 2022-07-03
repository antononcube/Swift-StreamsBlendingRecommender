//
//  CoreSBR.swift
//
//
//  Created by Anton Antonov on 7/1/22.
//
public class CoreSBR {
    
    //========================================================
    // Data members
    //========================================================
    var SMRMatrix: [[String: String]] = [[String: String]]()
    var itemInverseIndexes: [String : [String : Double]] = [String : [String : Double]]()
    var tagInverseIndexes: [String : [String : Double]] = [String : [String : Double]]()
    var tagTypeToTags: [String : Set<String> ] = [String : Set<String> ]();
    var globalWeights: [String: Double] = [:]
    var knownTags: Set<String> = Set<String>()
    var knownItems: Set<String> = Set<String>()
    
    //========================================================
    /// Initialization
    public init() {
        
    }
    
    //========================================================
    // Setters ?
    //========================================================
    
    //========================================================
    /// Ingest SMR matrix CSV file.
    /// - Parameters:
    ///    - fileName: CSV file name.
    ///    - itemColumnName: The items column name.
    ///    - tagTypeColumnName: The tag types column name.
    ///    - valueColumnName: The values (tags) column name.
    ///    - weightColumnName: The weights column name.
    ///    - make: Should the inverse indexes be made or not?
    ///    - sep: Separator of CSV fields.
    public func ingestSMRMatrixCSVFile(fileName: String,
                                       itemColumnName: String = "Item",
                                       tagTypeColumnName: String = "TagType",
                                       valueColumnName: String = "Value",
                                       weightColumnName: String = "Weight",
                                       make: Bool = false,
                                       sep: Character = ",") -> Bool {
        
        let res = IngestCSVFile(fileName : fileName,
                                mapper : ["Item" : itemColumnName,
                                          "TagType" : tagTypeColumnName,
                                          "Value" : valueColumnName,
                                          "Weight" : weightColumnName],
                                sep :sep);
        
        if res.isEmpty { return false }
        
        self.SMRMatrix = res
        
        self.itemInverseIndexes = [:]
        self.tagInverseIndexes = [:]
        
        if make {    
            return self.makeTagInverseIndexes()
        }
        
        return true;
    }
    
    //========================================================
    /// Make the inverse indexes that correspond to the SMR matrix.
    public func makeTagInverseIndexes() -> Bool {
        
        // Split into a hash by tag type.
        let inverseIndexGroups = Dictionary(grouping: self.SMRMatrix, by: { r in r["TagType"]! })

        // For each tag type split into hash by Value.
        var inverseIndexesPerTagType: Dictionary<String, Dictionary<String, Array<[String : String]>>>
        inverseIndexesPerTagType = inverseIndexGroups.mapValues { it0 in Dictionary(grouping: it0, by: { $0["Value"]! }) }

        // Re-make each array of hashes into a hash.
        // println( inverseIndexesPerTagType.mapValues{ typeRec -> typeRec.value.mapValues{ it.value.size } } )


        var inverseIndexesPerTagType2: Dictionary<String, Dictionary<String, Dictionary<String, Double>>>
        inverseIndexesPerTagType2 = inverseIndexesPerTagType.mapValues { typeRec in
            typeRec.mapValues { tagRec in
                tagRec.associateBy(
                    { $0["Item"]! },
                    { Double($0["Weight"]!)! })
            }
        }

        // Derive the tag type to tags hash map.
        self.tagTypeToTags = inverseIndexesPerTagType2.mapValues { it in Set(it.keys) }

        
        // Flatten the inverse index groups.
        self.tagInverseIndexes = [String: [String : Double]]();
        for (_, v) in inverseIndexesPerTagType2 {
            self.tagInverseIndexes.merge(v) { (_, new) in new }
        }
        
        // Assign known tags.
        self.knownTags = Set(self.tagInverseIndexes.keys);

        // We make sure item inverse indexes are empty.
        self.itemInverseIndexes = [String: [String : Double]]();
        
        return false
    }
    
    //========================================================
    /**
     * Transpose the tag inverse indexes into item inverse indexes.
     * This operation corresponds to changing the representation of sparse matrix
     * from column major to row major format.
     */
    public func transposeTagInverseIndexes() -> Bool {

        // Transpose tag inverse indexes into item inverse indexes.

        var items: Set<String> = Set<String>()
        for (_, v) in tagInverseIndexes {
            for (i, _) in v { items.insert(i) }
        }
        
        self.itemInverseIndexes = [String: [String : Double]]();

        for i in items { self.itemInverseIndexes[i] = [:] }
        for (t, dt) in tagInverseIndexes {
            for (i, w) in dt {
                self.itemInverseIndexes[i]!.merge([t : w]) { (current, _) in current }
            }
        }

        // Assign known items.
        self.knownItems = Set(self.itemInverseIndexes.keys);

        return true;
    }
    
    //========================================================
    /// Recommend items for a consumption profile (that is a list or a mix of tags.)
    /// - Parameters:
    ///    - prof: A list or a mix of tags.
    ///    - nrecs: Number of recommendations.
    ///    - normalize: Should the recommendation scores be normalized or not?
    ///    - warn: Should warnings be issued or not?
    public func recommendByProfile( prof: [String],
                                    nrecs: Int = 10,
                                    normalize: Bool = true,
                                    warn: Bool = true )
    -> [Dictionary<String, Double>.Element] {
        let profd =  Dictionary(uniqueKeysWithValues: zip(prof, [Double](repeating: 1.0, count: prof.count)))
        return recommendByProfile(prof: profd, nrecs: nrecs, normalize: normalize, warn: warn)
    }
     
    /// Recommend items for a consumption profile (that is a list or a mix of tags.)
    /// - Parameters:
    ///    - prof: A list or a mix of tags.
    ///    - nrecs: Number of recommendations.
    ///    - normalize: Should the recommendation scores be normalized or not?
    ///    - warn: Should warnings be issued or not?
    public func recommendByProfile( prof: [String : Double],
                                    nrecs: Int = 10,
                                    normalize: Bool = true,
                                    warn: Bool = true )
    -> [Dictionary<String, Double>.Element] {
        
        // Make sure tags are known
        let profQuery: [String : Double] = prof.filter({ self.knownTags.contains($0.key) })

        if profQuery.count == 0 && warn {
            print("None of the items is known in the recommender.")
            return []
        }
        
        if profQuery.count < 0 && warn {
            print("Some of the items are unknown in the recommender.")
        }
        
        // Restrict to profile keys
        let keys2 = Set(profQuery.keys)
        
        // Get the tag inverse indexes and multiply their value by the corresponding item weight
        var weightedTagIndexes: [String : [String : Double] ] = [String: [String : Double]]();
//        weightedTagIndexes = self.tagInverseIndexes.filter({ keys2.contains($0.key) })
//
//        for k in keys2 {
//            weightedTagIndexes[k] = (weightedTagIndexes[k]!).mapValues({ $0 * profQuery[k]! })
//        }
                
        for k in keys2 {
            weightedTagIndexes[k] = (self.tagInverseIndexes[k]!).mapValues({ $0 * profQuery[k]! })
        }
        
        // Reduce the maps of maps into one map by adding the weights that correspond to the same keys
        var itemMix: [String : Double] = [String : Double] ()
        
        for k in keys2 {
            itemMix.merge(weightedTagIndexes[k]!) { (current, new) in current + new }
        }
        
        // Normalize
        // I am not happy with the function having the name "Normalize"
        // and the argument named "normalize". Using "normalizQ" (as I do, say, in R)
        // does not seem consistent.
        if normalize {
            itemMix = Normalize(itemMix, "max-norm")
        }

        // Convert to list of pairs and reverse sort
        let res = itemMix.sorted(by: { e1, e2 in e1.value > e2.value })
        
        // Result
        return (nrecs >= res.count) ? res : Array(res[0..<nrecs])
    }
}
