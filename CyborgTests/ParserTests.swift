//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//

@testable import Cyborg
import XCTest

class ParserTests: XCTestCase {

    func test_oneorMoreOf() {
        "a".withXMLString { str in
            "aaa".withXMLString { contents in
                XCTAssertEqual(oneOrMore(of: literal(str))(contents, 0).asOptional?.0,
                               Array(repeating: str, count: 3))
                "   a a   a".withXMLString { contents2 in
                    XCTAssertEqual(oneOrMore(of: consumeTrivia(before: literal(str)))(contents2, 0).asOptional?.0,
                                   Array(repeating: str, count: 3))
                }
            }
        }
    }

    func test_complex_number() {
        let (text, buffer) = XMLString.create(from: "-2.38419e-08")
        defer {
            buffer.deallocate()
        }
        let expected: CGFloat = -2.38419e-08
        switch number(from: text, at: 0) {
        case .ok(let result, let index):
            XCTAssert(result == expected)
            XCTAssertEqual(index, text.count)
        case .error(let error):
            XCTFail(error)
        }
    }

    func test_number_parser() {
        "-432".withXMLString { str in
            switch Cyborg.number(from: str, at: 0) {
            case .ok(let result, let index):
                XCTAssertEqual(result, -432)
                XCTAssertEqual(index, str.count)
            case .error(let error):
                XCTFail(error)
            }
        }
        "40".withXMLString { str2 in
            switch Cyborg.number(from: str2, at: 0) {
            case .ok(let result, let index):
                XCTAssertEqual(result, 40)
                XCTAssertEqual(index, str2.count)
            case .error(let error):
                XCTFail(error)
            }
        }
        "4".withXMLString { str3 in
            switch Cyborg.number(from: str3, at: 0) {
            case .ok(let result, let index):
                XCTAssertEqual(result, 4)
                XCTAssertEqual(index, str3.count)
            case .error(let error):
                XCTFail(error)
            }
        }
        "4.4 ".withXMLString { str4 in
            switch Cyborg.number(from: str4, at: 0) {
            case .ok(let result, let index):
                XCTAssertEqual(result, 4.4)
                XCTAssertEqual(index, str4.count - 1)
            case .error(let error):
                XCTFail(error)
            }
        }
        ".9 ".withXMLString { str5 in
            switch Cyborg.number(from: str5, at: 0) {
            case .ok(let result, let index):
                XCTAssertEqual(result, 0.9)
                XCTAssertEqual(index, str5.count - 1)
            case .error(let error):
                XCTFail(error)
            }
        }
        "-.9 ".withXMLString { str6 in
            switch Cyborg.number(from: str6, at: 0) {
            case .ok(let result, let index):
                XCTAssertEqual(result, -0.9)
                XCTAssertEqual(index, str6.count - 1)
            case .error(let error):
                XCTFail(error)
            }
        }
    }

}
