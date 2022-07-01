//
//  IngestCSVFile.swift
//  
//
//  Created by Anton Antonov on 7/1/22.
//

import Foundation
import SwiftCSV

//=========A===============================================
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
        
        let rows = csvFile.namedRows
        
        return rows
        
    } catch {
        // Catch errors from trying to load files
        print("Could not load or parse the file.")
        return []
    }
}
