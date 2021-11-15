//
//  Account.swift
//  Calendar
//
//  Created by 杜襄 on 2021/11/10.
//

import Foundation
import RealmSwift

class User: Object {

    @Persisted(primaryKey: true) var _id: String
    @Persisted var teams: List<Team>

    convenience init(userID: String) {
        self.init()
        self._id = userID
        self.teams.append(Team())
    }
}

class Team: EmbeddedObject {

    @Persisted var name: String
    @Persisted var partition: String

    override init() {
        super.init()
        self.name = "default"
        self.partition = UUID().uuidString
    }
}
