//
//  Buzzer.swift
//  Prana
//
//  Created by Luccas on 3/19/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation
import UIKit

protocol BuzzerDelegate: class {
    func buzzerNewActualRR(actualRR: Double)
    func buzzerNewMindfulBreaths(_ mindfuls: Int, goods: Int, ofTotalBreaths totals: Int)
    func buzzerNewBuzzerReason(_ reason: String)
    func burzzerNewTargetRR(targetRR: Double)
    func buzzerTimeElapsed(_ elapsed: Int)
    func buzzerNewUprightTime(_ uprightTime: Int, ofElapsed elapsed: Int)
    func buzzerNewSlouches(_ slouches: Int)
    func buzzerDidSessionComplete()
}

class Buzzer {
    var totalElapsedTime:Int = 0;  //(in 1/60 of a second, or 1/FPS movie frame rate)
    var breathTime:Int = -1;
    
    var inhalationTimeEnd:Int = 0;
    var retentionTimeEnd:Int = 0;
    var exhalationTimeEnd:Int = 0;
    var timeBetweenBreathsEnd:Int = 0;
    
    var whichPattern:Int = 0;
    var subPattern:Int = 0;
    
    var hasInhaled:Int = 0;
    var hasExhaled:Int = 0;
    var numOfInhales:Int = 0;
    var numOfExhales:Int = 0;
    var whenExhaled:Int = 0;
    var whenInhaled:Int = 0;
    
    var isBuzzing:Int = 0 {
        didSet {
            objLiveGraph.isBuzzing = isBuzzing
        }
    }
    var buzzCount:Int = 0;
    
    var takenFirstBreath:Int = 0;
    
    var buzzReason:Int = 0;
    
    var cycles:Int = 0;
    
    var hasUprightBeenSet:Int = 0;
    var trainingDuration:Int = 0;
    var slouchesCount:Int = 0;
    var uprightPostureTime:Int = 0;
    var mindfulBreathsCount:Int = 0;
    var gameSetTime:Int = 0;
    var prevPostureState:Int = 0;
    var enterFrameCount:Int = 0;
    
    var totalBreaths:Int = 0;
    
    var breathsOnCurrentLevel:Int = 0;
    var goodBreaths:Int = 0;
    
    var useBuzzerForPosture:Int = 1;
    
    var buzzerTrainingForPostureOnly:Int = 1
    
    var timer: Timer?
    
    var objLiveGraph: Live
    
    weak var delegate: BuzzerDelegate?
    
    var maxSubPattern:Int = 8
    
    var isBuzzerTrainingActive:Int = 0; // May 19th, ADDED THIS LINE
    
    var doWarningBuzzesforUnmindful:Int = 0; //JULY 13:New1p   Set this to 0 when on/off switch is off  to not buzz for warning buzzes when unmindful breathing, should be on by default
    
    init(pattern: Int, subPattern subPatt: Int, duration: Int, live: Live) {
        useBuzzerForPosture = 1;
        
        whichPattern = pattern
        subPattern = subPatt
        
        inhalationTimeEnd = Int(Pattern.getPatternValue(value: Pattern.patternSequence[whichPattern][subPattern][0]) * 20.0)
        retentionTimeEnd = inhalationTimeEnd + Int(Pattern.getPatternValue(value: Pattern.patternSequence[whichPattern][subPattern][1]) * 20.0)
        exhalationTimeEnd = retentionTimeEnd + Int(Pattern.getPatternValue(value: Pattern.patternSequence[whichPattern][subPattern][2]) * 20.0)
        timeBetweenBreathsEnd = exhalationTimeEnd + Int(Pattern.getPatternValue(value: Pattern.patternSequence[whichPattern][subPattern][3]) * 20.0)
        
        slouchesCount = 0;
        uprightPostureTime = 0;
        hasUprightBeenSet = 0;
        totalBreaths = 0;
        
        mindfulBreathsCount = 0;
        
        trainingDuration = duration // in second
        gameSetTime = trainingDuration;
        
        objLiveGraph = live
        objLiveGraph.addDelegate(self)
        
    }
    
    deinit {
        objLiveGraph.removeDelegate(self)
    }
    
    func startSession() {
        breathTime = -1;
        totalElapsedTime = 0;
        hasInhaled = 0;
        hasExhaled = 0;
        numOfInhales = 0;
        numOfExhales = 0;
        takenFirstBreath = 0;
        isBuzzing = 0;
        buzzCount = 0;

        isBuzzerTrainingActive = 1; // May 19th, ADDED THIS LINE
        
//        self.timer = Timer.scheduledTimer(timeInterval: 1.0 / 60.0, target: self, selector: #selector(self.enterFrameHandler), userInfo: nil, repeats: true)
    }
    
    func endSession() {
//        self.timer?.invalidate()
        isBuzzerTrainingActive = 0; //May 19th, ADDED THIS LINE
        clearBuzzerTraining();
    }
    
    
    @objc func enterFrameHandler() {
        
//        print("timer \(Date().timeIntervalSince1970)")
        //    buzzerTrainingUI.status.text = String(breathTime) + "  " + String(numOfInhales) +  "  " + String(numOfExhales) + "  " + String(whichPattern) + "  " + String(subPattern) + "  " + String(breathsOnCurrentLevel);
        
        buzzerTimerHandler();
        
            self.delegate?.buzzerNewActualRR(actualRR: self.objLiveGraph.respRate)
        
        totalElapsedTime+=1;
        
        
        if (buzzCount > 0) {
            
            buzzCount-=1;
            
            if (buzzCount == 0) {
                isBuzzing = 0;
                self.objLiveGraph.dampingLevel = 0;
                self.objLiveGraph.postureAttenuatorLevel = 0;
            }
            
        }
        
        breathTime+=1;
        
        if (breathTime < 0) {
            
            if (buzzReason == 1) { //due to bad breathing
                
                if (breathTime == -53) { // May 19th, Changed from -160      so that any guidance buzzing doesn't interfere with bad breath buzzing. Allows any guidance buzzing time to clear first.
                    if (doWarningBuzzesforUnmindful == 1) { //JULY 13:New1p
                        PranaDeviceManager.shared.sendCommand("Buzz,1.2");
                        isBuzzing = 1;
                        buzzCount = 30; //May 19th changed from 90
                    }
                }
            }
                
            else if (buzzReason == 2) { //due to bad posture
                
                if (breathTime == -93) { // May 19th, Changed from -280         so that any guidance buzzing doesn't interfere with bad breath buzzing. Allows any guidance buzzing time to clear first.
                    PranaDeviceManager.shared.sendCommand("Buzz,1");
                    isBuzzing = 1;
                    buzzCount = 63; //May 19th changed from 190
                }
                
                if (breathTime == -63) { //May 19th, Changed from -190        so that any guidance buzzing doesn't interfere with bad breath buzzing. Allows any guidance buzzing time to clear first.
                    PranaDeviceManager.shared.sendCommand("Buzz,1");
                    
                }
            }
            return; // May 19th comment change, if breath was bad, breatTime is set to -30, and needs time to clear bad breath buzzer indicator before proceeding
        }
        
        if (buzzerTrainingForPostureOnly == 1) {
            if (objLiveGraph.postureIsGood == 0 && useBuzzerForPosture == 1)  {   //****** May 7th 2019 changes
                self.delegate?.buzzerNewBuzzerReason("Slouching Posture")
//                buzzerTrainingUI.buzzerReason.text = "Slouching Posture";    //****** May 7th 2019 changes
                badPosture();    //****** May 7th 2019 changes
            }   //****** May 7th 2019 changes
            return;  //****** May 7th 2019 changes
        }   //****** May 7th 2019 changes
        
        if (breathTime >= timeBetweenBreathsEnd) {
            
            cycles+=1;
            breathTime = 0;
            hasInhaled = 0;
            hasExhaled = 0;
            numOfInhales = 0;
            numOfExhales = 0;
            whenInhaled = 0;
            whenExhaled = 0;
            buzzReason = 0;
            
            if (cycles > 2) {
                mindfulBreathsCount+=1;
                
                if (whichPattern == 0) {
                    goodBreaths+=1; //For breath pattern 0, for keeping track of 4 out of 5 good breaths to advance or recede
                }
                self.delegate?.buzzerNewMindfulBreaths(mindfulBreathsCount, goods: goodBreaths, ofTotalBreaths: totalBreaths)
            }
            
            
            if (whichPattern != 0) {
                
                if (Pattern.patternSequence[whichPattern].count > 1) {
                    subPattern+=1;
                    
                    if (subPattern > Pattern.patternSequence[whichPattern].count - 1) {
                        subPattern = 0;
                    }
                }
            }
            
            
            
            
        }
        
        
        
        
        
        /* if (takenFirstBreath == 0 && (self.objLiveGraph.bottomReversalFound == 1 || self.objLiveGraph.breathEnding == 1)) {
         return; //don't start buzzer training until user finishes the breath they were in (if any), same after bad breath
         }
         else {
         takenFirstBreath = 1;
         
         } */
        
        
        if (breathTime == 0) {
            PranaDeviceManager.shared.sendCommand("Buzz,0.10");
            
            inhalationTimeEnd = Int(Pattern.getPatternValue(value: Pattern.patternSequence[whichPattern][subPattern][0]) * 20.0)
            retentionTimeEnd = inhalationTimeEnd + Int(Pattern.getPatternValue(value: Pattern.patternSequence[whichPattern][subPattern][1]) * 20.0)
            exhalationTimeEnd = retentionTimeEnd + Int(Pattern.getPatternValue(value: Pattern.patternSequence[whichPattern][subPattern][2]) * 20.0)
            timeBetweenBreathsEnd = exhalationTimeEnd + Int(Pattern.getPatternValue(value: Pattern.patternSequence[whichPattern][subPattern][3]) * 20.0)
            
            self.delegate?.buzzerNewBuzzerReason("")
            
            self.delegate?.burzzerNewTargetRR(targetRR: roundNumber(num: (3600.0/Double(timeBetweenBreathsEnd))/3.0, dec: 10))
            
            isBuzzing = 1;
            buzzCount = 10; //May 19th changed from 30
            numOfInhales = 0;
            numOfExhales = 0;
            
            if (cycles >= 2) {
                
                totalBreaths+=1;
                
                if (whichPattern == 0) {
                    breathsOnCurrentLevel+=1;
                    
//                    if (breathsOnCurrentLevel == 6) {
//                        breathsOnCurrentLevel = 1;
//                        goodBreaths = 0;
//                    }
                    
                    if (breathsOnCurrentLevel == 6) {
                        if (goodBreaths >= 4) {
                            subPattern+=1;
                            if (subPattern > maxSubPattern) {
                                subPattern = maxSubPattern;
                            }
                        }
                        else {
                            subPattern-=1;
                            if (subPattern < 3) {
                                subPattern = 3; //minimum is 15bmp for buzzer training
                            }
                        }
                        breathsOnCurrentLevel = 1; //JULY 13:NEW1r
                        goodBreaths = 0;     //JULY 13:NEW1r
                    }
                    
                }
                
            }
            
            //buzzerTrainingUI.status0.text = "New Breath Start";
        }
        
        if (breathTime == inhalationTimeEnd) {
            PranaDeviceManager.shared.sendCommand("Buzz,0.10");
            isBuzzing = 1;
            buzzCount = 10; //May 19th changed from 30
            
            
        }
        
        
        if (breathTime == exhalationTimeEnd) {
            PranaDeviceManager.shared.sendCommand("Buzz,0.10");
            isBuzzing = 1;
            buzzCount = 14; //May 19th changed from 40
        }
        
        if (breathTime == exhalationTimeEnd + 6) { // May 19th, Changed from 20 to 6
            PranaDeviceManager.shared.sendCommand("Buzz,0.10");
            
        }
        
        if (cycles < 2) {
            return;
        }
        
        if (self.objLiveGraph.postureIsGood == 0 && useBuzzerForPosture == 1)  {
            self.delegate?.buzzerNewBuzzerReason("Slouching Posture")
            totalBreaths-=1; //necessary to return to previous count if posture was the cause
            breathsOnCurrentLevel-=1; //necessary to return to previous count if posture was the cause
            badPosture();
            return;
        }
        
        if (self.objLiveGraph.bottomReversalFound == 1 && hasInhaled == 0) {
            hasInhaled = 1;
            hasExhaled = 0;
            numOfInhales+=1;
        }
        
        if (self.objLiveGraph.topReversalFound == 1 && hasExhaled == 0) {
            if (numOfInhales > 0) { //idea is that an inhale must have occured first (within the breath window). This helps prevent exhales carrying into the start of a breath after a bad breath.
                hasExhaled = 1;
                hasInhaled = 0;
                numOfExhales+=1;
            }
        }
        
        if (numOfInhales > 1) {
            self.delegate?.buzzerNewBuzzerReason("Multiple inhales")
            //buzzerTrainingUI.status0.text = "numOfInhales > 1";
            badBreath();
            return;
        }
        
        if (breathTime >= inhalationTimeEnd) {
            if (numOfInhales == 0) {
                self.delegate?.buzzerNewBuzzerReason("Inhalation late")
                //buzzerTrainingUI.status0.text = "No inhale by inhalationTimeEnd";
                badBreath();
                return;
            }
        }
        
        if (breathTime < retentionTimeEnd) {
            if (numOfExhales > 0) {
                self.delegate?.buzzerNewBuzzerReason("Exhalation early")
                //buzzerTrainingUI.status0.text = "Exhalation before retentionTimeEnd";
                badBreath();
                return;
            }
        }
        
        if (breathTime >= exhalationTimeEnd) {
            if (numOfExhales == 0) {
                self.delegate?.buzzerNewBuzzerReason("Exhalation late")
                //buzzerTrainingUI.status0.text = "No exhalation by exhalationTimeEnd";
                badBreath();
                return;
            }
        }
        
        
    }
    
    func buzzerTimerHandler() {
        
        enterFrameCount+=1;
        
        if (enterFrameCount < 20) {  // May 19th, changed to 20
            return;
        }
        
        enterFrameCount = 0;
        
        trainingDuration-=1;
        
        self.delegate?.buzzerTimeElapsed(trainingDuration)
        
        
        if (self.objLiveGraph.postureIsGood == 1) {
            uprightPostureTime+=1;
        }
        
        if (prevPostureState == 1) {
            if (self.objLiveGraph.postureIsGood == 0) {
                slouchesCount+=1;
                self.delegate?.buzzerNewSlouches(slouchesCount)
            }
        }

        self.delegate?.buzzerNewUprightTime(uprightPostureTime, ofElapsed: gameSetTime - trainingDuration)
        
        prevPostureState = self.objLiveGraph.postureIsGood;
        
        
        
        if (trainingDuration == 0) {
            
            self.delegate?.buzzerDidSessionComplete()
            
            clearBuzzerTraining();
            PranaDeviceManager.shared.sendCommand("Buzz,2.5")
        }
        
    }
    
    func badBreath() {
        
        breathTime = -60;  //May 19th Changed to -60 from -180
        hasInhaled = 0;
        hasExhaled = 0;
        numOfInhales = 0;
        numOfExhales = 0;
        takenFirstBreath = 0;
        whenInhaled = 0;
        whenExhaled = 0;
        buzzReason = 1;
        self.delegate?.buzzerNewMindfulBreaths(mindfulBreathsCount, goods: goodBreaths, ofTotalBreaths: totalBreaths)
        //    buzzerTrainingUI.mindfulBreaths.text = String(mindfulBreathsCount) + " of " + String(totalBreaths);
        
    }
    
    func badPosture() {
        
        breathTime = -100;  //May 19th Changed to -100 from -300
        hasInhaled = 0;
        hasExhaled = 0;
        numOfInhales = 0;
        numOfExhales = 0;
        takenFirstBreath = 0;
        whenInhaled = 0;
        whenExhaled = 0;
        buzzReason = 2;
        
    }
    
    func clearBuzzerTraining()  {
        
        isBuzzing = 0;
        buzzCount = 0;
        cycles = 0;
        buzzReason = 0;
        prevPostureState = 0;
        breathsOnCurrentLevel = 0;
        goodBreaths = 0;
        
    }
    
    func roundNumber(num:Double, dec:Double) -> Double {
        return round(num*dec)/dec
    }
}

extension Buzzer: LiveDelegate {
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
        guard self.isBuzzerTrainingActive == 1 else {
            return
        }
        self.enterFrameHandler()
    }
    
    
}
