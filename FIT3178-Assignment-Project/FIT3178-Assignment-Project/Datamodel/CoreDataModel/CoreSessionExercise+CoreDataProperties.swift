//
//  CoreSessionExercise+CoreDataProperties.swift
//  FIT3178-Assignment-Project
//
//  Created by Jared Tucker on 6/6/2023.
//
//

import Foundation
import CoreData


extension CoreSessionExercise {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreSessionExercise> {
        return NSFetchRequest<CoreSessionExercise>(entityName: "CoreSessionExercise")
    }

    @NSManaged public var sets: Int16
    @NSManaged public var exercise: CoreExercise?
    @NSManaged public var performance: NSSet?
    @NSManaged public var session: CoreSession?

}

// MARK: Generated accessors for performance
extension CoreSessionExercise {

    @objc(addPerformanceObject:)
    @NSManaged public func addToPerformance(_ value: CoreSetRepWeight)

    @objc(removePerformanceObject:)
    @NSManaged public func removeFromPerformance(_ value: CoreSetRepWeight)

    @objc(addPerformance:)
    @NSManaged public func addToPerformance(_ values: NSSet)

    @objc(removePerformance:)
    @NSManaged public func removeFromPerformance(_ values: NSSet)

}

extension CoreSessionExercise : Identifiable {

}
