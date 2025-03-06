//
//  IsFirstLaunchEntity.swift
//  Bankbook Saver
//
//  Created by 정근호 on 3/5/25.
//

import Foundation
import RealmSwift

class IsFirstLaunchEntity: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var isFirstLaunch: Bool
}
