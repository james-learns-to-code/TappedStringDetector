//
//  RegexTest.swift
//  BaseProjectTests
//
//  Created by Dongseok Lee on 2020/02/10.
//  Copyright © 2020 Good Effect. All rights reserved.
//

import Quick
import Nimble
@testable import BaseProject

final class RegexTest: QuickSpec {
    
    override func spec() {
        describe("Regex") {
            context("match") {
                it("should exact pattern") {
                    let timestamps = self.findTimestampString(in: RegexTestString.timestamp, using: RegexQuery.advancedQuery)
                    print(timestamps)
                    expect(timestamps).to(equal(RegexTestString.advancedTimestampResult))
                }
            }
        }
    }
    
    private func findTimestampString(in text: String, using regex: String) -> [String]? {
        let range = NSRange(text.startIndex..., in: text)
        guard let regex = try? NSRegularExpression(pattern: regex) else { return nil }
        let results = regex.matches(in: text, range: range)
        return results
            .compactMap { $0.range }
            .compactMap { Range($0, in: text) }
            .map { String(text[$0]) }
    }
}
