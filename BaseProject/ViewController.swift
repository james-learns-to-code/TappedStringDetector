//
//  ViewController.swift
//  BaseProject
//
//  Created by leedongseok on 12/06/2019.
//  Copyright © 2019 Good Effect. All rights reserved.
//

import UIKit

// MARK: Condition
extension UITextView {
    
    func getTimestampIfHas(at point: CGPoint, using regex: String) -> String? {
        guard
            let textViewText = self.text,
            let characterRange = characterRange(at: point),  // UITextRange = (UITextPosition, UITextPosition)
            let selected = text(in: characterRange),
            selected.isTimestampCharacter,
            let position = closestPosition(to: point) else { return nil }
        printIfDebug("position " + "\(String(describing: position))")

        let direction = UITextDirection(rawValue: UITextLayoutDirection.right.rawValue)
        guard
            let lineRange = tokenizer.rangeEnclosingPosition(position, with: .line, inDirection: direction),
            let line = text(in: lineRange) else { return nil }
        printIfDebug("rangeEnclosingPosition " + "\(lineRange)")
        printIfDebug("\(line)")
        
        guard let results = findTimestampString(in: line, using: regex) else { return nil }
        printIfDebug("findTimestampString " + "\(results)")

        let characterOffset = offset(from: beginningOfDocument, to: position)
        let lineStartOffset = offset(from: beginningOfDocument, to: lineRange.start)

        // line 기준 range를 가져왔으니, characterRange를 포함하는지를 알아내야 한다.
        let ranges = results.map { $0.range }
        
        for range in ranges {
            // line 기준 range를 전체 text 기준 range로 바꾼다.
            // line의 시작 offset + 리스트 range 하면 전체 text 기준 range로

            let fullRange = NSMakeRange(lineStartOffset + range.location, range.length)
            if fullRange.location <= characterOffset, fullRange.location + fullRange.length > characterOffset {
                if let timestampRange = Range(fullRange, in: textViewText) {
                    return String(textViewText[timestampRange])
                }
            }
            // 1:00:00:00:00 와 같은 문자는 range내에 바깥을 탭하더라도 인식될 수 있다.
            // 이경우 앞에 숫자만 인식하도록 해야하는데, regex로 분석이 어려울 수 있다.
            // 그러므로 일단 광범위 한 케이스를 인식하고, 추가로 비즈니스 로직와 대입하여 매칭되는 range를 가져오도록 하자. 이후 매칭되는 range와 터치한 부분의 range가 일치한다면 히트로 설정한다.
        }
        return nil
    }
    
    private func findTimestampString(in text: String, using regex: String) -> [NSTextCheckingResult]? {
        let range = NSRange(text.startIndex..., in: text)
        if let regex = try? NSRegularExpression(pattern: regex) {
            return regex.matches(in: text, range: range)
        }
        return nil
    }
}

// MARK: - Test
final class ViewController: UIViewController {

    private let label = UILabel()
    private let pattern = UITextField(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()

        pattern.font = .systemFont(ofSize: 30)
        self.view.addSubview(pattern, topAnchor: 100, heightAnchor: 100)
        pattern.delegate = self
        pattern.returnKeyType = .done
        pattern.text = RegexQuery.advancedQuery
        
        let text = DetectorTextView(frame: .zero)
        text.textContainer.lineFragmentPadding = 0
        text.textContainerInset = .zero
        self.view.addSubview(text, topAnchor: 200, heightAnchor: 500)
        text.font = .systemFont(ofSize: 40)
        text.text = RegexTestString.timestamp
        text.isEditable = false
        text.isSelectable = false
        text.detectorDelegate = self
        text.detectionCondition = text.getTimestampIfHas
        
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 30)
        self.view.addSubview(label, topAnchor: 750, heightAnchor: 60)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ViewController: DetectorTextViewDelegate {
    func didTapTimestamp(string: String?) {
        label.text = string
    }

    var regex: String? {
        return pattern.text
    }
}

protocol DetectorTextViewDelegate: AnyObject {
    func didTapTimestamp(string: String?)
    var regex: String? { get }
}

class DetectorTextView: UITextView {
    weak var detectorDelegate: DetectorTextViewDelegate?
    
    // Condition injectable
    var detectionCondition: ((CGPoint, String)-> String?)?
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let regex = detectorDelegate?.regex else { return }
        touches.forEach { touch in
            let location = touch.location(in: self)
            printIfDebug("\(String(describing: point))")
            let string = detectionCondition?(location, regex)
            detectorDelegate?.didTapTimestamp(string: string)
        }
    }
}


// MARK: - Extension
private extension String {
    var isTimestampCharacter: Bool {
        if Int(self) != nil { return true }
        if self == ":" { return true }
        return false
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// Alternative way
//extension Collection {
//    subscript(safe index: Index) -> Iterator.Element? {
//        return (startIndex <= index && index < endIndex) ? self[index] : nil
//    }
//}

extension StringProtocol {
    subscript(safe index: Int) -> Character? {
        guard index < count else { return nil }
        guard let index = self.index(startIndex, offsetBy: index, limitedBy: endIndex) else { return nil }
        return self[index]
    }
}

extension StringProtocol {
    subscript(safe range: Range<String.Index>) -> Self.SubSequence {
        let startIndex = range.lowerBound < self.startIndex ? self.startIndex : range.lowerBound
        let endIndex = range.upperBound > self.endIndex ? self.endIndex : range.upperBound
        return self[startIndex..<endIndex]
    }
}

func printIfDebug(_ string: String) {
    print(string)
}

private extension UITextView {
    // For testing
    private func getTimestampByTokenizer(at point: CGPoint) -> String? {
        let direction = UITextDirection(rawValue: UITextLayoutDirection.right.rawValue)

        if let range = characterRange(at: point) {
            printIfDebug("characterRange " + (text(in: range) ?? ""))
        }
        guard let position = closestPosition(to: point) else { return nil }
        printIfDebug("\(position)")
        if let range = characterRange(byExtending: position, in: .left) {
            printIfDebug("characterRange " + (text(in: range) ?? ""))
        }
        if let range = characterRange(byExtending: position, in: .right) {
            printIfDebug("characterRange " + (text(in: range) ?? ""))
        }
        let characterOffset = offset(from: beginningOfDocument, to: position)
        printIfDebug("\(characterOffset)")
        if let range = tokenizer.rangeEnclosingPosition(position, with: .character, inDirection: direction) {
            printIfDebug("rangeEnclosingPosition " + "\(range)")
            printIfDebug("\(String(describing: text(in: range)))")
        }
        if let position = tokenizer.position(from: position, toBoundary: .character, inDirection: direction) {
            printIfDebug("position " + "\(position)")
            if let range = characterRange(byExtending: position, in: .left) {
                printIfDebug("\(String(describing: text(in: range)))")
            }
            if let range = characterRange(byExtending: position, in: .right) {
                printIfDebug("\(String(describing: text(in: range)))")
            }
        }
        return nil
    }
}

extension UITextView {
    
    func getTimestampByTraverse(at point: CGPoint) -> String? {
        guard
            let textViewText = self.text,
            let range = characterRange(at: point),
            let selected = text(in: range),
            selected.isTimestampCharacter,
            let position = closestPosition(to: point) else { return nil }
        printIfDebug("position " + "\(String(describing: position))")

        var baseOffset = offset(from: beginningOfDocument, to: position)
        printIfDebug("baseOffset " + "\(baseOffset)")
        if baseOffset > 0 {
            baseOffset -= 1
        }
        
        let baseIndex = textViewText.index(textViewText.startIndex, offsetBy: baseOffset)
        printIfDebug("index " + "\(baseIndex)")
        printIfDebug("text[index] " + "\(String(describing: textViewText[safe: baseIndex]))")

        let textStartIndex = textViewText.startIndex
        
        // Traverse to each side
        var startIndex: String.Index = baseIndex
        var endIndex: String.Index = baseIndex
        var beforeCharacter: Character?
        
        let exclusive = CharacterSet(charactersIn: ":")
        let delimeters = CharacterSet.whitespacesAndNewlines
        var conditions = CharacterSet.decimalDigits
        conditions.formUnion(exclusive)
        let traverseLimit = 100
        
        // To the left
        var indexOffset = 1
        while indexOffset < traverseLimit {
            let offset = baseOffset - indexOffset
            let index = textViewText.index(textStartIndex, offsetBy: offset)
            guard let character = textViewText[safe: index] else { break }
            if character.unicodeScalars.contains(where: { delimeters.contains($0)}) { break }
            if character.unicodeScalars.contains(where: { conditions.contains($0)}) == false { break }
            if
                let beforeCharacter = beforeCharacter,
                character.unicodeScalars.contains(where: { exclusive.contains($0) }),
                beforeCharacter.unicodeScalars.contains(where: { exclusive.contains($0) }) { break }
            
            beforeCharacter = character
            startIndex = index
            indexOffset += 1
            printIfDebug("text[startIndex] " + "\(String(describing: textViewText[safe: startIndex]))")
            guard offset > 0 else { break }
        }
        
        // To the right
        beforeCharacter = nil
        indexOffset = 1
        while indexOffset < traverseLimit {
            guard let index = textViewText.index(textStartIndex, offsetBy: baseOffset + indexOffset, limitedBy: textViewText.endIndex) else { break }
            endIndex = index
            guard let character = textViewText[safe: endIndex] else { break }
            if character.unicodeScalars.contains(where: { delimeters.contains($0)}) { break }
            if character.unicodeScalars.contains(where: { conditions.contains($0)}) == false { break }
            
            if
                let beforeCharacter = beforeCharacter,
                character.unicodeScalars.contains(where: { exclusive.contains($0) }),
                beforeCharacter.unicodeScalars.contains(where: { exclusive.contains($0) }) { break }
            
            beforeCharacter = character
            indexOffset += 1
            printIfDebug("text[endIndex] " + "\(String(describing: textViewText[safe: endIndex]))")
        }
        let ranged = String(textViewText[safe: startIndex..<endIndex])
        return ranged.trimmingCharacters(in: exclusive)
    }
}
extension UIView {
    func addSubview(_ subview: UIView, topAnchor top: CGFloat, heightAnchor height: CGFloat) {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: topAnchor, constant: top),
            subview.leftAnchor.constraint(equalTo: leftAnchor),
            subview.rightAnchor.constraint(equalTo: rightAnchor),
            subview.heightAnchor.constraint(equalToConstant: height)
        ])
    }
}
