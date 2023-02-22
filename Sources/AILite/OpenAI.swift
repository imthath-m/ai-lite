//
// Created by Imthathullah on 22/02/23.
//

import Foundation
import MINetworkKit

public actor OpenAI: MINetworkable {
  public let decoder: JSONDecoder = {
    let decoder: JSONDecoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()

  public init(apiKey: String) {
    Request.apiKey = apiKey
  }
}

public extension OpenAI {
  /// Completes a given prompt using a specified model, with an optional word limit and creativity score.
  ///
  /// - Parameters:
  ///   - prompt: The prompt to complete.
  ///   - model: The model to use when completing the prompt.
  ///   - wordLimit: The maximum number of words to use when completing the prompt (defaults to 256).
  ///   - creativityScore: A score between 0 and 1 indicating the creativity of the completion (defaults to 0.5).
  /// - Returns: A `Completion` object containing the completed prompt.
  /// - Throws: An error if the completion request fails.
  func complete(prompt: String, using model: Model, wordLimit: Int16 = 256, creativityScore: Double = 0.5) async throws -> Completion {
    let request: OpenAI.Request = try .completionRequest(prompt: prompt, model: model, wordLimit: wordLimit, creativityScore: creativityScore)
    return try await get(from: request)
  }
}

extension OpenAI.Request {
  static var apiKey: String = ""

  static func completionRequest(prompt: String, model: OpenAI.Model, wordLimit: Int16 = 256, creativityScore: Double = 0.5) throws -> OpenAI.Request {
    let dataDictionary: [String: Any] = [
      "model": model.rawValue,
      "prompt": prompt,
      "max_tokens": (wordLimit * 4) / 3, // 1 word is ~0.75 tokens as mentioned in OpenAI docs
      "temperature": creativityScore,
      "top_p": 1,
      "frequency_penalty": 0,
      "presence_penalty": 0
    ]
    let data: Data = try JSONSerialization.data(withJSONObject: dataDictionary, options: [])
    return OpenAI.Request(
      path: .completions,
      method: .post,
      headers: ["Content-Type": "application/json", "Authorization": "Bearer \(Self.apiKey)"],
      body: data
    )
  }
}
