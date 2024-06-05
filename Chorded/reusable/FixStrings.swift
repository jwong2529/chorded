//
//  FixStrings.swift
//  Chorded
//
//  Created by Janice Wong on 6/5/24.
//

import Foundation

class FixStrings {
    
    
    //ex: change SZA (2) to SZA
    func deleteDistinctArtistNum(_ string: String) -> String {
        guard string.count >= 4 else {
            return string
        }
        
        let lastChar = string[string.index(before:string.endIndex)]
        let secondToLastChar = string[string.index(string.endIndex, offsetBy: -2)]
        let thirdToLastChar = string[string.index(string.endIndex, offsetBy: -3)]
        let fourthToLastChar = string[string.index(string.endIndex, offsetBy: -4)]
        
        if lastChar == ")" && thirdToLastChar == "(" && secondToLastChar.isNumber && fourthToLastChar == " " {
            let truncatedString = String(string.dropLast(4))
            return truncatedString
        } else {
            return string
        }
    }
    
    //compare strings while ignoring case, whitespace, accents, and punctuations
    func compareBasicCharsOfStrings(_ str1: String, _ str2: String) -> Bool {
        let options: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive, .literal]
        let sanitizedStr1 = str1.folding(options: options, locale: .current)
            .components(separatedBy: .whitespacesAndNewlines).joined()
            .components(separatedBy: .punctuationCharacters).joined()
        let sanitizedStr2 = str2.folding(options: options, locale: .current)
            .components(separatedBy: .whitespacesAndNewlines).joined()
            .components(separatedBy: .punctuationCharacters).joined()
        return sanitizedStr1 == sanitizedStr2
    }
    
    func sanitizeString(_ string: String) -> String {
        let disallowedCharacters = CharacterSet(charactersIn: ".$#[]/").union(.controlCharacters)
        return string.components(separatedBy: disallowedCharacters).joined()
    }
    
    func encodeString(_ string: String) -> String? {
        return string.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    }
    
    func decodeString(_ encodedString: String) -> String? {
        return encodedString.removingPercentEncoding
    }
    
    func normalizeString(_ string: String) -> String {
        let allowedCharacters = CharacterSet.alphanumerics.union(.whitespaces)
        let normalizedString = string
            .lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)
            .components(separatedBy: allowedCharacters.inverted)
            .joined()
        return normalizedString
    }
    
}
