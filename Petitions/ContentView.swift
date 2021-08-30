//
//  ContentView.swift
//  Petitions
//
//  Created by Emmanuel Ola on 8/2/21.
//

import SwiftUI

extension URLSession {
    func decode<T: Decodable>(
        _ type: T.Type = T.self,
        from url: URL,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
        dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .deferredToData,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate
    ) async throws -> T {
        let (data, _) = try await data(from: url)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = keyDecodingStrategy
        decoder.dataDecodingStrategy = dataDecodingStrategy
        decoder.dateDecodingStrategy = dateDecodingStrategy
        
        let decoded = try decoder.decode(T.self, from: data)
        return decoded
    }
}

struct Petition: Codable, Identifiable {
    let id: String
    let title: String
    let body: String
    let deadline: Date
    let created: Date
    let signatureCount: Int
    let signatureThreshold: Int
    let signaturesNeeded: Int
    
    var progress: Double {
        guard signaturesNeeded != 0 else {
            return Double(signatureCount) / Double(signatureThreshold)
        }
        
        return (Double(signatureCount) / Double(signaturesNeeded))
    }
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }
    
}

struct ContentView: View {
    
    @State private var petitions = [Petition]()
    
    var body: some View {
        
        NavigationView {
            List(petitions) { petition in
                VStack {
                    Text("\(petition.title)").bold()
                    Text(
"""

Created on: \(Petition.dateFormatter.string(from: petition.created))
Deadline: \(Petition.dateFormatter.string(from: petition.deadline))
"""
                    )
                    ProgressView(value:
                                    petition.progress)
                }
            }
            .navigationTitle("Petitions")
            .task {
                do {
                    petitions = try await fetchPetitions()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

func fetchPetitions() async throws -> [Petition] {
    let url = URL(string: "https://www.hackingwithswift.com/samples/petitions.json")!
    return try await URLSession.shared.decode(from: url, dateDecodingStrategy: .secondsSince1970)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
