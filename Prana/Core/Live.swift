//
//  Live.swift
//  Prana
//
//  Created by Luccas on 3/19/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation
import CoreBluetooth


protocol LiveDelegate {
    func liveNewBreathingCalculated()
    func liveNewPostureCalculated()
    func liveNewRespRateCaclculated()
    func liveDidUprightSet()
}

class Live: NSObject {
    
    public struct Constants {
        static let numberOfBeathingSamples: Int = 100
        static let maxYOfBreathing: Float = 100
        static let maxXOfPosture: Float = 100
    }
    
    var delegates: [LiveDelegate] = []
    
    open func addDelegate(_ delegate: LiveDelegate) {
        self.delegates.append(delegate)
    }
    
    open func removeDelegate(_ delegate: LiveDelegate) {
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
    
    // init again later
    var totalPoints: Int = 600
    let initialPrepareCount: Int = 5
    var fullBreathGraphHeight: Double = 400.0
    var yStartPos: Double = 500
    var count: Int = -1
    
    
    var appMode: Int = 3 // DC.appMode
    var isBuzzing: Int = 0// DC.objBuzzerTraining.isBuzzing
    
    var xCoord: Int = 0
    var dataArray: [Double] = []
    
    
    var graphY: Double = 0
    var graphYSeries: [Double] = []
    var breathSensor: [Double] = []
    var relativePosturePositionFiltered: [Double] = []
    var zSensor: [Double] = []
    var xSensor: [Double] = []
    var ySensor: [Double] = []
    var dampHistory: [Double] = []
    var rotationSensor: [Double] = []
    var relativeInhaleLevelSG: Double = 0.0
    var relativeInhaleLevelRS: Double = 0.0
    var bellyBreathHasStarted: Int = 0
    /*var bottomReversalLine:StartInhale = new StartInhale(); //blue line deoxygenated
     var topReversalLine:StartExhale = new StartExhale(); //red line oxygenated
     var endBreathLine:EndBreathThreshold = new EndBreathThreshold(); //yellow line
     var zeroLine:ZeroLine = new ZeroLine(); //green line
     var showDebugUI:ControlArrowUp = new ControlArrowUp();
     var testUI:TestUI = new TestUI();
     var postureUI:PostureUI = new PostureUI();*/
    var upStreak: Int = 0
    var downStreak: Int = 0
    var upStreakStart: Int = 0
    var downStreakStart: Int = 0
    var bottomReversalY: Double = 500
    var topReversalY: Double = 0
    var isDrawTop: Bool = false
    var isDrawBottom: Bool = false
    var stuckBreaths: Int = 0
    var endBreathY: Double = 0
    var bottomReversalFound: Int = 0
    var topReversalFound: Int = 0
    var scrollX: Int = 0
    var currentStrainGaugeLowest: Double = 0
    var currentStrainGaugeHighest: Double = 0
    var breathEnding: Int = 0
    var strainGauge: Double = 1
    var uprightPostureAngle: Double = 0
    var uprightSet: Int = 0 {
        didSet {
            for item in self.delegates {
                item.liveDidUprightSet()
            }
        }
    }
    var currentPostureAngle: [Double] = []
    var xPos: Int = 0
    var whichPostureFrame: Int = 1
    var useRotationSensor: Int = 0
    var postureRange: Double = 0.18
    var postureAttenuator: Double = 0.15
    var smoothBreathingCoef: Double = 1
    var lightBreathsInARow: Int = 0
    var deepBreathsInARow: Int = 0
    var damp: Double = 0
    var dampX: Double = 0
    var dampY: Double = 0
    var dampZ: Double = 0
    var noisyMovements: Int = 0
    var dampingLevel: Int = 0
    var postureAttenuatorLevel: Int = 0
    var currentStrainGaugeLowestNew: Double = 0
    var currentStrainGaugeHighestNew: Double = 0
    var newStrainGaugeRange: Double = 0
    var currentStrainGaugeHighestPrev: Double = 0
    var breathTopExceeded: Int = 0
    var guidedPath: [Double] = []
    var strainGaugeMinRange: Double = 0.0005
    var birdDeltaY: Double = 0
    var birdVelocity: Double = 0
    //var RRtimer:Timer = new Timer(100)
    var timeElapsed: Double = 0
    var whenBreathsEnd: [Double] = []
    var respRate: Double = 0
    var breathCount: Int = 0
    var stuckBreathsThreshold: Int = 1
    var breathTopExceededThreshold: Int = 1
    var smoothBreathingCoefBaseLevel: Double = 0.15
    var postureIsGood: Int = 1
    var minBreathRange: Double = 10
    var reversalThreshold: Int = 6
    var birdIncrements: Int = 24
    var avgRespRate: Double = 0
    
    
    override init() {
        super.init()
        totalPoints = Constants.numberOfBeathingSamples
        yStartPos = Double(Constants.maxYOfBreathing) - 2
        fullBreathGraphHeight = yStartPos * 0.9
        count = -1
        
        
        graphYSeries = [Double](repeating: yStartPos, count: totalPoints)
        breathSensor = [Double](repeating: 0.0, count: totalPoints)
        relativePosturePositionFiltered = [Double](repeating: 0.0, count: totalPoints)
        zSensor = [Double](repeating: 0.0, count: totalPoints)
        xSensor = [Double](repeating: 0.0, count: totalPoints)
        ySensor = [Double](repeating: 0.0, count: totalPoints)
        dampHistory = [Double](repeating: 0.0, count: totalPoints)
        rotationSensor = [Double](repeating: 0.0, count: totalPoints)
        currentPostureAngle = [Double](repeating: 0.0, count: totalPoints)
        guidedPath = [Double](repeating: 0.0, count: totalPoints)
        whenBreathsEnd = [Double]()
        whenBreathsEnd.append(0)
        
        relativeInhaleLevelSG = 0.0
        relativeInhaleLevelRS = 0.0
        bellyBreathHasStarted = 0
        upStreak = 0
        downStreak = 0
        upStreakStart = 0
        downStreakStart = 0
        bottomReversalY = yStartPos
        topReversalY = 0
        isDrawTop = false
        isDrawBottom = false
        stuckBreaths = 0
        endBreathY = 0
        bottomReversalFound = 0
        topReversalFound = 0
        scrollX = 0
        currentStrainGaugeLowest = 0
        currentStrainGaugeHighest = 0
        breathEnding = 0
        strainGauge = 1
        uprightPostureAngle = 0
        uprightSet = 0
        xPos = 0
        whichPostureFrame = 1
        useRotationSensor = 0
        postureRange = 0.18
        postureAttenuator = 0.15
        smoothBreathingCoef = 1
        lightBreathsInARow = 0
        deepBreathsInARow = 0
        damp = 0
        dampX = 0
        dampY = 0
        dampZ = 0
        noisyMovements = 0
        dampingLevel = 0
        postureAttenuatorLevel = 0
        currentStrainGaugeLowestNew = 0
        currentStrainGaugeHighestNew = 0
        newStrainGaugeRange = 0
        currentStrainGaugeHighestPrev = 0
        breathTopExceeded = 0
        strainGaugeMinRange = 0.0005
        birdDeltaY = 0
        birdVelocity = 0
        timeElapsed = Date().timeIntervalSince1970
        respRate = 0
        breathCount = 0
        stuckBreathsThreshold = 1
        breathTopExceededThreshold = 1
        smoothBreathingCoefBaseLevel = 0.15
        postureIsGood = 1
        minBreathRange = Double(fullBreathGraphHeight/16)
        reversalThreshold = 6
        birdIncrements = 20
        avgRespRate = 0
        
        // from startMode()
        currentStrainGaugeHighest = currentStrainGaugeLowest + 0.003
        currentStrainGaugeHighestPrev = currentStrainGaugeHighest
        currentStrainGaugeLowestNew = currentStrainGaugeLowest
        currentStrainGaugeHighestNew = currentStrainGaugeHighest
        
        stuckBreathsThreshold = 1
        breathTopExceededThreshold = 1
        minBreathRange = fullBreathGraphHeight/16.0
        
        PranaDeviceManager.shared.addDelegate(self)
    }
    
    deinit {
        PranaDeviceManager.shared.removeDelegate(self)
    }
    
    func displayDebugStats() {
        let strln1: String = "strainGauge = " + String(roundNumber(num: strainGauge, dec: 100000)) + "  magneticAngle = " + String(roundNumber(num: rotationSensor[count], dec: 1000)) + " " + String(useRotationSensor)
        let strln2: String = "Z = " + String(roundNumber(num: zSensor[count], dec: 1000)) + "  Y = " + String(roundNumber(num: ySensor[count], dec: 1000)) + "  X = " + String(roundNumber(num: xSensor[count], dec: 1000)) + "  " + String(roundNumber(num: currentPostureAngle[count], dec: 1000))
        let strln3: String = String(roundNumber(num: currentStrainGaugeHighest, dec: 100000)) + "  " + String(roundNumber(num: currentStrainGaugeLowest, dec: 100000)) + "  " + String(roundNumber(num: currentStrainGaugeHighest - currentStrainGaugeLowest, dec: 100000)) + "  " + String(breathTopExceeded) + " noisy " + String(dampingLevel) + " stuck " + String(stuckBreaths)
        let strln4: String = ""
        
    }
    
    func resetCount() {
        
        if (count == totalPoints) {
            xSensor.removeFirst()
            ySensor.removeFirst()
            zSensor.removeFirst()
            currentPostureAngle.removeFirst()
            rotationSensor.removeFirst()
            breathSensor.removeFirst()
            graphYSeries.removeFirst()
            dampHistory.removeFirst()
            relativePosturePositionFiltered.removeFirst()
            
            xSensor.append(0.0)
            ySensor.append(0.0)
            zSensor.append(0.0)
            currentPostureAngle.append(0.0)
            rotationSensor.append(0.0)
            breathSensor.append(0.0)
            graphYSeries.append(0.0)
            dampHistory.append(0.0)
            relativePosturePositionFiltered.append(0.0)
            
            count = totalPoints - 1
        }
    }
    
    func storeSensorData(sensorData: [Double]) {
        
        dataArray = sensorData
        
        count += 1
        
        resetCount()
        
        if (count < initialPrepareCount) {
            xSensor[count] = dataArray[3]
            ySensor[count] = dataArray[2]
            zSensor[count] = dataArray[4]
            
            if (xSensor[count] == 0 && ySensor[count] == 0) {
                currentPostureAngle[count] = 2*(asin(zSensor[count]/Double.pi))
            } else {
                currentPostureAngle[count] = 2*(atan(zSensor[count]/sqrt(pow(xSensor[count], 2) + pow(ySensor[count], 2)))/Double.pi)
            }
            
            rotationSensor[count] = -Double(dataArray[5])
            breathSensor[count] = 2.0 - Double(dataArray[1]);     //strainGauge = Number(dataArray[4]); Use this version instead if signal INCREASES when inhaling
            
            graphYSeries[count] = yStartPos
            dampHistory[count] = 1
            relativePosturePositionFiltered[count] = currentPostureAngle[count]
            currentStrainGaugeLowest = strainGauge
            currentStrainGaugeHighest = currentStrainGaugeLowest + 0.003
            currentStrainGaugeHighestPrev = currentStrainGaugeHighest
        } else {
            xSensor[count] = 0.5*Double(dataArray[3]) + (1.0-0.5)*xSensor[count-1]
            ySensor[count] = 0.5*Double(dataArray[2]) + (1.0-0.5)*ySensor[count-1]
            zSensor[count] = 0.5*Double(dataArray[4]) + (1.0-0.5)*zSensor[count-1]
            
            if (xSensor[count] == 0 && ySensor[count] == 0) {
                currentPostureAngle[count] = 2*(asin(zSensor[count])/Double.pi)
            } else {
                currentPostureAngle[count] = 2*(atan(zSensor[count]/sqrt(pow(xSensor[count], 2)+pow(ySensor[count], 2)))/Double.pi)
            }
            
            rotationSensor[count] = 0.5*(-Double(dataArray[5])) + (1.0-0.5)*rotationSensor[count-1]
            breathSensor[count] = 0.5*(2-Double(dataArray[1])) + (1.0-0.5)*breathSensor[count-1]
        }
        
        strainGauge = breathSensor[count]
        
        if (count == initialPrepareCount) {
            currentStrainGaugeHighest = currentStrainGaugeLowest + 0.003
            currentStrainGaugeHighestPrev = currentStrainGaugeHighest
        }
        
        if (count > (initialPrepareCount + 1)) {
            if (abs(rotationSensor[count] - rotationSensor[count-(initialPrepareCount + 1)]) > 0.3) {
                useRotationSensor = 1
            } else {
                if (useRotationSensor == 1) {
                    useRotationSensor = 0
                }
            }
        }
    }
    
    func setSmoothingAndDamping() {
        
        dampX = 0.005/abs(xSensor[count]-xSensor[count-3])
        dampY = 0.005/abs(ySensor[count]-ySensor[count-3])
        dampZ = 0.005/abs(zSensor[count]-zSensor[count-3])
        
        damp = min(dampX, dampY, dampZ)
        
        if (damp > 1) {
            damp = 1
        }
        
        dampHistory[count] = damp
        
        if (dampHistory[count] < 0.4) {
            dampingLevel += 1
        } else {
            dampingLevel -= 1
        }
        
        if (dampingLevel > 10) {
            dampingLevel = 10
        } else if (dampingLevel < 0) {
            dampingLevel = 0
        }
        
        if (appMode != 3) {   //Don't set noisyMovements during Buzzer Training, because a noisy movement is almost gauranteed during a breath cycle due to the buzzer occuring at some point (hard to be sure isBuzzing would eliminate that, really need to add a buzzer flag status to the datastream to be sure).
            if (dampingLevel >= 7) {
                noisyMovements = 1
            }
        }
        
        if (topReversalFound == 1) {
            smoothBreathingCoef = smoothBreathingCoefBaseLevel
        } else {
            smoothBreathingCoef = smoothBreathingCoefBaseLevel - 0.05
        }
        
        if (isBuzzing == 0) {
            var a: Double = 0
            if (dampingLevel > 0) {
                smoothBreathingCoef = smoothBreathingCoef*Double(truncating: pow(0.8, dampingLevel) as NSNumber)
                
                a = (currentStrainGaugeHighest - currentStrainGaugeLowest) / 0.015
                
                if (a>0 && a<1) {
                    smoothBreathingCoef = smoothBreathingCoef * a
                }
            }
        }
    }
    
    func setRelativeInhaleLevelStrainGauge() {
        
        relativeInhaleLevelSG = (strainGauge-currentStrainGaugeLowest) / (currentStrainGaugeHighest-currentStrainGaugeLowest)
        
        if (relativeInhaleLevelSG > 1) {
            relativeInhaleLevelSG = 1
            
            currentStrainGaugeHighest = 0.5*strainGauge + (1-0.5)*currentStrainGaugeHighest
            
            if ((currentStrainGaugeHighest-currentStrainGaugeLowest) < strainGaugeMinRange) {
                currentStrainGaugeHighest = currentStrainGaugeLowest + strainGaugeMinRange
            }
        } else if (relativeInhaleLevelSG < 0) {
            relativeInhaleLevelSG = 0
            
            currentStrainGaugeHighest = (currentStrainGaugeHighest - currentStrainGaugeLowest) + strainGauge
            currentStrainGaugeLowest = strainGauge
            
            if ((currentStrainGaugeHighest-currentStrainGaugeLowest) < strainGaugeMinRange) {
                currentStrainGaugeHighest = currentStrainGaugeLowest + strainGaugeMinRange
            }
        } else if (relativeInhaleLevelSG < 0.05 && !((breathSensor[count] > breathSensor[count-1]) && (breathSensor[count-1] > breathSensor[count-2]) && (breathSensor[count-2] > breathSensor[count-3]) && (breathSensor[count-3] > breathSensor[count-4]) && (breathSensor[count-4] > breathSensor[count-5]) && (breathSensor[count-5] > breathSensor[count-6]) ) ) {
            
            relativeInhaleLevelSG = 0
            
            currentStrainGaugeHighest = (currentStrainGaugeHighest - currentStrainGaugeLowest) + strainGauge;
            
            currentStrainGaugeLowest = strainGauge
            
            if (currentStrainGaugeHighest-currentStrainGaugeLowest < strainGaugeMinRange) {
                currentStrainGaugeHighest = currentStrainGaugeLowest + strainGaugeMinRange
            }
        }
    }
    
    func displayBreathingGraph() {
        
        graphY = -Double(fullBreathGraphHeight)*relativeInhaleLevelSG + Double(yStartPos)
        let beforeValue = graphYSeries[count-1]
        let value = smoothBreathingCoef*graphY + (1.0 - smoothBreathingCoef)*beforeValue
        graphYSeries[count] = value
        
        for item in self.delegates {
            item.liveNewBreathingCalculated()
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
                postureAttenuatorLevel += 1
                
                if (postureAttenuatorLevel > 5) {
                    postureAttenuatorLevel = 5
                }
            } else {
                postureAttenuatorLevel -= 1
                if (postureAttenuatorLevel < 0) {
                    postureAttenuatorLevel = 0
                }
            }
            
            switch (postureAttenuatorLevel) {
            case 1:
                postureAttenuator = postureAttenuator * 0.7
                break;
            case 2:
                postureAttenuator = postureAttenuator * 0.7*0.8
                break
            case 3:
                postureAttenuator = postureAttenuator * 0.7*0.8*0.8
                break
            case 4:
                postureAttenuator = postureAttenuator * 0.7*0.8*0.8*0.8
                break
            case 5:
                postureAttenuator = postureAttenuator * 0.7*0.8*0.8*0.8*0.8
                break
            default:
                break;
            }
            
            relativePosturePositionFiltered[count] = Double(postureAttenuator * currentPostureAngle[count] + (1-postureAttenuator) * relativePosturePositionFiltered[count-1])
            xPos = Int(Double(Constants.maxXOfPosture)*(1-(abs(relativePosturePositionFiltered[count] - uprightPostureAngle)/postureRange)))
            
            if (xPos > Int(Constants.maxXOfPosture)) {
                xPos = Int(Constants.maxXOfPosture)
            }
            if (xPos < 0) {
                xPos = 0
            }
            
            for item in self.delegates {
                item.liveNewPostureCalculated()
            }

            whichPostureFrame = Int(round(30*((Constants.maxXOfPosture - Float(xPos))/Constants.maxXOfPosture)));
            
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
            
        } else {
            if (xSensor[count] == 0 && ySensor[count] == 0) {
                relativePosturePositionFiltered[count] = 2*(sin(zSensor[count])/Double.pi)
            } else {
                relativePosturePositionFiltered[count] = 2*(atan(zSensor[count]/sqrt(pow(xSensor[count],2) + pow(ySensor[count], 2)))/Double.pi)
            }
        }
    }
    
    func processBreathingPosture(sensorData: [Double]) {
        
        storeSensorData(sensorData: sensorData)
        
        if (count < 5) {
            return
        }
        
        setSmoothingAndDamping()
        setRelativeInhaleLevelStrainGauge()
        displayPostureIndicator()
        displayBreathingGraph()
        reversalDetector()
        displayDebugStats()

        if (breathEnding == 1) {
            if (graphYSeries[count] > endBreathY) {
                //                endBreathLine
                stuckBreaths = 0
                breathEnding = 0
                breathCount += 1
                calculateRespRate()
                setNewStrainGaugeRange()
                
                noisyMovements = 0
                currentStrainGaugeLowest = strainGauge
            }
        }
    }
    
    func calculateRespRate() {
        let now = Date().timeIntervalSince1970
        
        let elapsed = now - timeElapsed
        
        whenBreathsEnd.append(elapsed)
        
        if (breathCount > 2 && breathCount < 5) {
            respRate = 2 * (60.0 / (whenBreathsEnd[breathCount] - whenBreathsEnd[breathCount-2]))
        } else if (breathCount >= 5) {
            respRate = 4 * (60.0 / (whenBreathsEnd[breathCount] - whenBreathsEnd[breathCount-4]))
            avgRespRate = 60*(Double(breathCount)/elapsed)
        }
        
        respRate = roundNumber(num:respRate, dec:10.0)
        avgRespRate = roundNumber(num:avgRespRate, dec:10.0)
        
        for item in self.delegates {
            item.liveNewRespRateCaclculated()
        }
    }
    
    func setNewStrainGaugeRange() {
        var rangeSet:Int = 0
        
        newStrainGaugeRange = currentStrainGaugeHighestNew - currentStrainGaugeLowestNew
        
        if noisyMovements == 0 { //do not set the range to be more sensitive when noisy movements
            
            if newStrainGaugeRange < (0.70*(currentStrainGaugeHighest - currentStrainGaugeLowest)) {
                
                lightBreathsInARow += 1
                breathTopExceeded = 0
                
                if lightBreathsInARow > 1 {
                    
                    rangeSet = 1
                    currentStrainGaugeLowest = 0.5*currentStrainGaugeLowestNew + (1-0.5)*currentStrainGaugeLowest
                    currentStrainGaugeHighest = 0.5*currentStrainGaugeHighestNew + (1-0.5)*currentStrainGaugeHighest
                    
                    if ( (currentStrainGaugeHighest - currentStrainGaugeLowest) < strainGaugeMinRange) {
                        currentStrainGaugeHighest = currentStrainGaugeLowest + strainGaugeMinRange
                    }
                    
                    
                }
                
            }
                
            else  {
                
                lightBreathsInARow = 0;  //Also do not reset this when noisy movements
            }
        }
        
        
        
        
        if (rangeSet == 0) {
            if (noisyMovements == 0) {
                
                if ( (currentStrainGaugeHighest-currentStrainGaugeLowest) > 1.5*(currentStrainGaugeHighestPrev-currentStrainGaugeLowest)) {
                    
                    breathTopExceeded += 1
                    lightBreathsInARow = 0
                    
                    if (breathTopExceeded > breathTopExceededThreshold) {
                        currentStrainGaugeHighest = ((0.3*currentStrainGaugeHighest + (1-0.3)*currentStrainGaugeHighestPrev) - currentStrainGaugeLowest) + strainGauge
                    }
                    else {
                        currentStrainGaugeHighest = (currentStrainGaugeHighestPrev - currentStrainGaugeLowest) + strainGauge //Since currentStrainGaugeLowest is being set to strainGauge below, this preserves the range but relative to the new floor.
                    }
                }
                    
                else {
                    breathTopExceeded = 0
                }
            }
            else {
                currentStrainGaugeHighest = (currentStrainGaugeHighestPrev - currentStrainGaugeLowest) + strainGauge //Since currentStrainGaugeLowest is being set to strainGauge below, this preserves the range but relative to the new floor.
            }
        }
        
        
    }
    
    func reversalDetector() {
        
        if (count <= reversalThreshold + 1) {
            return
        }
        
        var up:Int = 0
        var down:Int = 0
        //        var i:Int = 0
        
        if (upStreak == 0) {
            for i:Int in 0...reversalThreshold {
                if (graphYSeries[count-i] < graphYSeries[count-i-1]) {
                    up += 1
                    if (up == reversalThreshold+1) {
                        upStreak = 1
                        upStreakStart = count - (reversalThreshold + 1)
                    }
                }
            }
        }
        
        if (downStreak == 0) {
            for i:Int in 0...reversalThreshold {
                if (graphYSeries[count-i] > graphYSeries[count-i-1]) {
                    down += 1;
                    if (down == reversalThreshold+1) {
                        downStreak = 1;
                        downStreakStart = count-(reversalThreshold+1);
                    }
                }
            }
        }
        
        if (up == (reversalThreshold+1)) {
            if (downStreak == 1) {
                downStreak = 0
                bottomReversalFound = 1
                bottomReversalY = graphYSeries[downStreakStart]
                
                currentStrainGaugeLowestNew = breathSensor[count - (reversalThreshold+2)]
                
                if downStreakStart <= upStreakStart {
                    for i:Int in downStreakStart...upStreakStart {
                        if (graphYSeries[i] > bottomReversalY) {
                            bottomReversalY = graphYSeries[i]
                        }
                    }
                }
                
                
                //                bottomReversalLine.y = bottomReversalY
                //                topReversalLine.y = 5000
                isDrawTop = false
                isDrawBottom = true
                
                if (breathEnding == 1) {
                    stuckBreaths += 1
                }
                
                if (stuckBreaths == 0) {
                    currentStrainGaugeHighestPrev = currentStrainGaugeHighest
                }
                
                topReversalFound = 0
            }
        }
        
        if (down == (reversalThreshold+1)) {
            if (upStreak == 1) {
                upStreak = 0
                topReversalY = graphYSeries[upStreakStart]
                
                if upStreakStart <= downStreakStart {
                    for i:Int in upStreakStart...downStreakStart {
                        if (graphYSeries[i] < topReversalY) {
                            topReversalY = graphYSeries[i]
                        }
                    }
                }
                
                
                if ( ((bottomReversalY-topReversalY < minBreathRange) && (stuckBreaths > 0)) || (yStartPos-topReversalY < (minBreathRange/3)) ) {
                    return
                }
                
                topReversalFound = 1
                
                currentStrainGaugeHighestNew = breathSensor[count-(reversalThreshold+2)]
                
                //                topReversalLine.y = topReversalY
                isDrawBottom = false
                isDrawTop = true
                
                if (bottomReversalFound == 1 || breathCount < 2) {
                    bottomReversalFound = 0
                    breathEnding = 1
                    
                    if breathCount < 2 {
                        endBreathY = bottomReversalY - 0.95 * (bottomReversalY - topReversalY)
                    } else if (appMode == 2) {
                        //
                    } else if (appMode == 1 || appMode == 3) {
                        endBreathY = bottomReversalY - 0.2*(bottomReversalY-topReversalY)
                        
                        if (noisyMovements == 1) {
                            endBreathY = bottomReversalY - 0.5*(bottomReversalY - topReversalY)
                        }
                        
                        if (stuckBreaths >= stuckBreathsThreshold) {
                            endBreathY = bottomReversalY - 0.5*(bottomReversalY - topReversalY)
                        }
                    }
                    
                    //                    endBreathLine.y = endBreathY
                }
            }
        }
    }
    
    func setPostureResponsiveness(val: Int) {
        switch(val) {
        case 1:
            postureRange = 0.15
        case 2:
            postureRange = 0.1
        case 3:
            postureRange = 0.05
        default:
            break
        }
    }
    
    func setBreathingResponsiveness(val: Int) {
        switch(val) {
        case 1:
            smoothBreathingCoefBaseLevel = 0.15
            reversalThreshold = 6
            birdIncrements = 24
        case 2:
            smoothBreathingCoefBaseLevel = 0.4
            reversalThreshold = 5
            birdIncrements = 20
        case 3:
            smoothBreathingCoefBaseLevel = 0.6
            reversalThreshold = 3
            birdIncrements = 12
        default:
            break
        }
    }
    
    func learnUprightAngleHandler()  {
        if (count < 0) {
            return
        }
        
        uprightSet = 1;
        
        if (xSensor[count] == 0 && ySensor[count] == 0) {
            uprightPostureAngle = 2*(asin(zSensor[count])/Double.pi);
        }
        else {
            uprightPostureAngle = 2*(atan(zSensor[count]/sqrt(pow(xSensor[count],2)+pow(ySensor[count],2)))/Double.pi);
        }
        
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
        
    }
    
    func roundNumber(num:Double, dec:Double) -> Double {
        return round(num*dec)/dec
    }
}

extension Live: PranaDeviceManagerDelegate {
    func PranaDeviceManagerDidStartScan() {
        
    }
    
    func PranaDeviceManagerDidStopScan(with error: String?) {
        
    }
    
    func PranaDeviceManagerDidDiscover(_ device: PranaDevice) {
        
    }
    
    func PranaDeviceManagerDidConnect(_ deviceName: String) {
        
    }
    
    func PranaDeviceManagerFailConnect() {
        
    }
    
    func PranaDeviceManagerDidOpenChannel() {
        
    }
    
    func PranaDeviceManagerDidReceiveData(_ parameter: CBCharacteristic) {
        
    }
    
    func PranaDeviceManagerDidReceiveLiveData(_ data: String!) {
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
            paras.append(0.0)
            
            processBreathingPosture(sensorData: paras)
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
            setUprightButtonPush(sensorData: paras)
        }
    }
    
    
}
