/*
* Copyright 2016 Andrey Ilskiy
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import Foundation

public enum PropertyListValue {
    case boolean(Bool)

    case integer(Int)

    case float(Float)

    case double(Double)

    case string(String)

    case date(Date)

    case data(Data)

    case array([PropertyListRepresentable])

    case dictionary([String: PropertyListRepresentable])

    static func extract(from: PropertyListValue) -> Any? {
        var result: Any? = nil

        switch from {
        case .boolean(let value):
            result = value

        case .integer(let value):
            result = value

        case .float(let value):
            result = value

        case .double(let value):
            result = value

        case .string(let value):
            result = value

        case .date(let value):
            result = value

        case .data(let value):
            result = value

        case .array(let value):
            let maped = value.map { return extract(from: $0.propertyListValue) }
            result = maped
        case .dictionary(let value):
            var maped = [String : Any]()
            value.forEach { maped.updateValue(extract(from: $1.propertyListValue), forKey: $0) }
        }

        return result
    }
}

public protocol PropertyListRepresentable {
    var propertyListValue: PropertyListValue { get }

    init?(propertyListValue: PropertyListValue)
}

//MARK: -

extension PropertyListSerialization {
    public static func data(fromPropertyList plist: PropertyListRepresentable, format: PropertyListSerialization.PropertyListFormat, options opt: PropertyListSerialization.WriteOptions) throws -> Data {
        let extracted = PropertyListValue.extract(from: plist.propertyListValue)

        return try data(fromPropertyList: extracted, format: format, options: opt)
    }
}

//MARK: -

extension UserDefaults {
    public func set(_ value: PropertyListRepresentable?, forKey defaultName: String) {
        let extracted: Any? = value == nil ? nil : PropertyListValue.extract(from: value!.propertyListValue)
        set(extracted, forKey: defaultName)
    }
}

//MARK: -

extension Bool: PropertyListRepresentable {
    public init?(propertyListValue: PropertyListValue) {
        switch propertyListValue {
        case .boolean(let val):
            self.init(val)
        default:
            return nil
        }
    }

    public var propertyListValue: PropertyListValue {
        return .boolean(self)
    }
}

extension Int: PropertyListRepresentable {
    public init?(propertyListValue: PropertyListValue) {
        switch propertyListValue {
        case .integer(let val):
            self.init(val)
        default:
            return nil
        }
    }

    public var propertyListValue: PropertyListValue {
        return .integer(self)
    }
}

extension Float: PropertyListRepresentable {
    public init?(propertyListValue: PropertyListValue) {
        switch propertyListValue {
        case .float(let val):
            self.init(val)
        default:
            return nil
        }
    }

    public var propertyListValue: PropertyListValue {
        return .float(self)
    }
}

extension Double: PropertyListRepresentable {
    public init?(propertyListValue: PropertyListValue) {
        switch propertyListValue {
        case .double(let val):
            self.init(val)
        default:
            return nil
        }
    }

    public var propertyListValue: PropertyListValue {
        return .double(self)
    }
}


extension String: PropertyListRepresentable {
    public init?(propertyListValue: PropertyListValue) {
        switch propertyListValue {
        case .string(let val):
            self.init(val)
        default:
            return nil
        }
    }

    public var propertyListValue: PropertyListValue {
        return .string(self)
    }
}

extension Date: PropertyListRepresentable {
    public init?(propertyListValue: PropertyListValue) {
        switch propertyListValue {
        case .date(let val):
            self.init(timeIntervalSinceReferenceDate: val.timeIntervalSinceReferenceDate)
        default:
            return nil
        }
    }

    public var propertyListValue: PropertyListValue {
        return .date(self)
    }
}
