import Foundation

public struct Credits: Codable, Sendable, Equatable {
    public let cast: [CastMember]
    public let crew: [CrewMember]

    public init(cast: [CastMember], crew: [CrewMember]) {
        self.cast = cast
        self.crew = crew
    }
}

public struct CastMember: Codable, Sendable, Equatable, Identifiable {
    public let id: Int
    public let name: String
    public let character: String
    public let profilePath: String?
    public let order: Int

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case character
        case profilePath = "profile_path"
        case order
    }

    public init(id: Int, name: String, character: String, profilePath: String?, order: Int) {
        self.id = id
        self.name = name
        self.character = character
        self.profilePath = profilePath
        self.order = order
    }
}

public struct CrewMember: Codable, Sendable, Equatable, Identifiable {
    public let id: Int
    public let name: String
    public let job: String
    public let department: String
    public let profilePath: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case job
        case department
        case profilePath = "profile_path"
    }

    public init(id: Int, name: String, job: String, department: String, profilePath: String?) {
        self.id = id
        self.name = name
        self.job = job
        self.department = department
        self.profilePath = profilePath
    }
}
