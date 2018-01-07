/*
 * LipikaEngine is a multi-codepoint, user-configurable, phonetic, Transliteration Engine.
 * Copyright (C) 2017 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

infix operator =~

class RegEx {
    private let pattern: NSRegularExpression
    private var input: String?
    private var matches: [NSTextCheckingResult]?
    
    init(pattern: String) throws {
        self.pattern = try NSRegularExpression(pattern: pattern, options: [])
    }
    
    static func =~ (regex: RegEx, input: String) -> Bool {
        regex.input = input
        regex.matches = regex.pattern.matches(in: input, options: [], range: NSRange(location: 0, length: input.unicodeScalars.count))
        return regex.matches != nil && !regex.matches!.isEmpty
    }
    
    func allMatching() -> [String]? {
        if let matches = self.matches, let input = self.input {
            return matches.flatMap() { String(input[Range($0.range(at: 0), in: input)!]) }
        }
        else {
            return nil
        }
    }
    
    func matching(ordinal: Int = 0) -> String? {
        if let matches = self.matches, let input = self.input {
            return (input as NSString).substring(with: matches[ordinal].range(at: 0))
        }
        else {
            return nil
        }
    }
    
    func captured(match: Int = 0, capture: Int = 1) -> String? {
        if let matches = self.matches, let input = self.input {
            let range = matches[match].range(at: capture)
            if range.length == 0 { return nil }
            return String(input[Range(range, in: input)!])
        }
        else {
            return nil
        }
    }
    
    func replacing(match: Int = 0, with replacement: String) -> String? {
        if let matches = self.matches, let input = self.input {
            return (input as NSString).replacingCharacters(in: matches[match].range, with: replacement)
        }
        else {
            return input
        }
    }
}
