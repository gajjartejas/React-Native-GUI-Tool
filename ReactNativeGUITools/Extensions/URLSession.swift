//
//  URLSession.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 11/05/24.
//

import Foundation

extension URLSession {
    func get(_ url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        let task = dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200 ... 299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let errorDescription = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                let error = NSError(domain: "HTTP", code: -1, userInfo: [NSLocalizedDescriptionKey: errorDescription])
                completion(.failure(error))
                return
            }

            if let data = data {
                completion(.success(data))
            } else {
                let error = NSError(domain: "Data", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
