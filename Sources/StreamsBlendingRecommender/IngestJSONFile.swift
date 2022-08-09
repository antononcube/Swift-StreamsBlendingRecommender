//
//  File.swift
//  
//
//  Created by Anton Antonov on 8/9/22.
//

import Foundation

// Could not figure out how to do these functions generic.
// Tried to follow the directions here:
//  https://stackoverflow.com/q/39448849/14163984

//========================================================
// Ingest from JSON dictionary file
//========================================================
/// Ingest JSON file. (Tag-to-item-weight.)
/// - Parameters:
///    - fileName: JSON file name.
public func IngestJSONDictionaryFile<T1:Decodable, T2:Decodable>(fileName: String) -> [T1 : T2] {

    let fileManager = FileManager.default

    if !fileManager.fileExists(atPath: fileName) {
        print("File does not exist: \(fileName).")
        return [T1: T2]()
    }

    do {

        let data = try Data(contentsOf: URL(fileURLWithPath: fileName));

        let jsonData = try! JSONDecoder().decode([T1 : T2].self, from: data)

        return jsonData

    } catch {
        print("Cannot ingest JSON dictionary file.")
        return [T1: T2]()
    }
}
