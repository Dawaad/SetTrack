//
//  LineBarView.swift
//  FIT3178-Assignment-Project
//
//  Created by Jared Tucker on 8/6/2023.
//

import Foundation
import SwiftUI
import Charts

struct sessionPerformance: Identifiable{
    let id = UUID()
    let index: Int
    let performance: Int
}

struct lineBarView: View{
    var data: [sessionPerformance] = [sessionPerformance]()
    init(){
        weak var databaseController: DatabaseProtocol?
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        let routine = databaseController?.statRoutine
        let exercise = databaseController?.statExercise
        
        let performance = databaseController!.retrieveDataForGraph(routine: routine!, exercise: exercise!)
        
        var i = 0
        while i < performance.count{
            data.append(sessionPerformance(index: i, performance: performance[i]))
            i += 1
        }
        
    }
    
    var body: some View{
        Chart(data) { performance in
            LineMark(x: .value("Session Number", performance.index), y: .value("Exercise Volume Average", performance.performance)).foregroundStyle(.red)
            
        }
        Text("")
    }
    
}
