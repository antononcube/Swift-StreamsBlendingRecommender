import XCTest
@testable import StreamsBlendingRecommender
//@testable import LSATopicSBR

final class LSATopicSBRTests: XCTestCase {
    
    private var sbrWLExampleDataTopics : LSATopicSBR!
    
    override func setUp() {
        
        self.sbrWLExampleDataTopics = LSATopicSBR()
        
        let urlLSATopicWordMatrixCSV = Bundle.module.url(forResource: "WLExampleData-dfLSATopicWordMatrix", withExtension: "csv")
        
        let fname: String = (urlLSATopicWordMatrixCSV?.absoluteString)!.replacingOccurrences(of: "file://", with: "");
        
        _ = self.sbrWLExampleDataTopics.ingestLSAMatrixCSVFile(fileName: fname, sep: ",")
        
        _ = self.sbrWLExampleDataTopics.makeTagInverseIndexes()
    }
    
    func test_creation() throws {
        
        let sbrLSA : LSATopicSBR = LSATopicSBR()
        
        //Topic-word matrix
        let urlLSATopicWordMatrixCSV = Bundle.module.url(forResource: "WLExampleData-dfLSATopicWordMatrix", withExtension: "csv")
        
        let fname: String = (urlLSATopicWordMatrixCSV?.absoluteString)!.replacingOccurrences(of: "file://", with: "");
        
        let res : Bool = sbrLSA.ingestLSAMatrixCSVFile(fileName: fname, sep: ",")
        
        _ = sbrLSA.makeTagInverseIndexes()
        
        XCTAssertTrue(res)
        
        XCTAssertTrue(sbrLSA.SMRMatrix.count > 3000)
    }
    
    
    func test_global_weights_ingestion_CSV() throws {
        
        //Global weights
        let urlLSAGlobalWeightsCSV = Bundle.module.url(forResource: "WLExampleData-dfLSAWordGlobalWeights", withExtension: "csv")
        
        let fname: String = (urlLSAGlobalWeightsCSV?.absoluteString)!.replacingOccurrences(of: "file://", with: "");
        
        let res : Bool = sbrWLExampleDataTopics.ingestGlobalWeightsCSVFile(fileName: fname, sep: ",")
        
        XCTAssertTrue(res)
        
        XCTAssertTrue(sbrWLExampleDataTopics.globalWeights.count > 1000)
    }
    
    func test_global_weights_ingestion_JSON() throws {
        
        //Global weights
        let urlLSAGlobalWeightsJSON = Bundle.module.url(forResource: "WLExampleData-aLSAWordGlobalWeights", withExtension: "json")
        
        let fname: String = (urlLSAGlobalWeightsJSON?.absoluteString)!.replacingOccurrences(of: "file://", with: "");
        
        let res : Bool = sbrWLExampleDataTopics.ingestGlobalWeightsJSONFile(fileName: fname)
        
        XCTAssertTrue(res)
        
        XCTAssertTrue(sbrWLExampleDataTopics.globalWeights.count > 1000)
    }
    
    func test_stem_rules_ingestion_CSV() throws {
        
        //Stem rules
        let urlLSAStemRulesCSV = Bundle.module.url(forResource: "WLExampleData-dfStemRules", withExtension: "csv")
        
        let fname: String = (urlLSAStemRulesCSV?.absoluteString)!.replacingOccurrences(of: "file://", with: "");
        
        let res : Bool = sbrWLExampleDataTopics.ingestStemRulesCSVFile(fileName: fname, sep: ",")
        
        XCTAssertTrue(res)
        
        XCTAssertTrue(sbrWLExampleDataTopics.stemRules.count > 1000)
    }
    
    
    func test_stem_rules_ingestion_JSON() throws {
        
        //Stem rules
        let urlLSAStemRulesJSON = Bundle.module.url(forResource: "WLExampleData-aStemRules", withExtension: "json")
        
        let fname: String = (urlLSAStemRulesJSON?.absoluteString)!.replacingOccurrences(of: "file://", with: "");
        
        let res : Bool = sbrWLExampleDataTopics.ingestStemRulesJSONFile(fileName: fname)
        
        XCTAssertTrue(res)
        
        XCTAssertTrue(sbrWLExampleDataTopics.stemRules.count > 1000)
    }
    
    func test_represent_by_terms() throws {

        let query = "airline time series"
        
        let qbag = sbrWLExampleDataTopics.representByTerms(query)

        XCTAssertTrue(qbag.count >= 3)
    }

    func test_represent_by_topics() throws {

        let query = "airline time series"
        
        let qbag = sbrWLExampleDataTopics.representByTopics(query)

        XCTAssertTrue(qbag.count >= 3)
    }

    func test_recommend_by_text() throws {

        let query = "titanic survival data records"
        
        let qbag = sbrWLExampleDataTopics.recommendByText(query, 10)

        XCTAssertTrue(qbag.count >= 3)
    }

    func test_creation_JSON() throws {
        
        let sbrLSA : LSATopicSBR = LSATopicSBR()
        
        //Topic-word matrix column associations / dictionaries
        let urlLSATopicWordMatrixJSON = Bundle.module.url(forResource: "WLExampleData-LSAMatrixColumnDictionaries", withExtension: "json")
        
        let fname: String = (urlLSATopicWordMatrixJSON?.absoluteString)!.replacingOccurrences(of: "file://", with: "");
        
        let res : Bool = sbrLSA.ingestLSAMatrixJSONFile(fileName: fname, tagTypesFromTagPrefixes: true, sep: ":")
        
        XCTAssertTrue(res)
        
        XCTAssertTrue(sbrLSA.tagInverseIndexes.count > 9)
        
        let query = "titanic survival data records"
        
        let qbag = sbrLSA.recommendByText(query, 10)

        XCTAssertTrue(qbag.count >= 3)
    }
}
