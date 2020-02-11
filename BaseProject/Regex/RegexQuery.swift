//
//  RegexQuery.swift
//  BaseProject
//
//  Created by Dongseok Lee on 2020/02/10.
//  Copyright © 2020 Good Effect. All rights reserved.
//

import Foundation

struct RegexQuery {
    //        let pattern = #"[\d]{1,2}[:\d\d]{3,30}"#
    //        let pattern = #"(?:(?:(\d?\d):)?([0-5]?\d):)([0-5]\d)"#
    //        let pattern = #"[\d]{1,2}(:\d\d)+"#
    //        let pattern = #"[\d]{1,3}(:\d\d)+\d?"#
    //        pattern.text = "[\\d]{1,3}(:\\d\\d)+\\d?"

//    static let query = #"[\d]{1,3}(:\d{1,2})+\d{1,3}?"#

    // Regex로 모든 케이스를 검사할때 사용할 쿼리
//    static let advancedQuery = #"(?<!(\d:?))(?:(?:(\d?\d):)?([0-5]?\d):)+([0-5]\d)(?!(\d|:\d\d\d))"#
//    static let advancedQuery = #"(?<!(\d:?))(?:(?:(\d?\d):)?([0-5]?\d):)([0-5]\d)(?!(\d|(.*:\d{3,})))"#
//    static let advancedQuery = #"(?<![\d:])(?:(?:(\d\d?):([0-5]\d:))|([0-5]?\d:))+([0-5]\d)(?![\d:])"#
    
    // 01:22:33:343:123 인식 안됨
//    static let advancedQuery = #"(?<!\d:?)(?:(?:(\d?\d):)?([0-5]?\d):)([0-5]\d)(?!\d|[\d:]*:\d{3,})"#
    static let advancedQuery = #"(?<!\d:?)(?:(?:(\d?\d):)?([0-5]?\d):)([0-5]\d)(?!\d|[\d:]*:\d{3,}|:\d(?:[^\d]|$))"#
}
