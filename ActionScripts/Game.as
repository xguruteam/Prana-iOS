package  {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.media.*;
	import flash.net.*;
	import fl.events.ComponentEvent;
	import flash.text.*;
	import flash.events.TextEvent;		
	import flash.utils.*;	
	
	//Copyright 2015 Andre Persidsky
	
	public class Game extends MovieClip {		
		
		var DC:Main;						
		var balloon:BirdAnim = new BirdAnim(); //balloon is the breath level game element (in flowchart)		
		var flyingObjects:Array = new Array();			
		var clouds1:ZenGardenBackground = new ZenGardenBackground();
		var clouds2:ZenGardenBackground = new ZenGardenBackground();		
		var gameComplete:GameComplete = new GameComplete();
		var gamePanel:GamePanel = new GamePanel();			
		var startBreathThreshold:int = -49;				
		var minBreathDepth:int;
		var maxBreathDepth:int;
		var inhalationTime:Number;
		var retentionTime:Number;		
		var exhalationTime:Number;
		var timeBetweenBreaths:Number;				
		var lastX:int = 400;				
		var targetLayer:MovieClip = new MovieClip();	
		var breaths:int;				
		var patternSequence:Array = new Array();		
		var breathsOnCurrentLevel:int = 0;
		var goodBreaths:int = 0;		
		//var myTimer:Timer = new Timer(33.3333);		
		//var myTimer2:Timer = new Timer(8.33);		
		//var gameTimer:Timer = new Timer(1000);
		var targetsHit:int = 0;			
		var whichFlower:int = 0;							
		var calibrationBreathsDone:int = 0;		
		var fullBreathGraphHeight:int = 400;
		var yStartPos:int = 500;			
		var whichPattern:int = 0;		
		var updatePatternsStage:int = 0;
		var updateBreathPatterns:int = 0;
		var xStep:int = 45;	
		var mindfulBreathCount:int = 0;		
		var initialFadeIn:int = 0;
		var totalBreaths:int = 0;
		var subPattern:int = 0;
		var nameOfPattern:String;
		var trainingPosture:int = 0;
		var trainingDuration:int = 120;
		var uprightPostureTime:int = 0;
		var gameSetTime:int = 0;
		var prevPostureState:int = 0;
		var slouchesCount:int = 0;
		var hasUprightBeenSet:int = 0;
		var enterFrameCount:int = 0;
		var secondCounter:int = 0;
		var xd:int = 2;
		var whichBirdFrame:int = 0;		
		var skipCalibration:int = 0;  //JULY 13:Change1i For visual training, if this is set to 1, it causes the function addCalibrationBreathRegion() not to run, which skips the initial 15 second respiration assessment. If whichPattern = 0 (Slowing pattern), and skipCalibration is 1, then startSubPattern and maxSubPattern determine the initial respiration rate and minimum respiration rate
		var startSubPattern:Number = 5; //may 8th  The example value 5 here corresponds to 12bpm. Note, for Buzzer Training, if the non-custom Slowing pattern is used, then this value should be set to 5
		var maxSubPattern:int = 34; //may 8th  SET THIS TO THE INDEX VALUE found under //Dynamic slow breathing pattern below, between 0-34. This value corresponds TO THE MINIMUM RESPIRATION RATE SELECTED ON THE CUSTOM BREATH PATTERN PAGE. This value should be 34 if skipCalibration = 0. The example value 8 here corresponds to 9.2bpm
		var customSlowingPatternIsActive:int = 0; //July 13:New1i  When user is using the Slowing Pattern from the pattern gallery (custom), then this should be set to 1. In this case, the first breathing pattern is set to startSubPattern, and maxSubPattern should also be set based on user selection on the custom pattern screen (15 second calibration is never skipped now for any pattern)
		var breathLevel:int = 2;  //AUG 1st ADDED			
		var startRecordingActualBreaths:int = 0; //AUG 12th NEW
		var savedCurrentBreaths:int = 0; //AUG 12th NEW
		var graphStartTime:Number = 0; //AUG 12th NEW
		var breathingGraph:MovieClip = new MovieClip(); //AUG 12th NEW
		var postureGraph:MovieClip = new MovieClip(); //AUG 12th NEW
		var lastXForActualBreath:Number = 0; //AUG 12th NEW
		var	lastYForActualBreath:Number = 0; //AUG 12th NEW				
		var previousExpectedBreathStartTime:Number = 0; //AUG 12th NEW
		var previousExpectedBreathRR:Number = 0; //AUG 12th NEW	 		
		var postureSessionTime:int = 0; //AUG 12th NEW
		var enteredPatternWhileExhaling:int = 0; //AUG 12th NEW	

		
		public function Game(main:Main) {			
		
			DC = main;					
			
			addChild(clouds1);
			addChild(clouds2);					
			addChild(balloon);	
			addChild(targetLayer);			
			addChild(gameComplete);
			addChild(gamePanel);
			
			clouds1.x = 0;
			clouds1.y = 0;
			clouds2.x = 3840;
			clouds2.y = 0;								
			
			gamePanel.x = 580;
			gamePanel.y = 925;			
			
			balloon.x = 300;
			balloon.y = yStartPos;				
						
				
			
			//myTimer.addEventListener(TimerEvent.TIMER, timerListener);			
			//myTimer2.addEventListener(TimerEvent.TIMER, timerListener2);
			//gameTimer.addEventListener(TimerEvent.TIMER, gameTimerHandler);
			
			gameComplete.x = 630;
			gameComplete.y = 280;
			gameComplete.visible = false;
			
			gamePanel.backButton.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);
			gamePanel.backButton.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			gamePanel.backButton.addEventListener(MouseEvent.MOUSE_UP,backButtonHandler);
			gamePanel.backButton.buttonMode = true;		
			
			//gamePanel.startGameButton.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);
			//gamePanel.startGameButton.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			gamePanel.startGameButton.addEventListener(MouseEvent.MOUSE_UP,startGameButtonHandler);
			gamePanel.startGameButton.buttonMode = true;			
			
			gamePanel.setInhaledButton.addEventListener(MouseEvent.MOUSE_DOWN,setInhaledButtonHandler);
			gamePanel.setInhaledButton.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			gamePanel.setInhaledButton.addEventListener(MouseEvent.MOUSE_UP,unclickButton);		
			gamePanel.setInhaledButton.buttonMode = true;		
			
			gamePanel.setUprightButton.addEventListener(MouseEvent.MOUSE_DOWN,setUprightButtonHandler);
			gamePanel.setUprightButton.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			gamePanel.setUprightButton.addEventListener(MouseEvent.MOUSE_UP,unclickButton);		
			gamePanel.setUprightButton.buttonMode = true;	
			
			gamePanel.postureResponse.level1.addEventListener(MouseEvent.CLICK,postureSelectorHandler);
			gamePanel.postureResponse.level2.addEventListener(MouseEvent.CLICK,postureSelectorHandler);
			gamePanel.postureResponse.level3.addEventListener(MouseEvent.CLICK,postureSelectorHandler);	
			
			gamePanel.breathResponse.level1.addEventListener(MouseEvent.CLICK,breathSelectorHandler);
			gamePanel.breathResponse.level2.addEventListener(MouseEvent.CLICK,breathSelectorHandler);
			gamePanel.breathResponse.level3.addEventListener(MouseEvent.CLICK,breathSelectorHandler);			
			
			
			gamePanel.postureState.gotoAndStop(1);
			
			definePatternSequence();
			
						
		}
		
		
		function unclickButton(evt:MouseEvent)  {	
		
			evt.currentTarget.gotoAndStop(1);
		}
		
		function clickButton(evt:MouseEvent)  {	
		
			evt.currentTarget.gotoAndStop(2);
		}
		
		
		function setInhaledButtonHandler(evt:MouseEvent)  {	
		
			evt.currentTarget.gotoAndStop(2);
			//DC.objLiveGraph.count;
			
			DC.objLiveGraph.currentStrainGaugeHighest = DC.objLiveGraph.strainGauge;
			DC.objLiveGraph.currentStrainGaugeHighestPrev = DC.objLiveGraph.strainGauge;	
			
			if ( (DC.objLiveGraph.currentStrainGaugeHighest - DC.objLiveGraph.currentStrainGaugeLowest) < DC.objLiveGraph.strainGaugeMinRange) {
				DC.objLiveGraph.currentStrainGaugeHighest = DC.objLiveGraph.currentStrainGaugeLowest + DC.objLiveGraph.strainGaugeMinRange;
			}
			
			DC.objLiveGraph.lightBreathsInARow = 0;	
			DC.objLiveGraph.breathTopExceeded = 0;
							
			
		}
		
		function setUprightButtonHandler(evt:MouseEvent)  {	
			
			DC.objLiveGraph.learnUprightAngleHandler(evt);
			
			if (hasUprightBeenSet == 0) {
				
				uprightHasBeenSet();
			}
			
			hasUprightBeenSet = 1;			
			
		}		
		
				
		function roundNumber(numb:Number, decimal:Number):Number {
		
			return Math.round(numb*decimal)/decimal;
		}
		
		
		
		public function clearGame():void {		
			
			DC.objModeScreen.stopData();
			
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler); 
			
			
			//myTimer.stop();
			//myTimer2.stop();
			//gameTimer.stop();
			
			while (targetLayer.numChildren > 0) {
				targetLayer.removeChildAt(0);
			}
										
			flyingObjects = [];
			
			lastX = 400;			
						
			breathsOnCurrentLevel = 0;
			goodBreaths = 0;	
			totalBreaths = 0;
			mindfulBreathCount = 0;		
			
			calibrationBreathsDone = 0;
			initialFadeIn = 0;						
			updatePatternsStage = 0;
			updateBreathPatterns = 0;
			targetsHit = 0;			
			uprightPostureTime = 0;		 
			prevPostureState = 0;
			slouchesCount = 0;	
									
			gameComplete.visible = false;
			
			balloon.visible = false;
			
		
			
		}
		
		function definePatternSequence():void {
			
			//inhalationTime = 3;
			//retentionTime = 4;						
			//exhalationTime = 5;
			//timeBetweenBreaths = 1;	
			
			//the values herein define the # of columns of flowers now!!!! Each column is 0.50 seconds. That's the best reliable granularity.
			
			patternSequence = [];
			patternSequence[0] = [];
			
			
			//Dynamic slow breathing pattern //July 13:Change1l  (this section was updated)
						
			patternSequence[0].push([1,0,1,0.5]); //24 bpm		
			patternSequence[0].push([1,0,1.5,0.5]); //20 bpm
			
			patternSequence[0].push([1,0,1.5,1]); //17.14 bpm
			patternSequence[0].push([1.5,0,1.5,1]); //15 bpm
			
			patternSequence[0].push([1.5,0,1.5,1.5]); //13.3 bpm
			patternSequence[0].push([1.5,0,2,1.5]); //12 bpm
			
			patternSequence[0].push([2,0,2,1.5]); //10.9 bpm
			patternSequence[0].push([2,0,2.5,1.5]); //10 bpm
			
			patternSequence[0].push([2.5,0,2.5,1.5]); //9.2 bpm
			patternSequence[0].push([2.5,0,3,1.5]); //8.6 bpm
			
			patternSequence[0].push([3,0,3,1.5]); //8 bpm
			patternSequence[0].push([3,0,3.5,1.5]); //7.5 bpm
			
			patternSequence[0].push([3.5,0,3.5,1.5]); //7.1 bpm
			patternSequence[0].push([3.5,0,4,1.5]); //6.7 bpm
			
			patternSequence[0].push([4,0,4,1.5]); //6.3 bpm
			patternSequence[0].push([4,0,4.5,1.5]); //6 bpm
			
			patternSequence[0].push([4.5,0,4.5,1.5]); //5.7 bpm
			patternSequence[0].push([4.5,0,5,1.5]); //5.5 bpm
			
			patternSequence[0].push([5,0,5,1.5]); //5.2 bpm
			patternSequence[0].push([5,0,5.5,1.5]); //5 bpm
			
			patternSequence[0].push([5,0,5.5,2]); //4.8 bpm
			patternSequence[0].push([5.5,0,5.5,2]); //4.6 bpm
			
			patternSequence[0].push([5.5,0,6,2]); //4.4 bpm
			patternSequence[0].push([6,0,6,2]); //4.3 bpm
			
			patternSequence[0].push([6,0,6.5,2]); //4.1 bpm
			patternSequence[0].push([6.5,0,6.5,2]); //4 bpm
			
			patternSequence[0].push([6.5,0,7,2]); //3.9 bpm
			patternSequence[0].push([7,0,7,2]); //3.8 bpm
			
			patternSequence[0].push([7,0,7.5,2]); //3.6 bpm
			patternSequence[0].push([7.5,0,7.5,2]); //3.5 bpm
			
			patternSequence[0].push([7.5,0,8,2]); //3.4 bpm
			patternSequence[0].push([8,0,8,2]); //3.3 bpm
			
			patternSequence[0].push([8,0,8.5,2]); //3.2 bpm
			patternSequence[0].push([8.5,0,8.5,2]); //3.1 bpm
			
			patternSequence[0].push([9,0,9,2]); //3 bpm
			
			
			//Dynamic slow breathing pattern
			/**
						
			patternSequence[0].push([1,0,1,0.5]); //24 bpm		
			patternSequence[0].push([1,0,1.5,0.5]); //20 bpm
			
			patternSequence[0].push([1,0,1.5,1]); //17.14 bpm
			patternSequence[0].push([1.5,0,1.5,1]); //15 bpm
			
			patternSequence[0].push([1.5,0,1.5,1.5]); //13.3 bpm
			patternSequence[0].push([1.5,0,2,1.5]); //12 bpm
			
			patternSequence[0].push([1.5,0,2,2]); //10.9 bpm
			patternSequence[0].push([2,0,2,2]); //10 bpm
			
			patternSequence[0].push([2,0,2,2.5]); //9.2 bpm
			patternSequence[0].push([2,0,2.5,2.5]); //8.6 bpm
			
			patternSequence[0].push([2,0,2.5,3]); //8 bpm
			patternSequence[0].push([2.5,0,2.5,3]); //7.5 bpm
			
			patternSequence[0].push([3,0,2.5,3]); //7.1 bpm
			patternSequence[0].push([3,0,3,3]); //6.7 bpm
			
			patternSequence[0].push([3,0,3,3.5]); //6.3 bpm
			patternSequence[0].push([3.5,0,3,3.5]); //6 bpm
			
			patternSequence[0].push([3.5,0,3.5,3.5]); //5.7 bpm
			patternSequence[0].push([4,0,3.5,3.5]); //5.5 bpm
			
			patternSequence[0].push([4,0,3.5,4]); //5.2 bpm
			patternSequence[0].push([4,0,4,4]); //5 bpm
			
			patternSequence[0].push([4.5,0,4,4]); //4.8 bpm
			patternSequence[0].push([4.5,0,4.5,4]); //4.6 bpm
			
			patternSequence[0].push([4.5,0,4.5,4.5]); //4.4 bpm
			patternSequence[0].push([5,0,4.5,4.5]); //4.3 bpm
			
			patternSequence[0].push([5,0,5,4.5]); //4.1 bpm
			patternSequence[0].push([5.5,0,5,4.5]); //4 bpm
			
			patternSequence[0].push([5.5,0,5,5]); //3.9 bpm
			patternSequence[0].push([5.5,0,5.5,5]); //3.8 bpm
			
			patternSequence[0].push([6,0,5.5,5]); //3.6 bpm
			patternSequence[0].push([6,0,6,5]); //3.5 bpm
			
			patternSequence[0].push([6,0,6,5.5]); //3.4 bpm
			patternSequence[0].push([6.5,0,6,5.5]); //3.3 bpm
			
			patternSequence[0].push([6.5,0,6.5,5.5]); //3.2 bpm
			patternSequence[0].push([7,0,7,5.5]); //3.1 bpm
			
			patternSequence[0].push([7,0,7,6]); //3 bpm
			**/
			
			//Meditation 1 breathing pattern
			
			patternSequence[1] = [];
			patternSequence[1].push([1,0,1,1,"MEDITATION PATTERN 1"]); 
			patternSequence[1].push([2,0,2,1.5]); 
			patternSequence[1].push([3,0,3,1.5]); 
			patternSequence[1].push([4,0,4,2]); 
			patternSequence[1].push([5,0,5,2]); 
			
			//Meditation 2 breathing pattern
			
			patternSequence[2] = [];
			patternSequence[2].push([2,0,1,1,"MEDITATION PATTERN 2"]); 
			patternSequence[2].push([2,0,2,1.5]); 
			patternSequence[2].push([2,0,3,1.5]); 
			patternSequence[2].push([2,0,4,2]); 
			patternSequence[2].push([2,0,5,2]); 
			
			//Focus breathing patterns
			
			patternSequence[3] = [];
			patternSequence[4] = [];
			patternSequence[5] = [];
			patternSequence[6] = [];
			patternSequence[7] = [];
			patternSequence[3].push([1.5,0,1.5,1,"FOCUS PATTERN 15 BPM"]); //15 bpm
			patternSequence[4].push([2,0,2,1,"FOCUS PATTERN 12 BPM"]); //12 bpm  AUG 1st CHANGE
			patternSequence[5].push([2.5,0,2.5,1,"FOCUS PATTERN 10 BPM"]); //10 bpm AUG 1st CHANGE
			patternSequence[6].push([3,0,3,1.5,"FOCUS PATTERN 8 BPM"]); //8 bpm  AUG 1st CHANGE
			patternSequence[7].push([4,0,4,2,"FOCUS PATTERN 6 BPM"]); //6 bpm   AUG 1st CHANGE
			
			//Relax breathing patterns
			
			patternSequence[8] = [];
			patternSequence[9] = [];
			patternSequence[10] = [];
			patternSequence[11] = [];
			patternSequence[12] = [];
			patternSequence[8].push([1,0,2,1,"RELAX PATTERN 15 BPM"]); //15 bpm
			patternSequence[9].push([1.5,0,2.5,1,"RELAX PATTERN 12 BPM"]); //12 bpm AUG 1st CHANGE
			patternSequence[10].push([1.5,0,3,1.5,"RELAX PATTERN 10 BPM"]); //10 bpm
			patternSequence[11].push([2,0,4,1.5,"RELAX PATTERN 8 BPM"]); //8 bpm  AUG 1st CHANGE
			patternSequence[12].push([3,0,5.5,1.5,"RELAX PATTERN 6 BPM"]); //6 bpm  AUG 1st CHANGE
			
			//Sleep breathing patterns
			
			patternSequence[13] = [];
			patternSequence[14] = [];
			patternSequence[15] = [];
			patternSequence[13].push([2,3,4,2,"SLEEP PATTERN 2-3-4"]); //15 bpm
			patternSequence[14].push([3,5,6,2.5,"SLEEP PATTERN 3-5-6"]); //12 bpm
			patternSequence[15].push([4,7,8,3,"SLEEP PATTERN 4-7-8"]); //10 bpm			
						
		}
		
		
		function addCalibrationBreathRegion():void {		
									
			targetLayer.addChild(new deepBellyBreathCue());			
			targetLayer.getChildAt(0).x = lastX;
			targetLayer.getChildAt(0).y = 650;		
			
			lastX = lastX + 1500;		
			
		}
		
				
		function createNextBreathPattern(whichBreath:int):void {			
			
			var i:int;						
			var startX:int = lastX;			
			var targetType:Class;	
			var minInhalationHeight:Number;
			
			var inhalationColumns:int = 0;
			var retentionColumns:int = 0;
			var exhalationColumns:int = 0;
			var timeBetweenBreathsColumns:int = 0;
			
			
			if (whichFlower == 0) {
				targetType = getDefinitionByName("Flower1Anim") as Class;				
				whichFlower = 1; //for alternating the flower type in the breath pattern
			}
			else {
				targetType = getDefinitionByName("Flower2Anim") as Class;				
				whichFlower = 0;
			}				
			
			var c:int = -1;
			
			if (whichBreath == 0) {
				flyingObjects.push(new Array());			
				breaths = flyingObjects.length-1;		
				flyingObjects[breaths][0] = new Array();
			}
			else {
				breaths = whichBreath;				
			}
							
			startBreathThreshold = yStartPos + int(.15*(-fullBreathGraphHeight));
			minInhalationHeight = yStartPos + int(0.50*(-fullBreathGraphHeight)); //min breath is 50% of a fullbreath				
			
			inhalationTime = patternSequence[whichPattern][subPattern][0];
			retentionTime = patternSequence[whichPattern][subPattern][1];
			exhalationTime = patternSequence[whichPattern][subPattern][2];
			timeBetweenBreaths = patternSequence[whichPattern][subPattern][3];
			
			
			inhalationColumns = Math.round(inhalationTime*2);
			retentionColumns = Math.round(retentionTime*2);
			exhalationColumns = Math.round(exhalationTime*2);
			timeBetweenBreathsColumns = Math.round(timeBetweenBreaths*2); 			
			
			flyingObjects[breaths][1] = roundNumber((60/(inhalationTime + retentionTime + exhalationTime + timeBetweenBreaths)),10);			
			
			
			if (inhalationColumns < 1) {
				inhalationColumns = 1;
			}			
			
			if (exhalationColumns < 1) {
				exhalationColumns = 1;
			}	
			
			if (timeBetweenBreathsColumns < 1) {
				timeBetweenBreathsColumns = 1;
			}
			
			//retentionColumns can be 0
			
			if (whichPattern != 0) {				
				
				if (patternSequence[whichPattern].length > 1) {
					subPattern++;
					
					if (subPattern > patternSequence[whichPattern].length - 1) {
						subPattern = 0;
					}
				}
			}			
			
						
		
			var yStep:Number = (minInhalationHeight-yStartPos)/(inhalationColumns); 	
			
			for (i = 0; i<inhalationColumns; i = i + 1) { 			
				
				flyingObjects[breaths][0].push(new targetType()); 					
				c++;				
				flyingObjects[breaths][0][c].x = Math.round(lastX+i*xStep);  
				flyingObjects[breaths][0][c].y = Math.round((i*yStep)+yStartPos); //last target in inhalation should reach minInhalationHeight
				targetLayer.addChild(flyingObjects[breaths][0][c]);
				
				flyingObjects[breaths][0].push(new targetType()); 
				c++;				
				flyingObjects[breaths][0][c].x = Math.round(lastX+i*xStep);  
				flyingObjects[breaths][0][c].y = Math.round((i*yStep)+yStartPos - 50); 
				targetLayer.addChild(flyingObjects[breaths][0][c]);
				
				flyingObjects[breaths][0].push(new targetType()); 
				c++;				
				flyingObjects[breaths][0][c].x = Math.round(lastX+i*xStep);  
				flyingObjects[breaths][0][c].y = Math.round((i*yStep)+yStartPos - 100); 
				targetLayer.addChild(flyingObjects[breaths][0][c]);
				
				if (i > 0 || inhalationColumns == 1) { //first column should only contain 3 targets
					flyingObjects[breaths][0].push(new targetType()); 
					c++;					
					flyingObjects[breaths][0][c].x = Math.round(lastX+i*xStep);  
					flyingObjects[breaths][0][c].y = Math.round((i*yStep)+yStartPos - 150); 
					targetLayer.addChild(flyingObjects[breaths][0][c]);	
				}
			
			}				
			lastX = Math.round(lastX+(inhalationColumns)*xStep);					
			
			
			
			for (i = 0; i<retentionColumns; i = i + 1) {		
				
				flyingObjects[breaths][0].push(new targetType());					
				c++;				
				flyingObjects[breaths][0][c].x = Math.round(lastX+i*xStep); 
				flyingObjects[breaths][0][c].y = Math.round(minInhalationHeight);
				targetLayer.addChild(flyingObjects[breaths][0][c]);
				
				flyingObjects[breaths][0].push(new targetType());					
				c++;				
				flyingObjects[breaths][0][c].x = Math.round(lastX+i*xStep); 
				flyingObjects[breaths][0][c].y = Math.round(minInhalationHeight - 50);
				targetLayer.addChild(flyingObjects[breaths][0][c]);
				
				flyingObjects[breaths][0].push(new targetType());					
				c++;				
				flyingObjects[breaths][0][c].x = Math.round(lastX+i*xStep); 
				flyingObjects[breaths][0][c].y = Math.round(minInhalationHeight - 100);
				targetLayer.addChild(flyingObjects[breaths][0][c]);				
				
				flyingObjects[breaths][0].push(new targetType());					
				c++;				
				flyingObjects[breaths][0][c].x = Math.round(lastX+i*xStep); 
				flyingObjects[breaths][0][c].y = Math.round(minInhalationHeight - 150);
				targetLayer.addChild(flyingObjects[breaths][0][c]);									
		
			}							
			lastX = Math.round(lastX+retentionColumns*xStep); 	
			
				
			
			yStep = Math.round( (minInhalationHeight-yStartPos)/(exhalationColumns) ); 		
			
			for (i = 0; i<exhalationColumns; i = i + 1) {				
				
				flyingObjects[breaths][0].push(new targetType());
				c++;				
				flyingObjects[breaths][0][c].x = Math.round(lastX+i*xStep); 
				flyingObjects[breaths][0][c].y = Math.round(minInhalationHeight-i*yStep);			
				targetLayer.addChild(flyingObjects[breaths][0][c]);	
					
				flyingObjects[breaths][0].push(new targetType());
				c++;				
				flyingObjects[breaths][0][c].x = Math.round(lastX+i*xStep); 
				flyingObjects[breaths][0][c].y = Math.round(minInhalationHeight-i*yStep - 50);			
				targetLayer.addChild(flyingObjects[breaths][0][c]);
				
				flyingObjects[breaths][0].push(new targetType());
				c++;				
				flyingObjects[breaths][0][c].x = Math.round(lastX+i*xStep); 
				flyingObjects[breaths][0][c].y = Math.round(minInhalationHeight-i*yStep - 100);			
				targetLayer.addChild(flyingObjects[breaths][0][c]);
				
				if (i < exhalationColumns-1) {
					flyingObjects[breaths][0].push(new targetType());
					c++;					
					flyingObjects[breaths][0][c].x = Math.round(lastX+i*xStep); 
					flyingObjects[breaths][0][c].y = Math.round(minInhalationHeight-i*yStep - 150);			
					targetLayer.addChild(flyingObjects[breaths][0][c]);		
				}			
			
			}			
				
			lastX = Math.round(lastX+(exhalationColumns)*xStep); 
						
			for (i = 0; i<timeBetweenBreathsColumns; i = i + 1) {							
				
				flyingObjects[breaths][0].push(new targetType());
				c++;												
				flyingObjects[breaths][0][c].x = Math.round(lastX + i*xStep);	
				flyingObjects[breaths][0][c].y = yStartPos;				
				targetLayer.addChild(flyingObjects[breaths][0][c]);
				
				flyingObjects[breaths][0].push(new targetType());
				c++;				 								
				flyingObjects[breaths][0][c].x = Math.round(lastX + i*xStep);	
				flyingObjects[breaths][0][c].y = yStartPos - 50;				
				targetLayer.addChild(flyingObjects[breaths][0][c]);	
				
				if (i == 0) {
					flyingObjects[breaths][0].push(new targetType());
					c++;				 								
					flyingObjects[breaths][0][c].x = Math.round(lastX + i*xStep);	
					flyingObjects[breaths][0][c].y = yStartPos - 100;				
					targetLayer.addChild(flyingObjects[breaths][0][c]);
				}
				
				if (exhalationColumns == 1) {
					flyingObjects[breaths][0].push(new targetType());
					c++;					
					flyingObjects[breaths][0][c].x = Math.round(lastX+i*xStep); 
					flyingObjects[breaths][0][c].y = yStartPos - 150;			
					targetLayer.addChild(flyingObjects[breaths][0][c]);
				}				
				
			}										
			
			lastX = Math.round(lastX + timeBetweenBreathsColumns*xStep);			
			
		}
		
		
		function gameTimerHandler():void {		
			
			trainingDuration--;
			postureSessionTime++; //AUG 1st NEW (measured in seconds, int)			
			
			gamePanel.elapsedTime.text = convertTime(trainingDuration);
			
			if (DC.objLiveGraph.postureIsGood == 1) {
				uprightPostureTime++;
			}
			
			if (prevPostureState == 1) {
				if (DC.objLiveGraph.postureIsGood == 0) {
					slouchesCount++;
				}
			}
			
			if (DC.objLiveGraph.postureIsGood != DC.objLiveGraph.judgedPosture[DC.objLiveGraph.judgedPosture.length-1][1]) { //AUG 1st NEW
				DC.objLiveGraph.judgedPosture.push([postureSessionTime,DC.objLiveGraph.postureIsGood]); //AUG 1st NEW Only recording the changes in posture, that's all you need to create the full posture graph
			} //AUG 1st NEW
			
			drawPostureGraph(); //AUG 1st NEW
			
			//gamePanel.timeUpright.text = String(uprightPostureTime) + " of " + String(gameSetTime);
			gamePanel.timeUpright.text = String(uprightPostureTime) + " of " + String(gameSetTime - trainingDuration);			
			
			gamePanel.slouches.text = String(slouchesCount);
			
			prevPostureState = DC.objLiveGraph.postureIsGood;
			
			if (trainingDuration == 0) {
				
				gamePanel.sessionCompleteIndicator.visible = true;
				
				gamePanel.startGameButton.visible = false;
				gamePanel.backButton.visible = true; 
				
				clearGame();
			}
			
		}	
		
		function convertTime(a:int):String {
			var min:int = Math.floor(a/60);
			var sec:int = Math.floor(a%60);
			var b:String;
			var secString:String;
			if (sec < 10) {
				secString = "0" + String(sec);
			}
			else {
				secString = String(sec);
			}
			b = String(min) + ":" + secString;
			return(b);
		}
		
		function enterFrameHandler(e:Event):void {
			
			moveBird();
			
			secondCounter++;
			enterFrameCount++;
			
			if (enterFrameCount == 1) {
				scrollAndUpdate();
				enterFrameCount = 0;
			}
			
			if (secondCounter == 60) {
				gameTimerHandler();
				secondCounter = 0;
			}
		}
		
		function moveBird():void {		
			
			var count:int = DC.objLiveGraph.count;
					
			if (DC.objLiveGraph.guidedPath.length > 0) {
				
				balloon.y = DC.objLiveGraph.guidedPath.shift();
			}				
			
			if (xd == 2) {
				
				whichBirdFrame++;
				
				if (whichBirdFrame == 16) {
					
					whichBirdFrame = 1;
					//balloon.gotoAndPlay(1);
				}
				
				balloon.gotoAndStop(whichBirdFrame);
			}	
				
		}
		
		
		function fadeInPatterns():void {
			
			var i:int = 0;
			var i2:int = 0;			
		
			for (i = 0; i<flyingObjects.length; i++) {	

				for (i2 = 0; i2<flyingObjects[i][0].length; i2++) {	

					flyingObjects[i][0][i2].alpha += 0.05;			
		
				}				
			}
			
			if (flyingObjects[0][0][0].alpha > 0.99) {
			
				initialFadeIn = 0;						
				
			}		
			
		}
		
		
		function setInvisibleInitialPatterns():void {
			
			var i:int = 0;
			var i2:int = 0;			
		
			for (i = 0; i<flyingObjects.length; i++) {	

				for (i2 = 0; i2<flyingObjects[i][0].length; i2++) {	

					flyingObjects[i][0][i2].alpha = 0;			
		
				}				
			}
		}
		
		
		function updateNextBreaths():void {
			
			var i:int;
			var i2:int;
			
			if (updatePatternsStage == 0) {
				for (i = 1; i<flyingObjects.length; i++) {	
	
					for (i2 = 0; i2<flyingObjects[i][0].length; i2++) {	
	
						flyingObjects[i][0][i2].alpha -= 0.05;			
			
					}				
				}
				if (flyingObjects[1][0][0].alpha <= 0.05) {
				
					updatePatternsStage++;
				
					//fade out complete
				}
			}
			
			
			
			if (updatePatternsStage == 1) {			
				
				for (i = 1; i<flyingObjects.length; i++) {	
	
					for (i2 = 0; i2<flyingObjects[i][0].length; i2++) {	
	
						targetLayer.removeChild(flyingObjects[i][0][i2]);	
									
					}			
					
					flyingObjects[i] = new Array();
					flyingObjects[i][0] = new Array();
					
				}
				
				lastX = flyingObjects[0][0][flyingObjects[0][0].length-1].x + xStep;
				
				for (i = 1; i<flyingObjects.length; i++) {
					createNextBreathPattern(i);
					
					for (i2 = 0; i2<flyingObjects[i][0].length; i2++) {	
	
						flyingObjects[i][0][i2].alpha = 0;	
			
					}	
				}	
				
				updatePatternsStage++;
			
			}
			
			
			if (updatePatternsStage == 2) {
				for (i = 1; i<flyingObjects.length; i++) {	
	
					for (i2 = 0; i2<flyingObjects[i][0].length; i2++) {	
	
						flyingObjects[i][0][i2].alpha += 0.05;			
			
					}				
				}
				
				if (flyingObjects[1][0][0].alpha > 0.99) {
				
					updatePatternsStage = 0;	
					updateBreathPatterns = 0;
					
				}
			}			
			
			
		}
		
		
		function scrollAndUpdate():void{			
			
			var i:int;
			var i2:int;
			var count:int = DC.objLiveGraph.count;			
			
			var a:Number = 0;
			
			 if (xd == 2) {
				xd = 1;
			}
			else if (xd == 1) {
				xd = 2;
			} 			
			
			
			//gamePanel.mindfulBreaths.text = String(roundNumber(DC.objLiveGraph.currentStrainGaugeHighest - DC.objLiveGraph.currentStrainGaugeLowest,100000));
			gamePanel.actualRate.text = String(DC.objLiveGraph.respRate);
			
			if (xd == 2) {
				clouds1.x = clouds1.x - 1;
				clouds2.x = clouds2.x - 1;
			}
			
			if (clouds2.x == 0) {
				clouds1.x = 3840;
			}
			
			if (clouds1.x == 0) {
				clouds2.x = 3840;
			}
			
			lastX = lastX - xd; 						
			
			
			if (updateBreathPatterns == 1) {
				updateNextBreaths();
			}		
			
			if (initialFadeIn == 1) {
				fadeInPatterns();
			}
					
	
			for (i = 0; i < targetLayer.numChildren; i++) {
				targetLayer.getChildAt(i).x -= xd;
			}			
			
			//may 8th **************
			if (calibrationBreathsDone == 0 && skipCalibration == 1) { 
				
				calibrationBreathsDone = 1;	 
				
				if (whichPattern == 0) {						
						
						lastX = 500; 
						
						initialFadeIn = 1; //fade in initial patterns					
						
						subPattern = startSubPattern; 
						createInitialSetOfBreathPatterns();	 								
						
						gamePanel.targetRate.text = String(flyingObjects[0][1]); 
					
						DC.objLiveGraph.breathTopExceededThreshold = 1; //AUG 1st NEW  if you skip calibation, these should still be set
						DC.objLiveGraph.lightBreathsThreshold = 1; //AUG 1st NEW  if you skip calibation, these should still be set
						DC.objLiveGraph.minBreathRange = DC.objLiveGraph.fullBreathGraphHeight/8; //AUG 1st NEW
						DC.objLiveGraph.minBreathRangeForStuck = (DC.objLiveGraph.fullBreathGraphHeight/4); //AUG 1st NEW  (4 helps patterns like 478 when user holds breath between inhale/exhale, so that random body movements less likely to trigger stuck breath)
				}
				
			} 
			//may 8th **************
			
			
			else if (calibrationBreathsDone == 0 && skipCalibration == 0) {	//AUG 1st CHANGED
				
			//	if ((targetLayer.getChildAt(0).x <= -1130+xStep) && startRecordingActualBreaths == 0) {  //AUG 12th NEW					
					
					//DC.objLiveGraph.judgedBreaths.push([ [],DC.objLiveGraph.actualBreathsWithinAPattern.concat(),-1]); //the concat() here is to copy the array (to avoid possible reference problem)					
					//DC.objLiveGraph.actualBreathsWithinAPattern = [] //AUG 12th NEW
					//startRecordingActualBreaths = 1; //AUG 12th NEW
					//previousExpectedBreathStartTime = roundNumber((DC.objLiveGraph.timeElapsed-graphStartTime)+0.5,10); //AUG 12th NEW, the 0.5 here is to add back the 1/2 second due to 320+xStep above THIS IS THE EXPECTED OR TARGET breath	(i'm setting it here only because I need it for the first actual breath location)
					//enteredPatternWhileExhaling = DC.objLiveGraph.breathEnding;  //AUG 12th NEW idea here is if user did not finish exhaling during last breath, and that exhale carries into the first breath, then the first breath is bad 
				//}
				
				if (targetLayer.getChildAt(0).x <= -1130) {  //accounting for 70 width of bird					
					targetLayer.removeChildAt(0);
					calibrationBreathsDone = 1;	
					DC.objLiveGraph.breathTopExceededThreshold = 1; //JULY 13:NEW1f
					DC.objLiveGraph.lightBreathsThreshold = 1; //JULY 13:NEW1f
					DC.objLiveGraph.minBreathRange = DC.objLiveGraph.fullBreathGraphHeight/8; //AUG 1st NEW
					DC.objLiveGraph.minBreathRangeForStuck = (DC.objLiveGraph.fullBreathGraphHeight/4); //AUG 1st NEW
										
					if (whichPattern == 0) {						
						
						lastX = 500;
						
						initialFadeIn = 1; //fade in initial patterns
						
						if (DC.objLiveGraph.calibrationRR >= 17.14) { //JULY 13:Change1h  AUG 1st CHANGE
							subPattern = 2;
							createInitialSetOfBreathPatterns();
						}
						else if (DC.objLiveGraph.calibrationRR <=8) { // AUG 1st CHANGE
							subPattern = 10;
							createInitialSetOfBreathPatterns();
						}
						
						else {
							for (i = 0; i < patternSequence[0].length; i++) {
								a = 60/(patternSequence[0][i][0] + patternSequence[0][i][1] + patternSequence[0][i][2]+ patternSequence[0][i][3]);
								if (DC.objLiveGraph.calibrationRR > a) { // AUG 1st CHANGE
									subPattern = i;
									if (customSlowingPatternIsActive == 1) { //July 13:New1i  
										subPattern = startSubPattern; //July 13:New1i  
									} //July 13:New1i  
									createInitialSetOfBreathPatterns();
									break;
								}
							
							}						
						}
					}
					
					gamePanel.targetRate.text = String(flyingObjects[0][1]);
				}				
			}
			
			else if (calibrationBreathsDone == 1) {
				
				checkTargetsHit();	
				
				if ((flyingObjects[0][0][0].x <= 320+xStep) && DC.objLiveGraph.judgedBreaths.length == 0) {   //AUG 12th NEW, when bird is 1/2 second before the first flower of the first pattern
					
					DC.objLiveGraph.judgedBreaths.push([ [],DC.objLiveGraph.actualBreathsWithinAPattern.concat(),-1]); //AUG 12th NEW the concat() here is to copy the array (to avoid possible reference problem),saving all non-judged breaths here during 15 second calibration	
								
					DC.objLiveGraph.actualBreathsWithinAPattern = []; //AUG 12th NEW	
					previousExpectedBreathStartTime = roundNumber((DC.objLiveGraph.timeElapsed-graphStartTime)+0.5,10); //AUG 12th NEW, the 0.5 here is to add back the 1/2 second due to 320+xStep above THIS IS THE EXPECTED OR TARGET breath	
					enteredPatternWhileExhaling = DC.objLiveGraph.breathEnding; //AUG 12th NEW, idea here is if user did not finish exhaling during last breath, and that exhale carries into the current breath, then the current breath is bad 
					
					//DC.objLiveGraph.testUI.indicator4.txt1.text = String(DC.objLiveGraph.judgedBreaths.length);
						
				} //AUG 12th NEW
				
				else if ((flyingObjects[0][0][flyingObjects[0][0].length-1].x <= 320+xStep) && savedCurrentBreaths == 0) {   //AUG 12th NEW when bird is 1/2 second before the first flower of a pattern after the first pattern
					
					savedCurrentBreaths = 1; //AUG 12th NEW						
					
					if (DC.objLiveGraph.actualBreathsWithinAPattern.length == 0) { //AUG 12th NEW					
						
						DC.objLiveGraph.actualBreathsWithinAPattern = [[previousExpectedBreathStartTime, 0]]; //AUG 12th NEW  If user did not breathe at all during the target breath, create a breath with 0 RR
												
					}	//AUG 12th NEW		
					
					
					if (DC.objLiveGraph.judgedBreaths.length == 1) {
						
						DC.objLiveGraph.judgedBreaths.push([ [], DC.objLiveGraph.actualBreathsWithinAPattern.concat(), 0]); //AUG 12th NEW the .concat() is to copy the array (to avoid reference problem), the 0 is placeholder to be assigned in the "assessed" functions below

					}
					else {
						
						DC.objLiveGraph.judgedBreaths.push([ [previousExpectedBreathStartTime,previousExpectedBreathRR], DC.objLiveGraph.actualBreathsWithinAPattern.concat(), 0]); //AUG 12th NEW the .concat() is to copy the array (to avoid reference problem), the 0 is placeholder to be assigned in the "assessed" functions below

					}
					
					previousExpectedBreathStartTime = roundNumber((DC.objLiveGraph.timeElapsed-graphStartTime)+0.5,10); //AUG 12th NEW, the 0.5 here is to add back the 1/2 second due to 320+xStep above THIS IS THE EXPECTED OR TARGET breath	
					previousExpectedBreathRR = flyingObjects[0][1]; //AUG 12th NEW	
					DC.objLiveGraph.actualBreathsWithinAPattern = []; //AUG 12th NEW	
					
				}  //AUG 12th NEW			
								
				
				if (flyingObjects[0][0][flyingObjects[0][0].length-1].x <= 320) { 			
						
					savedCurrentBreaths = 0; //AUG 12th NEW
					updateBreathPatterns = 0;				
					
					if (whichPattern == 0) {	
						assessBreathForDynamicPattern();	
					}
					else {
						assessBreathForRegularPattern();
					}
					
					if (DC.objLiveGraph.judgedBreaths.length > 2) { //AUG 12th NEW
						drawBreathingGraph(); //AUG 12th NEW
					} //AUG 12th NEW
					
					enteredPatternWhileExhaling = DC.objLiveGraph.breathEnding; //AUG 12th NEW, idea here is if user did not finish exhaling during last breath, and that exhale carries into the current breath, then the current breath is bad 
					flyingObjects.splice(0,1);					
					gamePanel.targetRate.text = String(flyingObjects[0][1]);				
					createNextBreathPattern(0);						
					
				}		
				
				if (targetLayer.getChildAt(0).x <= -100) {
					targetLayer.removeChildAt(0);
				}	
			}
		
		}
		
		////AUG 12th NEW FUNCTION
		function drawPostureGraph():void {
			
			var XStart:Number = 50; //Just the starting X value on the graph
			var graphBaseY:int = 325;
			var graphXScale:Number = 5;					
			
			removeChild(postureGraph);
			postureGraph = new MovieClip(); //Just clearing the postureGraph between calls (because I'm calling this function multiple times for testing), you may not need this
			addChild(postureGraph); //AUG 12th NEW
			postureGraph.x = 0;  //AUG 12th NEW		
			
			for (var i:int = 0; i<DC.objLiveGraph.judgedPosture.length; i++) {	
				
				if (DC.objLiveGraph.judgedPosture[i][1] == 1) {
					postureGraph.graphics.lineStyle(8,0x008000); 
				} 
				else {
					postureGraph.graphics.lineStyle(8,0xFF0000); 
				}
									
				postureGraph.graphics.moveTo(XStart+(graphXScale*DC.objLiveGraph.judgedPosture[i][0]), graphBaseY);
				
				if (i < DC.objLiveGraph.judgedPosture.length-1) {					
					
					postureGraph.graphics.lineTo(XStart+(graphXScale*DC.objLiveGraph.judgedPosture[i+1][0]), graphBaseY);						
					
				}
				else {
					postureGraph.graphics.lineTo(XStart+(graphXScale*postureSessionTime), graphBaseY);
					
				}			
				
			}		
			
		}
		
		////AUG 12th NEW FUNCTION
		function drawBreathingGraph():void {		
			
			removeChild(breathingGraph);
			breathingGraph = new MovieClip(); //Just clearing the breathingGraph between calls (because I'm calling this function multiple times for testing), you may not need this
			addChild(breathingGraph); 
			breathingGraph.x = 0; 		
			
			//NOTE, this function should only be called when the training session is complete, because maxTargetRR requires all the data to correctly select the max target RR Y axis value (for testing in my code, I'm calling this early and multiple times within a session)
			lastXForActualBreath = 0;
			lastYForActualBreath = 0;
			var i:int = 0;
			var i2:int = 0;	
			var timeVal:Number;
			var RRVal:Number;
			var maxTargetRR:Number = 0;
			var graphBaseY:int = 250;
			var graphXScale:Number = 5; //NOTE, set this scale so that in VT and BT, 3 mins occupies the full width of the iphone 
			var YCeiling:Number = 5; //This is the absolute ceiling of the graph
			var YMaxRR:Number = 30;  //This corresponds to the max RR on the graph range (so if graph crosses this line and hits YCeiling, then user just knows their RR exceeded the range)
			var XStart:Number = 50; //Just the starting X value on the graph
			
			var textMaxRR:TextField = new TextField();                
            textMaxRR.x = XStart-25;
            textMaxRR.y = YMaxRR;
            textMaxRR.background = true;
            textMaxRR.autoSize = TextFieldAutoSize.LEFT;             
			addChild(textMaxRR);
			
			var text0Axis:TextField = new TextField();                
            text0Axis.x = XStart-25;
            text0Axis.y =  graphBaseY+YMaxRR;
            text0Axis.background = true;
            text0Axis.autoSize = TextFieldAutoSize.LEFT; 
            text0Axis.text = "0";
			addChild(text0Axis);
			
			var textMidPoint:TextField = new TextField();                
            textMidPoint.x = XStart-25;
            textMidPoint.y = (graphBaseY-YMaxRR)/2 + YMaxRR;
            textMidPoint.background = true;
            textMidPoint.autoSize = TextFieldAutoSize.LEFT;            
			addChild(textMidPoint);
			
			
			//Draw the X axis (0 axis)
			breathingGraph.graphics.lineStyle(1,0x000000); //AUG 12th NEW		
			breathingGraph.graphics.moveTo(XStart, graphBaseY+YMaxRR);
			breathingGraph.graphics.lineTo(1920, graphBaseY+YMaxRR);		
			
			//Draw the X axis midpoint
			breathingGraph.graphics.lineStyle(1,0x000000); //AUG 12th NEW		
			breathingGraph.graphics.moveTo(XStart, (graphBaseY-YMaxRR)/2 + YMaxRR);
			breathingGraph.graphics.lineTo(1920, (graphBaseY-YMaxRR)/2 + YMaxRR);	
			
			//Draw the YMaxRR X axis 			
			breathingGraph.graphics.moveTo(XStart, YMaxRR);
			breathingGraph.graphics.lineTo(1920, YMaxRR);
			
			//Draw the top X axis 			
			breathingGraph.graphics.moveTo(XStart, YCeiling);
			breathingGraph.graphics.lineTo(1920, YCeiling);
			
			//Draw the Y axis		
			breathingGraph.graphics.moveTo(XStart, graphBaseY+YMaxRR);
			breathingGraph.graphics.lineTo(XStart, YCeiling);
			
			//Draw the X axis number lines (1,2,3)	
			breathingGraph.graphics.moveTo(XStart+(1*60*graphXScale), graphBaseY+YMaxRR-5);
			breathingGraph.graphics.lineTo(XStart+(1*60*graphXScale), graphBaseY+YMaxRR+5);
			
			breathingGraph.graphics.moveTo(XStart+(2*60*graphXScale), graphBaseY+YMaxRR-5);
			breathingGraph.graphics.lineTo(XStart+(2*60*graphXScale), graphBaseY+YMaxRR+5);
			
			breathingGraph.graphics.moveTo(XStart+(3*60*graphXScale), graphBaseY+YMaxRR-5);
			breathingGraph.graphics.lineTo(XStart+(3*60*graphXScale), graphBaseY+YMaxRR+5);
			
			
			
			
			//Find the largest target RR for setting the Y axis top bounds of the graph
			for (i = 0; i<DC.objLiveGraph.judgedBreaths.length; i++) {
				if (DC.objLiveGraph.judgedBreaths[i][0].length > 0) {
					if (DC.objLiveGraph.judgedBreaths[i][0][1] > maxTargetRR) {
						maxTargetRR = DC.objLiveGraph.judgedBreaths[i][0][1];
					}
				}
			}
			
			//Make sure it's an even integer so that the graph midpoint is also an integer 
			maxTargetRR = Math.round(maxTargetRR);
			if ( (maxTargetRR % 2) != 0) {
				maxTargetRR = maxTargetRR + 1;
			}		
			
			textMaxRR.text = String(maxTargetRR);
			textMidPoint.text = String(maxTargetRR/2);
			
			//DC.objLiveGraph.testUI.indicator4.txt1.text = String(maxTargetRR);	
			
			for (i = 0; i<DC.objLiveGraph.judgedBreaths.length; i++) {						
				
				// Draw and connect the target (expected) breaths graph nodes
				if (DC.objLiveGraph.judgedBreaths[i][0].length > 0) {
					
					RRVal = (graphBaseY*(1-(DC.objLiveGraph.judgedBreaths[i][0][1]/maxTargetRR))) + YMaxRR;
					if (RRVal < YCeiling) {
						RRVal = YCeiling; //This is Y coordinate min ceiling, (0,0 is upper left corner here)
					}
					
					breathingGraph.graphics.beginFill(0x0000FF,1); //AUG 12th NEW
					breathingGraph.graphics.lineStyle(3,0x0000FF); //AUG 12th NEW		
					breathingGraph.graphics.drawCircle(graphXScale*DC.objLiveGraph.judgedBreaths[i][0][0] + XStart, RRVal, 2);
					
					if (i > 0) {
						
						if (DC.objLiveGraph.judgedBreaths[i-1][0].length > 0) {
							
							breathingGraph.graphics.moveTo(graphXScale*DC.objLiveGraph.judgedBreaths[i][0][0] + XStart, RRVal);
							
							RRVal = (graphBaseY*(1-(DC.objLiveGraph.judgedBreaths[i-1][0][1]/maxTargetRR))) + YMaxRR;
							if (RRVal < YCeiling) {
								RRVal = YCeiling; //This is Y coordinate min ceiling, (0,0 is upper left corner here)
							}
							breathingGraph.graphics.lineTo(graphXScale*DC.objLiveGraph.judgedBreaths[i-1][0][0] + XStart, RRVal);
						}
					}	
					
				}		
								
				// Draw and connect the actual breaths graph nodes
				for (i2 = 0; i2<DC.objLiveGraph.judgedBreaths[i][1].length; i2++) {			
			
					if (DC.objLiveGraph.judgedBreaths[i][1][i2].length > 0) {						
					
						timeVal = graphXScale*(DC.objLiveGraph.judgedBreaths[i][1][i2][0]) + XStart;						
						RRVal = (graphBaseY*(1-(DC.objLiveGraph.judgedBreaths[i][1][i2][1]/maxTargetRR))) + YMaxRR;
						
						if (RRVal < YCeiling) {
							RRVal = YCeiling; //This is Y coordinate min ceiling, (0,0 is upper left corner here)
						}						
						
						if (DC.objLiveGraph.judgedBreaths[i][2] == -1) { //The breaths before the training starts (during 15 second calibration for example) should be black nodes and black lines (meaning not judged)
							breathingGraph.graphics.beginFill(0x000000,1); 
							breathingGraph.graphics.lineStyle(3,0x000000); 	
						}
						else if (DC.objLiveGraph.judgedBreaths[i][2] == 0) {
							breathingGraph.graphics.beginFill(0xFF0000,1); 
							breathingGraph.graphics.lineStyle(3,0xFF0000); 	
						}
						else {
							breathingGraph.graphics.beginFill(0x008000,1); 					
							breathingGraph.graphics.lineStyle(3,0x008000); 	
						}
					
						breathingGraph.graphics.drawCircle(timeVal, RRVal,2);
						//DC.objLiveGraph.testUI.indicator4.txt1.text = String(timeVal) + "   " + String(RRVal);			
					
					//	if ( (RRVal != (graphBaseY + YMaxRR)) && (lastYForActualBreath != (graphBaseY + YMaxRR)) ) { //I Might add this back later, remove for now, Don't connect the lines if there was no breath (so there will be one red node at the bottom line, disconnected, meaning no breath during that pattern)
							if (i2 > 0) {
								breathingGraph.graphics.moveTo(lastXForActualBreath, lastYForActualBreath);
								breathingGraph.graphics.lineTo(timeVal, RRVal);
							}
							else if (i > 0 && (lastXForActualBreath != 0 && lastYForActualBreath != 0) ) {
								breathingGraph.graphics.moveTo(lastXForActualBreath,lastYForActualBreath);
								breathingGraph.graphics.lineTo(timeVal, RRVal);
							}
					//	}
					
						lastXForActualBreath = timeVal;
						lastYForActualBreath = RRVal;
					}
					
					
				}	
			
			}
		}
		
		function assessBreathForRegularPattern():void {		
			
			//totalBreaths++; //AUG 12th REMOVED
			
			if (flyingObjects[0][0].length == targetsHit && (DC.objLiveGraph.judgedBreaths[DC.objLiveGraph.judgedBreaths.length-1][1].length == 1) && enteredPatternWhileExhaling == 0) {  //AUG 1st CHANGED				
				
				mindfulBreathCount++;				
				
				DC.objLiveGraph.judgedBreaths[DC.objLiveGraph.judgedBreaths.length-1][2] = 1; //AUG 1st NEW					
				
			}
			
			totalBreaths++; //AUG 12th ADDED
			targetsHit = 0;	
			
			gamePanel.mindfulBreaths.text = String(mindfulBreathCount) + " of " + String(totalBreaths);
			
		}
		
		
		function assessBreathForDynamicPattern():void {			
						
			breathsOnCurrentLevel++;		
			//totalBreaths++; //AUG 12th REMOVED
			if (breathsOnCurrentLevel == 6) {
				breathsOnCurrentLevel = 1;
				goodBreaths = 0;
				
			}
			
			if (flyingObjects[0][0].length == targetsHit && (DC.objLiveGraph.judgedBreaths[DC.objLiveGraph.judgedBreaths.length-1][1].length == 1) && enteredPatternWhileExhaling == 0) {	//AUG 1st CHANGED
				
				goodBreaths++;
				mindfulBreathCount++;				
				
				DC.objLiveGraph.judgedBreaths[DC.objLiveGraph.judgedBreaths.length-1][2] = 1; //AUG 1st NEW	
				
				
			}					
						
			totalBreaths++; //AUG 12th ADDED				
			targetsHit = 0;	
						
			if (breathsOnCurrentLevel == 5) {				
				
				if (goodBreaths >= 4) {
					
					subPattern++;
					if (subPattern > maxSubPattern) { //may 8th  maxSubPattern is representing the minimum target respiration rate
						subPattern = maxSubPattern;  //may 8th
					}
					else {
						updateBreathPatterns = 1;
					}
				}
				
				else {
					
					subPattern--;
					if (subPattern < 0) {
						subPattern = 0;
					}
					else {
						updateBreathPatterns = 1;
					}
					
				}
				
				
				
				
			}	
			
			//gamePanel.mindfulBreaths.text = String(goodBreaths) + "/" + String(breathsOnCurrentLevel);	
			gamePanel.mindfulBreaths.text = String(mindfulBreathCount) + " of " + String(totalBreaths);
			
		}
		
			
		function createInitialSetOfBreathPatterns():void  {				
			
			createNextBreathPattern(0); 
			createNextBreathPattern(0);
			createNextBreathPattern(0);
			createNextBreathPattern(0);
			createNextBreathPattern(0);
			createNextBreathPattern(0);		
			
			createNextBreathPattern(0);
			createNextBreathPattern(0);
			createNextBreathPattern(0);
			createNextBreathPattern(0);	
			
			if (whichPattern == 0) {
				setInvisibleInitialPatterns();
			}
			
		}
		
		function uprightHasBeenSet():void {
			
			gamePanel.startGameButton.visible = true;
			gamePanel.uprightPostureNotification.visible = false;
			gamePanel.elapsedTime.visible = true;
						
		}
		
			
		
		function startMode():void  {				
			
			addChild(DC.objLiveGraph); //***JULY 13th ADDED   Luccas, ignore this, this is just to show the live graph on my desktop for debugging
			DC.objLiveGraph.scaleX = 0.7;  //***JULY 13th ADDED   Luccas, ignore this, this is just to show the live graph on my desktop
			DC.objLiveGraph.scaleY = 0.7;  //***JULY 13th ADDED   Luccas, ignore this, this is just to show the live graph on my desktop
			DC.objLiveGraph.postureUI.visible = false;  //***JULY 13th ADDED   Luccas, ignore this, this is just to show the live graph on my desktop
			
			
			
			gamePanel.startGameButton.gotoAndStop(1);
			gamePanel.backButton.visible = true;
			balloon.visible = false;
			startRecordingActualBreaths = 0; //AUG 12th NEW
			savedCurrentBreaths = 0; //AUG 12th NEW
			graphStartTime = 0;  //AUG 12th New				
			
			DC.objLiveGraph.startMode(); //Need this here because user needs to be able set posture before scrolling starts!	
			
			DC.objLiveGraph.breathTopExceededThreshold = 0; //AUG 1st NEW
			DC.objLiveGraph.lightBreathsThreshold = 0; //AUG 1st NEW
			DC.objLiveGraph.minBreathRange = DC.objLiveGraph.fullBreathGraphHeight/16; //AUG 1st 	
			DC.objLiveGraph.minBreathRangeForStuck = (DC.objLiveGraph.fullBreathGraphHeight/16); //AUG 1st 
			
			if (DC.objLiveGraph.postureLevel == 1) {  //AUG 1st NEW 
				gamePanel.postureResponse.level1.selected = true; //AUG 1st NEW 
			} //AUG 1st NEW 
			else if (DC.objLiveGraph.postureLevel == 2) { //AUG 1st NEW 
				gamePanel.postureResponse.level2.selected = true; //AUG 1st NEW 
			} //AUG 1st NEW 
			else if (DC.objLiveGraph.postureLevel == 3) { //AUG 1st NEW 
				gamePanel.postureResponse.level3.selected = true; //AUG 1st NEW 
			} //AUG 1st NEW 
			
			if (breathLevel == 1) {  //AUG 1st NEW 
				gamePanel.breathResponse.level1.selected = true; //AUG 1st NEW 
				DC.objLiveGraph.smoothBreathingCoefBaseLevel = 0.15;  //AUG 1st NEW 
				DC.objLiveGraph.reversalThreshold = 6;   //AUG 1st NEW 
				DC.objLiveGraph.birdIncrements = 24;	 //AUG 1st NEW 
			} //AUG 1st NEW 
			else if (breathLevel == 2) { //AUG 1st NEW 
				gamePanel.breathResponse.level2.selected = true; //AUG 1st NEW 
				DC.objLiveGraph.smoothBreathingCoefBaseLevel = 0.4; //AUG 1st NEW 
				DC.objLiveGraph.reversalThreshold = 5; //AUG 1st NEW 
				DC.objLiveGraph.birdIncrements = 20; //AUG 1st NEW 
			} //AUG 1st NEW 
			else if (breathLevel == 3) { //AUG 1st NEW 
				gamePanel.breathResponse.level3.selected = true; //AUG 1st NEW 
				DC.objLiveGraph.smoothBreathingCoefBaseLevel = 0.6; //AUG 1st NEW 
				DC.objLiveGraph.reversalThreshold = 3; //AUG 1st NEW 
				DC.objLiveGraph.birdIncrements = 12; //AUG 1st NEW 
			}	 //AUG 1st NEW 					
			
			if (whichPattern != 0) {
			
				nameOfPattern = patternSequence[whichPattern][0][4];
			
			}
		
			else {
			
				nameOfPattern = "SLOWING PATTERN";
			}
		
			gamePanel.patternName.text = nameOfPattern;	
			
			gamePanel.elapsedTime.text = convertTime(trainingDuration);
			
			if (trainingPosture == 1) {
				gamePanel.postureType.text = "LOWER BACK SEATED";
			}
			else if (trainingPosture == 2) {
				gamePanel.postureType.text = "UPPER BACK SEATED";
			}
			
			else if (trainingPosture == 3) {
				gamePanel.postureType.text = "UPPER BACK STANDING";
			}
			
			gameSetTime = trainingDuration;		
			
			gamePanel.sessionCompleteIndicator.visible = false;
			
			gamePanel.startGameButton.visible = false;
			gamePanel.uprightPostureNotification.visible = true;
			gamePanel.elapsedTime.visible = false;
			
			hasUprightBeenSet = 0;
			
			if (DC.objGame.trainingPosture == 1 || DC.objGame.trainingPosture == 2) {
				DC.objGame.gamePanel.postureState.gotoAndStop(1);	
			}
			else if (DC.objGame.trainingPosture == 3) {
				DC.objGame.gamePanel.postureState.gotoAndStop(31);
			}			
			
			//AUG 1st BLOCK OF CODE REMOVED
			//if (DC.objLiveGraph.postureUI.postureSelector.postureLevel1.selected == true) {				
				//gamePanel.postureResponse.level1.selected = true;
			//}
			//else if (DC.objLiveGraph.postureUI.postureSelector.postureLevel2.selected == true) {				
				//gamePanel.postureResponse.level2.selected = true;
			//}
			//else if (DC.objLiveGraph.postureUI.postureSelector.postureLevel3.selected == true) {				
				//gamePanel.postureResponse.level3.selected = true;
			//}					
				
			
			//if (DC.objLiveGraph.postureUI.breathSelector.breathLevel1.selected == true) {
				//gamePanel.breathResponse.level1.selected = true;
			//}
			//else if (DC.objLiveGraph.postureUI.breathSelector.breathLevel2.selected == true) {
				//gamePanel.breathResponse.level2.selected = true;
			//}
			//else if (DC.objLiveGraph.postureUI.breathSelector.breathLevel3.selected == true) {
				//gamePanel.breathResponse.level3.selected = true;
			//}						
			
			
		}
		
		function postureSelectorHandler(evt:MouseEvent)  {
			
			if (gamePanel.postureResponse.level1.selected == true) {
				//DC.objLiveGraph.postureUI.postureSelector.postureLevel1.selected = true; // AUG 1st REMOVED
				DC.objLiveGraph.postureRange = 0.15;
				DC.objLiveGraph.postureLevel = 1;  // AUG 1st NEW
			}
			
			else if (gamePanel.postureResponse.level2.selected == true) {
				//DC.objLiveGraph.postureUI.postureSelector.postureLevel2.selected = true;  // AUG 1st REMOVED
				DC.objLiveGraph.postureRange = 0.10;
				DC.objLiveGraph.postureLevel = 2;  // AUG 1st NEW
			}
			
			else if (gamePanel.postureResponse.level3.selected == true) {
				//DC.objLiveGraph.postureUI.postureSelector.postureLevel3.selected = true;  // AUG 1st REMOVED
				DC.objLiveGraph.postureRange = 0.05;
				DC.objLiveGraph.postureLevel = 3;  // AUG 1st NEW
			}
			
		}
		
		function breathSelectorHandler(evt:MouseEvent)  {
			
			if (gamePanel.breathResponse.level1.selected == true) {
				//DC.objLiveGraph.postureUI.breathSelector.breathLevel1.selected = true;  // AUG 1st REMOVED
				DC.objLiveGraph.smoothBreathingCoefBaseLevel = 0.15;
				DC.objLiveGraph.reversalThreshold = 6; 
				//DC.objLiveGraph.birdIncrements = 16;
				DC.objLiveGraph.birdIncrements = 24;
				breathLevel = 1;  // AUG 1st NEW
			}
			
			else if (gamePanel.breathResponse.level2.selected == true) {
				//DC.objLiveGraph.postureUI.breathSelector.breathLevel2.selected = true;  // AUG 1st REMOVED
				DC.objLiveGraph.smoothBreathingCoefBaseLevel = 0.4;
				DC.objLiveGraph.reversalThreshold = 5;
				//DC.objLiveGraph.birdIncrements = 12;
				DC.objLiveGraph.birdIncrements = 20;
				breathLevel = 2;  // AUG 1st NEW
			}
			
			else if (gamePanel.breathResponse.level3.selected == true) {
				//DC.objLiveGraph.postureUI.breathSelector.breathLevel3.selected = true;  // AUG 1st REMOVED
				DC.objLiveGraph.smoothBreathingCoefBaseLevel = 0.6;
				DC.objLiveGraph.reversalThreshold = 3;
				DC.objLiveGraph.birdIncrements = 12;
				breathLevel = 3;  // AUG 1st NEW
			}
			
		}
		
		
		
		
		function backButtonHandler(evt:MouseEvent):void  {	
			
			DC.objLiveGraph.postureUI.visible = true;  //July 13th ADDED, YOU may not need this Luccas, in BT and PT, I hide the postureUI when displaying the live graph (because the postureUI component is part of Live graph but unecessary when viewed in BT and PT, because those already separately display the posture details), but you probably organized the structure differently
			DC.objLiveGraph.scaleX = 1;  //***July 13th ADDED  YOU may not need this Luccas
			DC.objLiveGraph.scaleY = 1;  //***July 13th ADDED  YOU may not need this Luccas
			
			DC.removeChild(DC.objGame);
			DC.addChild(DC.objModeScreen);	
			DC.objModeScreen.startScreen3.visible = false;
			DC.objModeScreen.startScreen4.visible = true;
			DC.objModeScreen.VTLauncher1.visible = false;
			DC.appMode = 0;	
			trainingDuration = 0;
			
			gamePanel.mindfulBreaths.text = "--";
			gamePanel.targetRate.text = "--";
			gamePanel.actualRate.text = "--";
			gamePanel.patternName.text = "--";
			gamePanel.timeUpright.text = "--";
			gamePanel.slouches.text = "0";
			
		}
			
		
		function startGameButtonHandler(evt:MouseEvent):void  {	
			
			if (gamePanel.startGameButton.currentFrame == 1) {
				
				graphStartTime = DC.objLiveGraph.timeElapsed;  //AUG 12th New				
				DC.objLiveGraph.judgedBreaths = []; //AUG 12th NEW	
				DC.objLiveGraph.judgedPosture = []; //AUG 12th NEW					
				DC.objLiveGraph.actualBreathsWithinAPattern = [] //AUG 12th NEW
				postureSessionTime = 0; //AUG 12th NEW
				
				addChild(breathingGraph); //AUG 12th NEW
				addChild(postureGraph); //AUG 12th NEW
				
				DC.objLiveGraph.judgedPosture.push([0,DC.objLiveGraph.postureIsGood]); //AUG 12th NEW  Record the initial posture state, NOTE: this array only records CHANGES in posture, not every second of posture state
				
				balloon.visible = true;
				
				gamePanel.startGameButton.gotoAndStop(2);			
				
				if (skipCalibration == 0) { //may 8th
					addCalibrationBreathRegion(); //may 8th
				} //may 8th
				
				gamePanel.backButton.visible = false; //You MUST end the session first before the back button re-appears.
				
				if (whichPattern != 0) {
					createInitialSetOfBreathPatterns(); //This may be called at other times, so there is a separate flag for that
					gamePanel.targetRate.text = String(flyingObjects[0][1]); // may 8th
				}										
				
				addEventListener(Event.ENTER_FRAME, enterFrameHandler); 
				
				//myTimer.start();
				//myTimer2.start();
				//gameTimer.start();
								
				DC.objLiveGraph.stuckBreathsThreshold = 3; //JULY 13:NEW1g need more stuck breaths during the game, otherwise bird falls suddenly too often.
				//DC.objLiveGraph.breathTopExceededThreshold = 0; //AUG 1st REMOVED  set to 0, so that breath range can be found more quickly during calibration
				//DC.objLiveGraph.lightBreathsThreshold = 0; //AUG 1st REMOVED  set to 0, so that breath range can be found more quickly during calibration
				//DC.objLiveGraph.minBreathRange = DC.objLiveGraph.fullBreathGraphHeight/8; //AUG 1st REMOVED	
				//DC.objLiveGraph.minBreathRangeForStuck = (DC.objLiveGraph.fullBreathGraphHeight/8); //AUG 1st REMOVED
				DC.objLiveGraph.breathCountAtCalibrationStart = DC.objLiveGraph.breathCount;  //AUG 1st New	
				DC.objLiveGraph.timeElapsedAtCalibrationStart = DC.objLiveGraph.timeElapsed;  //AUG 1st New			
				
			}
			
			
			else if (gamePanel.startGameButton.currentFrame == 2) {
				
				gamePanel.startGameButton.visible = false;
				gamePanel.backButton.visible = true; 
				
				DC.objLiveGraph.saveData(); //***march20
				
				clearGame();
				
			}
			
		}
		
		
		function checkTargetsHit():void {			
			
			var i:int;
			var i2:int;
			var count:int = DC.objLiveGraph.count;							
			
			for (i2 = 0; i2<flyingObjects[0][0].length; i2++) {							
				
				if (balloon.hitTestObject(flyingObjects[0][0][i2]) == true) {
						
					if (flyingObjects[0][0][i2] is Flower1Anim || flyingObjects[0][0][i2] is Flower2Anim) {															
						
						if (flyingObjects[0][0][i2].currentFrame == 1) {
							targetsHit++;
							
							flyingObjects[0][0][i2].gotoAndPlay(2);	
							
							if ((flyingObjects[0][0][i2+1] is Flower1Anim || flyingObjects[0][0][i2+1] is Flower2Anim) && flyingObjects[0][0][i2+1].x == flyingObjects[0][0][i2].x) {
								flyingObjects[0][0][i2+1].gotoAndPlay(2);
								targetsHit++;
							}
							
							if ((flyingObjects[0][0][i2+2] is Flower1Anim || flyingObjects[0][0][i2+2] is Flower2Anim) && flyingObjects[0][0][i2+2].x == flyingObjects[0][0][i2].x) {
								flyingObjects[0][0][i2+2].gotoAndPlay(2);
								targetsHit++;
							}
							
							if ((flyingObjects[0][0][i2+3] is Flower1Anim || flyingObjects[0][0][i2+3] is Flower2Anim) && flyingObjects[0][0][i2+3].x == flyingObjects[0][0][i2].x) {
								flyingObjects[0][0][i2+3].gotoAndPlay(2);
								targetsHit++;
							}
							
						
							
							if (i2 > 0 && (flyingObjects[0][0][i2-1] is Flower1Anim || flyingObjects[0][0][i2-1] is Flower2Anim) && flyingObjects[0][0][i2-1].x == flyingObjects[0][0][i2].x) {
								flyingObjects[0][0][i2-1].gotoAndPlay(2);
								targetsHit++;
							}
							
							if (i2 > 1 && (flyingObjects[0][0][i2-2] is Flower1Anim || flyingObjects[0][0][i2-2] is Flower2Anim) && flyingObjects[0][0][i2-2].x == flyingObjects[0][0][i2].x) {
								flyingObjects[0][0][i2-2].gotoAndPlay(2);
								targetsHit++;
							}
							
							if (i2 > 2 && (flyingObjects[0][0][i2-3] is Flower1Anim || flyingObjects[0][0][i2-3] is Flower2Anim) && flyingObjects[0][0][i2-3].x == flyingObjects[0][0][i2].x) {
								flyingObjects[0][0][i2-3].gotoAndPlay(2);
								targetsHit++;
							}			
						
							
							
						}						
						
					}						
				
				}				
				
				
			}
						
											
		
								
			
		}
		
	
		

	}
	
}
