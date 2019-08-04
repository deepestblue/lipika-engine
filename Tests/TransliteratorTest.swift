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

class MyConfig: Config {
    private let mappingDirectoryName: String
    private let customDirectoryName: String
    private let baseURL = Bundle(for: TransliteratorTest.self).bundleURL.appendingPathComponent("Contents", isDirectory: true).appendingPathComponent("Resources", isDirectory: true)
    
    init(mappingDirectoryName: String = "Mapping", customDirectoryName: String = "Custom") {
        self.mappingDirectoryName = mappingDirectoryName
        self.customDirectoryName = customDirectoryName
    }
    override var stopCharacter: UnicodeScalar {
        return "\\"
    }
    override var mappingDirectory: URL {
        return baseURL.appendingPathComponent(mappingDirectoryName)
    }
    override var customMappingDirectory: URL {
        return baseURL.appendingPathComponent(customDirectoryName)
    }
    override var logLevel: Level {
        return .debug
    }
}

class TransliteratorTest: XCTestCase {
    private var factory: LiteratorFactory?
    
    override func setUp() {
        super.setUp()
        do {
            factory = try LiteratorFactory(config: MyConfig())
        }
        catch {
            XCTFail("Cannot initiate LiteratorFactory due to \(error)")
        }
    }
    
    func testHappyCase() throws {
        let transliterator = try factory!.transliterator(schemeName: "Barahavat", scriptName: "Hindi")
        let result: Literated = transliterator.transliterate("atreya")
        XCTAssertEqual(result.finalaizedOutput, "अत्रे")
        XCTAssertEqual(result.unfinalaizedOutput, "य")
    }
    
    func testNestedOutput() throws {
        let transliterator = try factory!.transliterator(schemeName: "Barahavat", scriptName: "Hindi")
        let result: Literated = transliterator.transliterate("aitareya")
        XCTAssertEqual(result.finalaizedOutput, "ऐतरे")
        XCTAssertEqual(result.unfinalaizedOutput, "य")
    }
    
    func testMappedNoOutput() throws {
        let transliterator = try factory!.transliterator(schemeName: "Barahavat", scriptName: "Hindi")
        let result: Literated = transliterator.transliterate("k.l")
        XCTAssertEqual(result.finalaizedOutput, "")
        XCTAssertEqual(result.unfinalaizedOutput, "क.l")
        let result1: Literated = transliterator.transliterate("u")
        XCTAssertEqual(result1.finalaizedOutput, "")
        XCTAssertEqual(result1.unfinalaizedOutput, "कॢ")
        let result2: Literated = transliterator.transliterate("pi")
        XCTAssertEqual(result2.finalaizedOutput, "कॢ")
        XCTAssertEqual(result2.unfinalaizedOutput, "पि")
    }
    
    func testNoScriptMapping() throws {
        let transliterator = try factory!.transliterator(schemeName: "Barahavat", scriptName: "Kannada")
        let result: Literated = transliterator.transliterate("Ya")
        XCTAssertEqual(result.finalaizedOutput, "Y")
        XCTAssertEqual(result.unfinalaizedOutput, "ಅ")
    }
    
    func testStopCharacter() throws {
        let transliterator = try factory!.transliterator(schemeName: "Barahavat", scriptName: "Devanagari")
        let result: Literated = transliterator.transliterate("k\\.lu")
        XCTAssertEqual(result.finalaizedOutput, "क्")
        XCTAssertEqual(result.unfinalaizedOutput, "ऌ")
        let result1: Literated = transliterator.transliterate("k\\\\.lu")
        XCTAssertEqual(result1.finalaizedOutput, "क्ऌक्\\")
        XCTAssertEqual(result1.unfinalaizedOutput, "ऌ")
        let result2: Literated = transliterator.transliterate("\\\\\\")
        XCTAssertEqual(result2.finalaizedOutput, "क्ऌक्\\ऌ\\")
        XCTAssertEqual(result2.unfinalaizedOutput, "")
    }
    
    func testEscapeCharacter() throws {
        let transliterator = try factory!.transliterator(schemeName: "Baraha", scriptName: "Kannada")
        let result: Literated = transliterator.transliterate("r`!`zoonT`}`zeeE")
        XCTAssertEqual(result.finalaizedOutput, "ರ್!಼ಊನ್ಟ್}಼ಈ")
        XCTAssertEqual(result.finalaizedInput, "r`!`zoonT`}`zee")
        XCTAssertEqual(result.unfinalaizedOutput, "ಏ")
        XCTAssertEqual(result.unfinalaizedInput, "E")
    }
    
    func testPartialReplayWithRetroactiveRemoval() throws {
        let transliterator = try factory!.transliterator(schemeName: "Baraha", scriptName: "Kannada")
        let result: Literated = transliterator.transliterate("sUr^^ya")
        XCTAssertEqual(result.finalaizedInput, "sUr^^")
        XCTAssertEqual(result.unfinalaizedInput, "ya")
    }
    
    func testSeriesOfMappedNoOutputs() throws {
        let transliterator = try factory!.transliterator(schemeName: "Barahavat", scriptName: "Devanagari")
        let result: Literated = transliterator.transliterate(".l")
        XCTAssertEqual(result.unfinalaizedInput, ".l")
        XCTAssertEqual(result.unfinalaizedOutput, ".l")
    }
    
    func testSameEpochDoubleRuleMappedNoOutput() throws {
        let transliterator = try factory!.transliterator(schemeName: "Baraha", scriptName: "Gurmukhi")
        let idemResult: Literated = transliterator.transliterate("V\\ch")
        XCTAssertEqual(idemResult.finalaizedOutput + idemResult.unfinalaizedOutput, "Vਛ")
    }

    func testRuleMappedNoOutputs() throws {
        factory = try LiteratorFactory(config: MyConfig(mappingDirectoryName: "LipikaTestMapping"))
        let transliterator = try factory!.transliterator(schemeName: "Test", scriptName: "Test")
        let result1: [Result] = transliterator.transliterate("a")
        XCTAssertEqual(result1[0].output, "a")
        let result2: [Result] = transliterator.transliterate("1")
        XCTAssertEqual(result2[0].output, "क")
        let result3: [Result] = transliterator.transliterate("b")
        XCTAssertEqual(result3[0].output, "कb")
        let result4: [Result] = transliterator.transliterate("4")
        XCTAssertEqual(result4[0].output, "कघ")
        let result5: [Result] = transliterator.transliterate("c")
        XCTAssertEqual(result5[0].output, "कघc")
        let result6: [Result] = transliterator.transliterate("7")
        XCTAssertEqual(result6[0].output, "छघक")
    }
    
    func testRuleMappedNoOutputsMappedOuputNoMappedOutput() throws {
        factory = try LiteratorFactory(config: MyConfig(mappingDirectoryName: "LipikaTestMapping"))
        let transliterator = try factory!.transliterator(schemeName: "Test", scriptName: "Test")
        let result: [Result] = transliterator.transliterate("a1b4c7W")
        XCTAssertEqual(result[0].output, "छघक")
        XCTAssertEqual(result[1].output, "W")
    }

    func testRuleMappedNoOutputsNoMappedOutput() throws {
        factory = try LiteratorFactory(config: MyConfig(mappingDirectoryName: "LipikaTestMapping"))
        let transliterator = try factory!.transliterator(schemeName: "Test", scriptName: "Test")
        let result: [Result] = transliterator.transliterate("a1b4cW")
        XCTAssertEqual(result[0].output, "कघ")
        XCTAssertEqual(result[1].output, "c")
        XCTAssertEqual(result[2].output, "W")
    }

    func testRuleMappedOutputMappedNoOutputs() throws {
        factory = try LiteratorFactory(config: MyConfig(mappingDirectoryName: "LipikaTestMapping"))
        let transliterator = try factory!.transliterator(schemeName: "Test", scriptName: "Test")
        let result1: [Result] = transliterator.transliterate("c")
        XCTAssertEqual(result1[0].output, "c")
        let result2: [Result] = transliterator.transliterate("7")
        XCTAssertEqual(result2[0].output, "ङ")
        let result3: [Result] = transliterator.transliterate("b")
        XCTAssertEqual(result3[0].output, "ङb")
        let result4: [Result] = transliterator.transliterate("4")
        XCTAssertEqual(result4[0].output, "ङघ")
        let result5: [Result] = transliterator.transliterate("a")
        XCTAssertEqual(result5[0].output, "ङघa")
        let result6: [Result] = transliterator.transliterate("1")
        XCTAssertEqual(result6[0].output, "कघछ")
    }

    func testRuleMappedOutputMappedNoOutputsMappedOutputNoMappedOutput() throws {
        factory = try LiteratorFactory(config: MyConfig(mappingDirectoryName: "LipikaTestMapping"))
        let transliterator = try factory!.transliterator(schemeName: "Test", scriptName: "Test")
        let result: [Result] = transliterator.transliterate("c7b4a1W")
        XCTAssertEqual(result[0].output, "कघछ")
        XCTAssertEqual(result[1].output, "W")
    }

    func testRuleMappedOutputMappedNoOutputsNoMappedOuput() throws {
        factory = try LiteratorFactory(config: MyConfig(mappingDirectoryName: "LipikaTestMapping"))
        let transliterator = try factory!.transliterator(schemeName: "Test", scriptName: "Test")
        let result: [Result] = transliterator.transliterate("c7b4aW")
        XCTAssertEqual(result[0].output, "ङघ")
        XCTAssertEqual(result[1].output, "a")
        XCTAssertEqual(result[2].output, "W")
    }
    
    func testSameEpochMappedOutputMappedNoOutput() throws {
        let transliterator = try factory!.transliterator(schemeName: "ITRANS", scriptName: "IPA")
        let idemResult: Literated = transliterator.transliterate("L^|")
        XCTAssertEqual(idemResult.finalaizedOutput + idemResult.unfinalaizedOutput, "L^|")
    }

    func testInitPerformance() {
        self.measure {
            do {
                _ = try factory!.transliterator(schemeName: "Barahavat", scriptName: "Hindi")
            }
            catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
}
