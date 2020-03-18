//
//  Live.swift
//  Prana
//
//  Created by Guru on 9/28/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation

@objc protocol LiveDelegate {
    @objc optional func liveMainLoop(timeElapsed: Double, sensorData: [Double])
    @objc optional func liveUprightHasBeenSet()
    @objc optional func liveNew(graphY: Double)
    @objc optional func liveNew(postureFrame: Int)
    @objc optional func liveNew(oneMinuteRespirationRate: Int)
    @objc optional func liveNew(respirationRate: Double)
    @objc optional func liveNew(sessionAvgRate: Double)
    @objc optional func liveNew(breathCount: Int)
    @objc optional func liveNew(endBreathLineY: Double)
    @objc optional func liveNew(bottomReversalLineY: Double)
}

class Live: NSObject {
    
    let liveQueue = DispatchQueue(label: "liveQueue")
    
    func setPostureResponsiveness(val: Int) {
        liveQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            self.postureSelectorHandler(level: val)
        }
    }
    
    func setBreathingResponsiveness(val: Int) {
        liveQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            self.breathSelectorHandler(level: val)
        }
    }
    
    func setUpright() {
        liveQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            self.learnUprightAngleHandler()
        }
    }
    
    var delegates: [LiveDelegate] = []
    
    func addDelegate(_ delegate: LiveDelegate) {
        delegates.append(delegate)
    }
    
    func removeDelegate(_ delegate: LiveDelegate) {
        guard !delegates.isEmpty else { return }
        var i: Int = 0
        for item in self.delegates {
            let obj1 = delegate as! NSObject
            let obj2 = item as! NSObject
            if obj2.isEqual(obj1) {
                break
            }
            i = i + 1
        }
        self.delegates.remove(at: i)
    }
    
    func stopMode(reset: Bool = false) {
        backButtonHandler()
        PranaDeviceManager.shared.removeDelegate(self)
        delegates.removeAll()
        if reset { resetBreathRange() }
    }
    
    // MARK: New Properties
    static var maxCount = 1800
    var appMode = 0 // DC.appMode
    var isBuzzing = 0 // DC.objBuzzerTraining.isBuzzing
    var calibrationBreathsDone = 0 // DC.objGame.calibrationBreathsDone
    var graphStartTime: Double = 0 // DC.objGame.graphStartTime, DC.objBuzzerTraining.graphStartTime
    
    // MARK: Properties from orignal Action Script
    var count: Int = -1;
    var fullBreathGraphHeight: Double = 400;
    var yStartPos: Double = 500;
    var graphYSeries: [Double] = Array(repeating: 0, count: maxCount + 1);
    var breathSensor: [Double] = Array(repeating: 0, count: maxCount + 1);
    var relativePosturePositionFiltered: [Double] = Array(repeating: 0, count: maxCount + 1);
    var zSensor: [Double] = Array(repeating: 0, count: maxCount + 1);
    var xSensor: [Double] = Array(repeating: 0, count: maxCount + 1);
    var ySensor: [Double] = Array(repeating: 0, count: maxCount + 1);
    var dampHistory: [Double] = Array(repeating: 0, count: maxCount + 1);
    var rotationSensor: [Double] = Array(repeating: 0, count: maxCount + 1);
    var relativeInhaleLevelSG: Double = 0;
    var relativeInhaleLevelRS: Double = 0;
    var bellyBreathHasStarted: Int = 0;
    
    var upStreak: Int = 0;
    var downStreak: Int = 0;
    var upStreakStart: Int = 0;
    var downStreakStart: Int = 0;
    var bottomReversalY: Double = 500;
    var topReversalY: Double = 0;
    var stuckBreaths: Int = 0;
    var endBreathY: Double = 0;
    var bottomReversalFound: Int = 0;
    var topReversalFound: Int = 0;
    //    var scrollX: Int;
    var breathEnding: Int = 0;
    var strainGauge: Double = 1;
    var uprightPostureAngle: Double = 0;
    var uprightSet: Int = 0;
    var currentPostureAngle: [Double] = Array(repeating: 0, count: maxCount + 1);
    
    
    var useRotationSensor: Int = 0;
    var postureRange: Double = 0.18;
    var postureAttenuator: Double = 0.15;
    var smoothBreathingCoef: Double = 1;
    var lightBreathsInARow: Int = 0;
    var deepBreathsInARow: Int = 0;
    
    var noisyMovements: Int = 0;
    var dampingLevel: Int = 0;
    var postureAttenuatorLevel: Int = 0;
    var newStrainGaugeRange: Double = 0;
    var breathTopExceeded: Int = 0;
    
    var strainGaugeMinRange: Double = 0.0005;
    
    //var RRtimer:Timer = new Timer(100);
    var timeElapsed: Double = 0;
    //var whenBreathsEnd:Array = new Array;    //AUG 1st REMOVED
    var respRate: Double = 0;
    var breathCount: Int = 0;
    var stuckBreathsThreshold: Int = 3;  //AUG 1st CHANGED
    var breathTopExceededThreshold: Int = 1;
    var smoothBreathingCoefBaseLevel: Double = 0.40;
    var postureIsGood: Int = 1;
    var minBreathRange: Double = 0;  //***March16Change
    var minBreathRangeForStuck: Double = 0;
    var reversalThreshold: Int = 5; //AUG 1st CHANGED
    var birdIncrements: Int = 20;
    var avgRespRate: Double = 0;
    
    var EIRatio: [[Double]] = []; // May31st ADDED
    var exhaleCorrectionFactor: Double = 0; // May31st ADDED
    var inhaleStartTime: Double = 0; // May31st ADDED
    var inhaleEndTime: Double = 0; // May31st ADDED
    var exhaleEndTime: Double = 0; // May31st ADDED
    var EIAvgSessionRatio: Double = 0; // May31st ADDED
    var EIAvgSessionSummation: Double = 0; //AUG 1st ADDED
    var EIRatioCount: Int = 0; // May31st ADDED
    var EIGoodToMeasure: Int = 0; // May31st ADDED
    var EI1Minute: Double = 0;  //JULY 13th:NEW1b
    var lightBreathsThreshold: Int = 1; //JULY 13th:NEW1i
    
    var whenBreathsStart: [Double] = []; //Aug 1st ADDED
    
    
    var calibrationRR: Double = 0; //AUG 1st ADDED
    var timeElapsedAtCalibrationStart: Double = 0; //AUG 1st ADDED
    var breathCountAtCalibrationStart: Int = 0; //AUG 1st ADDED
    
    var postureLevel: Int = 2;  //AUG 1st ADDED
    var breathLevel: Int = 2;  //AUG 1st ADDED
    
    var enterFrameCount: Int = 0; //AUG 1st NEW
    var inhaleIsValid: Int = 0; //AUG 1st NEW
    var strainGaugeRangePrev: Double = 0.003; //AUG 1st NEW
    
    //    var breathsForGraph:Array = new Array; //AUG 12th NEW
    var actualBreathsWithinAPattern: [CoreBreath] = []; //AUG 12th NEW
    var judgedBreaths: [LiveBreath] = []; //AUG 12th NEW
    var judgedPosture: [LivePosture] = []; //AUG 12th NEW
    
    override init() {
        super.init()
    }
    
    deinit {
        print("Core Live deinit")
    }
    
    func resetCount() {
        
        var resetThreshold:Int = Live.maxCount;
        var resetWindow:Int = 600;
        
        if (count == Live.maxCount) { //***march18
            
            for i in (resetThreshold - resetWindow) ... resetThreshold
            {
                
                xSensor[i - (resetThreshold - resetWindow)] = xSensor[i];
                ySensor[i - (resetThreshold - resetWindow)] = ySensor[i];
                zSensor[i - (resetThreshold - resetWindow)] = zSensor[i];
                currentPostureAngle[i - (resetThreshold - resetWindow)] = currentPostureAngle[i];
                rotationSensor[i - (resetThreshold - resetWindow)] = rotationSensor[i];
                breathSensor[i - (resetThreshold - resetWindow)] = breathSensor[i];
                graphYSeries[i - (resetThreshold - resetWindow)] = graphYSeries[i];
                dampHistory[i - (resetThreshold - resetWindow)] = dampHistory[i];
                relativePosturePositionFiltered[i - (resetThreshold - resetWindow)] = relativePosturePositionFiltered[i];

            }
            
            count = resetWindow;
            downStreakStart = downStreakStart - (resetThreshold - resetWindow);
            upStreakStart = upStreakStart - (resetThreshold - resetWindow);
            if (downStreakStart < 0) {
                downStreakStart = 0;
            }
            if (upStreakStart < 0) {
                upStreakStart = 0;
            }
        }
    }
    
    func roundSensorArrays() {
        xSensor[count] = roundNumber(xSensor[count], 1000000000); //***march18
        ySensor[count] = roundNumber(ySensor[count], 1000000000); //***march18
        zSensor[count] = roundNumber(zSensor[count], 1000000000); //***march18
        rotationSensor[count] = roundNumber(rotationSensor[count], 1000000000); //***march18
        breathSensor[count] = roundNumber(breathSensor[count], 1000000000); //***march18
        currentPostureAngle[count] = roundNumber(currentPostureAngle[count], 1000000000); //***march18
    }
    
    func storeSensorData(_ sensorData: [Double]) {
        let dataArray = sensorData;
        
        count+=1;
        
        resetCount();
        
        if (count < 8) { //JULY 13:Change1m
            
            xSensor[count] = Double(dataArray[3]);
            ySensor[count] = Double(dataArray[2]);
            zSensor[count] = Double(dataArray[4]);
            
            if (xSensor[count] == 0 && ySensor[count] == 0) {
                currentPostureAngle[count] = 2*(asin(zSensor[count])/Double.pi);
            }
            else {
                currentPostureAngle[count] = 2*(atan(zSensor[count]/sqrt(pow(xSensor[count],2)+pow(ySensor[count],2)))/Double.pi);
            }
            
            rotationSensor[count] = -Double(dataArray[5]);
            breathSensor[count] = 2 - Double(dataArray[1]);     //strainGauge = Number(dataArray[4]); Use this version instead if signal INCREASES when inhaling
            
            graphYSeries[count] = yStartPos;
            dampHistory[count] = 1;
            relativePosturePositionFiltered[count] = currentPostureAngle[count];
            currentStrainGaugeLowest = strainGauge;
            currentStrainGaugeHighest = currentStrainGaugeLowest + 0.003;
            currentStrainGaugeHighestPrev = currentStrainGaugeHighest;
            
            
        }
            
        else {
            
            xSensor[count] = 0.50 * Double(dataArray[3]) + (1.0 - 0.50) * xSensor[count-1];
            ySensor[count] = 0.50 * Double(dataArray[2]) + (1.0 - 0.50) * ySensor[count-1];
            zSensor[count] = 0.50 * Double(dataArray[4]) + (1.0 - 0.50) * zSensor[count-1];
            
            if (xSensor[count] == 0 && ySensor[count] == 0) {
                currentPostureAngle[count] = 2*(asin(zSensor[count])/Double.pi);
            }
            else {
                currentPostureAngle[count] = 2*(atan(zSensor[count]/sqrt(pow(xSensor[count],2)+pow(ySensor[count],2)))/Double.pi);
            }
            
            rotationSensor[count] = 0.50 * (-Double(dataArray[5])) + (1.0 - 0.50) * rotationSensor[count-1];
            //breathSensor[count] = 0.5 * (Number(dataArray[1])) + (1.0 - 0.5) * breathSensor[count-1];
            breathSensor[count] = 0.5 * (2 - Double(dataArray[1])) + (1.0 - 0.5) * breathSensor[count-1];
            //breathSensor[count] = 2 - Number(dataArray[4]);     //strainGauge = Number(dataArray[4]); Use this version instead if signal INCREASES when inhaling
            
        }
        
        
        roundSensorArrays(); //***march18
        
        strainGauge = breathSensor[count];
        
        
        if (count == 8) { //JULY 13:Change1m
            
            currentStrainGaugeHighest = currentStrainGaugeLowest + 0.003;
            currentStrainGaugeHighestPrev = currentStrainGaugeHighest;
            
        }
        
        if (count > 6) {
            
            if (abs(rotationSensor[count] - rotationSensor[count-6]) > 0.3) {
                
                useRotationSensor = 1;
                
            }
                
            else {
                
                if (useRotationSensor == 1) {
                    
                    useRotationSensor = 0;
                    //currentStrainGaugeLowest = strainGauge - (((graphYSeries[count-1] - yStartPos)/(-fullBreathGraphHeight)) * (currentStrainGaugeHighest - currentStrainGaugeLowest));
                    
                    //noisyMovements = 0;
                    //dampingLevel = 1; //dampingLevel is usually around 5 when rotating, so when transitioning back to strain gauge, it should be set lower, otherwise graph gets momentarily stuck
                }
                
            }
            
        }
    }
    
    func setSmoothingAndDamping() {
        let dampX = 0.005/abs(xSensor[count] - xSensor[count-3]);
        let dampY = 0.005/abs(ySensor[count] - ySensor[count-3]);
        let dampZ = 0.005/abs(zSensor[count] - zSensor[count-3]);
        
        var damp = min(dampX, dampY, dampZ);
        //damp = 0.005/Math.abs(currentPostureAngle[count] - currentPostureAngle[count-3]);
        
        if (damp > 1) {
            damp = 1;
        }
        
        dampHistory[count] = damp;
        
        if (dampHistory[count] < 0.4) {
            dampingLevel+=1;
        }
            
        else {
            dampingLevel-=1;
        }
        
        if (dampingLevel > 10) {
            dampingLevel = 10;
        }
        else if (dampingLevel < 0) {
            dampingLevel = 0;
        }
        
        if (appMode != 3) {  //Don't set noisyMovements during Buzzer Training, because a noisy movement is almost gauranteed during a breath cycle due to the buzzer occuring at some point (hard to be sure isBuzzing would eliminate that, really need to add a buzzer flag status to the datastream to be sure).
            if (dampingLevel >= 7) {
                noisyMovements = 1;
            }
        }
        
        
        if (topReversalFound == 1) {
            
            smoothBreathingCoef = smoothBreathingCoefBaseLevel;
        }
        else {
            
            smoothBreathingCoef = smoothBreathingCoefBaseLevel - 0.05;
        }
        
        
        if (isBuzzing == 0) {
            
            var a:Double = 0;
            
            if (dampingLevel > 0) {
                
                smoothBreathingCoef = smoothBreathingCoef * Double(truncating: pow(0.80, dampingLevel) as NSNumber);
                
                a = (currentStrainGaugeHighest - currentStrainGaugeLowest)/0.015; //to further dampen when the range is very sensitive
                
                if (a > 0  && a < 1) {
                    smoothBreathingCoef = smoothBreathingCoef * a;
                }
                
            }
            
        }
            
        else if (isBuzzing == 1) { //May 19 ADDED
            
            smoothBreathingCoef = smoothBreathingCoef * 0.5; //May 19 ADDED
            
        } //May 19 ADDED
    }
    
    func setRelativeInhaleLevelStrainGauge() {
        relativeInhaleLevelSG = (strainGauge - currentStrainGaugeLowest) / (currentStrainGaugeHighest - currentStrainGaugeLowest);
        
        
        if (relativeInhaleLevelSG > 1)  {
            
            relativeInhaleLevelSG = 1;
            
            //if (noisyMovements == 0) { //AUG 1st NEW
            currentStrainGaugeHighest = 0.5*strainGauge + (1-0.5)*currentStrainGaugeHighest;
            //} //AUG 1st NEW
            
            if ( (currentStrainGaugeHighest - currentStrainGaugeLowest) < strainGaugeMinRange) {
                currentStrainGaugeHighest = currentStrainGaugeLowest + strainGaugeMinRange;
            }
            
        }
            
        else if (relativeInhaleLevelSG < 0)  {
            
            relativeInhaleLevelSG = 0;
            currentStrainGaugeHighest = (currentStrainGaugeHighest - currentStrainGaugeLowest) + strainGauge; //Since currentStrainGaugeLowest is being set to strainGauge below, this preserves the range but relative to the new floor.
            currentStrainGaugeLowest = strainGauge;
            
            if ( (currentStrainGaugeHighest - currentStrainGaugeLowest) < strainGaugeMinRange) {
                currentStrainGaugeHighest = currentStrainGaugeLowest + strainGaugeMinRange;
            }
            
        }
            
        else {
            
            if (appMode != 3) { // JULY 13:Change1n  (all the rest of the code below in this function was updated, about 20 lines)
                
                if (relativeInhaleLevelSG < 0.05 && !((breathSensor[count] > breathSensor[count-1]) && (breathSensor[count-1] > breathSensor[count-2]) && (breathSensor[count-2] > breathSensor[count-3]) && (breathSensor[count-3] > breathSensor[count-4]) && (breathSensor[count-4] > breathSensor[count-5]) && (breathSensor[count-5] > breathSensor[count-6]) ) ) {
                    
                    relativeInhaleLevelSG = 0;
                    currentStrainGaugeHighest = (currentStrainGaugeHighest - currentStrainGaugeLowest) + strainGauge; //Since currentStrainGaugeLowest is being set to strainGauge below, this preserves the range but relative to the new floor.
                    
                    currentStrainGaugeLowest = strainGauge;
                    if ( (currentStrainGaugeHighest - currentStrainGaugeLowest) < strainGaugeMinRange) {
                        currentStrainGaugeHighest = currentStrainGaugeLowest + strainGaugeMinRange;
                    }
                }
            }
            else {
                
                if (relativeInhaleLevelSG < 0.10 && !((breathSensor[count] > breathSensor[count-1]) && (breathSensor[count-1] > breathSensor[count-2]) && (breathSensor[count-2] > breathSensor[count-3]) && (breathSensor[count-3] > breathSensor[count-4]) && (breathSensor[count-4] > breathSensor[count-5]) && (breathSensor[count-5] > breathSensor[count-6]) && (breathSensor[count-6] > breathSensor[count-7]) && (breathSensor[count-7] > breathSensor[count-8]) ) ) {
                    
                    relativeInhaleLevelSG = 0;
                    currentStrainGaugeHighest = (currentStrainGaugeHighest - currentStrainGaugeLowest) + strainGauge; //Since currentStrainGaugeLowest is being set to strainGauge below, this preserves the range but relative to the new floor.
                    
                    currentStrainGaugeLowest = strainGauge;
                    if ( (currentStrainGaugeHighest - currentStrainGaugeLowest) < strainGaugeMinRange) {
                        currentStrainGaugeHighest = currentStrainGaugeLowest + strainGaugeMinRange;
                    }
                }
            }
            
        }
    }
    
    func displayBreathingGraph() {
        
        let graphY = (-fullBreathGraphHeight*relativeInhaleLevelSG) + yStartPos;
        graphYSeries[count] = smoothBreathingCoef*graphY + (1.0 - smoothBreathingCoef)*graphYSeries[count-1]; //dampen the sensor signal
        
        delegates.forEach { $0.liveNew?(graphY: graphYSeries[count]) }
        
        //Guided path
        
        if (appMode == 2) {
            
            // TODO: move bird
        }
    }
    
    func displayPostureIndicator() {
        if (uprightSet == 1) {
            
            if (isBuzzing == 1) { //Don't evaluate posture if buzzer is buzzing! The buzzer TOTALLY messes up the accelerometer signal
                postureAttenuator = 0;
            }
            else {
                postureAttenuator = 0.10;
            }
            
            
            if (useRotationSensor == 1) {
                
                postureAttenuatorLevel+=1;
                
                if (postureAttenuatorLevel > 5) {
                    postureAttenuatorLevel = 5;
                }
                
            }
                
            else {
                
                postureAttenuatorLevel-=1;
                if (postureAttenuatorLevel < 0) {
                    postureAttenuatorLevel = 0;
                }
                
            }
            
            
            switch postureAttenuatorLevel {
                
            case 1:
                postureAttenuator = postureAttenuator * 0.70;
                break;
                
            case 2:
                postureAttenuator = postureAttenuator * 0.70 * 0.80;
                break;
                
            case 3:
                postureAttenuator = postureAttenuator * 0.70 * 0.80 * 0.80;
                break;
                
            case 4:
                postureAttenuator = postureAttenuator * 0.70 * 0.80 * 0.80 * 0.80;
                break;
                
            case 5:
                postureAttenuator = postureAttenuator * 0.70 * 0.80 * 0.80 * 0.80 * 0.80;
                break;
            default:
                break
            }
            
            relativePosturePositionFiltered[count] = Double(postureAttenuator*currentPostureAngle[count] + (1-postureAttenuator)*relativePosturePositionFiltered[count-1]);
            
            var xPos = Double(598*(1 - (abs(relativePosturePositionFiltered[count] - uprightPostureAngle)/postureRange)));
            //note, the absolute value here is needed because we don't know for sure antomy of user! For example,if you wear on belly, then angle goes other way when leaning forward, and without absolute value, it does not work.
            
            
            
            if (xPos > 598) {
                xPos = 598;
            }
            
            if (xPos < 2) {
                xPos = 2;
            }
            
//            postureUI.sliderGraph.postureMarker.x = xPos;
            
            var whichPostureFrame = Int(30*((598 - xPos)/598));
            
            if (whichPostureFrame < 1) {
                whichPostureFrame = 1;
            }
            else if (whichPostureFrame > 30) {
                whichPostureFrame = 30;
            }
            
            if (whichPostureFrame > 19) {
                postureIsGood = 0;
            }
            else {
                postureIsGood = 1;
            }
            
            
            //postureUI.postureAnim.gotoAndStop(whichPostureFrame);

            delegates.forEach { $0.liveNew?(postureFrame: whichPostureFrame) }
            
        }
            
        else {
            
            if (xSensor[count] == 0 && ySensor[count] == 0) {
                relativePosturePositionFiltered[count] = 2*(asin(zSensor[count])/Double.pi);
            }
            else {
                relativePosturePositionFiltered[count] = 2*(atan(zSensor[count]/sqrt(pow(xSensor[count],2)+pow(ySensor[count],2)))/Double.pi);
            }
            
            
        }
    }
    
    func processBreathingandPosture(_ sensorData: [Double]) {
        timeElapsed = timeElapsed + (1/20.0);    // May 19th, ADDED THIS LINE, note it is 1/20, not 1/60 as previously in enterFrameHandler
        
        enterFrameCount+=1; //AUG 1st NEW
        
//        if (enterFrameCount >= 20) {  //AUG 1st NEW
//            enterFrameCount = 0; //AUG 1st NEW
            if (timeElapsed >= 60) { //AUG 1st NEW
                delegates.forEach { $0.liveNew?(oneMinuteRespirationRate: calculateOneMinuteRespRate()) }
            } //AUG 1st NEW
            
//        } //AUG 1st NEW

        if (timeElapsed > 0) { //March 3rd 2020,  NEW
            avgRespRate = 60*(Double(breathCount)/timeElapsed);    //March 3rd 2020,  NEW
            avgRespRate = roundNumber(avgRespRate, 10); //March 3rd 2020,  NEW
        } //March 3rd 2020,  NEW


        delegates.forEach { $0.liveMainLoop?(timeElapsed: timeElapsed, sensorData: sensorData) }
        /*
        if (DC.objBuzzerTraining.isBuzzerTrainingActive == 1) {  // May 19th, ADDED THIS LINE
            DC.objBuzzerTraining.buzzerTrainingMainLoop()  // May 19th, ADDED THIS LINE
        }  // May 19th, ADDED THIS LINE
        
        if (DC.objPassiveTracking.isPassiveTrackingActive == 1) {  // May 19th, ADDED THIS LINE
            DC.objPassiveTracking.passiveTrackingMainLoop()  // May 19th, ADDED THIS LINE
        }  // May 19th, ADDED THIS LINE
        */
        
        storeSensorData(sensorData);
        
        if (count < 8) { //JULY 13:Change1m   Changed 5 to 8 here. This could have been causing crashes. For example, in setRelativeInhaleLevelStrainGauge(), I was accessing arrays based on count-6, which is a negative index value when count = 5  (and now I have count-8 there)
            return;
        }
        
        setSmoothingAndDamping();
        setRelativeInhaleLevelStrainGauge();
        displayPostureIndicator();
        displayBreathingGraph();
        reversalDetector();
        
        if (breathEnding == 1) {
            
            if (graphYSeries[count] > endBreathY) {
                
                if (EIGoodToMeasure == 1 && exhaleCorrectionFactor < 1.3 && stuckBreaths == 0 && (inhaleEndTime - inhaleStartTime > 0)) {  // AUG 1st CHANGED, if stuckBreaths > 0, then EIRatio can sometimes be negative
                    
                    exhaleEndTime = timeElapsed; //May 31st ADDED
                    //EIRatio[EIRatioCount] = [(exhaleCorrectionFactor*(exhaleEndTime - inhaleEndTime))/((1-(0.05/smoothBreathingCoefBaseLevel))*(inhaleEndTime - inhaleStartTime)),timeElapsed]; // JULY 13th:CHANGE1c  REMOVED
                    let ratio = [roundNumber((exhaleCorrectionFactor*(exhaleEndTime - inhaleEndTime))/(inhaleEndTime - inhaleStartTime),10),timeElapsed]; // JULY 13th:NEW1c
                    
                    EIRatio.append(ratio) ; // May 31st ADDED
                    EIAvgSessionSummation = EIAvgSessionSummation + ratio[0]; // AUG 1st NEW
                    EIAvgSessionRatio = roundNumber(EIAvgSessionSummation/Double(EIRatio.count),10); // AUG 1st CHANGED
                    EIRatioCount+=1;  // May 31st ADDED
                    EIGoodToMeasure = 0; //May31st ADDED
                    
                }  // May 31st ADDED
                
                delegates.forEach { $0.liveNew?(sessionAvgRate: avgRespRate) }
                
                delegates.forEach { $0.liveNew?(endBreathLineY: 5000) }
//                endBreathLine.y = 5000;
                
                //stuckBreaths = 0;  JULY 13th REMOVED
                breathEnding = 0;
                //breathCount++;  //Aug 1st REMOVED
                //calculateRealTimeRR();    //Aug 1st REMOVED
                
                
                //if (timeElapsed >= 60) { //AUG 1st REMOVED
                //postureUI.oneMinuteRespirationRateIndicator.text = String(calculateOneMinuteRespRate()); //AUG 1st REMOVED
                //} //AUG 1st REMOVED
                
                //if (DC.appMode == 1 && timeElapsed >= 60) { //AUG 1st REMOVED    NOTE: appMode == 1 means it is Passive Tracking mode
                //calculateOneMinuteEI(); //AUG 1st REMOVED
                //if (DC.objPassiveTracking.isPassiveTrackingActive == 1) { //Aug 1st REMOVED
                //DC.objPassiveTracking.passiveTrackingUI.lastMinuteEI.text = String(EI1Minute); //Aug 1st REMOVED
                //} //Aug 1st REMOVED
                //} //AUG 1st REMOVED
                
                //if (stuckBreaths == 0) { //AUG 1st REMOVED
                setNewStrainGaugeRange(); //AUG 1st CHANGED (indent spacing)
                //} //AUG 1st REMOVED
                //else {  //AUG 1st REMOVED
                //currentStrainGaugeHighest = (currentStrainGaugeHighestPrev - currentStrainGaugeLowest) + strainGauge; //AUG 1st REMOVED //Since currentStrainGaugeLowest is being set to strainGauge below, this preserves the range but relative to the new floor. JULY 13th:NEW1i
                
                //if ( (currentStrainGaugeHighest - currentStrainGaugeLowest) < strainGaugeMinRange) { //AUG 1st REMOVED //JULY 13th:NEW1i
                //currentStrainGaugeHighest = currentStrainGaugeLowest + strainGaugeMinRange; //AUG 1st REMOVED //JULY 13th:NEW1i
                //} //AUG 1st REMOVED //JULY 13th:NEW1i
                //} //AUG 1st REMOVED //JULY 13th:NEW1i
                
                if (stuckBreaths == 0) { //AUG 1st NEW
                    
                    currentStrainGaugeHighestPrev = currentStrainGaugeHighest; // //AUG 1st NEW     only set this when the breath is not stuck! Otherwise it could be set much higher (to the value which exceeded the ceiling)
                    strainGaugeRangePrev = currentStrainGaugeHighest - currentStrainGaugeLowest; //AUG 1st NEW
                    
                    if (strainGaugeRangePrev < strainGaugeMinRange) { //AUG 1st NEW
                        strainGaugeRangePrev = strainGaugeMinRange; //AUG 1st NEW
                    } //AUG 1st NEW
                    
                } //AUG 1st NEW
                
                stuckBreaths = 0; //JULY 13th:NEW1i
                noisyMovements = 0; //This is where to reset this. Thus, ANY noisy movement during inhalation will trigger a higher endBreathY
                currentStrainGaugeLowest = strainGauge;
                
            }
        }
    }
    
    func calculateOneMinuteEI() {
        guard EIRatio.count > 0 else { return }
        
        EI1Minute = 0;  //JULY 13th:CHANGE1b
        var breathsInLastMinute:Int = 0; // May 31st ADDED
        
        for i in ((0..<(EIRatio.count - 1)).map { Int($0) }.reversed()) { // May 31st ADDED
            
            if (EIRatio[i][1] >= (timeElapsed - 60)) { // May 31st ADDED
                EI1Minute = EI1Minute + EIRatio[i][0]; // May 31st ADDED
                breathsInLastMinute+=1; // May 31st ADDED
            } // May 31st ADDED
            else { // May 31st ADDED
                break; // May 31st ADDED
            } // May 31st ADDED
        } // May 31st ADDED
        
        if (breathsInLastMinute > 0) { // May 31st ADDED
            EI1Minute = roundNumber(EI1Minute / Double(breathsInLastMinute),10); // May 31st ADDED
        } // May 31st ADDED
        else { // May 31st ADDED
            EI1Minute = 1; // May 31st ADDED
        } // May 31st ADDED
        
        //return(EI1Minute); //JULY 13th:CHANGE1b  REMOVE THIS LINE
    }
    
    func calculateRealTimeAndSessionAverageRR() {
        whenBreathsStart.append(timeElapsed);
        
//        if (whenBreathsStart.count == 1) {
//            if ((whenBreathsStart[0] - 0) > 0) {
//                respRate = 1 * (60.0 / (whenBreathsStart[0] - 0));
//                respRate = roundNumber(respRate, 10);
//            }
//        }
            
        if (whenBreathsStart.count >= 2) {
            let lastIndex = whenBreathsStart.count-1;
//            breathCount+=1; //only start to increment this when there are at least 2 breath starts (as complete breath is defined by 2 breath starts), Big bug previously, not counting stuck breaths towards breathCount, so every time there is a VALID inhale, increase this count even if stuck
            
            if ((whenBreathsStart[lastIndex] - whenBreathsStart[lastIndex-1]) > 0) {
                respRate = 1 * (60.0 / (whenBreathsStart[lastIndex] - whenBreathsStart[lastIndex-1]));
            }
            
//            if (timeElapsed > 0) {
//                avgRespRate = 60*(Double(breathCount)/timeElapsed);
//
//            }
            
//            if (appMode == 2 && calibrationBreathsDone == 0) {  //Aug 1st  NEW
//                if (timeElapsed-timeElapsedAtCalibrationStart > 0) { //Aug 1st  NEW
//                    calibrationRR = 60*(Double(breathCount-breathCountAtCalibrationStart)/(timeElapsed-timeElapsedAtCalibrationStart)); //Aug 1st  NEW
//                    calibrationRR = roundNumber(calibrationRR, 10); //Aug 1st  NEW
//                } //Aug 1st  NEW
//            } //Aug 1st  NEW
            
            respRate = roundNumber(respRate, 10);
//            avgRespRate = roundNumber(avgRespRate, 10);

            delegates.forEach { $0.liveNew?(respirationRate: respRate) }
//            postureUI.respirationRateIndicator.text = String(respRate);
            
        }
        
        if (appMode == 2) { //Aug 12th  NEW
            actualBreathsWithinAPattern.append(CoreBreath(it: roundNumber(timeElapsed-graphStartTime,10), rr: respRate)); //Aug 12th  NEW
        } //Aug 12th  NEW
        else if (appMode == 3) { //AUG 1st NEW for BT
            actualBreathsWithinAPattern.append(CoreBreath(it: roundNumber(timeElapsed-graphStartTime,10), rr: respRate)); //Aug 12th  NEW
        } //Aug 12th  NEW
    }
    
    func calculateOneMinuteRespRate() -> Int {
        
        var breathsInLastMinute: Int = 0;
        
        guard !whenBreathsStart.isEmpty else { return breathsInLastMinute }
        
        for i in ((0..<(whenBreathsStart.count)).map { Int($0) }.reversed()) {
            if (whenBreathsStart[i] >= (timeElapsed - 60)) {
                breathsInLastMinute+=1;
            } else {
                break
            }
        }
        return breathsInLastMinute;
        
    }
    
    func setNewStrainGaugeRange() {
        if (noisyMovements == 1 || stuckBreaths > 0) {    //AUG 1st CHANGED
            
            //currentStrainGaugeHighest = (currentStrainGaugeHighestPrev - currentStrainGaugeLowest) + strainGauge; // //AUG 1st REMOVED Since currentStrainGaugeLowest is being set to strainGauge below, this preserves the range but relative to the new floor.
            
            currentStrainGaugeLowest = strainGauge; //AUG 1st NEW
            currentStrainGaugeHighest = currentStrainGaugeLowest + strainGaugeRangePrev; //AUG 1st NEW
            
            //if ( (currentStrainGaugeHighest - currentStrainGaugeLowest) < strainGaugeMinRange) { //AUG 1st REMOVED
            //currentStrainGaugeHighest = currentStrainGaugeLowest + strainGaugeMinRange; //AUG 1st REMOVED
            //}    //AUG 1st REMOVED
            
            return;
        }
        
        newStrainGaugeRange = currentStrainGaugeHighestNew - currentStrainGaugeLowestNew;
        
        if (newStrainGaugeRange < (0.65*(currentStrainGaugeHighest - currentStrainGaugeLowest))) {
            
            lightBreathsInARow+=1;
            breathTopExceeded = 0;
            
            if (lightBreathsInARow > lightBreathsThreshold) {
                
                currentStrainGaugeLowest = 0.5*currentStrainGaugeLowestNew + (1-0.5)*currentStrainGaugeLowest;
                currentStrainGaugeHighest = 0.5*currentStrainGaugeHighestNew + (1-0.5)*currentStrainGaugeHighest;
                
                currentStrainGaugeHighest = (currentStrainGaugeHighest - currentStrainGaugeLowest) + strainGauge; //Since currentStrainGaugeLowest is being set to strainGauge below, this preserves the range but relative to the new floor.
                
                currentStrainGaugeLowest = strainGauge; //AUG 1st NEW
                if ( (currentStrainGaugeHighest - currentStrainGaugeLowest) < strainGaugeMinRange) {
                    currentStrainGaugeHighest = currentStrainGaugeLowest + strainGaugeMinRange;
                }
                
                return;
                
            }
            
        }
            
        else  {
            
            lightBreathsInARow = 0;  //Also do not reset this when noisy movements
        }
        
        
        if ( (currentStrainGaugeHighest-currentStrainGaugeLowest) > 1.25*(currentStrainGaugeHighestPrev-currentStrainGaugeLowest)) {    //AUG 1st change
            
            breathTopExceeded+=1;
            lightBreathsInARow = 0;
            
            if (breathTopExceeded > breathTopExceededThreshold) {
                currentStrainGaugeHighest = ((0.3*currentStrainGaugeHighest + (1-0.3)*currentStrainGaugeHighestPrev) - currentStrainGaugeLowest) + strainGauge;
            }
            else {
                //currentStrainGaugeHighest = (currentStrainGaugeHighestPrev - currentStrainGaugeLowest) + strainGauge; // AUG 1st REMOVED Since currentStrainGaugeLowest is being set to strainGauge below, this preserves the range but relative to the new floor.
                currentStrainGaugeHighest = strainGauge + strainGaugeRangePrev; //AUG 1st NEW
            }
            
            currentStrainGaugeLowest = strainGauge; //AUG 1st NEW
            if ( (currentStrainGaugeHighest - currentStrainGaugeLowest) < strainGaugeMinRange) {
                currentStrainGaugeHighest = currentStrainGaugeLowest + strainGaugeMinRange;
            }
            
        }
            
        else {
            
            breathTopExceeded = 0;
            //currentStrainGaugeHighest = (currentStrainGaugeHighestPrev - currentStrainGaugeLowest) + strainGauge; //AUG 1st REMOVED Since currentStrainGaugeLowest is being set to strainGauge below, this preserves the range but relative to the new floor.
            currentStrainGaugeHighest = strainGauge + strainGaugeRangePrev; //AUG 1st NEW
            currentStrainGaugeLowest = strainGauge; //AUG 1st NEW
            if ( (currentStrainGaugeHighest - currentStrainGaugeLowest) < strainGaugeMinRange) {
                currentStrainGaugeHighest = currentStrainGaugeLowest + strainGaugeMinRange;
            }
            
        }
    }
    
    func reversalDetector() {
        if (count <= reversalThreshold + 1) {
            return;
        }
        
        var up:Int = 0;
        var down:Int = 0;
//        var i:Int = 0;
        
        if (bottomReversalFound == 1) {  //AUG 1st NEW
            
            if ( (breathEnding == 1 && (bottomReversalY - graphYSeries[count] > (minBreathRangeForStuck))) || (breathEnding == 0 && (yStartPos - graphYSeries[count] > minBreathRange)) ) { //This means the breath is not a false positive breath (not due to noise)  //AUG 1st NEW
                
                if (inhaleIsValid == 0) { //AUG 1st NEW
                    
                    inhaleIsValid = 1; //AUG 1st NEW
                    
                    breathCount += 1;
                    
                    calculateRealTimeAndSessionAverageRR(); //AUG 1st NEW
                    
                    delegates.forEach { $0.liveNew?(breathCount: breathCount) }
//                    postureUI.howManyBreaths.text = String(breathCount); //AUG 1st NEW REMOVE THIS, for testing only
                    
                    delegates.forEach { $0.liveNew?(bottomReversalLineY: bottomReversalY) }
//                    bottomReversalLine.y = bottomReversalY; //AUG 1st NEW
                    
                    delegates.forEach { $0.liveNew?(endBreathLineY: 5000) }
//                    endBreathLine.y = 5000; //AUG 1st NEW, Hide this end breath line (for case when stuck breaths and a new valid inhale is happening)
                    
                    if (breathEnding == 1) {  // //AUG 1st NEW This means a bottom reversal occured BEFORE the previous breath ended! (ie before the previous breath crossed the endBreathLine)
                        
                        stuckBreaths+=1; //AUG 1st NEW
                        
                    } //AUG 1st NEW
                    
                    
                } //AUG 1st NEW
            } //AUG 1st NEW
        } //AUG 1st NEW
        
        
        if (upStreak == 0) {
            
            for i in 0 ... reversalThreshold  {
                
                if (graphYSeries[count-i] < graphYSeries[count-i-1]) {
                    up+=1; //BECAUSE graph is negative going up!!!!!!!!!!!!!!!
                    if (up == reversalThreshold+1) {
                        upStreak = 1;
                        upStreakStart = count-(reversalThreshold+1);
                    }
                }
            }
        }
        
        
        if (downStreak == 0) {
            
            for i in 0 ... reversalThreshold  {
                
                if (graphYSeries[count-i] > graphYSeries[count-i-1]) {
                    down+=1; //BECAUSE graph is positive going down!!!!!!!!!!!!!!!
                    if (down == reversalThreshold+1) {
                        downStreak = 1;
                        downStreakStart = count-(reversalThreshold+1);
                    }
                    
                }
            }
        }
        
        
        if (up == reversalThreshold+1) {
            
            if (downStreak == 1 || breathCount == 0) { //downStreak must have been previously set, thus a bottom reversal has just been found
                
                downStreak = 0;
                bottomReversalFound = 1;
                inhaleIsValid = 0; //AUG 1st NEW
                inhaleStartTime = timeElapsed - Double(reversalThreshold+1)*(1/20); //May 31st ADDED
                
                bottomReversalY = graphYSeries[downStreakStart];
                
                currentStrainGaugeLowestNew = breathSensor[count-(reversalThreshold+2)];
                
                if downStreakStart <= upStreakStart {
                    for i in downStreakStart ... upStreakStart { //This is needed because upStreakStart could conceivably be higher than downStreakStart
                        
                        if (graphYSeries[i] > bottomReversalY){ //Find the lowest point on the graph within the bounds
                            bottomReversalY = graphYSeries[i];
                        }
                        
                    }
                } else {
                    print("stop")
                }
                
                //bottomReversalLine.y = bottomReversalY; // AUG 1st REMOVED

//                topReversalLine.y = 5000;
                
                //if (breathEnding == 1) {  // // AUG 1st REMOVED  This means a bottom reversal occured BEFORE the previous breath ended! (ie before the previous breath crossed the endBreathLine)
                
                //stuckBreaths++;  // AUG 1st REMOVED
                //} // AUG 1st REMOVED
                
                
                //if (stuckBreaths == 0) { //AUG 1st REMOVED
                
                //currentStrainGaugeHighestPrev = currentStrainGaugeHighest; // AUG 1st REMOVED  only set this when the breath is not stuck! Otherwise it could be set much higher (to the value which exceeded the ceiling)
                
                //} //AUG 1st REMOVED
                
                topReversalFound = 0;
                
            }
            
        }
        
        
        
        if (down == (reversalThreshold+1)) {
            
            if (upStreak == 1) { //upStreak must have been previously set, thus a top reversal has just been found
                
                upStreak = 0;
                
                topReversalY = graphYSeries[upStreakStart];
                
                if upStreakStart <= downStreakStart {
                    for i in upStreakStart ... downStreakStart {
                        
                        if (graphYSeries[i] < topReversalY){
                            topReversalY = graphYSeries[i];
                        }
                    }
                } else {
                    print("stop")
                }
                
                //if (DC.appMode != 3 && DC.appMode != 1 ) { // AUG 1st REMOVED
                //if ( ((bottomReversalY - topReversalY < minBreathRange) && stuckBreaths > 0) || (yStartPos - topReversalY < minBreathRange) ) { //AUG 1st REMOVED, minBreathRange/3 changed to just minBreathRange (now just setting minBreathRange in BT and VT and PT)
                if (inhaleIsValid == 0 && breathCount > 2) {  //AUG 1st ADDED
                    bottomReversalFound = 0; //AUG 1st ADDED
                    return; // Require a min breath range when breath is stuck, otherwise breath holding does not work and breath range sensitivity can artificially spike due to noise
                }
                //}  // AUG 1st REMOVED
                //else { // AUG 1st REMOVED
                //if ( ((bottomReversalY - topReversalY < minBreathRange) && stuckBreaths > 0) || (yStartPos - topReversalY < (minBreathRange*3)) ) {  //JULY 13:New1o  changed to *3 here to make a greater requirement to be considered a breath during BT  (to help reduce BT false positives)  // AUG 1st REMOVED
                //bottomReversalFound = 0; // AUG 1st REMOVED
                //return; // Require a min breath range when breath is stuck, otherwise breath holding does not work and breath range sensitivity can artificially spike due to noise   // AUG 1st REMOVED
                //} // AUG 1st REMOVED
                //}  // AUG 1st REMOVED
                
                topReversalFound = 1;
                
                currentStrainGaugeHighestNew = breathSensor[count-(reversalThreshold+2)];
                
                //topReversalLine.y = topReversalY;    //AUG 1st REMOVED (no longer showing the top reversal line, since the peak of the graph already indicates that)
                
                
                
                if (bottomReversalFound == 1 || breathCount < 2) {
                    
                    if (bottomReversalFound == 1 && breathCount >= 2 ) { //May 31st ADDED
                        inhaleEndTime = timeElapsed - Double(reversalThreshold+1)*(1/20); //May 31st ADDED
                        EIGoodToMeasure = 1; //May 31st ADDED
                    } //May 31st ADDED
                    
                    bottomReversalFound = 0;
                    breathEnding = 1;
                    exhaleCorrectionFactor = 1; //May 31st ADDED
                    
                    //DC.objStartConnection.socket.writeUTFBytes("Buzz,0.2" + "\n");
                    //DC.objStartConnection.socket.flush();
                    
                    if (breathCount < 2 && appMode != 2) { //***March16Change    May 30th Change
                        endBreathY = bottomReversalY - 0.95*(bottomReversalY - topReversalY); //***March16Change, This addresses scnenario if user plugs in belt AFTER starting LiveGraph which can cause strainGauge value to suddenly greatly jump, and create situation where breath graph is stuck far above the yellow line
                        exhaleCorrectionFactor = 1/(1-0.95); //May 31st ADDED
                    } //***March16Change
                        
                    else if (appMode == 2) { //***March16Change  (else added)
                        
                        if (calibrationBreathsDone == 1) {
                            endBreathY = yStartPos + Double(0.20*(-fullBreathGraphHeight));
                            exhaleCorrectionFactor = 1/(1-0.20); //May 31st ADDED
                        }
                        else if (calibrationBreathsDone == 0) {
                            endBreathY = bottomReversalY - 0.60*(bottomReversalY - topReversalY); //end breath line
                            exhaleCorrectionFactor = 1/(1-0.60); //May 31st ADDED
                        }
                        
                        if (noisyMovements == 1 && stuckBreaths > 0) {
                            endBreathY = bottomReversalY - 0.50*(bottomReversalY - topReversalY); //end breath line
                            exhaleCorrectionFactor = 1/(1-0.50); //May 31st ADDED
                        }
                        
                        if (stuckBreaths >= stuckBreathsThreshold) {
                            endBreathY = bottomReversalY - 0.50*(bottomReversalY - topReversalY); //end breath line
                            exhaleCorrectionFactor = 1/(1-0.50); //May 31st ADDED
                        }
                        
                    }
                        
                    else if (appMode == 1 || appMode == 3) {
                        
                        endBreathY = bottomReversalY - 0.20*(bottomReversalY - topReversalY); //end breath line
                        exhaleCorrectionFactor = 1/(1-0.20); //May 31st ADDED
                        
                        if (noisyMovements == 1) {
                            endBreathY = bottomReversalY - 0.50*(bottomReversalY - topReversalY); //end breath line
                            exhaleCorrectionFactor = 1/(1-0.50); //May 31st ADDED
                        }
                        
                        if (stuckBreaths >= stuckBreathsThreshold) {
                            endBreathY = bottomReversalY - 0.50*(bottomReversalY - topReversalY); //end breath line
                            exhaleCorrectionFactor = 1/(1-0.50); //May 31st ADDED
                        }
                    }
                    
                    delegates.forEach { $0.liveNew?(endBreathLineY: endBreathY) }
                    delegates.forEach { $0.liveNew?(bottomReversalLineY: 5000) }
//                    endBreathLine.y = endBreathY;
//                    bottomReversalLine.y = 5000; //AUG 1st NEW  Hide this line when endBreath line appears, idea is green line appears when valid breath starts, and yellow line appears then when exhale starts (and green line disappears)
                    
                }
                
            }
            
            
        }
    }
    
    func postureSelectorHandler(level: Int) {
        
        if (level == 1) {  //AUG 1st CHANGE (just changed the property name to level1, but this may not affect you Luccas)
            
            //postureRange = 0.25;
            postureRange = 0.15;
            postureLevel = 1;  // AUG 1st NEW
        }
        else if (level == 2) {  //AUG 1st CHANGE (just changed the property name to level2, but this may not affect you Luccas)
            //postureRange = 0.15;
            postureRange = 0.10;
            postureLevel = 2;  // AUG 1st NEW
        }
        else if (level == 3) {  //AUG 1st CHANGE (just changed the property name to level3, but this may not affect you Luccas)
            //postureRange = 0.08;
            postureRange = 0.05;
            postureLevel = 3;  // AUG 1st NEW
        }
    }
    
    func breathSelectorHandler(level: Int) {
        if (level == 1) {  //AUG 1st CHANGED name
            smoothBreathingCoefBaseLevel = 0.15;
            reversalThreshold = 6;
            birdIncrements = 24;
            breathLevel = 1;  // AUG 1st NEW
            minBreathRange = (fullBreathGraphHeight/16); //AUG 1st NEW, make even less prone to noise for level 1
            minBreathRangeForStuck = (fullBreathGraphHeight/16); //AUG 1st NEW
            
        }
        else if (level == 2) {  //AUG 1st CHANGED name
            smoothBreathingCoefBaseLevel = 0.4;
            reversalThreshold = 5;
            birdIncrements = 20;
            breathLevel = 2;  // AUG 1st NEW
            minBreathRange = (fullBreathGraphHeight/16)/2; //AUG 1st NEW, make even less prone to noise for level 1
            minBreathRangeForStuck = (fullBreathGraphHeight/16); //AUG 1st NEW
        }
        else if (level == 3) { //AUG 1st CHANGED name
            smoothBreathingCoefBaseLevel = 0.6;
            reversalThreshold = 3;
            birdIncrements = 12;
            breathLevel = 3;  // AUG 1st NEW
            minBreathRange = (fullBreathGraphHeight/16)/2; //AUG 1st NEW, make even less prone to noise for level 1
            minBreathRangeForStuck = (fullBreathGraphHeight/16); //AUG 1st NEW
        }
    }
    
    func learnUprightAngleHandler() {
        if count < 0 { return }
        
        uprightSet = 1;
        
        if (xSensor[count] == 0 && ySensor[count] == 0) {
            uprightPostureAngle = 2*(asin(zSensor[count])/Double.pi);
        }
        else {
            uprightPostureAngle = 2*(atan(zSensor[count]/sqrt(pow(xSensor[count],2)+pow(ySensor[count],2)))/Double.pi);
        }
        
        delegates.forEach { $0.liveUprightHasBeenSet?() }
    }
    
    func setUprightButtonPush(sensorData a:[Double])  {
        
        if (count < 0) {
            return
        }
        
        uprightSet = 1;
        
        if (a[1] == 0.0 && a[2] == 0.0) {
            uprightPostureAngle = 2*(asin(a[3])/Double.pi);
        }
        else {
            uprightPostureAngle = 2*(atan(a[3]/sqrt(pow(a[1],2)+pow(a[2],2)))/Double.pi);
        }
        
        delegates.forEach { $0.liveUprightHasBeenSet?() }
    }
    
    func backButtonHandler() {
        PranaDeviceManager.shared.stopGettingLiveData()
    }

    func startMode() {
        exhaleCorrectionFactor = 0; //May 31st ADDED
        EIAvgSessionRatio = 0; //May 31st ADDED
        EIAvgSessionSummation = 0; //AUG 1st ADDED
        EIRatio = [];  //May 31st ADDED
        inhaleStartTime = 0; //May 31st ADDED
        inhaleEndTime = 0; //May 31st ADDED
        exhaleEndTime = 0; //May 31st ADDED
        EIRatioCount = 0; //May 31st ADDED
        EI1Minute = 0;  //JULY 13th:NEW1b
        //whenBreathsEnd = []; //AUG 1st REMOVED
        //whenBreathsEnd[0] = 0; AUG 1st REMOVED
        whenBreathsStart = []; // Aug 1st ADDED
        calibrationRR = 12; //AUG 1st ADDED
        
        actualBreathsWithinAPattern = []; //AUG 12th NEW
        
        enterFrameCount = 0; //AUG 1st NEW
        inhaleIsValid = 0; //AUG 1st NEW
        breathCount = 0;
        timeElapsed = 0;
        respRate = 0;
        avgRespRate = 0;
        
        currentStrainGaugeHighest = currentStrainGaugeLowest + 0.003; //AUG 1st ADDED
        currentStrainGaugeHighestPrev = currentStrainGaugeHighest;  //AUG 1st ADDED
        currentStrainGaugeLowestNew = currentStrainGaugeLowest; //AUG 1st ADDED
        currentStrainGaugeHighestNew = currentStrainGaugeHighest;    ///AUG 1st ADDED
        strainGaugeRangePrev = 0.003; //AUG 1st NEW
        
        relativeInhaleLevelSG = 0; //AUG 1st NEW
        currentStrainGaugeHighest = (currentStrainGaugeHighest - currentStrainGaugeLowest) + strainGauge; //AUG 1st NEW
        currentStrainGaugeLowest = strainGauge;        //AUG 1st NEW
        if ( (currentStrainGaugeHighest - currentStrainGaugeLowest) < strainGaugeMinRange) { //AUG 1st NEW
            currentStrainGaugeHighest = currentStrainGaugeLowest + strainGaugeMinRange; //AUG 1st NEW
        } //AUG 1st NEW
        
        PranaDeviceManager.shared.addDelegate(self)
        PranaDeviceManager.shared.startGettingLiveData()
        
        //RRtimer.start();
        //addEventListener(Event.ENTER_FRAME, enterFrameHandler);  May 19th, REMOVED THIS LINE
        stuckBreathsThreshold = 3; //AUG 1st CHANGED
        breathTopExceededThreshold = 1;
        lightBreathsThreshold = 1; //JULY 13th:NEW1i
        lightBreathsInARow = 0; //JULY 13th:NEW1i
        breathTopExceeded = 0; //JULY 13th:NEW1i
        stuckBreaths = 0; //JULY 13th:NEW1i
        //minBreathRange = (fullBreathGraphHeight/16)/2; //AUG 1st REMOVED (setting it below),  This is important because resolutions on devices are different. Previously it was set to 25, which is an absolute value. Now it is set relative to the fullBreathGraphHeight (whatever that is set to for the particular device, it was 400 on desktop)
        upStreak = 0; //Jan 8th NEW
        downStreak = 0; //Jan 8th NEW
        bottomReversalFound = 0; //Jan 8th NEW
        topReversalFound = 0; //Jan 8th NEW

        
        if (breathLevel == 1) {  //AUG 1st NEW
            smoothBreathingCoefBaseLevel = 0.15;  //AUG 1st NEW
            reversalThreshold = 6;   //AUG 1st NEW
            birdIncrements = 24;     //AUG 1st NEW
            minBreathRange = (fullBreathGraphHeight/16); //AUG 1st NEW, make even less prone to noise for level 1
            minBreathRangeForStuck = (fullBreathGraphHeight/16); //AUG 1st NEW
        } //AUG 1st NEW
        else if (breathLevel == 2) { //AUG 1st NEW
            smoothBreathingCoefBaseLevel = 0.4; //AUG 1st NEW
            reversalThreshold = 5; //AUG 1st NEW
            birdIncrements = 20; //AUG 1st NEW
            minBreathRange = (fullBreathGraphHeight/16)/2; //AUG 1st NEW
            minBreathRangeForStuck = (fullBreathGraphHeight/16); //AUG 1st NEW
        } //AUG 1st NEW
        else if (breathLevel == 3) { //AUG 1st NEW
            smoothBreathingCoefBaseLevel = 0.6; //AUG 1st NEW
            reversalThreshold = 3; //AUG 1st NEW
            birdIncrements = 12; //AUG 1st NEW
            minBreathRange = (fullBreathGraphHeight/16)/2; //AUG 1st NEW
            minBreathRangeForStuck = (fullBreathGraphHeight/16); //AUG 1st NEW
        }     //AUG 1st NEW
        delegates.forEach { $0.liveNew?(bottomReversalLineY: 5000) }
        delegates.forEach { $0.liveNew?(endBreathLineY: 5000) }
    }
    
}

extension Live: PranaDeviceManagerDelegate {
    
    func PranaDeviceManagerDidReceiveLiveData(_ data: String) {
        let raw = data.split(separator: ",")
        
        if raw[0] == "20hz" {
            if raw.count != 7 {
                return
            }
            var paras: [Double] = []
            paras.append(0.0)
            paras.append(Double(raw[1])!)
            paras.append(Double(raw[2])!)
            paras.append(Double(raw[3])!)
            paras.append(Double(raw[4])!)
            paras.append(Double(raw[5])!)
            paras.append(Double(raw[6])!)
            
            liveQueue.async { [weak self] in
                
                guard let self = self else {
                    return
                }
                
                self.processBreathingandPosture(paras)
            }
        }
        else if raw[0] == "Upright" {
            if raw.count != 4 {
                return
            }
            var paras: [Double] = []
            paras.append(0.0)
            paras.append(Double(raw[1])!)
            paras.append(Double(raw[2])!)
            paras.append(Double(raw[3])!)
            liveQueue.async { [weak self] in
                
                guard let self = self else {
                    return
                }
                
                self.setUprightButtonPush(sensorData: paras)
            }
        }
    }
    
}
