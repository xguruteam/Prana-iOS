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
			
			//Dynamic slow breathing pattern
						
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
			patternSequence[4].push([1.5,0,1.5,2,"FOCUS PATTERN 12 BPM"]); //12 bpm
			patternSequence[5].push([2,0,2,2,"FOCUS PATTERN 10 BPM"]); //10 bpm
			patternSequence[6].push([2.5,0,2.5,2.5,"FOCUS PATTERN 8 BPM"]); //8 bpm
			patternSequence[7].push([3.5,0,3.5,3,"FOCUS PATTERN 6 BPM"]); //6 bpm
			
			//Relax breathing patterns
			
			patternSequence[8] = [];
			patternSequence[9] = [];
			patternSequence[10] = [];
			patternSequence[11] = [];
			patternSequence[12] = [];
			patternSequence[8].push([1,0,2,1,"RELAX PATTERN 15 BPM"]); //15 bpm
			patternSequence[9].push([1,0,2,2,"RELAX PATTERN 12 BPM"]); //12 bpm
			patternSequence[10].push([1.5,0,3,1.5,"RELAX PATTERN 10 BPM"]); //10 bpm
			patternSequence[11].push([1.5,0,3,3,"RELAX PATTERN 8 BPM"]); //8 bpm
			patternSequence[12].push([2.5,0,5,2.5,"RELAX PATTERN 6 BPM"]); //6 bpm
			
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
			
			gamePanel.elapsedTime.text = convertTime(trainingDuration);
			
			if (DC.objLiveGraph.postureIsGood == 1) {
				uprightPostureTime++;
			}
			
			if (prevPostureState == 1) {
				if (DC.objLiveGraph.postureIsGood == 0) {
					slouchesCount++;
				}
			}
			
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
			
			
			if (calibrationBreathsDone == 0) {	
				
				if (targetLayer.getChildAt(0).x <= -1130) {  //accounting for 70 width of bird
					targetLayer.removeChildAt(0);
					calibrationBreathsDone = 1;					
					
					if (whichPattern == 0) {						
						
						lastX = 500;
						
						initialFadeIn = 1; //fade in initial patterns
						
						if (DC.objLiveGraph.respRate >= 24) {
							subPattern = 0;
							createInitialSetOfBreathPatterns();
						}
						else if (DC.objLiveGraph.respRate <=8) {
							subPattern = 10;
							createInitialSetOfBreathPatterns();
						}
						
						else {
							for (i = 0; i < patternSequence[0].length; i++) {
								a = 60/(patternSequence[0][i][0] + patternSequence[0][i][1] + patternSequence[0][i][2]+ patternSequence[0][i][3]);
								if (DC.objLiveGraph.respRate > a) {
									subPattern = i;
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
				
				if (flyingObjects[0][0][flyingObjects[0][0].length-1].x <= 320) {  
				
					updateBreathPatterns = 0;
					
					if (whichPattern == 0) {	
						assessBreathForDynamicPattern();	
					}
					else {
						assessBreathForRegularPattern();
					}
					
					flyingObjects.splice(0,1);					
					gamePanel.targetRate.text = String(flyingObjects[0][1]);				
					createNextBreathPattern(0);	
				
				}		
				
				if (targetLayer.getChildAt(0).x <= -100) {
					targetLayer.removeChildAt(0);
				}	
			}
		
		}
		
		function assessBreathForRegularPattern():void {		
			
			totalBreaths++;	
			
			if (flyingObjects[0][0].length == targetsHit) {					
				
				mindfulBreathCount++;
			}
			
			targetsHit = 0;	
			
			gamePanel.mindfulBreaths.text = String(mindfulBreathCount) + " of " + String(totalBreaths);
			
		}
		
		
		function assessBreathForDynamicPattern():void {			
						
			breathsOnCurrentLevel++;		
			totalBreaths++;		
			if (breathsOnCurrentLevel == 6) {
				breathsOnCurrentLevel = 1;
				goodBreaths = 0;
				
			}
			
			if (flyingObjects[0][0].length == targetsHit) {	
				
				goodBreaths++;
				mindfulBreathCount++;
			}
			
			targetsHit = 0;	
						
			if (breathsOnCurrentLevel == 5) {				
				
				if (goodBreaths >= 4) {
					
					subPattern++;
					if (subPattern > 34) {
						subPattern = 34;
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
			
			gamePanel.startGameButton.gotoAndStop(1);
			gamePanel.backButton.visible = true;
			balloon.visible = false;
			
			
			DC.objLiveGraph.startMode(); //Need this here because user needs to be able set posture before scrolling starts!
			
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
			
			
			if (DC.objLiveGraph.postureUI.postureSelector.postureLevel1.selected == true) {				
				gamePanel.postureResponse.level1.selected = true;
			}
			else if (DC.objLiveGraph.postureUI.postureSelector.postureLevel2.selected == true) {				
				gamePanel.postureResponse.level2.selected = true;
			}
			else if (DC.objLiveGraph.postureUI.postureSelector.postureLevel3.selected == true) {				
				gamePanel.postureResponse.level3.selected = true;
			}					
				
			
			if (DC.objLiveGraph.postureUI.breathSelector.breathLevel1.selected == true) {
				gamePanel.breathResponse.level1.selected = true;
			}
			else if (DC.objLiveGraph.postureUI.breathSelector.breathLevel2.selected == true) {
				gamePanel.breathResponse.level2.selected = true;
			}
			else if (DC.objLiveGraph.postureUI.breathSelector.breathLevel3.selected == true) {
				gamePanel.breathResponse.level3.selected = true;
			}						
			
			
		}
		
		function postureSelectorHandler(evt:MouseEvent)  {
			
			if (gamePanel.postureResponse.level1.selected == true) {
				DC.objLiveGraph.postureUI.postureSelector.postureLevel1.selected = true;
				DC.objLiveGraph.postureRange = 0.15;
			}
			
			else if (gamePanel.postureResponse.level2.selected == true) {
				DC.objLiveGraph.postureUI.postureSelector.postureLevel2.selected = true;
				DC.objLiveGraph.postureRange = 0.10;
			}
			
			else if (gamePanel.postureResponse.level3.selected == true) {
				DC.objLiveGraph.postureUI.postureSelector.postureLevel3.selected = true;
				DC.objLiveGraph.postureRange = 0.05;
			}
			
		}
		
		function breathSelectorHandler(evt:MouseEvent)  {
			
			if (gamePanel.breathResponse.level1.selected == true) {
				DC.objLiveGraph.postureUI.breathSelector.breathLevel1.selected = true;
				DC.objLiveGraph.smoothBreathingCoefBaseLevel = 0.15;
				DC.objLiveGraph.reversalThreshold = 6;
				//DC.objLiveGraph.birdIncrements = 16;
				DC.objLiveGraph.birdIncrements = 24;
			}
			
			else if (gamePanel.breathResponse.level2.selected == true) {
				DC.objLiveGraph.postureUI.breathSelector.breathLevel2.selected = true;
				DC.objLiveGraph.smoothBreathingCoefBaseLevel = 0.4;
				DC.objLiveGraph.reversalThreshold = 5;
				//DC.objLiveGraph.birdIncrements = 12;
				DC.objLiveGraph.birdIncrements = 20;
			}
			
			else if (gamePanel.breathResponse.level3.selected == true) {
				DC.objLiveGraph.postureUI.breathSelector.breathLevel3.selected = true;
				DC.objLiveGraph.smoothBreathingCoefBaseLevel = 0.6;
				DC.objLiveGraph.reversalThreshold = 3;
				DC.objLiveGraph.birdIncrements = 12;
			}
			
		}
		
		
		
		
		function backButtonHandler(evt:MouseEvent):void  {	
			
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
				
				balloon.visible = true;
				
				gamePanel.startGameButton.gotoAndStop(2);			
				
				addCalibrationBreathRegion();
				
				gamePanel.backButton.visible = false; //You MUST end the session first before the back button re-appears.
				
				if (whichPattern != 0) {
					createInitialSetOfBreathPatterns(); //This may be called at other times, so there is a separate flag for that
				}										
				
				addEventListener(Event.ENTER_FRAME, enterFrameHandler);
				
				//myTimer.start();
				//myTimer2.start();
				//gameTimer.start();
								
				DC.objLiveGraph.stuckBreathsThreshold = 2; //need more stuck breaths during the game, otherwise bird falls suddenly too often.
				DC.objLiveGraph.breathTopExceededThreshold = 1;		
				DC.objLiveGraph.minBreathRange = 50;
				
			
			}
			
			
			else if (gamePanel.startGameButton.currentFrame == 2) {
				
				gamePanel.startGameButton.visible = false;
				gamePanel.backButton.visible = true; 
				
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
