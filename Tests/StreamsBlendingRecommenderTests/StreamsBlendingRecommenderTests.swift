import XCTest
@testable import StreamsBlendingRecommender
//@testable import CoreSBR

final class StreamsBlendingRecommenderTests: XCTestCase {
    
    private var sbrWLExampleData : CoreSBR!
    
    override func setUp() {
        
        let urlSMRMatrixCSV = Bundle.module.url(forResource: "WLExampleData-dfSMRMatrix", withExtension: "csv")
        
        self.sbrWLExampleData = CoreSBR()
        
        let fname: String = (urlSMRMatrixCSV?.absoluteString)!.replacingOccurrences(of: "file://", with: "");
        
        _ = self.sbrWLExampleData.ingestSMRMatrixCSVFile(fileName: fname, sep: ",")
        
        _ = self.sbrWLExampleData.makeTagInverseIndexes()
    }
    
    func testCSVIngestion() throws {
        
        let urlSMRMatrixCSV = Bundle.module.url(forResource: "WLExampleData-dfSMRMatrix", withExtension: "csv")
        
        let sbr: CoreSBR = CoreSBR()
        
        let fname: String = (urlSMRMatrixCSV?.absoluteString)!.replacingOccurrences(of: "file://", with: "");
        
        let res: Bool = sbr.ingestSMRMatrixCSVFile(fileName: fname, sep: ",")
        
        XCTAssertTrue(res)
        
        XCTAssertTrue(sbr.SMRMatrix.count > 3000)
    }
    
    func testNorms() throws {
        
        XCTAssertTrue(abs(Norm([1, 212, 21, 2, 5]) - 213.1079538637636) < 0.00001 )
        
        XCTAssertTrue(Norm([1, 212, 21, 2, 5], "inf-norm") == 212 )
        
        XCTAssertTrue(Norm([1, 212, 21, 2, 5], "max-norm") == 212 )
        
        XCTAssertTrue(Norm([1, 212, 21, 2, 5], "one-norm") == 241 )
        
        XCTAssertTrue(Norm(["a" : 1, "b" : 212, "c" : 21, "d" : 2, "e" : 5]) - 213.1079538637636 < 0.00001 )
        
        XCTAssertTrue(Norm(["a" : 1, "b" : 212, "c" : 21, "d" : 2, "e" : 5], "inf-norm") == 212 )
        
        XCTAssertTrue(Norm(["a" : 1, "b" : 212, "c" : 21, "d" : 2, "e" : 5], "one-norm") == 241 )
        
    }
    
    func testNormalizing() throws {
        
        XCTAssertTrue(abs(Normalize([1, 212, 21, 2, 5], "inf-norm").max()! - 1.0) < 10e-10 )
        
        // vec = {1, 212, 21, 2, 5};
        // N[vec/Norm[vec, 2]] // Total // FullForm
        let r: [String : Double] = ["a" : 1.0, "b" : 212.0, "c" : 21, "d" : 2, "e" : 5.0]
        XCTAssertTrue( abs(Normalize(r, "euclidean").values.reduce(0, +) - 1.1308822389335467) < 1e-10)
        XCTAssertTrue( abs(Normalize(Array(r.values), "euclidean").reduce(0, +) - 1.1308822389335467) < 1e-10)
        
    }
    
    func testRecommendByProfile() throws {
        
        let urlSMRMatrixCSV = Bundle.module.url(forResource: "WLExampleData-dfSMRMatrix", withExtension: "csv")
        
        let sbr: CoreSBR = CoreSBR()
        
        let fname: String = (urlSMRMatrixCSV?.absoluteString)!.replacingOccurrences(of: "file://", with: "");
        
        _ = sbr.ingestSMRMatrixCSVFile(fileName: fname, sep: ",")
        
        _ = sbr.makeTagInverseIndexes()
        
        let prof = ["ApplicationArea:Aviation", "DataType:TimeSeries"]
        
        let lsRecs: [Dictionary<String, Double>.Element] = sbr.recommendByProfile(prof: prof, nrecs: 10, normalize: true)
        // print(lsRecs)
        
        let aRecs: [String : Double] = Dictionary(uniqueKeysWithValues: lsRecs)
        // print(aRecs)
        
        XCTAssertTrue( aRecs["Statistics-AirlinePassengerMiles"] != nil )
        XCTAssertTrue( abs(aRecs["Statistics-AirlinePassengerMiles"]! - 1.00) < 1.0e-10 )
        
        XCTAssertTrue( aRecs["Statistics-InternationalAirlinePassengers"] != nil )
        XCTAssertTrue( abs(aRecs["Statistics-InternationalAirlinePassengers"]! - 1.00) < 1.0e-10 )
        
    }
    
    func testFilterByProfile() throws {
        
        let res = sbrWLExampleData.filterByProfile(prof: ["Word:time", "Word:kidney"])

        XCTAssertTrue( Set(["Statistics-KidneyInfection", "Statistics-KidneyTransplant"]).intersection(res).count == 2)
    }
    
    func testRetrieveByQyueryElements() throws {
        
        let res = sbrWLExampleData.retrieveByQueryElements(should: ["Word:time"], must: ["Word:kidney"], mustNot: ["Word:transplant"])
        XCTAssertTrue( res.count == 1 )
        XCTAssertTrue( Set(["Statistics-KidneyInfection", "Statistics-KidneyTransplant"]).intersection(Dictionary(uniqueKeysWithValues: res).keys).count == 1)
    }
}
