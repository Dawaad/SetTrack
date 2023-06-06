//
//  CoreExercise+CoreDataProperties.swift
//  FIT3178-Assignment-Project
//
//  Created by Jared Tucker on 6/6/2023.
//
//

import Foundation
import CoreData


extension CoreExercise {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreExercise> {
        return NSFetchRequest<CoreExercise>(entityName: "CoreExercise")
    }

    @NSManaged public var category: String?
    @NSManaged public var difficulty: String?
    @NSManaged public var id: String?
    @NSManaged public var instructions: String?
    @NSManaged public var isCustom: Bool
    @NSManaged public var name: String?
    @NSManaged public var userID: String?
    @NSManaged public var sesssionExercise: CoreSessionExercise?

}

extension CoreExercise : Identifiable {

}
