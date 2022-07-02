public class CoreSBR {
    
    //========================================================
    // Data members
    //========================================================
    var SMRMatrix: [[String: String]] = []
    var itemInverseIndexes: [String: [String : Double]] = [:]
    var tagInverseIndexes: [String: [String : Double]] = [:]
    var tagTypeToTags: [String: [String]] = [:]
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
        var inverseIndexGroups = Dictionary(grouping: self.SMRMatrix, by: { r in r["TagType"]! })

        // For each tag type split into hash by Value.
        var inverseIndexesPerTagType = inverseIndexGroups.mapValues { it0 in Dictionary(grouping: it0, by: { $0["Value"] }) }

        // Re-make each array of hashes into a hash.
        // println( inverseIndexesPerTagType.mapValues{ typeRec -> typeRec.value.mapValues{ it.value.size } } )

        /*
        var inverseIndexesPerTagType2 = inverseIndexesPerTagType.mapValues { typeRec in
            typeRec.mapValues { tagRec in
                tagRec.value.associateBy(
                    { $0["Item"] },
                    { Double($0["Weight"]) })
            }
        }

        // Derive the tag type to tags hash map.
        self.tagTypeToTags = inverseIndexesPerTagType2.mapValues { it in Set(it.value.keys) }

        // Flatten the inverse index groups.
        self.tagInverseIndexes = [String: [String : Double]]();
        for (k, v) in inverseIndexesPerTagType2 {
            self.tagInverseIndexes.merge(v) { (_, new) in new }
        }

        // Assign known tags.
        self.knownTags = Set(self.tagInverseIndexes.keys);

        // We make sure item inverse indexes are empty.
        self.itemInverseIndexes = [String: [String : Double]]();
        */
        
        return false
    }
    
}
