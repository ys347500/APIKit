import Foundation

/// `Response` protocol represents response of Web API.
public protocol Response {
    /// The data parser type that deserialize HTTP response body.
    associatedtype Parser: DataParser

    /// Instatiates a parser.
    static var parser: Parser { get }

    /// Instantiates response from parsed data `Parser.Parsed` and `HTTPURLResponse`.
    init(data: Parser.Parsed, urlResponse: HTTPURLResponse) throws

    // MARK: - Interceptors 

    /// Intercepts `Data` and `HTTPURLResponse`.
    /// If an error is thrown in this method, the result of `Session.send()` turns `.failure(.responseError(error))`.
    /// The default implementation of this method is provided to throw `RequestError.unacceptableStatusCode`
    /// if the HTTP status code is not in `200..<300`.
    static func intercept(data: Data, urlResponse: HTTPURLResponse) throws -> (Data, HTTPURLResponse)
    
    /// Intercepts `Parser.Parsed` and `HTTPURLResponse`.
    /// If an error is thrown in this method, the result of `Session.send()` turns `.failure(.responseError(error))`.
    /// This method is called after `intercept(data:urlResponse:)`.
    static func intercept(parsed: Parser.Parsed, urlResponse: HTTPURLResponse) throws -> (Parser.Parsed, HTTPURLResponse)
    
    /// Intercepts `Self` and `HTTPURLResponse`.
    /// If an error is thrown in this method, the result of `Session.send()` turns `.failure(.responseError(error))`.
    /// This method is called after `intercept(data:urlResponse:)` and `intercept(parsed:urlResponse:)`.
    static func intercept(instance: Self, urlResponse: HTTPURLResponse) throws -> (Self, HTTPURLResponse)
}

public extension Response {
    public static func intercept(data: Data, urlResponse: HTTPURLResponse) throws -> (Data, HTTPURLResponse) {
        guard 200..<300 ~= urlResponse.statusCode else {
            throw ResponseError.unacceptableStatusCode(urlResponse.statusCode)
        }
        return (data, urlResponse)
    }
    
    public static func intercept(parsed: Parser.Parsed, urlResponse: HTTPURLResponse) throws -> (Parser.Parsed, HTTPURLResponse) {
        return (parsed, urlResponse)
    }
    
    public static func intercept(instance: Self, urlResponse: HTTPURLResponse) throws -> (Self, HTTPURLResponse) {
        return (instance, urlResponse)
    }
}