import XCTest
@testable import StreamsBlendingRecommender
//@testable import CoreSBR

final class StreamsBlendingRecommenderTests: XCTestCase {
    func testCSVIngestion() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        // XCTAssertEqual(StreamsBlendingRecommender().text, "Hello, World!")
        
        let urlSMRMatrixCSV = Bundle.module.url(forResource: "WLExampleData-dfSMRMatrix", withExtension: "csv")
        
        let smr: CoreSBR = CoreSBR()
        
        let fname: String = (urlSMRMatrixCSV?.absoluteString)!.replacingOccurrences(of: "file://", with: "");
        
        let res: Bool = smr.ingestSMRMatrixCSVFile(fileName: fname)

        XCTAssertTrue(res)
        
        XCTAssertTrue(smr.SMRMatrix.count > 3000)
    }
    
    func testNorms() throws {
        
        XCTAssertTrue(abs(Norm([1, 212, 21, 2, 5]) - 213.1079538637636) < 0.00001 )
        
        XCTAssertTrue(Norm([1, 212, 21, 2, 5], "inf-norm") == 212 )
        
        XCTAssertTrue(Norm([1, 212, 21, 2, 5], "one-norm") == 241 )

        XCTAssertTrue(Norm(["a" : 1, "b" : 212, "c" : 21, "d" : 2, "e" : 5]) - 213.1079538637636 < 0.00001 )

        XCTAssertTrue(Norm(["a" : 1, "b" : 212, "c" : 21, "d" : 2, "e" : 5], "inf-norm") == 212 )

        XCTAssertTrue(Norm(["a" : 1, "b" : 212, "c" : 21, "d" : 2, "e" : 5], "one-norm") == 241 )

    }
    
    func testNormalizing() throws {
        
        XCTAssertTrue(abs(Normalize([1, 212, 21, 2, 5], "inf-norm").max()! - 1.0) < 10e-10 )

        let r: [String : Double] = ["a" : 1.0, "b" : 212.0, "c" : 21, "d" : 2, "e" : 5.0]
        XCTAssertTrue( abs(Normalize(r, "euclidean").values.reduce(0, +) - 1.1308822389335467) < 1e-10)
        XCTAssertTrue( abs(Normalize(Array(r.values), "euclidean").reduce(0, +) - 1.1308822389335467) < 1e-10)
        
    }
}
