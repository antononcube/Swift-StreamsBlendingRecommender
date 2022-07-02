//
//  IngestCSVFile.swift
//  
//
//  Created by Anton Antonov on 7/1/22.
//

import Foundation
import SwiftCSV

//========================================================
/// Ingest CSV file.
/// - Parameters:
///   - fileName: CSV file name.
///   - mapper: Maps internal to actual column names.
///   - sep: Separator of CSV fields.
public func IngestCSVFile( fileName: String,
                    mapper :Dictionary<String, String> = ["Item" : "Item",
                                                          "TagType" : "TagType",
                                                          "Value" : "Value",
                                                          "Weight" : "Weight"],
                    sep: Character = ",") -> [[String : String]] {
    
    
    do {
                
        let csvFile: CSV = try CSV(url: URL(fileURLWithPath: fileName),
                                   delimiter: sep,
                                   loadColumns: false)
        
        let rowsOrig: [[String : String]] = csvFile.namedRows
        
        if mapper["Item"] == "Item" &&
            "TagType" == mapper["TagType"] &&
            "Value" == mapper["Value"] &&
            "Weight" == mapper["Weight"] {
            return rowsOrig
        }
            
        let rows: [[String : String]]  = rowsOrig.map( { ["Item" : $0[mapper["Item"]!]!,
                                                          "TagType" : $0[mapper["TagType"]!]!,
                                                          "Value" : $0[mapper["Value"]!]!,
                                                          "Weight" : $0[mapper["Weight"]!]!] })
                
        return rows
        
    } catch {
        // Catch errors from trying to load files
        print("Could not load or parse the file.")
        return []
    }
}
