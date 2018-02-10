//
//  Entry.swift
//  BulletJournal
//
//  Created by Victor Zhong on 2/9/18.
//  Copyright © 2018 Victor Zhong. All rights reserved.
//

import Foundation

enum EntryType {
    case task, note, event
}

enum EntryState {
    case active, done, crossed
}

struct Entry {
    let id: String
    let date: Date
    let type: EntryType
    let state: EntryState
    let comment: String
    let starred: Bool
}
