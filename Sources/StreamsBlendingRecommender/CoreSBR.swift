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
    //========================================================
    public init() {
        
    }
    
    //========================================================
    // Setters ?
    //========================================================
    
    //========================================================
    // Ingest from CSV file
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
    // Make tag inverse indexes
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
    // Transpose tag inverse indexes
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
    // Make from dataset
    //========================================================
    /// Make tag inverse indexes from wide form dataset.
    /// - Parameters:
    ///   - data: A list of hashes.
    ///   - tagTypes: Tag types to use -- columns of the dataset. If empty the complement of itemColumnName is used.
    ///   - itemColumnName: Which column is the identifier column.
    ///   - addTagTypesToColumnNames: Should the tag types be prefixes of the tags or not?
    ///   - sep: Separator between the tag type prefixes and the tags.
    func makeTagInverseIndexesFromWideForm(data: [[String:String]],
                       tagTypes: [String],
                       itemColumnName: String,
                       addTagTypesToColumnNames: Bool = false,
                       sep: String = ":") {
        
//        var tagTypesLocal = tagTypes
//
//        if tagTypesLocal.isEmpty {
//            tagTypesLocal = data.columns.map { $0.name }
//            tagTypesLocal = tagTypesLocal.filter({ $0 != itemColumnName })
//        }
//
//        // Hash of mixes
//        var matrices: [String : [[String : Double]]];
//        for tagType in tagTypesLocal {
//
//            //Cross-tabulate tag-vs-item
//            var res = crossTabulate(data, tagType, itemColumnName)
//
//            //If specified add the tag type to the tag-keys.
//            if addTagTypesToColumnNames {
//                //TBD...
//            }
//
//            //Assign
//            matrices[tagType] = res
//        }
//
//        //Finish the tag inverse index making.
//        return makeTagInverseIndexes(matrices)
    }
    
    //========================================================
    // Profile
    //========================================================
    /// Recommend items for a consumption profile (that is a list or a mix of tags.)
    /// - Parameters:
    ///    - items: A  list of items or an item-to-weight dictionary.
    ///    - normalize: Should the recommendation scores be normalized or not?
    ///    - warn: Should warnings be issued or not?
    public func profile( items: [String],
                         normalize: Bool = true,
                         warn: Bool = true )
    -> [Dictionary<String, Double>.Element] {
        let itemsd = Dictionary(uniqueKeysWithValues: zip(items, [Double](repeating: 1.0, count: items.count)))
        return profile(items: itemsd, normalize: normalize, warn: warn)
    }
    
    /// Recommend items for a consumption profile (that is a list or a mix of tags.)
    /// - Parameters:
    ///    - items: A  list of items or an item-to-weight dictionary.
    ///    - normalize: Should the recommendation scores be normalized or not?
    ///    - warn: Should warnings be issued or not?
    public func profile( items: [String : Double],
                         normalize: Bool = true,
                         warn: Bool = true )
    -> [Dictionary<String, Double>.Element] {
        
        // Transpose inverse indexes if needed
        if self.itemInverseIndexes.isEmpty {
            let res = self.transposeTagInverseIndexes()
            if !res {
                print("Cannot transpose tag inverse indexes.")
                return []
            }
        }
        
        // Except the line above the code of this method is same/dual to .recommendByProfile
        
        // Make sure items are known
        let itemsQuery: [String : Double] = items.filter({ self.knownItems.contains($0.key) })

        if itemsQuery.count == 0 && warn {
            print("None of the items is known in the recommender.")
            return []
        }
        
        if itemsQuery.count < 0 && warn {
            print("Some of the items are unknown in the recommender.")
        }
        
        // Restrict to items keys
        let keys2 = Set(itemsQuery.keys)
        
        // Get the item inverse indexes and multiply their value by the corresponding item weight
        var weightedItemIndexes: [String : [String : Double] ] = [String: [String : Double]]();
                
        for k in keys2 {
            weightedItemIndexes[k] = (self.itemInverseIndexes[k]!).mapValues({ $0 * itemsQuery[k]! })
        }
        
        // Reduce the maps of maps into one map by adding the weights that correspond to the same keys
        var tagMix: [String : Double] = [String : Double] ()
        
        for k in keys2 {
            tagMix.merge(weightedItemIndexes[k]!) { (current, new) in current + new }
        }
        
        // Normalize
        // I am not happy with the function having the name "Normalize"
        // and the argument named "normalize". Using "normalizQ" (as I do, say, in R)
        // does not seem consistent.
        if normalize {
            tagMix = Normalize(tagMix, "max-norm")
        }

        // Convert to list of pairs and reverse sort
        let res = tagMix.sorted(by: { e1, e2 in e1.value > e2.value })
        
        // Result
        return res
    }
    
    //========================================================
    // Recommend by history
    //========================================================
    /// Recommend items for a consumption history.
    ///  - Parameters:
    ///    - items: A  list of items or an item-to-weight dictionary.
    ///    - nrecs: Number of recommendations.
    ///    - normalize: Should the recommendation scores be normalized or not?
    ///    - warn: Should warnings be issued or not?
    public func recommend( items: [String],
                           nrecs: Int = 10,
                           normalize: Bool = true,
                           warn: Bool = true )
    -> [Dictionary<String, Double>.Element] {
        let itemsd =  Dictionary(uniqueKeysWithValues: zip(items, [Double](repeating: 1.0, count: items.count)))
        return recommend(items: itemsd, nrecs: nrecs, normalize: normalize, warn: warn)
    }
    
    
    public func recommend( items: [String : Double],
                           nrecs: Int = 10,
                           normalize: Bool = true,
                           warn: Bool = true )
    -> [Dictionary<String, Double>.Element] {
        
        let res = profile(items: items, normalize: normalize, warn: warn)
        
        return recommendByProfile(prof: Dictionary(uniqueKeysWithValues: res),
                                  nrecs: nrecs,
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
            print("None of the tags is known in the recommender.")
            return []
        }
        
        if profQuery.count < 0 && warn {
            print("Some of the tags are unknown in the recommender.")
        }
        
        // Restrict to profile keys
        let keys2 = Set(profQuery.keys)
        
        // Get the tag inverse indexes and multiply their value by the corresponding item weight
        var weightedTagIndexes: [String : [String : Double] ] = [String: [String : Double]]();
                
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
    
    //========================================================
    // Filter by profile
    //========================================================
    /// Filter items by profile
    /// - Parameters:
    ///   - prof: A profile specification used to filter with.
    ///   - type: The type of filtering one of "union" or "intersection".
    ///   - warn: Should warnings be issued or not?
    public func filterByProfile( prof : [String],
                                 type : String = "intersection",
                                 warn : Bool = true) -> [String] {
        
        var profMix : Set<String>
        let profSet = Set(prof)
        
        if type.lowercased() == "intersection" {
            
            let tagItemSets = self.tagInverseIndexes.filter({ profSet.contains($0.key) }).map({ Set($0.value.keys) })

            profMix = tagItemSets.suffix(from:1).reduce(tagItemSets[0], { x, y in x.intersection(y) })
                
        } else if type.lowercased() == "union" {
            
            let tagItemSets = self.tagInverseIndexes.filter({ profSet.contains($0.key) }).map({ Set($0.value.keys) })
            
            profMix = tagItemSets.reduce(Set<String>(), { x, y in x.union(y) })
        
        } else {
            if warn {
                print("The value of the type argument is expected to be one of \"intersection\" or \"union\".")
            }
            return []
        }
        
        return Array(profMix)
    }
    
    
    //========================================================
    // Retrieve by query elements
    //========================================================
    /// Retrieve by query elements.
    /// - Parameters:
    ///   - should: A profile specification used to recommend with.
    ///   - must: A profile specification used to filter with. The items in the result must have the tags in the must argument.
    ///   - mustNot: A profile specification used to filter with. The items in the result must not have the tags in the must not argument.
    ///   - mustType: The type of filtering with the must tags; one of "union" or "intersection".
    ///   - mustNotType: The type of filtering with the must not tags; one of "union" or "intersection".
    ///   - warn: Should warnings be issued or not?
    public func retrieveByQueryElements( should : [String],
                                         must : [String],
                                         mustNot : [String],
                                         mustType : String = "intersection",
                                         mustNotType : String = "union",
                                         warn: Bool = true) -> [Dictionary<String, Double>.Element] {
    
        if should.count + must.count + mustNot.count == 0 {
            if warn { print("All query specifications are empty.") }
            return [Dictionary<String, Double>.Element]()
        }
        
        //-------------------------------------------------
        // Should
        //-------------------------------------------------
        var shouldItems: Set<String> = []
        var profRecs : Dictionary<String, Double> = [:]
        if should.count > 0 || must.count > 0 {
            profRecs = Dictionary(uniqueKeysWithValues: recommendByProfile(prof: should + must, warn: warn))
            shouldItems = Set(profRecs.keys)
        }

        var res: Set<String> = shouldItems
        
        //-------------------------------------------------
        // Must
        //-------------------------------------------------
        var mustItems: Set<String> = []
        if must.count > 0 {
            mustItems = Set(filterByProfile(prof: must, type: mustType, warn: warn))
        } else {
            mustItems = self.knownItems
        }

        if mustItems.count > 0 {
            res = res.intersection(mustItems)
        }

        //-------------------------------------------------
        // Must Not
        //-------------------------------------------------
        var mustNotItems: Set<String> = []
        if mustNot.count > 0 {
            mustNotItems = Set(filterByProfile(prof: mustNot, type: mustNotType, warn: warn))
        }
        
        if mustNotItems.count > 0 {
            res.subtract(mustNotItems)
        }

        // Result
        return Array(profRecs.filter({ res.contains($0.key) })).sorted(by: { e1, e2 in e1.value > e2.value })
    }
    
}
