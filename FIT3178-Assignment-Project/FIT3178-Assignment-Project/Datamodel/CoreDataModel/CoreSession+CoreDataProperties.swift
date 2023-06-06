//
//  CoreSession+CoreDataProperties.swift
//  FIT3178-Assignment-Project
//
//  Created by Jared Tucker on 6/6/2023.
//
//

import Foundation
import CoreData


extension CoreSession {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreSession> {
        return NSFetchRequest<CoreSession>(entityName: "CoreSession")
    }

    @NSManaged public var endDateTime: Date?
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var startDateTime: Date?
    @NSManaged public var userID: String?
    @NSManaged public var routineID: String?
    @NSManaged public var exercises: NSSet?

}

// MARK: Generated accessors for exercises
extension CoreSession {

    @objc(addExercisesObject:)
    @NSManaged public func addToExercises(_ value: CoreSessionExercise)

    @objc(removeExercisesObject:)
    @NSManaged public func removeFromExercises(_ value: CoreSessionExercise)

    @objc(addExercises:)
    @NSManaged public func addToExercises(_ values: NSSet)

    @objc(removeExercises:)
    @NSManaged public func removeFromExercises(_ values: NSSet)

}

extension CoreSession : Identifiable {

}
