//
//  HorizontalPokemonStruct.swift
//  PokemonBook
//
//  Created by Nakama on 31/12/19.
//  Copyright © 2019 dikasetiadi. All rights reserved.
//

import Foundation
import UIKit

public struct ListPokemonDataDummy: Codable {
    let name: String
    let id: String
    let imageurl: String
    let xdescription: String
    let ydescription: String
    let height: String
    let category: String
    let weight: String
    let typeofpokemon: [String]
    let weaknesses: [String]
    let evolutions: [String]
    let abilities: [String]
    let hp: Int
    let attack: Int
    let defense: Int
    let special_attack: Int
    let special_defense: Int
    let speed: Int
    let total: Int
    let male_percentage: String?
    let female_percentage: String?
    let genderless: Int // or Bool ?
    let cycles: String
    let egg_groups: String
    let evolvedfrom: String
    let reason: String
    let base_exp: String
    var evolveArr: [ListPokemonDataDummy]?
    var evolvedFromData: [ListPokemonDataDummy]?
    
    init(_ dictionary: [String: Any]) {
        self.name = dictionary["name"] as? String ?? ""
        self.id = dictionary["name"] as? String ?? "0"
        self.imageurl = dictionary["imageurl"] as? String ?? ""
        self.xdescription = dictionary["xdescription"] as? String ?? ""
        self.ydescription = dictionary["ydescription"] as? String ?? ""
        self.height = dictionary["height"] as? String ?? "0"
        self.category = dictionary["category"] as? String ?? ""
        self.weight = dictionary["weight"] as? String ?? "0"
        self.typeofpokemon = dictionary["typeofpokemon"] as? [String] ?? [""]
        self.weaknesses = dictionary["weaknesses"] as? [String] ?? ["none"]
        self.evolutions = dictionary["evolutions"] as? [String] ?? [""]
        self.abilities = dictionary["abilities"] as? [String] ?? ["none"]
        self.hp = dictionary["hp"] as? Int ?? 0
        self.attack = dictionary["attack"] as? Int ?? 0
        self.defense = dictionary["defense"] as? Int ?? 0
        self.special_attack = dictionary["special_attack"] as? Int ?? 0
        self.special_defense = dictionary["special_defense"] as? Int ?? 0
        self.speed = dictionary["speed"] as? Int ?? 0
        self.total = dictionary["total"] as? Int ?? 0
        self.male_percentage = dictionary["male_percentage"] as? String ?? nil
        self.female_percentage = dictionary["female_percentage"] as? String ?? nil
        self.genderless = dictionary["genderless"] as? Int ?? 0
        self.cycles = dictionary["cycles"] as? String ?? ""
        self.egg_groups = dictionary["egg_groups"] as? String ?? ""
        self.evolvedfrom = dictionary["evolvedfrom"] as? String ?? ""
        self.reason = dictionary["reason"] as? String ?? ""
        self.base_exp = dictionary["base_exp"] as? String ?? ""
        self.evolveArr = []
        self.evolvedFromData = []
    }
}
