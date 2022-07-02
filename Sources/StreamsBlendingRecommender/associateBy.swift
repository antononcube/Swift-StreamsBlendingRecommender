//
//  File.swift
//  
//
//  Created by Anton Antonov on 7/1/22.
//

import Foundation

public
extension Sequence
{
    /// Taken from: https://gist.github.com/humblehacker/30713566c7a1884e339384bc83a46a12
    /// Returns a Dictionary using the result of `keySelector` as the key, and the result of `valueTransform` as the value
    func associateBy<T, K: Hashable, V>(_ keySelector: (T) -> K, _ valueTransform: (T) -> V) -> [K:V] where T == Iterator.Element
    {
        var dict: [K:V] = [:]
        for element in self {
            dict[keySelector(element)] = valueTransform(element)
        }
        return dict
    }
}
