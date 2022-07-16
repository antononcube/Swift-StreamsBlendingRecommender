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
        
        let csvFile: CSV = try CSV<Named>(url: URL(fileURLWithPath: fileName),
                                          delimiter: CSVDelimiter.character(sep),
                                          loadColumns: false)

        let rowsOrig: [[String : String]] = csvFile.rows

        
        //Check that the file had expected column names
        if Set(mapper.values).intersection(rowsOrig[0].keys).count < mapper.count {
            print("The ingested CSV file does not have the expected column names: \(mapper.keys).")
            return []
        }
        
        //Invert mapper
        var mapperInv: [String : String] = [:]
        
        for pair in mapper {
            mapperInv[pair.value] = pair.key
        }

        //Check "sameness"
        if mapper.map({ $0 == $1 }).reduce(true, { $0 && $1 }) {
            return rowsOrig
        }
        
        //Re-map keys
        //This seems very long code for a simple operation.
        //Hopefully it is fast enough.
        let rows: [[String : String]] =
        rowsOrig.map( { rec in
            
            var rec2 : [String : String] = [:]
            
            for (k, v) in rec2 {
                if mapperInv[k] != nil {
                    rec2[mapperInv[k]!] = v
                } else {
                    rec2[k] = v
                }
            }
            
            return rec2
        })
        
        return rows
        
    } catch {
        // Catch errors from trying to load files
        print("Could not load or parse the file.")
        return []
    }
}
