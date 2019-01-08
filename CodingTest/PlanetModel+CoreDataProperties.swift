//
//  PlanetModel+CoreDataProperties.swift
//  CodingTest
//
//  Created by Ashvarya Singh on 08/01/19.
//  Copyright © 2019 Test. All rights reserved.
//
//

import Foundation
import CoreData


extension PlanetModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlanetModel> {
        return NSFetchRequest<PlanetModel>(entityName: "PlanetModel")
    }

    @NSManaged public var nameParam: String?
    @NSManaged public var gravityParam: String?

}
