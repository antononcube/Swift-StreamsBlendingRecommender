public class CoreSBR {
    
    //========================================================
    // Data members
    //========================================================
    var SMRMatrix: [[String: Any]] = []
    var itemInverseIndexes: [String: [String : Double]] = [:]
    var tagInverseIndexes: [String: [String : Double]] = [:]
    var tagTypeToTags: [String: [String]] = [:]
    var globalWeights: [String: Double] = [:]
    var knownTags: Set<Character> = Set<Character>()
    var knownItems: Set<Character> = Set<Character>()
    
    
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
        return false
    }
}
