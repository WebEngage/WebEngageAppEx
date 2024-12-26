//
//  WEXUtils.swift
//  WebEngageAppEx
//
//  Created by Shubham Naidu on 15/05/24.
//

import Foundation

@objcMembers
public class WEXUtils:NSObject {
    
    let rtlCharacterSet: CharacterSet = {
        var characterSet = CharacterSet()
        
        // Add Hebrew characters to the character set
        for scalarValue in 0x05D0...0x05EA {
            if let unicodeScalar = UnicodeScalar(scalarValue) {
                characterSet.insert(unicodeScalar)
            }
        }
        
        // Add Arabic characters to the character set
        for scalarValue in 0x0600...0x06FF {
            if let unicodeScalar = UnicodeScalar(scalarValue) {
                characterSet.insert(unicodeScalar)
            }
        }
        
        return characterSet
    }()
    
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
        if #available(iOS 10.2, *) {
            for scalar in character.unicodeScalars {
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
    
    @objc(isFirstCharRTLWithInputString:)
    public func isFirstCharRTL(inputString: Any) -> Bool {
        guard let firstChar = inputString as? Character else {
            return false
        }
        if let firstUnicodeScalar = firstChar.unicodeScalars.first {
            return rtlCharacterSet.contains(firstUnicodeScalar)
        }
        
        return false
    }
    
    @objc(getAttributedStringWithMessage:colorHex:viewController:)
    public func getAttributedString(message: String?, colorHex: String, viewController: WEXRichPushNotificationViewController?) -> NSAttributedString? {
        guard let message = message else {
            return nil
        }
        guard let attributedString = viewController?.getHtmlParsedString(message, isTitle: false, bckColor: colorHex) else {
            return nil
        }
        let finalAttributedString = NSMutableAttributedString(attributedString: attributedString)
        let rawString = attributedString.string
        let paragraphRanges = rawString.paragraphRanges()

        for range in paragraphRanges {
            let paragraphText = (rawString as NSString).substring(with: range)
            guard let alignment = viewController?.naturalTextAlignment(forText: paragraphText, forDescription: true) else {
                continue
            }
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = alignment
            finalAttributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
        }
        return finalAttributedString
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


extension String {
    func paragraphRanges() -> [NSRange] {
        let nsString = self as NSString
        var ranges: [NSRange] = []
        var paragraphStart = 0
        var paragraphEnd = 0
        var contentsEnd = 0
        
        let length = nsString.length
        while paragraphStart < length {
            nsString.getParagraphStart(&paragraphStart, end: &paragraphEnd, contentsEnd: &contentsEnd, for: NSMakeRange(paragraphStart, 0))
            ranges.append(NSMakeRange(paragraphStart, contentsEnd - paragraphStart))
            paragraphStart = paragraphEnd
        }
        
        return ranges
    }
}


