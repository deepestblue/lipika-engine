/*
 * LipikaEngine is a multi-codepoint, user-configurable, phonetic, Transliteration Engine.
 * Copyright (C) 2017 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import XCTest
@testable import LipikaEngine_OSX

class RulesTests: XCTestCase {
    var rules: Rules?
    
    override func setUp() {
        super.setUp()
        let testSchemesDirectory = MyConfig().mappingDirectory
        XCTAssertNotNil(testSchemesDirectory)
        XCTAssert(FileManager.default.fileExists(atPath: testSchemesDirectory.path))
        do {
            let factory = try EngineFactory(schemesDirectory: testSchemesDirectory)
            rules = try factory.rules(schemeName: "Barahavat", scriptName: "Hindi")
        }
        catch {
            XCTFail(error.localizedDescription)
        }
        XCTAssertNotNil(rules)
    }

    func testHappyCase() {
        XCTAssertEqual(rules?.rulesTrie[RuleInput(type: "CONSONANT")]?.value?.generate(replacement: ["CONSONANT":["A"]]), "A")
        XCTAssertEqual(rules?.rulesTrie[RuleInput(type: "CONSONANT")]?[RuleInput(type: "CONSONANT")]?.value?.generate(replacement: ["CONSONANT":["A", "A"]]), "A्A")
    }
    
    func testDeepNesting() throws {
        XCTAssertEqual(rules?.rulesTrie[RuleInput(type: "CONSONANT")]?[RuleInput(type: "CONSONANT")]?[RuleInput(type: "SIGN", key: "NUKTA")]?[RuleInput(type: "DEPENDENT")]?.value?.generate(replacement: ["CONSONANT":["A", "B"], "DEPENDENT":["C"]]), "A्B़C")
    }
    
    func testClassSpecificNextState() throws {
        let s1 = rules?.rulesTrie[RuleInput(type: "CONSONANT", key: "KA")]
        XCTAssertNotNil(s1)
        let s2 = s1?[RuleInput(type: "CONSONANT", key: "KA")]
        XCTAssertEqual(s2?.value?.generate(replacement: ["CONSONANT":["A", "A"]]), "A्A")
    }
    
    func testMultipleForwardMappings() throws {
        let result = rules?.mappingTrie["a".unicodeScalars()]
        XCTAssertEqual(result?.count, 2)
    }
    
    func testMostSpecificNextState() throws {
        let s1 = rules?.rulesTrie[RuleInput(type: "CONSONANT", key: "KA")]
        XCTAssertNotNil(s1)
        let s2 = s1?[RuleInput(type: "CONSONANT", key: "KA")]
        XCTAssertNotNil(s2)
        let s3 = s2?[RuleInput(type: "SIGN", key: "NUKTA")]
        XCTAssertNotNil(s3)
        let s4 = s3?[RuleInput(type: "DEPENDENT", key: "I")]
        XCTAssertNotNil(s4)
        XCTAssertEqual(s4?.value?.generate(replacement: ["CONSONANT":["A", "B"], "DEPENDENT":["C"]]), "A्B़C")
    }
}
