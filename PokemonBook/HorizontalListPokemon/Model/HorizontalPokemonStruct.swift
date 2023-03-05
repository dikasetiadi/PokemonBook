//
//  HorizontalPokemonStruct.swift
//  PokemonBook
//
//  Created by Nakama on 31/12/19.
//  Copyright © 2019 dikasetiadi. All rights reserved.
//

import Foundation
import UIKit

public struct ListPokemonDataDummy: Decodable {
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
    
    public enum CodingKeys: String, CodingKey {
        case name
        case id
        case imageurl
        case xdescription
        case ydescription
        case height
        case category
        case weight
        case typeofpokemon
        case weaknesses
        case evolutions
        case abilities
        case hp
        case attack
        case defense
        case special_attack
        case special_defense
        case speed
        case total
        case male_percentage
        case female_percentage
        case genderless
        case cycles
        case egg_groups
        case evolvedfrom
        case reason
        case base_exp
    }
}

extension ListPokemonDataDummy: Equatable {}
