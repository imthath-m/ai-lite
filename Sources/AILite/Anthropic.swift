//
//  File.swift
//  
//
//  Created by Imthathullah on 04/06/23.
//

import Foundation
import MINetworkKit

public class Anthropic: MINetworkable {
  public init(apiKey: String) {
    Anthropic.apiKey = apiKey
  }

  struct Request: MIRequest {
    public var urlString: String { "https://api.anthropic.com/v1/complete" }

    public var method: MINetworkKit.MINetworkMethod { .post }

    public var params: [String : Any]? { nil }

    public var headers: [String : String]? { ["Content-Type": "application/json", "X-API-Key" : Anthropic.apiKey] }

    public var body: Data?

    init(messages: [Message], model: Model = .claudeInstantLatest, responseTokenLimit: Int = 5000) throws {
      var prompt: String = ""

      messages.forEach { prompt += $0.sender.rawValue + $0.text }

      let dictionary: [String : Any] = [
        "prompt": prompt,
        "max_tokens_to_sample": responseTokenLimit,
        "model": model.rawValue
      ]

      self.body = try JSONSerialization.data(withJSONObject: dictionary, options: [])
    }
  }

  struct Response: Codable {
    public let completion: String
  }
}

public extension Anthropic {
  static var apiKey: String = ""

  func complete(messages: [Message], model: Model = .claudeInstantLatest, responseTokenLimit: Int = 5000) async throws -> String {
    assert(!Anthropic.apiKey.isEmpty, "Set apiKey before calling complete endpoint")
    let request = try Request(messages: messages, model: model, responseTokenLimit: responseTokenLimit).urlRequest()
    let response: Response = try await get(from: request)
    return response.completion
  }

  enum Model: String {
    case claudeInstantLatest = "claude-instant-v1.1-100k"
  }

  enum Sender: String, Codable {
    case human = "\n\nHuman: "
    case assistant = "\n\nAssitant: "
  }

  struct Message: Codable {
    let sender: Sender
    let text: String

    public init(sender: Sender, text: String) {
      self.sender = sender
      self.text = text
    }
  }
}
