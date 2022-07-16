import XCTest
@testable import StreamsBlendingRecommender
//@testable import CoreSBR
//@testable import LSATopicSBR
//@testable import LSAEndowedSBR

final class LSAEndowedSBRTests: XCTestCase {
    
    private var sbrWLExampleData : LSAEndowedSBR!
    
    override func setUp() {
        
        //========================================================
        // CoreSBR
        //========================================================
        let urlSMRMatrixCSV = Bundle.module.url(forResource: "WLExampleData-dfSMRMatrix", withExtension: "csv")
        
        let sbrCore = CoreSBR()
        
        var fname: String = (urlSMRMatrixCSV?.absoluteString)!.replacingOccurrences(of: "file://", with: "")
        
        _ = sbrCore.ingestSMRMatrixCSVFile(fileName: fname, sep: ",")
        
        _ = sbrCore.makeTagInverseIndexes()
        
        //========================================================
        // LSATopicSBR
        //========================================================
        let sbrLSA = LSATopicSBR()
        
        let urlLSATopicWordMatrixCSV = Bundle.module.url(forResource: "WLExampleData-dfLSATopicWordMatrix", withExtension: "csv")
        
        fname = (urlLSATopicWordMatrixCSV?.absoluteString)!.replacingOccurrences(of: "file://", with: "")
        
        _ = sbrLSA.ingestLSAMatrixCSVFile(fileName: fname, sep: ",")
        
        _ = sbrLSA.makeTagInverseIndexes()
        
        // Global weights
        let urlLSAGlobalWeightsCSV = Bundle.module.url(forResource: "WLExampleData-dfLSAWordGlobalWeights", withExtension: "csv")
        
        fname = (urlLSAGlobalWeightsCSV?.absoluteString)!.replacingOccurrences(of: "file://", with: "");
        
        _ = sbrLSA.ingestGlobalWeightsCSVFile(fileName: fname, sep: ",")
        
        
        //Stem rules
        let urlLSAStemRulesCSV = Bundle.module.url(forResource: "WLExampleData-dfStemRules", withExtension: "csv")
        
        fname = (urlLSAStemRulesCSV?.absoluteString)!.replacingOccurrences(of: "file://", with: "");
        
        _ = sbrLSA.ingestStemRulesCSVFile(fileName: fname, sep: ",")
                
        //========================================================
        // LSAEndowedSBR
        //========================================================
        self.sbrWLExampleData = LSAEndowedSBR( coreObj: sbrCore, lsaObj: sbrLSA)
        
    }
    

    func test_recommend_profile() throws {

        let prof = ["ApplicationArea:Aviation", "DataType:TimeSeries>"]
        
        let query = "airline time series"

        let qbag = sbrWLExampleData.recommendByProfile(prof: prof, text:query, nrecs: 10)
        print(qbag)
        XCTAssertTrue(qbag.count >= 3)
        XCTAssertTrue(qbag[0].key == "Statistics-InternationalAirlinePassengers")

    }

}
