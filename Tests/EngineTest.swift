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

class EngineTest: XCTestCase {
    var engine: Engine?

    override func setUp() {
        super.setUp()
        let testSchemesDirectory = MyConfig().mappingDirectory
        XCTAssertNotNil(testSchemesDirectory)
        XCTAssert(FileManager.default.fileExists(atPath: testSchemesDirectory.path))
        do {
            engine = try EngineFactory(schemesDirectory: testSchemesDirectory).engine(schemeName: "Barahavat", scriptName: "Hindi")
        }
        catch {
            XCTFail(error.localizedDescription)
        }
        XCTAssertNotNil(engine)
    }
    
    override func tearDown() {
        engine?.reset()
        super.tearDown()
    }
    
    func testHappyCase() throws {
        let r1 = engine?.execute(input: "k")
        XCTAssertEqual(r1?[0].input, "k")
        XCTAssertEqual(r1?[0].output, "क")
        XCTAssertEqual(r1?[0].isPreviousFinal, false)
        let r2 = engine?.execute(input: "k")
        XCTAssertEqual(r2?[0].input, "kk")
        XCTAssertEqual(r2?[0].output, "क्क")
        XCTAssertEqual(r2?[0].isPreviousFinal, false)
        let r3 = engine?.execute(input: "a")
        XCTAssertEqual(r3?[0].input, "kka")
        XCTAssertEqual(r3?[0].output, "क्क")
        XCTAssertEqual(r3?[0].isPreviousFinal, false)
        let r4 = engine?.execute(input: "u")
        XCTAssertEqual(r4?[0].input, "kkau")
        XCTAssertEqual(r4?[0].output, "क्कौ")
        XCTAssertEqual(r4?[0].isPreviousFinal, false)
    }
    
    func testPreviousFinal() throws {
        let r1 = engine?.execute(input: "k")
        XCTAssertEqual(r1?[0].input, "k")
        XCTAssertEqual(r1?[0].output, "क")
        XCTAssertEqual(r1?[0].isPreviousFinal, false)
        let r2 = engine?.execute(input: "u")
        XCTAssertEqual(r2?[0].input, "ku")
        XCTAssertEqual(r2?[0].output, "कु")
        XCTAssertEqual(r2?[0].isPreviousFinal, false)
        let r3 = engine?.execute(input: "m")
        XCTAssertEqual(r3?[1].input, "m")
        XCTAssertEqual(r3?[1].output, "म")
        XCTAssertEqual(r3?[1].isPreviousFinal, false)
        let r4 = engine?.execute(input: "a")
        XCTAssertEqual(r4?[1].input, "ma")
        XCTAssertEqual(r4?[1].output, "म")
        XCTAssertEqual(r4?[1].isPreviousFinal, false)
        let r5 = engine?.execute(input: "a")
        XCTAssertEqual(r5?[1].input, "maa")
        XCTAssertEqual(r5?[1].output, "मा")
        XCTAssertEqual(r5?[1].isPreviousFinal, false)
        let r6 = engine?.execute(input: "r")
        XCTAssertEqual(r6?[2].input, "r")
        XCTAssertEqual(r6?[2].output, "र")
        XCTAssertEqual(r6?[2].isPreviousFinal, false)
    }
    
    func testMappedNoOutput() throws {
        let r1 = engine?.execute(input: "k")
        XCTAssertEqual(r1?[0].input, "k")
        XCTAssertEqual(r1?[0].output, "क")
        XCTAssertEqual(r1?[0].isPreviousFinal, false)
        let r2 = engine?.execute(input: ".")
        XCTAssertEqual(r2?[1].input, ".")
        XCTAssertEqual(r2?[1].output, ".")
        XCTAssertEqual(r2?[1].isPreviousFinal, false)
        let r3 = engine?.execute(input: "l")
        XCTAssertEqual(r3?[1].input, ".l")
        XCTAssertEqual(r3?[1].output, ".l")
        XCTAssertEqual(r3?[1].isPreviousFinal, false)
        let r4 = engine?.execute(input: "u")
        XCTAssertEqual(r4?[0].input, "k.lu")
        XCTAssertEqual(r4?[0].output, "कॢ")
        XCTAssertEqual(r4?[0].isPreviousFinal, false)
        let r5 = engine?.execute(input: "p")
        XCTAssertEqual(r5?[1].input, "p")
        XCTAssertEqual(r5?[1].output, "प")
        XCTAssertEqual(r5?[1].isPreviousFinal, false)
        let r6 = engine?.execute(input: "i")
        XCTAssertEqual(r6?[1].input, "pi")
        XCTAssertEqual(r6?[1].output, "पि")
        XCTAssertEqual(r6?[1].isPreviousFinal, false)
    }
    
    func testNoMappedOutput() throws {
        let r1 = engine?.execute(input: "(")
        XCTAssertEqual(r1?[0].input, "(")
        XCTAssertEqual(r1?[0].output, "(")
        XCTAssertEqual(r1?[0].isPreviousFinal, false)
        let r2 = engine?.execute(input: ")")
        XCTAssertEqual(r2?[1].input, ")")
        XCTAssertEqual(r2?[1].output, ")")
        XCTAssertEqual(r2?[1].isPreviousFinal, false)
        let r3 = engine?.execute(input: ",")
        XCTAssertEqual(r3?[2].input, ",")
        XCTAssertEqual(r3?[2].output, ",")
        XCTAssertEqual(r3?[2].isPreviousFinal, false)
        _ = engine?.execute(inputs: "ma")
        let r4 = engine?.execute(input: ";")
        XCTAssertEqual(r4?[2].input, ";")
        XCTAssertEqual(r4?[2].output, ";")
        XCTAssertEqual(r4?[2].isPreviousFinal, false)
    }
    
    func testMultipleRules() throws {
        let testSchemesDirectory = MyConfig().mappingDirectory
        engine = try EngineFactory(schemesDirectory: testSchemesDirectory).engine(schemeName: "Barahavat", scriptName: "Kannada")
        let r1 = engine?.execute(input: "r")
        XCTAssertEqual(r1?[0].input, "r")
        XCTAssertEqual(r1?[0].output, "ರ್")
        XCTAssertEqual(r1?[0].isPreviousFinal, false)
        let r11 = engine?.execute(input: "^")
        XCTAssertEqual(r11?[0].input, "r^")
        XCTAssertEqual(r11?[0].output, "ರ್‌")
        XCTAssertEqual(r11?[0].isPreviousFinal, false)
        let r2 = engine?.execute(input: "y")
        XCTAssertEqual(r2?[0].input, "r^y")
        XCTAssertEqual(r2?[0].output, "ರ್‌ಯ್")
        XCTAssertEqual(r2?[0].isPreviousFinal, false)
        let r3 = engine?.execute(input: "a")
        XCTAssertEqual(r3?[0].input, "r^ya")
        XCTAssertEqual(r3?[0].output, "ರ‌್ಯ")
        XCTAssertEqual(r3?[0].isPreviousFinal, false)
    }
    
    func testMappingOutputMappingOutputMappingOutput() throws {
        let testSchemesDirectory = MyConfig().mappingDirectory
        engine = try EngineFactory(schemesDirectory: testSchemesDirectory).engine(schemeName: "Barahavat", scriptName: "Devanagari")
        let r1 = engine?.execute(input: "l")
        XCTAssertEqual(r1?[0].input, "l")
        XCTAssertEqual(r1?[0].output, "ल्")
        XCTAssertEqual(r1?[0].isPreviousFinal, false)
        let r2 = engine?.execute(input: "s")
        XCTAssertEqual(r2?[1].input, "s")
        XCTAssertEqual(r2?[1].output, "स्")
        XCTAssertEqual(r2?[1].isPreviousFinal, false)
        let r3 = engine?.execute(input: "h")
        XCTAssertEqual(r3?[1].input, "sh")
        XCTAssertEqual(r3?[1].output, "श्")
        XCTAssertEqual(r3?[1].isPreviousFinal, false)
    }

    func testMappedNoOuputToNoMappedOutput() throws {
        let r1 = engine?.execute(input: "j")
        XCTAssertEqual(r1?[0].input, "j")
        XCTAssertEqual(r1?[0].output, "ज")
        XCTAssertEqual(r1?[0].isPreviousFinal, false)
        let r2 = engine?.execute(input: ".")
        XCTAssertEqual(r2?[1].input, ".")
        XCTAssertEqual(r2?[1].output, ".")
        XCTAssertEqual(r2?[1].isPreviousFinal, false)
        let r21 = engine?.execute(input: "l")
        XCTAssertEqual(r21?[1].input, ".l")
        XCTAssertEqual(r21?[1].output, ".l")
        XCTAssertEqual(r21?[1].isPreviousFinal, false)
        let r3 = engine?.execute(input: "W")
        XCTAssertEqual(r3?[0].input, "j")
        XCTAssertEqual(r3?[0].output, "ज")
        XCTAssertEqual(r3?[0].isPreviousFinal, false)
        XCTAssertEqual(r3?[1].input, ".l")
        XCTAssertEqual(r3?[1].output, ".l")
        XCTAssertEqual(r3?[1].isPreviousFinal, true)
        XCTAssertEqual(r3?[2].input, "W")
        XCTAssertEqual(r3?[2].output, "W")
        XCTAssertEqual(r3?[2].isPreviousFinal, false)
    }

    func testMappedNoOuputToMappedOutput() throws {
        let r1 = engine?.execute(input: "j")
        XCTAssertEqual(r1?[0].input, "j")
        XCTAssertEqual(r1?[0].output, "ज")
        XCTAssertEqual(r1?[0].isPreviousFinal, false)
        let r2 = engine?.execute(input: ".")
        XCTAssertEqual(r2?[1].input, ".")
        XCTAssertEqual(r2?[1].output, ".")
        XCTAssertEqual(r2?[1].isPreviousFinal, false)
        let r21 = engine?.execute(input: "l")
        XCTAssertEqual(r21?[1].input, ".l")
        XCTAssertEqual(r21?[1].output, ".l")
        XCTAssertEqual(r21?[1].isPreviousFinal, false)
        let r3 = engine?.execute(input: "k")
        XCTAssertEqual(r3?[0].input, "j")
        XCTAssertEqual(r3?[0].output, "ज")
        XCTAssertEqual(r3?[0].isPreviousFinal, false)
        XCTAssertEqual(r3?[1].input, ".l")
        XCTAssertEqual(r3?[1].output, ".l")
        XCTAssertEqual(r3?[1].isPreviousFinal, true)
        XCTAssertEqual(r3?[2].input, "k")
        XCTAssertEqual(r3?[2].output, "क")
        XCTAssertEqual(r3?[2].isPreviousFinal, false)
    }
    
    func testMappedNoOuputToMappedNoOutputToMappedOutput() throws {
        let r1 = engine?.execute(input: "j")
        XCTAssertEqual(r1?[0].input, "j")
        XCTAssertEqual(r1?[0].output, "ज")
        XCTAssertEqual(r1?[0].isPreviousFinal, false)
        let r2 = engine?.execute(input: "R")
        XCTAssertEqual(r2?[1].input, "R")
        XCTAssertEqual(r2?[1].output, "R")
        XCTAssertEqual(r2?[1].isPreviousFinal, false)
        let r3 = engine?.execute(input: "R")
        XCTAssertEqual(r3?[0].input, "j")
        XCTAssertEqual(r3?[0].output, "ज")
        XCTAssertEqual(r3?[0].isPreviousFinal, false)
        XCTAssertEqual(r3?[1].input, "R")
        XCTAssertEqual(r3?[1].output, "R")
        XCTAssertEqual(r3?[1].isPreviousFinal, true)
        XCTAssertEqual(r3?[2].input, "R")
        XCTAssertEqual(r3?[2].output, "R")
        XCTAssertEqual(r3?[2].isPreviousFinal, false)
        let r4 = engine?.execute(input: "u")
        XCTAssertEqual(r4?[1].input, "Ru")
        XCTAssertEqual(r4?[1].output, "ऋ")
        XCTAssertEqual(r4?[1].isPreviousFinal, false)
    }
}
