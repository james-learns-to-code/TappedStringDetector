//
//  RegexTestString.swift
//  BaseProject
//
//  Created by Dongseok Lee on 2020/02/10.
//  Copyright © 2020 Good Effect. All rights reserved.
//

import Foundation

struct RegexTestString {
    static let text: String = """
    Text1Text1Text1Text1Text1Text1 Text1 Text1 Text1 Text1Text1Text1Text1
    Text2
    Text3
    Text4
    Text5Text5Text5Text5Text5 Text5Text5Text5 Text5Text5 Text5Text5Text5Text5
    Text6
    Text7
    """

    static let timestamp: String = """
    1:00:00 안녕하세요 반가워요 2:00:00 우와
    3:00:00 오호라

    4:00 이게 뭐징

    10:00 아하!!!!!!!!!!!!!!!!!!!!! 유후 20:00 에헤 30:00 40:00 5:00 1:00:00 - 1:0 - 1:
    아하호호10:00이히
    :::::0:00:::: 0:00:::::

    오호59:00유후61:00
    1:00:00:00:00
    -1:00:00:00:00
    000:00:01
    00:00:01
    01:00:00:00:01
    00:100:00
    01:00에서02:00까지
    01:00,02:00 01:00, 02:00
    01:22:33:343:123
    01:22:33:343:123123:123123
    1:1:12
    1:1:1
    01:00:1
    """
    
    // Regex로 모든 케이스를 검사할때 사용할 결과값
    static let advancedTimestampResult: [String] = [
        "1:00:00", "2:00:00", "3:00:00", "4:00", "10:00", "20:00", "30:00", "40:00", "5:00", "1:00:00", "10:00", "0:00", "0:00", "59:00", "1:00:00", "1:00:00", "00:00:01", "01:00:00", "01:00", "02:00", "01:00", "02:00", "01:00", "02:00", "1:1:12"
    ]
}
