//
//  CoreSetRepWeight+CoreDataProperties.swift
//  FIT3178-Assignment-Project
//
//  Created by Jared Tucker on 6/6/2023.
//
//

import Foundation
import CoreData


extension CoreSetRepWeight {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreSetRepWeight> {
        return NSFetchRequest<CoreSetRepWeight>(entityName: "CoreSetRepWeight")
    }

    @NSManaged public var rep: Int16
    @NSManaged public var weight: Int16
    @NSManaged public var restTime: Int16
    @NSManaged public var sessionExercise: CoreSessionExercise?

}

extension CoreSetRepWeight : Identifiable {

}
