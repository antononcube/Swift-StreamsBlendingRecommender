import XCTest
@testable import StreamsBlendingRecommender
//@testable import CoreSBR

final class StreamsBlendingRecommenderTests: XCTestCase {
    func testExample() throws {
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
}
