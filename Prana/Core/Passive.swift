//
//  Passive.swift
//  Prana
//
//  Created by Guru on 6/7/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation

protocol PassiveDelegate {
    func passiveDidRespRate(currentRR: Double, avgRR: Double, breathCount: Int)
    func passiveDidEI(realtimeEI: Double, avgEI: Double)
    func passiveDidCalculateOneMinuteEI(lastEI: Double)
    func passiveUprightTime(seconds: Int)
    func passiveSlouches(slouches: Int)
    func passiveTimeElapsed(elapsed: Int)
}

class Passive {
    //var isBuzzing:Int = 0; May 19th  REMOVE (we are now using isBuzzing in BuzzerTraining class as a global variable)
    var buzzCount:Int = 0;
    var hasUprightBeenSet:Int = 0;
    var trainingDuration:Int = 0;
    var slouchesCount:Int = 0;
    var uprightPostureTime:Int = 0;
    var gameSetTime:Int = 0;
    var prevPostureState:Int = 0;
    var enterFrameCount:Int = 0;
    var totalBreaths:Int = 0;
    var useBuzzerForPosture:Int = 1;
    var isPassiveTrackingActive:Int = 0;  // May 19th, ADDED THIS LINE
    var currentSlouchPostureTime:Int = 0; // May 31st ADDED THIS LINE
    var buzzTimeTrigger:Int = 0;  // May 31st ADDED THIS LINE
    var secondsElapsed:Int = 0; // May 31st ADDED THIS LINE
    
    var isBuzzing:Int = 0 {
        didSet {
            objLiveGraph.isBuzzing = isBuzzing
        }
    }
    
    var objLiveGraph: Live
    var delegate: PassiveDelegate?
    
    init(live: Live) {
        currentSlouchPostureTime = 0; //***May 31st ADDED
        secondsElapsed = 0; //***May 31st ADDED
        
        useBuzzerForPosture = 1;
        
        buzzTimeTrigger = 5; // May 31st ADDED THIS LINE
        
        slouchesCount = 0;
        uprightPostureTime = 0;
        hasUprightBeenSet = 0;
        totalBreaths = 0;
        
        trainingDuration = 0
        gameSetTime = trainingDuration;
        
        objLiveGraph = live
        objLiveGraph.addDelegate(self)
    }
    
    deinit {
        objLiveGraph.removeDelegate(self)
    }
    
    func start() {
        isBuzzing = 0
        
        buzzCount = 0;
        //addEventListener(Event.ENTER_FRAME, enterFrameHandler);  // May 19th, REMOVED THIS LINE
        isPassiveTrackingActive = 1; // May 19th, ADDED THIS LINE
        
//        objLiveGraph.whenBreathsEnd = [];
//        objLiveGraph.whenBreathsEnd.append(0);
        objLiveGraph.breathCount = 0;
        objLiveGraph.timeElapsed = 0;
        objLiveGraph.respRate = 0;
        objLiveGraph.avgRespRate = 0;
    }
    
    func stop() {
        isPassiveTrackingActive = 0; // May 19th, ADDED THIS LINE
        
        isBuzzing = 0; //May 19th Changed
        buzzCount = 0;
        prevPostureState = 0;
    }

    //function enterFrameHandler(e:Event):void {   May 19th, REMOVED THIS LINE
    func passiveTrackingMainLoop() { //May 19th, ADDED THIS LINE
    
        
        self.delegate?.passiveDidRespRate(currentRR: objLiveGraph.respRate, avgRR: objLiveGraph.avgRespRate, breathCount: objLiveGraph.breathCount)
        
        timerHandler();
        
        if (buzzCount > 0) {
            
            buzzCount-=1;
            
            //if (buzzCount == 0) { //May 19th REMOVED
            //DC.objBuzzerTraining.isBuzzing = 0; May 19th REMOVED
            //DC.objLiveGraph.dampingLevel = 0;  May 19th REMOVED
            //DC.objLiveGraph.postureAttenuatorLevel = 0;  May 19th REMOVED
            //}
            
        }
        
        
        if (buzzCount == 0 && objLiveGraph.postureIsGood == 0 && useBuzzerForPosture == 1 && isBuzzing == 0 && currentSlouchPostureTime >= buzzTimeTrigger)  { //May 31st Changed
            
            PranaDeviceManager.shared.sendCommand("Buzz,1"); //May 19th Changed
            isBuzzing = 1; //May 19th Changed
            buzzCount = 150; //May 19th Change
        }
        
        if (buzzCount == 120) { //May 19th ADDED LINE
            
            PranaDeviceManager.shared.sendCommand("Buzz,1"); //May 19th ADDED LINE
            
        } //May 19th ADDED LINE
        
        if (buzzCount == 90) { //May 19th ADDED LINE
            isBuzzing = 0; //May 19th ADDED LINE
            objLiveGraph.dampingLevel = 0; //May 19th ADDED LINE
            objLiveGraph.postureAttenuatorLevel = 0; //May 19th ADDED LINE
        } //May 19th ADDED LINE
    
    }
    
    func timerHandler() {
        
        enterFrameCount+=1;
        
        if (enterFrameCount < 20) {  //May 19th, changed from 60 to 20
            return;
        }
        
        enterFrameCount = 0;
        
        if (objLiveGraph.EIRatio.count > 0) {  //May 31st ADDED
            let realEI = objLiveGraph.EIRatio[objLiveGraph.EIRatio.count-1]["ratio"] as! Double
            let avgEI = roundNumber(num: objLiveGraph.EIAvgSessionRatio/Double(objLiveGraph.EIRatio.count), dec: 10)
            self.delegate?.passiveDidEI(realtimeEI: realEI, avgEI: avgEI)
        }
        
        secondsElapsed+=1;  //May 31st ADDED
        
        if (secondsElapsed >= 60) {  //May 31st ADDED
            secondsElapsed = 0;  //May 31st ADDED
            self.delegate?.passiveDidCalculateOneMinuteEI(lastEI: objLiveGraph.calculateOneMinuteEI())
        } //May 31st ADDED
        
        
        trainingDuration+=1;
        
        self.delegate?.passiveTimeElapsed(elapsed: trainingDuration)
        
        
        if (objLiveGraph.postureIsGood == 1) {
            uprightPostureTime+=1;
            currentSlouchPostureTime = 0; // May 31st ADDED THIS
        }
        else {  // May 31st ADDED THIS
            currentSlouchPostureTime+=1;  // May 31st ADDED THIS
        }  // May 31st ADDED THIS
        
        
        if (prevPostureState == 1) {
            if (objLiveGraph.postureIsGood == 0) {
                slouchesCount+=1;
            }
        }
        
        self.delegate?.passiveUprightTime(seconds: uprightPostureTime)
        self.delegate?.passiveSlouches(slouches: slouchesCount)
        
        prevPostureState = objLiveGraph.postureIsGood;
        
        
        
    }
    
    func roundNumber(num:Double, dec:Double) -> Double {
        return round(num*dec)/dec
    }
}

extension Passive: LiveDelegate {
    func liveNewBreathingCalculated() {
        
    }
    
    func liveNewPostureCalculated() {
        
    }
    
    func liveNewRespRateCaclculated() {
        
    }
    
    func liveDidUprightSet() {
        
    }
    
    func liveDebug(para1: String, para2: String, para3: String, para4: String) {
        
    }
    
    func liveProcess(sensorData: [Double]) {
        guard self.isPassiveTrackingActive == 1 else {
            return
        }
        self.passiveTrackingMainLoop()
    }
}
