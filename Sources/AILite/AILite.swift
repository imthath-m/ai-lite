public struct AILite {
    public private(set) var text = "Hello, World!"

    public init() {
    }
}

import Foundation

/// Use NetworkUploaderDelegate to stream the progress and get the percentage of file uploaded
public class MIEventHandler: NSObject, URLSessionDataDelegate {
  let request: URLRequest
  var dataHandler: ((Data) -> Void)?

  public init(request: URLRequest) {
    self.request = request
  }

  lazy public var session: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: .main)

  public func observe(dataChange: @escaping (Data) -> Void) {
    session.dataTask(with: request).resume()
    self.dataHandler = dataChange
  }

  public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    dataHandler?(data)
  }
}
