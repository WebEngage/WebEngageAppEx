//
//  WEXUtils.swift
//  WebEngageAppEx
//
//  Created by Shubham Naidu on 15/05/24.
//

import Foundation

@objcMembers
public class WEXUtils:NSObject {
    
    @objc(differentiateCharsAndEmojisWithInputString:)
        public func differentiateCharsAndEmojis(inputString: String) -> [NSArray] {
            var chars: [Character] = []
            var emojis: [Character] = []
            
            for char in inputString {
                if isEmoji(character: char) {
                    if isKeycapEmoji(char) {
                        emojis.append(char)
                        return [chars as NSArray, emojis as NSArray]
                    }
                } else {
                    chars.append(char)
                    return [chars as NSArray, emojis as NSArray]
                }
            }
            
            return [chars as NSArray, emojis as NSArray]
        }
    func isEmoji(character: Character) -> Bool {
        for scalar in character.unicodeScalars {
            if #available(iOSApplicationExtension 10.2, *) {
                if scalar.properties.isEmoji {
                    return true
                }
            }
        }
        return false
    }
    func isKeycapEmoji(_ scalar: Character) -> Bool {
        return !scalar.isTraditionalEmoji
    }
    func isFirstCharRTL(inputString: Any) -> Bool {
        guard let firstChar = inputString as? Character else {
            return false
        }
        let languageCharacterSet = CharacterSet(charactersIn: "\u{05D0}-\u{05EA}\u{0600}-\u{0645}\u{0646}-\u{06FF}")
        return languageCharacterSet.contains(firstChar.unicodeScalars.first!)
    }

}


extension Character {
    var isTraditionalEmoji: Bool {
        // Check if the character is a traditional emoji (e.g., 😊)
        let emojiRange = CharacterSet(charactersIn: "\u{1F600}"..."\u{1F64F}") // Emoticons
                        .union(CharacterSet(charactersIn: "\u{1F300}"..."\u{1F5FF}")) // Miscellaneous Symbols and Pictographs
                        .union(CharacterSet(charactersIn: "\u{1F680}"..."\u{1F6FF}")) // Transport and Map Symbols
                        .union(CharacterSet(charactersIn: "\u{2600}"..."\u{26FF}")) // Miscellaneous Symbols
                        .union(CharacterSet(charactersIn: "\u{2700}"..."\u{27BF}")) // Dingbats
                        .union(CharacterSet(charactersIn: "\u{1F900}"..."\u{1F9FF}")) // Supplemental Symbols and Pictographs
        return unicodeScalars.count == 1 && emojiRange.contains(unicodeScalars.first!)
    }
}
