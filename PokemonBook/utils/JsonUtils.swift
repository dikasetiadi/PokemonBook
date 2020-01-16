//
//  JsonUtils.swift
//  PokemonBook
//
//  Created by Nakama on 05/01/20.
//  Copyright © 2020 dikasetiadi. All rights reserved.
//

import Foundation

public func readJSONFromFile(fileName: String) -> Any? {
    var json: Any?
    if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
        do {
            let fileUrl = URL(fileURLWithPath: path)
            // Getting data from JSON file using the file URL
            let data = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
            json = try? JSONSerialization.jsonObject(with: data)
        } catch {
            // Handle error here
        }
    }
    
    return json
}

public func readJSONFromFileReturnData(fileName: String) -> Data? {
    var data: Data?
    
    if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
        do {
            let fileUrl = URL(fileURLWithPath: path)
            // Getting data from JSON file using the file URL
            data = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
        } catch {
            // Handle error here
        }
    }
    
    return data
}

public func loadFromBundle<T: Decodable>(_ filename: String, as type: T.Type = T.self) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: "json") else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
        return parse(data, as: T.self)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
}


public func loadFromURL<T: Decodable>(_ url: URL, as type: T.Type = T.self) -> T {
    do {
        let contents = try String(contentsOf: url)
        return parse(contents.data(using: .utf8)!, as: T.self)
    } catch {
        fatalError("Couldn't load data from \(url):\n\(error)")
    }
}

public func parse<T: Decodable>(_ data: Data, as type: T.Type = T.self) -> T {
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse data:\n\(error)")
    }
}
