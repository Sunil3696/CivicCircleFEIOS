//
//  APIClient.swift
//  CivicCircleApp
//
//  Created by Sunil Balami on 2024-12-01.
//
import Foundation
import UIKit

class APIClient {
    static let shared = APIClient() // Singleton instance
    public let baseURL = "http://10.0.0.185:3000/api/" // Backend URL
    private init() {}
    // Login API Call
    func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)auth/login") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        // Request body
        let body: [String: Any] = ["email": email, "password": password]
        let jsonData = try? JSONSerialization.data(withJSONObject: body)

        // Configure request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        // Network call
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(NSError(domain: "Network Error", code: 0, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Response Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "No response from server"])))
                return
            }

            if httpResponse.statusCode == 400 || httpResponse.statusCode == 401 {
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorMessage = json["error"] as? String {
                    completion(.failure(NSError(domain: "Invalid Credentials", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                } else {
                    completion(.failure(NSError(domain: "Invalid Credentials", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials. Please try again."])))
                }
                return
            }

            if httpResponse.statusCode != 200 {
                completion(.failure(NSError(domain: "Unexpected Error", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected error occurred. Please try again later."])))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "Response Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])))
                return
            }

            // Parse response
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let token = json["token"] as? String {
                UserDefaults.standard.set(token, forKey: "authToken") // Save token locally
                completion(.success(()))
            } else {
                completion(.failure(NSError(domain: "Response Parsing Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response from server"])))
            }
        }.resume()
    }

    func register(fullName: String, email: String, password: String, phone: String, address: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)auth/register") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        // Request body
        let body: [String: Any] = [
            "fullName": fullName,
            "email": email,
            "password": password,
            "phone": phone,
            "address": address
        ]
    
        let jsonData = try? JSONSerialization.data(withJSONObject: body)
print(body)
        // Configure request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        // Network call
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(NSError(domain: "Network Error", code: 0, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Response Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "No response from server"])))
                return
            }

            if httpResponse.statusCode != 201 {
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorMessage = json["error"] as? String {
                    completion(.failure(NSError(domain: "Registration Error", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                } else {
                    completion(.failure(NSError(domain: "Unexpected Error", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to register."])))
                }
                return
            }

            completion(.success(()))
        }.resume()
    }
    
    
    func requestPasswordReset(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)auth/request-reset") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        let body: [String: Any] = ["email": email]
        let jsonData = try? JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "Invalid Response", code: 0, userInfo: nil)))
                return
            }

            completion(.success(()))
        }.resume()
    }

    
    
    func verifyOTP(email: String, otp: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)auth/validate-otp") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        let body: [String: Any] = ["email": email, "otp": otp]
        let jsonData = try? JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "Invalid Response", code: 0, userInfo: nil)))
                return
            }

            completion(.success(()))
        }.resume()
    }
   
    
    func getBaseURL() -> String {
            return baseURL
        }

    func fetchForums(completion: @escaping (Result<[Forum], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)forums") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
//                print("❌ Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
//                print("📥 HTTP Status Code: \(httpResponse.statusCode)")
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            // Debugging raw JSON response
            if let jsonString = String(data: data, encoding: .utf8) {
//                print("📥 Raw Response Data: \(jsonString)")
            }

            do {
                let forums = try JSONDecoder().decode([Forum].self, from: data)
//                print("✅ Decoded Forums: \(forums)")
                completion(.success(forums))
            } catch {
//                print("❌ Decoding error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }


    // Create forum post with optional image
    
    
    func createForumPost(title: String, content: String, image: UIImage?, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)forums") else {
            print("❌ Invalid URL")
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("\(UserDefaults.standard.string(forKey: "authToken") ?? "")", forHTTPHeaderField: "Authorization")

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"title\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(title)\r\n".data(using: .utf8)!)

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"content\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(content)\r\n".data(using: .utf8)!)

        if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"images\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        // Debugging logs
        print("📤 Sending request to: \(url)")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        print("Body: \(String(data: body, encoding: .utf8) ?? "Unable to parse body")")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📥 HTTP Status Code: \(httpResponse.statusCode)")
            }

            if let data = data {
                print("📥 Response Data: \(String(data: data, encoding: .utf8) ?? "No response body")")
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                completion(.failure(NSError(domain: "Server Error", code: 0, userInfo: nil)))
                return
            }

            completion(.success(()))
        }.resume()
    }

    
    
    func fetchForumById(id: String, completion: @escaping (Result<Forum, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)forums/\(id)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                  let data = data else {
                completion(.failure(NSError(domain: "Invalid Response", code: 0, userInfo: nil)))
                return
            }

            do {
                let forum = try JSONDecoder().decode(Forum.self, from: data)
                completion(.success(forum))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    
    func likeForumPost(postId: String, completion: @escaping (Result<Int, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)forums/\(postId)/like") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("\(token)", forHTTPHeaderField: "Authorization")
        }

        // Empty body as the backend does not require any specific payload
        request.httpBody = try? JSONSerialization.data(withJSONObject: [:])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid Response", code: 0, userInfo: nil)))
                return
            }

            // Debugging HTTP response
            print("📥 HTTP Status Code: \(httpResponse.statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
            }

            if httpResponse.statusCode == 200 {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any], let likes = json["likes"] as? Int {
                        completion(.success(likes))
                    } else {
                        completion(.failure(NSError(domain: "Invalid Data", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response data"])))
                    }
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(NSError(domain: "Server Error", code: httpResponse.statusCode, userInfo: nil)))
            }
        }.resume()
    }

    
    func addCommentToForum(postId: String, body: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)forums/\(postId)/comment") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("\(token)", forHTTPHeaderField: "Authorization")
        }

        
       
        let bodyData = ["text": body]
        let jsonData = try? JSONSerialization.data(withJSONObject: bodyData)

        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "Invalid Response", code: 0, userInfo: nil)))
                return
            }

            completion(.success(()))
        }.resume()
    }



    
   }

extension APIClient {
    func fetchEvents(completion: @escaping (Result<[Event], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)events") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }

            do {
                let events = try JSONDecoder().decode([Event].self, from: data)
                completion(.success(events))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchEventById(id: String, completion: @escaping (Result<Event, Error>) -> Void) {
            guard let url = URL(string: "\(baseURL)events/\(id)") else {
                completion(.failure(NSError(domain: "Invalid URL", code: 0)))
                return
            }

            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "No data", code: 0)))
                    return
                }

                do {
                    let event = try JSONDecoder().decode(Event.self, from: data)
                    completion(.success(event))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }

    func likeEvent(eventId: String, completion: @escaping (Result<Int, APIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)events/\(eventId)/like") else {
            completion(.failure(.invalidResponse))
            return
        }

        var request = URLRequest(url: url)
        print("📤 Sending request to: \(url)")
        request.httpMethod = "POST"
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("\(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(.networkError(error.localizedDescription)))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                print("❌ Invalid response or status code")
                DispatchQueue.main.async {
                    completion(.failure(.unexpectedStatusCode))
                }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let updatedLikes = json["likes"] as? Int {
                    print("✅ Successfully updated likes: \(updatedLikes)")
                    DispatchQueue.main.async {
                        completion(.success(updatedLikes))
                    }
                } else {
                    print("❌ Invalid data in response")
                    DispatchQueue.main.async {
                        completion(.failure(.invalidResponse))
                    }
                }
            } catch {
                print("❌ JSON decoding error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse))
                }
            }
        }.resume()
    }



    func joinEvent(eventId: String, completion: @escaping (Result<Void, APIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)events/\(eventId)/join") else {
            print("❌ Invalid URL: \(baseURL)events/\(eventId)/join")
            completion(.failure(.invalidResponse))
            return
        }
        var request = URLRequest(url: url)
        print("📤 Request URL: \(url)")
        request.httpMethod = "POST"
        
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            print("📥 Authorization Token: \(token)")
            request.setValue("\(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("❌ No auth token found in UserDefaults")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(.networkError(error.localizedDescription)))
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📥 HTTP Status Code: \(httpResponse.statusCode)")
            } else {
                print("❌ Failed to cast response to HTTPURLResponse")
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse))
                }
                return
            }

            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("📥 Response Data: \(responseString)")
            } else {
                print("❌ No response data received")
            }

            if httpResponse.statusCode == 400 {
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorMessage = json["error"] as? String {
                    print("❌ Server Error Message: \(errorMessage)")
                    DispatchQueue.main.async {
                        completion(.failure(.networkError(errorMessage)))
                    }
                } else {
                    print("❌ Unexpected Status Code: \(httpResponse.statusCode)")
                    DispatchQueue.main.async {
                        completion(.failure(.unexpectedStatusCode))
                    }
                }
                return
            }

            if httpResponse.statusCode == 200 {
                print("✅ Successfully joined the event")
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } else {
                print("❌ Unexpected Status Code: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    completion(.failure(.unexpectedStatusCode))
                }
            }
        }.resume()
    }

    
 
        func cancelParticipation(eventId: String, completion: @escaping (Result<Void, APIError>) -> Void) {
            guard let url = URL(string: "\(baseURL)events/\(eventId)/cancel") else {
                completion(.failure(.invalidResponse))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            if let token = UserDefaults.standard.string(forKey: "authToken") {
                request.setValue("\(token)", forHTTPHeaderField: "Authorization")
            }

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(.networkError(error.localizedDescription)))
                    }
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    DispatchQueue.main.async {
                        completion(.failure(.invalidResponse))
                    }
                    return
                }

                if httpResponse.statusCode == 400 {
                    if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let errorMessage = json["error"] as? String {
                        DispatchQueue.main.async {
                            completion(.failure(.networkError(errorMessage)))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure(.unexpectedStatusCode))
                        }
                    }
                    return
                }

                if httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(.unexpectedStatusCode))
                    }
                }
            }.resume()
        }
    


        
}


    


extension APIClient {
    func fetchUserEvents(completion: @escaping (Result<[UserEvent], APIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)events/myEvents") else {
            print("❌ Invalid URL: \(baseURL)events/myEvents")
            completion(.failure(.invalidResponse))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("\(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("❌ Missing auth token")
        }
        
        print("📤 Fetching user events with URL: \(url)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                completion(.failure(.networkError(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response from server")
                completion(.failure(.invalidResponse))
                return
            }
            
            print("📥 HTTP Status Code: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode != 200 {
                print("❌ Unexpected status code: \(httpResponse.statusCode)")
                completion(.failure(.unexpectedStatusCode))
                return
            }
            
            guard let data = data else {
                print("❌ No data received from server")
                completion(.failure(.invalidResponse))
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Response Data: \(responseString)")
            } else {
                print("❌ Unable to parse response data")
            }
            
            do {
                let events = try JSONDecoder().decode([UserEvent].self, from: data)
                print("✅ Decoded user events: \(events)")
                completion(.success(events))
            } catch {
                print("❌ Decoding error: \(error.localizedDescription)")
                completion(.failure(.unknownError))
            }
        }.resume()
    }
    
    func deleteEvent(eventId: String, completion: @escaping (Result<Void, APIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)events/\(eventId)") else {
            print("❌ Invalid URL: \(baseURL)events/\(eventId)")
            completion(.failure(.invalidResponse))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("\(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("❌ Missing auth token")
        }
        
        print("📤 Deleting event with ID: \(eventId) using URL: \(url)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                completion(.failure(.networkError(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response from server")
                completion(.failure(.invalidResponse))
                return
            }
            
            print("📥 HTTP Status Code: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode != 200 {
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("❌ Error Response: \(responseString)")
                }
                completion(.failure(.unexpectedStatusCode))
                return
            }
            
            print("✅ Event with ID \(eventId) deleted successfully")
            completion(.success(()))
        }.resume()
    }
    
    
    func fetchUserInfo(completion: @escaping (Result<User, APIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)auth/me") else {
            print("❌ Invalid URL: \(baseURL)auth/me")
            completion(.failure(.invalidResponse))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("\(token)", forHTTPHeaderField: "Authorization")
            print("📥 Authorization Token: \(token)")
        } else {
            print("❌ No auth token found in UserDefaults")
        }
        
        print("📤 Fetching user info with URL: \(url)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(.networkError(error.localizedDescription)))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Failed to cast response to HTTPURLResponse")
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse))
                }
                return
            }
            
            print("📥 HTTP Status Code: \(httpResponse.statusCode)")
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("📥 Response Data: \(responseString)")
            } else {
                print("❌ No response data received")
            }
            
            guard let data = data, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse))
                }
                return
            }
            
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                print("✅ Successfully decoded user: \(user)")
                DispatchQueue.main.async {
                    completion(.success(user))
                }
            } catch {
                print("❌ JSON decoding error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(.unknownError))
                }
            }
        }.resume()
    }
    
    func createEventWithImage(eventDetails: EventDetails, image: UIImage, completion: @escaping (Result<Void, APIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)events") else {
            print("❌ Invalid URL: \(baseURL)events")
            completion(.failure(.invalidResponse))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            print("📥 Using Auth Token: \(token)")
            request.setValue("\(token)", forHTTPHeaderField: "Authorization")
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // Add text fields
        let fields = [
            "title": eventDetails.title,
            "description": eventDetails.description,
            "contactNumber": eventDetails.contactNumber,
            "venue": eventDetails.venue,
            "eventDateFrom": ISO8601DateFormatter().string(from: eventDetails.eventDateFrom),
            "eventDateTo": ISO8601DateFormatter().string(from: eventDetails.eventDateTo),
            "totalParticipantsRangeMin": "\(eventDetails.totalParticipantsRangeMin)",
            "totalParticipantsRangeMax": "\(eventDetails.totalParticipantsRangeMax)",
            "eventFee": eventDetails.eventFee
        ]

        print("📤 Event Fields: \(fields)")

        for (key, value) in fields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        // Add image
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"images\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
            print("📤 Image Data Added")
        } else {
            print("❌ Failed to compress image")
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        print("📤 Sending Request to: \(url)")
        print("📤 Request Headers: \(request.allHTTPHeaderFields ?? [:])")
        print("📤 Request Body Size: \(body.count) bytes")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network Error: \(error.localizedDescription)")
                completion(.failure(.networkError(error.localizedDescription)))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📥 HTTP Status Code: \(httpResponse.statusCode)")
            }

            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("📥 Response Data: \(responseString)")
            } else {
                print("❌ No Response Data")
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                print("❌ Unexpected Status Code")
                completion(.failure(.unexpectedStatusCode))
                return
            }

            print("✅ Event Created Successfully")
            completion(.success(()))
        }.resume()
    }

    
    
    func updateEvent(eventId: String, eventDetails: EventDetails, image: UIImage?, completion: @escaping (Result<Void, APIError>) -> Void) {
           guard let url = URL(string: "\(baseURL)events/\(eventId)") else {
               completion(.failure(.invalidResponse))
               return
           }

           var request = URLRequest(url: url)
           request.httpMethod = "PUT"
           if let token = UserDefaults.standard.string(forKey: "authToken") {
               request.setValue("\(token)", forHTTPHeaderField: "Authorization")
           }

           let boundary = "Boundary-\(UUID().uuidString)"
           request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

           var body = Data()

           // Add text fields
           let fields = [
               "title": eventDetails.title,
               "description": eventDetails.description,
               "contactNumber": eventDetails.contactNumber,
               "venue": eventDetails.venue,
               "eventDateFrom": ISO8601DateFormatter().string(from: eventDetails.eventDateFrom),
               "eventDateTo": ISO8601DateFormatter().string(from: eventDetails.eventDateTo),
               "totalParticipantsRangeMin": "\(eventDetails.totalParticipantsRangeMin)",
               "totalParticipantsRangeMax": "\(eventDetails.totalParticipantsRangeMax)",
               "eventFee": eventDetails.eventFee
           ]

           for (key, value) in fields {
               body.append("--\(boundary)\r\n".data(using: .utf8)!)
               body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
               body.append("\(value)\r\n".data(using: .utf8)!)
           }

           // Add image if available
           if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
               body.append("--\(boundary)\r\n".data(using: .utf8)!)
               body.append("Content-Disposition: form-data; name=\"images\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
               body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
               body.append(imageData)
               body.append("\r\n".data(using: .utf8)!)
           }

           body.append("--\(boundary)--\r\n".data(using: .utf8)!)
           request.httpBody = body

           URLSession.shared.dataTask(with: request) { data, response, error in
               if let error = error {
                   completion(.failure(.networkError(error.localizedDescription)))
                   return
               }

               guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                   completion(.failure(.unexpectedStatusCode))
                   return
               }

               completion(.success(()))
           }.resume()
       }
    
    func fetchNotifications(completion: @escaping (Result<[Notification], APIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)notification/user") else {
            print("❌ Invalid URL for notifications endpoint")
            completion(.failure(.invalidResponse))
            return
        }

        print("📤 Fetching notifications from URL: \(url)")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("\(token)", forHTTPHeaderField: "Authorization")
            print("🔑 Authorization token set: \(token.prefix(10))...") // Obfuscating token for security
        } else {
            print("❌ No auth token found in UserDefaults")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error while fetching notifications: \(error.localizedDescription)")
                completion(.failure(.networkError(error.localizedDescription)))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📥 HTTP Status Code: \(httpResponse.statusCode)")
            } else {
                print("❌ Failed to get HTTP response")
            }

            guard let data = data else {
                print("❌ No data received from notifications endpoint")
                completion(.failure(.invalidResponse))
                return
            }

            do {
                print("📥 Raw response data: \(String(data: data, encoding: .utf8) ?? "Unable to parse response")")
                let notifications = try JSONDecoder().decode([Notification].self, from: data)
                print("✅ Successfully decoded \(notifications.count) notifications")
                completion(.success(notifications))
            } catch {
                print("❌ Error decoding notifications: \(error.localizedDescription)")
                completion(.failure(.unknownError))
            }
        }.resume()
    }


}

   struct EventDetails: Codable {
       let title: String
       let description: String
       let contactNumber: String
       let venue: String
       let eventDateFrom: Date
       let eventDateTo: Date
       let totalParticipantsRangeMin: Int
       let totalParticipantsRangeMax: Int
       let eventFee: String
   }
    


