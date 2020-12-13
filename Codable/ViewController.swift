//
//  ViewController.swift
//  Codable
//
//  Created by Paul Hudson on 23/10/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import Cocoa

struct Entry : Codable {

    var url: URL
    var htmlURL : URL
    var name : String
    var email : String
    var date : Date
    
    enum CodingKeys : String, CodingKey{
        case url
        case htmlURL = "html_url"
        case commit
    }
    enum CommitCodingKeys : String , CodingKey {
        case author
    }
    enum AuthorCodingKeys : String , CodingKey {
        case name, email,date
    }
    
    init(from decoder : Decoder)  throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url = try container.decode(URL.self, forKey: .url)
        htmlURL = try container.decode(URL.self, forKey: .htmlURL)
        let commit = try container.nestedContainer(keyedBy: CommitCodingKeys.self, forKey: .commit)
        let author = try commit.nestedContainer(keyedBy: AuthorCodingKeys.self, forKey: .author)
        
        name = try author.decode(String.self, forKey: .name)
        email = try author.decode(String.self, forKey: .email)
        date = try author.decode(Date.self, forKey: .date)
    }
    
    func encode(to encoder : Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
        try container.encode(htmlURL, forKey: .htmlURL)
        
        var commit = container.nestedContainer(keyedBy: CommitCodingKeys.self, forKey: .commit)
        var author = commit.nestedContainer(keyedBy: AuthorCodingKeys.self, forKey: .author)
        
        try author.encode(name, forKey: .name)
        try author.encode(email, forKey: .email)
        try author.encode(date, forKey: .date)
        
        
    }
}

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        loadJSON()
    }

    func loadJSON() {
        guard let url = Bundle.main.url(forResource: "commits", withExtension: "json") else {
            fatalError("Unalbe to find JSON in Project")
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let contents = try Data(contentsOf: url)
            let decoded = try decoder.decode([Entry].self, from: contents)
            print(decoded[0].date)
            
            let encoder = JSONEncoder()
            if #available(macOS 10.13, iOS 11, *){
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            }else{
                encoder.outputFormatting = .prettyPrinted
            }
            let formatter = DateFormatter()
            formatter.dateStyle = .full
            formatter.timeStyle = . full
            
            encoder.dateEncodingStrategy = .custom{
                date, encoder in
                var container = encoder.singleValueContainer()
                try container.encode("The custom Date is \(date)")
            }
            
            let data = try encoder.encode(decoded)
            let str = String(decoding: data, as : UTF8.self)
            print(str)
        }
        catch DecodingError.keyNotFound(let key, let context){
            print("Missing key in key in Json : \(key) \(context)")
        }catch DecodingError.typeMismatch(let type, let context){
            print("Wrong type int JSON: \(type) \(context) ")
        }catch{
            print("Unable to parse JSON :\(error.localizedDescription)")
        }
    }
}

