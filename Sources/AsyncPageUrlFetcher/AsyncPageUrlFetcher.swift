// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation

@available(macOS 12.0, *)
struct AsyncPageURLFetcher: AsyncSequence, AsyncIteratorProtocol {
	var urlFn: (Int) -> (URL?) // return nil if you want the fetcher to quit
	var page: Int = 1
	private var isActive: Bool = true
	init(urlFn: @escaping (Int)->URL) {
		self.urlFn = urlFn
	}

	mutating func next() async -> Data? {
		// Once we're inactive always return nil immediately
		if !isActive { return nil }
		guard let url = urlFn(page) else {
			isActive = false
			return nil
		}
		//print(url)
		let session = URLSession(configuration: .ephemeral)
		let result = try? await session.data(from: url)
		if result != nil {
			page = page + 1
			return result!.0
		} else {
			isActive = false
			return nil
		}
	}

	func makeAsyncIterator() -> AsyncPageURLFetcher {
		self
	}


}
