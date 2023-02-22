//
//  File.swift
//  
//
//  Created by Imthathullah on 21/02/23.
//

import Foundation
import MINetworkKit

public extension OpenAI {
  struct Request: MIRequest {
    public var base: String { "https://api.openai.com/v1/" }
    public var urlString: String { base + path.rawValue }

    public let path: Path
    public let method: MINetworkMethod
    public let headers: [String: String]?
    public let params: [String: Any]?
    public let body: Data?

    public init(path: Path, method: MINetworkMethod, headers: [String: String]? = nil, params: [String: Any]? = nil, body: Data? = nil) {
      self.path = path
      self.method = method
      self.headers = headers
      self.params = params
      self.body = body
    }
  }

  enum Model: String, CaseIterable {
    case textDavinci3 = "text-davinci-003" // max 4k tokens
    case codeDavinci2 = "code-davinci-002" // max 8k tokens
  }
}

public extension OpenAI.Request {
  enum Path: String {
    case completions
  }
}

public struct Completion: Codable {
  public let id: String
  public let object: String
  public let created: Date
  public let model: String
  public let choices: [Choice]
  public let usage: Usage

  public struct Choice: Codable {
    public let text: String
    public let index: Int
    public let logprobs: Logprobs?
    public let finishReason: String
  }
}

public struct Usage {
  public let promptTokens: Int
  public let completionTokens: Int
  public let totalTokens: Int
}

extension Completion.Choice {
  public struct Logprobs {
    public let tokens: [String]
    public let tokenLogprobs: [Float]
    public let topLogprobs: [String: Float]
    public let textOffset: [Int]
  }
}

// MARK: Custom Codable

extension Usage: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.promptTokens = try container.decodeIfPresent(Int.self, forKey: .promptTokens) ?? 0
    self.completionTokens = try container.decodeIfPresent(Int.self, forKey: .completionTokens) ?? 0
    self.totalTokens = try container.decodeIfPresent(Int.self, forKey: .totalTokens) ?? 0
  }
}

extension Completion.Choice.Logprobs: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.tokens = try container.decodeIfPresent([String].self, forKey: .tokens) ?? []
    self.tokenLogprobs = try container.decodeIfPresent([Float].self, forKey: .tokenLogprobs) ?? []
    self.topLogprobs = try container.decodeIfPresent([String: Float].self, forKey: .topLogprobs) ?? [:]
    self.textOffset = try container.decodeIfPresent([Int].self, forKey: .textOffset) ?? []
  }
}
