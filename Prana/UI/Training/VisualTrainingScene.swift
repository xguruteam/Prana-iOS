//
//  VisualTrainingScene.swift
//  Prana
//
//  Created by Luccas on 3/21/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion


protocol VisualDelegate: class {
    func visualUprightHasBeenSet()
    func visualOnComplete()
    func visualOnTimer(v: Int)
    func visualNewTargetRateCalculated(rate: Double)
    func visualNewActualRateCalculated(rate: Double)
    func visualNewSessionAvgRRCalculated(rate: Double)
    func visualNewBreathDone(total: Int, mindful: Int)
    func visualPostureFrameCalculated(frameIndex: Int)
    func visualUprightTime(uprightPostureTime: Int, elapsedTime: Int)
    func visualNewSlouches(slouches: Int)
    func visualBattery(battery: Int)
}

public class Flower {
    var x: Double = 0.0
    var y: Double = 0.0
    var node: SKSpriteNode!
    var show: Bool = false
    
    init(x: Double, y: Double, c: Int) {
        self.x = x
        self.y = y
        
        let texture1: SKTexture = SKTexture(imageNamed: "fr01")
        texture1.filteringMode = .nearest
        let texture2: SKTexture = SKTexture(imageNamed: "fy01")
        texture2.filteringMode = .nearest
        
        if c == 0 {
            node = SKSpriteNode(texture: texture1)
            node.name = "flower1"
            node.setScale(VisualTrainingScene.Constants.FLOWER_SCALE)
        } else {
            node = SKSpriteNode(texture: texture2)
            node.name = "flower2"
            node.setScale(VisualTrainingScene.Constants.FLOWER_SCALE * texture1.size().height/texture2.size().height)
        }
        
        let p: CGPoint = VisualTrainingScene.convertFlowerY(x: x, y: y)
        node.position = CGPoint(x: p.x, y: p.y)
    }
}

public class Breath {
    var flowers: [[Flower]]!
    var rate: Double = 0.0
    var whichFlower: Int = 0
}


class VisualTrainingScene: SKScene {
    
    struct Constants {
        static let FRAMES_FLOWER: Int = 30
        static let FRAMES_BIRD: Int = 15
        static let FLOWER_SCALE: CGFloat = 0.5
    }
    
    var objLive: Live?
    
    weak var visualDelegate: VisualDelegate?
    
    var isBreathingOnly = false
    
    var _timer: RepeatingTimer?
    
    var label : SKLabelNode?
    var spinnyNode : SKShapeNode?
    
    var _started: Bool = false
    var _playOrPause: Bool = false
    var _playRegionY: CGFloat = 0
    var _playRegionH: CGFloat = 0
    
    var _birdX: CGFloat = 80.0
    
    var _bird: SKSpriteNode!
    
    var _bgCount: Int = 0
    var _bgWidth: CGFloat = 0.0
    
    var _flowerTexture1: SKTexture?
    var _flowerTexture2: SKTexture?
    var _flapAndRemoveFlowers1: SKAction?
    var _flapAndRemoveFlowers2: SKAction?
    var _moveAndRemoveFlowers: SKAction?
    
    var _calibrationRegion: SKSpriteNode?
    var _calibrationRegionLabel: SKLabelNode?
    var _messageNode: SKLabelNode!
    var _patternNameNode: SKLabelNode!
    var patternName: String!
    
    var _backgrounds: [SKSpriteNode]!
    
    var newGraphY: Double = 0
    var isAutoReset = false
    
    //
    var flyingObjects: [Breath] = []
    var breaths: Int = 0
    var goodBreaths: Int = 0
    var breathsOnCurrentLevel: Int = 0
    
    var startBreathThreshold: Int = -49
    var minBreathDepth: Int = 0
    var maxBreathDepth: Int = 0
    var inhalationTime: Double = 0.0
    var retentionTime: Double = 0.0
    var exhalationTime: Double = 0.0
    var timeBetweenBreaths: Double = 0.0
    var lastX: Double = 200.0
    
    var targetsHit: Int = 0
    var whichFlower: Int = 0
    var fullBreathGraphHeight: Double = 100.0
    var yStartPos: Double = 100.0
    var whichPattern: Int = 0
    var updatePatternsStage: Int = 0
    var updateBreathPatterns: Int = 0
    var xStep: Double = 22.5
    var flowerHeight: Double = 25.0
    var mindfulBreathCount: Int = 0
    var initialFadeIn: Int = 0
    var totalBreaths: Int = 0
    var subPattern: Int = 0
    var trainingPosture: Int = 0
    var trainingDuration: Int = 0
    var uprightPostureTime: Int = 0
    var gameSetTime: Int  = 0
    var prevPostureState: Int = 0
    var slouchesCount: Int = 0
    var hasUprightBeenSet: Int = 0
    var enterFrameCount: Int = 0
    var secondCounter: Int = 0
    var xd: Double = 0.75
    
    var _curYPosLive: Double = 0.0
    var _guidedPath: [Double] = []
    
    var _isUprightSet = false
    
    var _calibrationRegionWidth: Double = 600
    
    var initialMessage: String?
    
    var skipCalibration:Int = 0;  //may 8th  For visual training, if this is set to 1, it causes the function addCalibrationBreathRegion() not to run, which skips the initial 15 second respiration assessment. If whichPattern = 0 (Slowing pattern), and skipCalibration is 1, then startSubPattern and maxSubPattern determine the initial respiration rate and minimum respiration rate
    var startSubPattern:Int = 5; //may 8th  The example value 5 here corresponds to 12bpm. Note, for Buzzer Training, if the non-custom Slowing pattern is used, then this value should be set to 5
    var maxSubPattern:Int = 34; //may 8th  SET THIS TO THE INDEX VALUE found under //Dynamic slow breathing pattern below, between 0-34. This value corresponds TO THE MINIMUM RESPIRATION RATE SELECTED ON THE CUSTOM BREATH PATTERN PAGE. This value should be 34 if skipCalibration = 0. The example value 8 here corresponds to 9.2bpm
    var customSlowingPatternIsActive:Int = 0; //July 13:New1i  When user is using the Slowing Pattern from the pattern gallery (custom), then this should be set to 1. In this case, the first breathing pattern is set to startSuaddbPattern, and maxSubPattern should also be set based on user selection on the custom pattern screen (15 second calibration is never skipped now for any pattern)
    
    var breathLevel:Int = 2;  //AUG 1st ADDED
    var startRecordingActualBreaths:Int = 0; //AUG 12th NEW
    var savedCurrentBreaths:Int = 0; //AUG 12th NEW
//    var breathingGraph:MovieClip = new MovieClip(); //AUG 12th NEW
//    var postureGraph:MovieClip = new MovieClip(); //AUG 12th NEW
    var lastXForActualBreath:Double = 0; //AUG 12th NEW
    var lastYForActualBreath:Double = 0; //AUG 12th NEW
    var previousExpectedBreathStartTime:Double = 0; //AUG 12th NEW
    var previousExpectedBreathRR:Double = 0; //AUG 12th NEW
    var postureSessionTime:Int = 0; //AUG 12th NEW
    var enteredPatternWhileExhaling:Int = 0; //AUG 12th NEW
    
    convenience init(_ trainingDuration: Int, isBreathingOnly: Bool = false) {
        self.init()
        self.trainingDuration = trainingDuration
        self.isBreathingOnly = isBreathingOnly
    }
    
    deinit {
    }
    
    open func setUpright() {
        objLive?.learnUprightAngleHandler()
    }
    
    open func setBreathSensitivity(_ val: Int) {
        objLive?.setBreathingResponsiveness(val: val)
    }
    
    open func setPostureSensitivity(_ val: Int) {
        objLive?.setPostureResponsiveness(val: val)
    }
    
    override func didMove(to view: SKView) {
        
        // maybe set name of the breathing pattern in ViewController
        
        slouchesCount = 0
        uprightPostureTime = 0
        hasUprightBeenSet = 0
        totalBreaths = 0
        
//        trainingDuration = 180
        self.visualDelegate?.visualOnTimer(v: trainingDuration)
        
        mindfulBreathCount = 0
        gameSetTime = trainingDuration
        
        self._playOrPause = false
        
        _birdX = 100
        lastX = 200
        
        xStep = 22.5
//        _calibrationRegionWidth = xStep * 34.0
        
        xd = xStep / 30 // ???
        
        yStartPos = 140.0
        fullBreathGraphHeight = 175.0
        
        //
        self._playRegionY = CGFloat(yStartPos)
        self._playRegionH = CGFloat(fullBreathGraphHeight)
        
        let objLiveGraph = Live()
        objLive = objLiveGraph
        objLive?.addDelegate(self)
        objLive?.setBreathingResponsiveness(val: 2)
        objLive?.appMode = 2
        objLive?.calibrationBreathsDone = 0
        
        startRecordingActualBreaths = 0; //AUG 12th NEW
        savedCurrentBreaths = 0; //AUG 12th NEW
        objLiveGraph.graphStartTime = 0;  //AUG 12th New
        
        objLive?.startMode()
        
        objLiveGraph.breathTopExceededThreshold = 0; //AUG 1st NEW
        objLiveGraph.lightBreathsThreshold = 0; //AUG 1st NEW
        objLiveGraph.minBreathRange = objLiveGraph.fullBreathGraphHeight/16; //AUG 1st
        objLiveGraph.minBreathRangeForStuck = (objLiveGraph.fullBreathGraphHeight/16); //AUG 1st
        
        // Clibration Region
        _calibrationRegion = SKSpriteNode(color: UIColor.black, size: CGSize(width: _calibrationRegionWidth, height: 32))
        _calibrationRegion?.position = CGPoint(x: CGFloat(lastX) + _calibrationRegion!.size.width / 2, y: _playRegionY + _playRegionH/2)
        _calibrationRegion?.name = "calibration"
        
        _calibrationRegionLabel = SKLabelNode(text: initialMessage)
        _calibrationRegionLabel?.color = .white
        _calibrationRegionLabel?.fontName = "Quicksand"
        _calibrationRegionLabel?.fontSize = 16
        _calibrationRegionLabel?.position = CGPoint(x: 0, y: 0)
        _calibrationRegionLabel?.horizontalAlignmentMode = .center
        _calibrationRegionLabel?.verticalAlignmentMode = .center
        _calibrationRegion?.addChild(_calibrationRegionLabel!)
        _calibrationRegion?.size = CGSize(width: _calibrationRegionWidth, height: 32)

        

        _flowerTexture1 = SKTexture(imageNamed: "fr01")
        _flowerTexture1!.filteringMode = SKTextureFilteringMode.nearest
        
        _flowerTexture2 = SKTexture(imageNamed: "fy01")
        _flowerTexture2!.filteringMode = SKTextureFilteringMode.nearest
        
        let removeFlowers: SKAction = SKAction.hide()
        
        var texture: SKTexture?
        var flowerTextures1: [SKTexture] = []
        var flowerTextures2: [SKTexture] = []
        for i in 1...Constants.FRAMES_FLOWER {
            texture = SKTexture(imageNamed: String(format: "fr%02d", i))
            flowerTextures1.append(texture!)
            texture = SKTexture(imageNamed: String(format: "fy%02d", i))
            flowerTextures2.append(texture!)
        }
        
        let flapFlowersAction1: SKAction = SKAction.repeat(SKAction.animate(with: flowerTextures1, timePerFrame: 0.02), count: 1)
        _flapAndRemoveFlowers1 = SKAction.sequence([flapFlowersAction1, removeFlowers])
        
        let flapFlowersAction2: SKAction = SKAction.repeat(SKAction.animate(with: flowerTextures2, timePerFrame: 0.02), count: 1)
        _flapAndRemoveFlowers2 = SKAction.sequence([flapFlowersAction2, removeFlowers])
        
        createBackground()
        createBird()
        
        startSession()
        
        _messageNode = SKLabelNode(text: "First tap Set Upright to set your upright posture")
        _messageNode.position = CGPoint(x: size.width / 2, y: size.height * 3 / 4)
        _messageNode.color = .white
        _messageNode.fontName = "Quicksand-Bold"
        _messageNode.fontSize = 24
        _messageNode.zPosition = 20
        
        _patternNameNode = SKLabelNode(text: patternName)
        _patternNameNode.position = CGPoint(x: size.width / 2, y: _messageNode.position.y - 30)
        _patternNameNode.color = .white
        _patternNameNode.fontName = "Quicksand-Bold"
        _patternNameNode.fontSize = 18
        _patternNameNode.zPosition = 20
        
        if isBreathingOnly {
            _isUprightSet = true
            // enable start
            self.visualDelegate?.visualUprightHasBeenSet()
        }
        else {
            addChild(_messageNode)
        }
        
        addChild(_patternNameNode)
    }
    
    func createBird() {
        var texture: SKTexture
        var birdTextures: [SKTexture] = []
        for i in 1...Constants.FRAMES_BIRD {
            texture = SKTexture(imageNamed: String(format: "bird%02d", i))
            birdTextures.append(texture)
        }
        let flapAction: SKAction = SKAction.repeatForever(SKAction.animate(with: birdTextures, timePerFrame: 0.03))
        
        _bird = SKSpriteNode(texture: birdTextures[0])
        _bird.name = "bird"
        _bird.position = CGPoint(x: _birdX, y: _playRegionY)
        _bird.zPosition = 10
        _bird.setScale(1.0)
        _bird.run(flapAction)
        
        addChild(_bird)
        
    }
    
    
    
    func createBackground() {
        _backgrounds = []
        let backgroundTexture: SKTexture = SKTexture(imageNamed: "game-background")
        backgroundTexture.filteringMode = SKTextureFilteringMode.nearest
        let s: CGFloat = size.height / backgroundTexture.size().height
        
        _bgWidth = backgroundTexture.size().width * s
        let bg_height = size.height
        _bgCount = Int(size.width / _bgWidth + 2)
        
        var i = _bgCount
        while i > 0 {
            let sprite: SKSpriteNode = SKSpriteNode.init(texture: backgroundTexture)
            sprite.name = "background"
            sprite.setScale(s)
            sprite.position = CGPoint(x: CGFloat(i) * _bgWidth - _bgWidth / 2, y: bg_height/2)
            sprite.size.width = _bgWidth + CGFloat(5)
            sprite.zPosition = -10
            addChild(sprite)
            _backgrounds.append(sprite)
            i -= 1
        }
    }
    
    //
    override func update(_ currentTime: TimeInterval) {
        if _playOrPause {
            scrollAndUpdate()
            
            moveBackground()
            moveBird()
        }
    }
    
    func scrollAndUpdate() {
        
        guard let objLiveGraph = objLive else { return }
        
        lastX = lastX - xd
        
        self.visualDelegate?.visualNewActualRateCalculated(rate: (objLive?.respRate)!)
        
        if updateBreathPatterns == 1 {
            updateNextBreaths()
        }
        
        if initialFadeIn == 1 {
            fadeInPatterns()
        }
        
        for breath in flyingObjects {
            for column in breath.flowers {
                for flower in column {
                    flower.x -= xd
                    flower.node.position.x = CGFloat(flower.x)
                    
                    if (flower.node.position.x < size.width + (flower.node.texture?.size().width)!*VisualTrainingScene.Constants.FLOWER_SCALE/2.0 && !flower.show) {
                        flower.show = true
                        
                        addChild(flower.node)
                    }
                }
            }
        }
        
        //may 8th **************
        if (objLive?.calibrationBreathsDone == 0 && skipCalibration == 1) {
            
            _calibrationRegion!.position.x -= CGFloat(xd)
            
            if (_calibrationRegion?.position.x)! + _calibrationRegion!.frame.size.width/2 < (_birdX - 50) {
                _calibrationRegion?.removeFromParent()
                
                objLive?.calibrationBreathsDone = 1;
                
                if (whichPattern == 0) {
                    
                    lastX = Double(size.width / 4.0)
                    
                    initialFadeIn = 1; //fade in initial patterns
                    
                    subPattern = startSubPattern;
                    createInitialSetOfBreathPatterns();
                    
                    self.visualDelegate?.visualNewTargetRateCalculated(rate: flyingObjects[0].rate)
                    
                    objLiveGraph.breathTopExceededThreshold = 1; //AUG 1st NEW  if you skip calibation, these should still be set
                    objLiveGraph.lightBreathsThreshold = 1; //AUG 1st NEW  if you skip calibation, these should still be set
                    objLiveGraph.minBreathRange = objLiveGraph.fullBreathGraphHeight/8; //AUG 1st NEW
                    objLiveGraph.minBreathRangeForStuck = (objLiveGraph.fullBreathGraphHeight/4); //AUG 1st NEW  (4 helps patterns like 478 when user holds breath between inhale/exhale, so that random body movements less likely to trigger stuck breath)
                }
            }
        }
        //may 8th **************

        else if (objLive?.calibrationBreathsDone == 0 && skipCalibration == 0) {    //may 8th
            _calibrationRegion!.position.x -= CGFloat(xd)
            
            if (_calibrationRegion?.position.x)! + _calibrationRegion!.frame.size.width/2 < (_birdX - 50) {
                _calibrationRegion?.removeFromParent()
                
                objLive?.calibrationBreathsDone = 1
                objLive?.breathTopExceededThreshold = 1; //JULY 13:NEW1f
                objLive?.lightBreathsThreshold = 1; //JULY 13:NEW1f
                objLiveGraph.minBreathRange = objLiveGraph.fullBreathGraphHeight/8; //AUG 1st NEW
                objLiveGraph.minBreathRangeForStuck = (objLiveGraph.fullBreathGraphHeight/4); //AUG 1st NEW
                
                
                if whichPattern == 0 {
                    initialFadeIn = 1
                    
                    lastX = Double(size.width / 4.0)
                    
                    if (objLiveGraph.timeElapsed - objLiveGraph.timeElapsedAtCalibrationStart > 0) { //Jan 24th 2020 NEW
                        objLiveGraph.calibrationRR = 60.0 * (Double(objLiveGraph.breathCount - objLiveGraph.breathCountAtCalibrationStart) / (objLiveGraph.timeElapsed - objLiveGraph.timeElapsedAtCalibrationStart)); //Jan 24th 2020 NEW
                        objLiveGraph.calibrationRR = roundNumber(num: objLiveGraph.calibrationRR, dec: 10); //Jan 24th 2020 NEW
                    } //Jan 24th 2020 NEW
                    else {  //Jan 24th 2020 NEW
                        objLiveGraph.calibrationRR = 12; //Jan 24th 2020 NEW
                    } //Jan 24th 2020 NEW
                    
                    if objLive!.calibrationRR >= 17.14 {
                        subPattern = 2
                        createInitialSetOfBreathPatterns()
                    } else if objLive!.calibrationRR <= 8 {
                        subPattern = 10
                        createInitialSetOfBreathPatterns()
                    } else {
                        for i in 0...Pattern.patternSequence[0].count {
                            let a: Double = Double(60.0/(Pattern.getPatternValue(value: Pattern.patternSequence[0][i][0]) + Pattern.getPatternValue(value: Pattern.patternSequence[0][i][1]) + Pattern.getPatternValue(value: Pattern.patternSequence[0][i][2]) + Pattern.getPatternValue(value: Pattern.patternSequence[0][i][3])))
                            if objLive!.calibrationRR > a {
                                subPattern = i
                                if (customSlowingPatternIsActive == 1) { //July 13:New1i
                                    subPattern = startSubPattern; //July 13:New1i
                                } //July 13:New1i
                                createInitialSetOfBreathPatterns()
                                break
                            }
                        }
                    }
                }
                
                self.visualDelegate?.visualNewTargetRateCalculated(rate: flyingObjects[0].rate)
            }
            
        } else if objLive?.calibrationBreathsDone == 1 {
            checkTargetsHit()
            
            let cols = flyingObjects[0].flowers.count
            let flowers = flyingObjects[0].flowers[cols-1].count
            let lastFlowerOfBreath = flyingObjects[0].flowers[cols-1][flowers-1].node
            let firstFlowerOfBreath = flyingObjects[0].flowers[0][0].node
            
            if ((firstFlowerOfBreath!.position.x <= (_birdX + CGFloat(xStep))) && (objLiveGraph.judgedBreaths.count == 0)) {   //AUG 12th NEW, when bird is 1/2 second before the first flower of the first pattern
                
                objLiveGraph.judgedBreaths.append(LiveBreath(target: nil, actuals: objLiveGraph.actualBreathsWithinAPattern, breathStatus: -1)); //AUG 12th NEW the concat() here is to copy the array (to avoid possible reference problem),saving all non-judged breaths here during 15 second calibration
                
                objLiveGraph.actualBreathsWithinAPattern = []; //AUG 12th NEW
                previousExpectedBreathStartTime = roundNumber(num: (objLiveGraph.timeElapsed-objLiveGraph.graphStartTime)+0.5,dec: 10); //AUG 12th NEW, the 0.5 here is to add back the 1/2 second due to 320+xStep above THIS IS THE EXPECTED OR TARGET breath
//                if temp_previousExpectedBreathStartTime > previousExpectedBreathStartTime { previousExpectedBreathStartTime = temp_previousExpectedBreathStartTime }
                enteredPatternWhileExhaling = objLiveGraph.breathEnding; //AUG 12th NEW, idea here is if user did not finish exhaling during last breath, and that exhale carries into the current breath, then the current breath is bad
                
                //DC.objLiveGraph.testUI.indicator4.txt1.text = String(DC.objLiveGraph.judgedBreaths.length);
                
            } //AUG 12th NEW
                
            else if ((lastFlowerOfBreath!.position.x <= _birdX+CGFloat(xStep)) && savedCurrentBreaths == 0) {   //AUG 12th NEW when bird is 1/2 second before the first flower of a pattern after the first pattern
                
                savedCurrentBreaths = 1; //AUG 12th NEW
                
                if (objLiveGraph.actualBreathsWithinAPattern.count == 0) { //AUG 12th NEW
                    
                    objLiveGraph.actualBreathsWithinAPattern = [CoreBreath(it: previousExpectedBreathStartTime, rr: 0)]; //AUG 12th NEW  If user did not breathe at all during the target breath, create a breath with 0 RR
                    
                }    //AUG 12th NEW
                
                
                if (objLiveGraph.judgedBreaths.count == 1) {
                    
                    objLiveGraph.judgedBreaths.append(LiveBreath(target: nil, actuals: objLiveGraph.actualBreathsWithinAPattern, breathStatus: 0)); //AUG 12th NEW the .concat() is to copy the array (to avoid reference problem), the 0 is placeholder to be assigned in the "assessed" functions below
                    
                }
                else {
                    
                    objLiveGraph.judgedBreaths.append(LiveBreath(target: CoreBreath(it: previousExpectedBreathStartTime, rr: previousExpectedBreathRR), actuals: objLiveGraph.actualBreathsWithinAPattern, breathStatus: 0)); //AUG 12th NEW the .concat() is to copy the array (to avoid reference problem), the 0 is placeholder to be assigned in the "assessed" functions below
                    
                }
                
                previousExpectedBreathStartTime = roundNumber(num: (objLiveGraph.timeElapsed-objLiveGraph.graphStartTime)+0.5,dec: 10); //AUG 12th NEW, the 0.5 here is to add back the 1/2 second due to 320+xStep above THIS IS THE EXPECTED OR TARGET breath
//                if temp_previousExpectedBreathStartTime > previousExpectedBreathStartTime { previousExpectedBreathStartTime = temp_previousExpectedBreathStartTime }
                
                previousExpectedBreathRR = flyingObjects[0].rate; //AUG 12th NEW
                objLiveGraph.actualBreathsWithinAPattern = []; //AUG 12th NEW
                
            }  //AUG 12th NEW
            
            if lastFlowerOfBreath!.position.x < _birdX {
                savedCurrentBreaths = 0; //AUG 12th NEW
                updateBreathPatterns = 0
                
                if whichPattern == 0 {
                    assessBreathForDynamicPattern()
                } else {
                    assessBreathForRegularPattern()
                }
                
                if (objLiveGraph.judgedBreaths.count > 2) { //AUG 12th NEW
//                    drawBreathingGraph(); //AUG 12th NEW
                } //AUG 12th NEW
                
                enteredPatternWhileExhaling = objLiveGraph.breathEnding; //AUG 12th NEW, idea here is if user did not finish exhaling during last breath, and that exhale carries into the current breath, then the current breath is bad
                
                // section to remove first breath pattern and its nodes
                let breath0 = flyingObjects[0]
                for col in breath0.flowers {
                    for flower in col {
                        flower.node.removeFromParent()
                    }
                }
                
                flyingObjects.removeFirst()
                
                self.visualDelegate?.visualNewTargetRateCalculated(rate: flyingObjects[0].rate)
                
                createNextBreathPattern(whichBreath: 0)
            }
        }
    }
    
    
    //
    func moveBird() {
        guard objLive != nil else {
            return
        }
        
        let nextYPosLive = self.newGraphY
        if _curYPosLive != nextYPosLive {
            _curYPosLive = nextYPosLive
            _guidedPath = []
            
            let nextBirdY = convertCoordinateY(liveY: _curYPosLive)
            let currentBirdY = _bird.position.y
            
            var nextPoint: Double = 0

            let yStep = CGFloat(nextBirdY - currentBirdY) / CGFloat(objLive!.birdIncrements)
            
            for i in 1 ... objLive!.birdIncrements*2 {
                nextPoint = round(Double(currentBirdY) + Double(yStep) * Double(i))

                if nextPoint > yStartPos + fullBreathGraphHeight {
                    nextPoint = yStartPos + fullBreathGraphHeight
                } else if nextPoint < yStartPos {
                    nextPoint = yStartPos
                }

                _guidedPath.append(nextPoint)
            }
        }
        
        if _guidedPath.count < 1 {
            return
        }
        
        _bird.position.y = CGFloat(_guidedPath.first!)
        _guidedPath.removeFirst()
        
    }
    
    func convertCoordinateY(liveY v: Double) -> CGFloat {
        
        let d = (objLive?.yStartPos)! - (objLive?.fullBreathGraphHeight)!
        let r = Double(fullBreathGraphHeight) / (objLive?.fullBreathGraphHeight)!
        let v1: CGFloat = CGFloat(Double(v-d) * r)
        var v2: CGFloat = _playRegionH - v1 + _playRegionY
        
        if v2 < _playRegionY {
            v2 = _playRegionY
        }
        if v2 > (_playRegionY + _playRegionH) {
            v2 = _playRegionY + _playRegionH
        }
        
        return v2
    }
    
    //
    func moveBackground() {
        for node in _backgrounds {
            node.position.x -= 0.3
            
            self.isBackgroundEnd(oback: node)
        }
    }
    
    func isBackgroundEnd(oback: SKSpriteNode) {
        let x: CGFloat = oback.position.x
        if x < 0 - _bgWidth/2 {
            oback.position.x = CGFloat(self._bgCount)*_bgWidth - _bgWidth / 2
        }
    }

    
    //
    func gameTimerHandler() {
        guard let objLiveGraph = objLive else { return }
        trainingDuration -= 1
        postureSessionTime+=1; //AUG 1st NEW (measured in seconds, int)
        
        self.visualDelegate?.visualOnTimer(v: trainingDuration)
        
        if objLive!.postureIsGood == 1 {
            uprightPostureTime += 1
        }
        
        if prevPostureState == 1 {
            if objLive!.postureIsGood == 0 {
                slouchesCount += 1

                self.visualDelegate?.visualNewSlouches(slouches: slouchesCount)
            }
        }
        
        if objLiveGraph.judgedPosture.isEmpty {
            objLiveGraph.judgedPosture.append(LivePosture(time: postureSessionTime, isGood: objLiveGraph.postureIsGood)); //AUG 1st NEW Only recording the changes in posture, that's all you need to create the full posture graph
        }
        else if (objLiveGraph.postureIsGood != objLiveGraph.judgedPosture[objLiveGraph.judgedPosture.count-1].isGood) { //AUG 1st NEW
            objLiveGraph.judgedPosture.append(LivePosture(time: postureSessionTime, isGood: objLiveGraph.postureIsGood)); //AUG 1st NEW Only recording the changes in posture, that's all you need to create the full posture graph
        } //AUG 1st NEW
        
//        drawPostureGraph(); //AUG 1st NEW
        
        self.visualDelegate?.visualUprightTime(uprightPostureTime: uprightPostureTime, elapsedTime: (gameSetTime - trainingDuration))
        
        prevPostureState = (objLive?.postureIsGood)!
        
        if trainingDuration == 0 {
            self.visualDelegate?.visualOnComplete()
            stopSession()
//            clearGame()
            _messageNode.text = "Session Complete!"
            addChild(_messageNode)
        }
    }
    
    func createInitialSetOfBreathPatterns() {
        createNextBreathPattern(whichBreath: 0)
        createNextBreathPattern(whichBreath: 0)
        createNextBreathPattern(whichBreath: 0)
        createNextBreathPattern(whichBreath: 0)
        createNextBreathPattern(whichBreath: 0)
        createNextBreathPattern(whichBreath: 0)
        
        createNextBreathPattern(whichBreath: 0)
        createNextBreathPattern(whichBreath: 0)
        createNextBreathPattern(whichBreath: 0)
        createNextBreathPattern(whichBreath: 0)
        
        if whichPattern == 0 {
            setInvisibleInitialPatterns()
        }
    }
    
    func createNextBreathPattern(whichBreath: Int) {
        var minInhalationHeight: Double
        
        var inhalationColumns: Int = 0
        var retentionColumns: Int = 0
        var exhalationColumns: Int = 0
        var timeBetweenBreathsColumns: Int = 0
        
        if whichFlower == 0 {
            whichFlower = 1
        } else {
            whichFlower = 0
        }
        
        if whichBreath == 0 {
            flyingObjects.append(Breath())
            breaths = flyingObjects.count - 1
        } else {
            breaths = whichBreath
        }
        
        flyingObjects[breaths].flowers = nil
        flyingObjects[breaths].whichFlower = whichFlower
        
        startBreathThreshold = Int(yStartPos + 0.15*(fullBreathGraphHeight))
//        minInhalationHeight = yStartPos + 0.5*(fullBreathGraphHeight)
        minInhalationHeight = yStartPos + fullBreathGraphHeight - flowerHeight*3
        
        inhalationTime = Pattern.getPatternValue(value: Pattern.patternSequence[whichPattern][subPattern][0])
        retentionTime = Pattern.getPatternValue(value: Pattern.patternSequence[whichPattern][subPattern][1])
        exhalationTime = Pattern.getPatternValue(value: Pattern.patternSequence[whichPattern][subPattern][2])
        timeBetweenBreaths = Pattern.getPatternValue(value: Pattern.patternSequence[whichPattern][subPattern][3])
        
        inhalationColumns = Int(round(inhalationTime * 2.0))
        retentionColumns = Int(round(retentionTime * 2.0))
        exhalationColumns = Int(round(exhalationTime * 2.0))
        timeBetweenBreathsColumns = Int(round(timeBetweenBreaths * 2.0))
        
        flyingObjects[breaths].rate = roundNumber(num: (60.0/(inhalationTime + retentionTime + exhalationTime + timeBetweenBreaths)), dec: 10)
        
        if inhalationColumns < 1 {
            inhalationColumns = 1
        }
        if exhalationColumns < 1 {
            exhalationColumns = 1
        }
        if timeBetweenBreathsColumns < 1 {
            timeBetweenBreathsColumns = 1
        }
        
        if whichPattern != 0 {
            if Pattern.patternSequence[whichPattern].count > 1 {
                subPattern += 1
                
                if subPattern > Pattern.patternSequence[whichPattern].count - 1 {
                    subPattern = 0
                }
            }
        }
        
        flyingObjects[breaths].flowers = []
        var col: [Flower] = []
        
        var yStep: Double = (minInhalationHeight - Double(yStartPos))/Double(inhalationColumns)
        
        for i in 0..<inhalationColumns {
            col = []
            let xPos = round(lastX + Double(i)*xStep)
            
            col.append(Flower(x: xPos, y: round(Double(i)*yStep + Double(yStartPos)), c: whichFlower))
            col.append(Flower(x: xPos, y: round(Double(i)*yStep + Double(yStartPos) + flowerHeight*1), c: whichFlower))
            col.append(Flower(x: xPos, y: round(Double(i)*yStep + Double(yStartPos) + flowerHeight*2), c: whichFlower))
            if (i > 0 || inhalationColumns == 1) {
                col.append(Flower(x: xPos, y: round(Double(i)*yStep + Double(yStartPos) + flowerHeight*3), c: whichFlower))
            }
            
            flyingObjects[breaths].flowers.append(col)
        }
        lastX = lastX + Double(inhalationColumns)*xStep
        
        for i in 0..<retentionColumns {
            col = []
            let xPos = round(lastX + Double(i)*xStep)
            
            col.append(Flower(x: xPos, y: Double(minInhalationHeight), c: whichFlower))
            col.append(Flower(x: xPos, y: Double(minInhalationHeight + flowerHeight*1), c: whichFlower))
            col.append(Flower(x: xPos, y: Double(minInhalationHeight + flowerHeight*2), c: whichFlower))
            col.append(Flower(x: xPos, y: Double(minInhalationHeight + flowerHeight*3), c: whichFlower))
            
            flyingObjects[breaths].flowers.append(col)
        }
        lastX = lastX + Double(retentionColumns)*xStep
        
        yStep = round((minInhalationHeight - Double(yStartPos)) / Double(exhalationColumns))
        for i in 0 ..< exhalationColumns {
            col = []
            let xPos = round(lastX + Double(i)*xStep)
            
            col.append(Flower(x: xPos, y: round(Double(minInhalationHeight - Double(i)*yStep)), c: whichFlower))
            col.append(Flower(x: xPos, y: round(Double(minInhalationHeight - Double(i)*yStep)) + flowerHeight*1, c: whichFlower))
            col.append(Flower(x: xPos, y: round(Double(minInhalationHeight - Double(i)*yStep)) + flowerHeight*2, c: whichFlower))
            if i < exhalationColumns - 1 {
                col.append(Flower(x: xPos, y: round(Double(minInhalationHeight - Double(i)*yStep)) + flowerHeight*3, c: whichFlower))
            }
            
            flyingObjects[breaths].flowers.append(col)
        }
        lastX = lastX + Double(exhalationColumns)*xStep
        
        for i in 0 ..< timeBetweenBreathsColumns {
            col = []
            let xPos = round(lastX + Double(i)*xStep)
            
            col.append(Flower(x: xPos, y: Double(yStartPos), c: whichFlower))
            col.append(Flower(x: xPos, y: Double(yStartPos) + flowerHeight*1, c: whichFlower))
            
            if (i == 0) {
                col.append(Flower(x: xPos, y: Double(yStartPos) + flowerHeight*2, c: whichFlower))
            }
            
            if (exhalationColumns == 1) {
                col.append(Flower(x: xPos, y: Double(yStartPos) + flowerHeight*3, c: whichFlower))
            }
            
            flyingObjects[breaths].flowers.append(col)
        }
        lastX = lastX + Double(timeBetweenBreathsColumns)*xStep
        
    }
    
    
    func updateNextBreaths() {
        var breath: Breath!
        
        if (updatePatternsStage == 0) {
            for i in 1..<flyingObjects.count {
                breath = flyingObjects[i]
                for column in breath.flowers {
                    for flower in column {
                        flower.node.alpha -= 0.05
                    }
                }
            }
            
            if (flyingObjects[1].flowers[0][0].node.alpha <= 0.05) {
                updatePatternsStage += 1
            }
        }
        
        if (updatePatternsStage == 1) {
            for i in 1..<flyingObjects.count {
                breath = flyingObjects[i]
                for column in breath.flowers {
                    for flower in column {
                        flower.node.removeFromParent()
                    }
                }
                
                flyingObjects[i] = Breath()
            }
            
            whichFlower = flyingObjects[0].whichFlower
            
            let columns0 = flyingObjects[0].flowers.count
            lastX = Double(flyingObjects[0].flowers[columns0-1][0].node.position.x) + xStep
            
            for i in 1..<flyingObjects.count {
                createNextBreathPattern(whichBreath: i)
                
                breath = flyingObjects[i]
                
                for column in breath.flowers {
                    for flower in column {
                        flower.node.alpha = 0
                    }
                }
            }
            
            updatePatternsStage += 1
        }
        
        if (updatePatternsStage == 2) {
            for i in 1..<flyingObjects.count {
                breath = flyingObjects[i]
                for column in breath.flowers {
                    for flower in column {
                        flower.node.alpha += 0.05
                    }
                }
            }
            
            if (flyingObjects[1].flowers[0][0].node.alpha > 0.99) {
                updatePatternsStage = 0
                updateBreathPatterns = 0
            }
        }
    }
    
    func fadeInPatterns() {
        for i in 0..<flyingObjects.count {
            let breath = flyingObjects[i]
            for column in breath.flowers {
                for flower in column {
                    flower.node.alpha += 0.05
                }
            }
        }
        
        if (flyingObjects[0].flowers[0][0].node.alpha > 0.99) {
            initialFadeIn = 0
        }
    }
    
    func setInvisibleInitialPatterns() {
        for i in 0..<flyingObjects.count {
            let breath = flyingObjects[i]
            for column in breath.flowers {
                for flower in column {
                    flower.node.alpha = 0.0
                }
            }
        }
    }
    
    func checkTargetsHit() {
        let breath: Breath = flyingObjects[0]
        
        for column in breath.flowers {
            for flower in column {
                if flower.node.name != "" {
                    let distance = CGFloat(sqrt(pow(flower.x - Double(_bird.position.x), 2.0) + pow(flower.y - Double(_bird.position.y), 2.0)))
                    
                    if (distance <= flower.node.size.width/8 + _bird.size.width/2) {
                        targetsHit += 1
                        
                        for flower in column {
                            flower.node.name = ""
                            if breath.whichFlower == 0 {
                                flower.node.run(_flapAndRemoveFlowers1!)
                            }
                            else {
                                flower.node.run(_flapAndRemoveFlowers2!)
                            }
                        }
                        
                        return
                    }
                }
            }
        }
    }
    
    func assessBreathForRegularPattern() {
        
        guard let objLiveGraph = objLive else { return }
        
        if (flyingObjects[0].flowers.count == targetsHit && (objLiveGraph.judgedBreaths[objLiveGraph.judgedBreaths.count-1].actuals.count == 1) && enteredPatternWhileExhaling == 0) {  //AUG 1st CHANGED
            mindfulBreathCount += 1
            
            objLiveGraph.judgedBreaths[objLiveGraph.judgedBreaths.count-1].breathStatus = 1; //AUG 1st NEW
        }
        
        totalBreaths += 1
        targetsHit = 0
        
        self.visualDelegate?.visualNewBreathDone(total: totalBreaths, mindful: mindfulBreathCount)
    }
    
    func assessBreathForDynamicPattern() {
        
        guard let objLiveGraph = objLive else { return }
        
        breathsOnCurrentLevel += 1
        
        if breathsOnCurrentLevel == 6 {
            breathsOnCurrentLevel = 1
            goodBreaths = 0
        }
        
        if (flyingObjects[0].flowers?.count == targetsHit && (objLiveGraph.judgedBreaths[objLiveGraph.judgedBreaths.count-1].actuals.count == 1) && enteredPatternWhileExhaling == 0) {  //AUG 1st CHANGED
            goodBreaths += 1
            mindfulBreathCount += 1
            
            objLiveGraph.judgedBreaths[objLiveGraph.judgedBreaths.count-1].breathStatus = 1; //AUG 1st NEW
        }
        
        totalBreaths += 1
        targetsHit = 0
        
        if breathsOnCurrentLevel == 5 {
            if goodBreaths >= 4 {
                subPattern += 1
                if subPattern > maxSubPattern { //may 8th  maxSubPattern is representing the minimum target respiration rate
                    subPattern = maxSubPattern  //may 8th
                } else {
                    updateBreathPatterns = 1
                }
            } else {
                subPattern -= 1
                if subPattern < 0 {
                    subPattern = 0
                } else {
                    updateBreathPatterns = 1
                }
            }
        }
        
        self.visualDelegate?.visualNewBreathDone(total: totalBreaths, mindful: mindfulBreathCount)
    }
    
    func startStopSession() {
        if _playOrPause {
            stopSession()
        } else {
            startSession()
        }
    }
    
    func startSession() {
//        self._playOrPause = true
        
        PranaDeviceManager.shared.startGettingLiveData()
        
        if _started {
            return
        }
        _started = true
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 14.5) {
//            self.startMode()
//        }
    }
    
    func onStop() {
        _messageNode.text = "Session Ended Early"
        addChild(_messageNode)
        
        stopSession()
    }
    
    func stopSession() {
        self._playOrPause = false
        
        if _timer != nil {
            _timer!.suspend()
            _timer = nil
        }
        
        PranaDeviceManager.shared.stopGettingLiveData()
        
        objLive?.removeDelegate(self)
        objLive?.stopMode(reset: isAutoReset)
        objLive = nil
    }
    
    func startMode() {
        guard let objLiveGraph = objLive else { return }
        if _playOrPause {
            return
        }
        
        self._playOrPause = true
        
        objLiveGraph.graphStartTime = objLiveGraph.timeElapsed;  //AUG 12th New
        objLiveGraph.judgedBreaths = []; //AUG 12th NEW
        objLiveGraph.judgedPosture = []; //AUG 12th NEW
        objLiveGraph.actualBreathsWithinAPattern = [] //AUG 12th NEW
        postureSessionTime = 0; //AUG 12th NEW
        
//        addChild(breathingGraph); //AUG 12th NEW
//        addChild(postureGraph); //AUG 12th NEW
        
        objLiveGraph.judgedPosture.append(LivePosture(time: 0, isGood: objLiveGraph.postureIsGood)); //AUG 12th NEW  Record the initial posture state, NOTE: this array only records CHANGES in posture, not every second of posture state
        
        
        self._patternNameNode.removeFromParent()
        
//        if (skipCalibration == 0) { //may 8th
            addChild(_calibrationRegion!)
            lastX += Double(_calibrationRegion!.size.width)
//        } //may 8th
        
        if whichPattern != 0 {
            lastX += Double(size.width / 4.0)
            createInitialSetOfBreathPatterns()
            self.visualDelegate?.visualNewTargetRateCalculated(rate: flyingObjects[0].rate)
        }
        
        objLive?.stuckBreathsThreshold = 3
//        objLive?.breathTopExceededThreshold = 0
//        objLive?.lightBreathsThreshold = 0;
//        objLive?.minBreathRange = objLive!.fullBreathGraphHeight / 16.0 * 2.0
        objLiveGraph.breathCountAtCalibrationStart = objLiveGraph.breathCount;  //AUG 1st New
        objLiveGraph.timeElapsedAtCalibrationStart = objLiveGraph.timeElapsed;  //AUG 1st New
        
        
        _timer = RepeatingTimer(timeInterval: 1.0)
        _timer?.eventHandler = { [weak self] in
            self?.gameTimerHandler()
        }
        _timer?.resume()
//        _timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (_) in
//            self.gameTimerHandler()
//        })
    }
    
    func clearGame() {
        
        removeAllActions()
        removeAllChildren()
        
        flyingObjects = []
        
        lastX = 80
        
        breathsOnCurrentLevel = 0
        goodBreaths = 0
        totalBreaths = 0
        mindfulBreathCount = 0
        
        objLive?.calibrationBreathsDone = 0
        initialFadeIn = 0
        updatePatternsStage = 0
        updateBreathPatterns = 0
        targetsHit = 0
        uprightPostureTime = 0
        prevPostureState = 0
        slouchesCount = 0
    }
    
    
    public static func convertFlowerY(x: Double, y: Double) -> CGPoint {
        let texture1: SKTexture = SKTexture(imageNamed: "fr01")
        let r: CGFloat = CGFloat(y) - (5/12) * VisualTrainingScene.Constants.FLOWER_SCALE * texture1.size().height
        return CGPoint(x: CGFloat(x), y: r)
    }
    
    
    //
    func roundNumber(num:Double, dec:Double) -> Double {
        return round(num*dec)/dec
    }
    
    //
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
}

extension VisualTrainingScene: LiveDelegate {
    func liveMainLoop(timeElapsed: Double, sensorData: [Double]) {
        self.visualDelegate?.visualBattery(battery: Int(sensorData[6]))
    }
    
    func liveNew(postureFrame: Int) {
        self.visualDelegate?.visualPostureFrameCalculated(frameIndex: postureFrame)
    }
    
    func liveUprightHasBeenSet() {
        if !_isUprightSet {
            _isUprightSet = true
            DispatchQueue.main.async {
                self._messageNode.removeFromParent()
                self._patternNameNode.removeFromParent()
            }
        }
        
        // enable start
        self.visualDelegate?.visualUprightHasBeenSet()
    }
    
    func liveNew(graphY: Double) {
        self.newGraphY = graphY
    }
    
    func liveNew(sessionAvgRate: Double) {
        self.visualDelegate?.visualNewSessionAvgRRCalculated(rate: sessionAvgRate)
    }
    
}
