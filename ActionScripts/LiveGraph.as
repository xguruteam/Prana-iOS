package  {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.media.*;	
	import flash.net.*;	
	import flash.text.*;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.events.TextEvent;	
	import flash.utils.Timer;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import fl.controls.RadioButton;
	import fl.controls.RadioButtonGroup;
	
	public class LiveGraph extends MovieClip {		
		
		var storedXSensor:Array = new Array;
		var storedYSensor:Array = new Array;
		var storedZSensor:Array = new Array;
		var storedRSensor:Array = new Array;
		var storedBSensor:Array = new Array;
		
		var DC:Main;
		var breathGraph:MovieClip = new MovieClip();		
		var xCoord:int = 840;
		var dataArray:Array = new Array;
		var count:int = -1; 
		var fullBreathGraphHeight:int = 400;
		var yStartPos:int = 500;
		var graphY:Number;		
		var graphYSeries:Array = new Array;			
		var breathSensor:Array = new Array;	
		var relativePosturePositionFiltered:Array = new Array;		
		var zSensor:Array = new Array;		
		var xSensor:Array = new Array;		
		var ySensor:Array = new Array;		
		var dampHistory:Array = new Array;		
		var rotationSensor:Array = new Array;		
		var relativeInhaleLevelSG:Number;	
		var relativeInhaleLevelRS:Number;	
		var bellyBreathHasStarted:int = 0;					
		var bottomReversalLine:StartInhale = new StartInhale(); //blue line deoxygenated
		var topReversalLine:StartExhale = new StartExhale(); //red line oxygenated 
		var endBreathLine:EndBreathThreshold = new EndBreathThreshold(); //yellow line
		var zeroLine:ZeroLine = new ZeroLine(); //green line					
		var showDebugUI:ControlArrowUp = new ControlArrowUp();					
		var testUI:TestUI = new TestUI();		
		var postureUI:PostureUI = new PostureUI();							
		var upStreak:int = 0;
		var downStreak:int = 0;
		var upStreakStart:int = 0;
		var downStreakStart:int = 0;						
		var bottomReversalY:Number = 500;
		var topReversalY:Number = 0;
		var stuckBreaths:int = 0;
		var endBreathY:Number = 0;		
		var bottomReversalFound:int = 0;
		var topReversalFound:int = 0;							
		var scrollX:int;					
		var currentStrainGaugeLowest:Number;
		var currentStrainGaugeHighest:Number;		
		var breathEnding:int;		
		var strainGauge:Number = 1;		
		var uprightPostureAngle:Number = 0;		
		var uprightSet:int = 0;		
		var currentPostureAngle:Array = new Array;	
		var xPos:int = 0;	
		var whichPostureFrame:int = 1;		
		var useRotationSensor:int = 0;							
		var postureRange:Number = 0.18;		
		var postureAttenuator:Number = 0.15;	
		var smoothBreathingCoef:Number = 1;			
		var lightBreathsInARow:int = 0;	
		var deepBreathsInARow:int = 0;		
		var damp:Number;			
		var dampX:Number;
		var dampY:Number;
		var dampZ:Number;		
		var noisyMovements:int = 0;		
		var dampingLevel:int = 0;		
		var postureAttenuatorLevel:int = 0;			
		var currentStrainGaugeLowestNew:Number;		
		var currentStrainGaugeHighestNew:Number;		
		var newStrainGaugeRange:Number;
		var currentStrainGaugeHighestPrev:Number = 0;		
		var breathTopExceeded:int = 0;		
		var guidedPath:Array = new Array;
		var strainGaugeMinRange:Number = 0.0005;
		var birdDeltaY:Number = 0;	
		var birdVelocity:Number = 0;						
		//var RRtimer:Timer = new Timer(100);	
		var timeElapsed:Number = 0;
		//var whenBreathsEnd:Array = new Array;	//AUG 1st REMOVED	
		var respRate:Number = 0;
		var breathCount:int = 0;
		var stuckBreathsThreshold:int = 3;  //AUG 1st CHANGED
		var breathTopExceededThreshold:int = 1;
		var smoothBreathingCoefBaseLevel:Number = 0.40;
		var postureIsGood:int = 1;
		var minBreathRange:Number;  //***March16Change
		var minBreathRangeForStuck:Number;
		var reversalThreshold:int = 5; //AUG 1st CHANGED
		var birdIncrements:int = 20;
		var avgRespRate:Number = 0;	
		
		var EIRatio:Array = new Array; // May31st ADDED
		var exhaleCorrectionFactor:Number = 0; // May31st ADDED
		var inhaleStartTime:Number = 0; // May31st ADDED
		var inhaleEndTime:Number = 0; // May31st ADDED
		var exhaleEndTime:Number = 0; // May31st ADDED
		var EIAvgSessionRatio:Number = 0; // May31st ADDED
		var EIAvgSessionSummation:Number = 0; //AUG 1st ADDED
		var EIRatioCount:int = 0; // May31st ADDED
		var EIGoodToMeasure:int = 0; // May31st ADDED
		var EI1Minute:Number = 0;  //JULY 13th:NEW1b
		var lightBreathsThreshold:int = 1; //JULY 13th:NEW1i
		
		var whenBreathsStart:Array = new Array; //Aug 1st ADDED
		
		
		var calibrationRR:Number = 0; //AUG 1st ADDED
		var timeElapsedAtCalibrationStart:Number = 0; //AUG 1st ADDED
		var breathCountAtCalibrationStart:int = 0; //AUG 1st ADDED
		
		var postureLevel:int = 2;  //AUG 1st ADDED
		var breathLevel:int = 2;  //AUG 1st ADDED
		
		var enterFrameCount:int = 0; //AUG 1st NEW
		var	inhaleIsValid:int = 0; //AUG 1st NEW  
		var strainGaugeRangePrev:Number = 0.003; //AUG 1st NEW
		
		var breathsForGraph:Array = new Array; //AUG 12th NEW
		var actualBreathsWithinAPattern:Array = new Array; //AUG 12th NEW	
		var judgedBreaths:Array = new Array; //AUG 12th NEW	
		var judgedPosture:Array = new Array; //AUG 12th NEW	
				
		public function LiveGraph(main:Main) {
			
			DC = main; //to have access to the document class				
			
			breathGraph.graphics.lineStyle(4,0x3300FF);	
			breathGraph.graphics.moveTo(xCoord,500);			
			
			showDebugUI.x = 70;
			showDebugUI.y = 1000;				
			
			//postureUI.postureSelector.level2.selected = true; //AUG 1st REMOVED
			//postureUI.breathSelector.level2.selected = true;	 //AUG 1st REMOVED
			
			addChild(testUI);
			testUI.y = 550;
			testUI.x = 0;
			testUI.visible = false;
			bottomReversalLine.y = 500;
			topReversalLine.y = 0;
			endBreathLine.y = 5000; //hide it initially
			zeroLine.y = 500;		
			
			//scrollX = breathGraph.x;
			breathGraph.x = 0;
			scrollX = 0;
			
			postureUI.x = 37;
			postureUI.y = 395;								
			
			postureUI.postureSelector.level1.addEventListener(MouseEvent.CLICK,postureSelectorHandler);
			postureUI.postureSelector.level2.addEventListener(MouseEvent.CLICK,postureSelectorHandler);
			postureUI.postureSelector.level3.addEventListener(MouseEvent.CLICK,postureSelectorHandler);	
			
			postureUI.breathSelector.level1.addEventListener(MouseEvent.CLICK,breathSelectorHandler); //AUG 1st CHANGED name
			postureUI.breathSelector.level2.addEventListener(MouseEvent.CLICK,breathSelectorHandler);  //AUG 1st CHANGED name
			postureUI.breathSelector.level3.addEventListener(MouseEvent.CLICK,breathSelectorHandler);  //AUG 1st CHANGED name
			
			showDebugUI.addEventListener(MouseEvent.MOUSE_DOWN,showDebugUIHandler);			
			showDebugUI.buttonMode = true;					
			
			postureUI.learnUprightButton.addEventListener(MouseEvent.MOUSE_DOWN,learnUprightAngleHandler);
			postureUI.learnUprightButton.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			postureUI.learnUprightButton.addEventListener(MouseEvent.MOUSE_UP,unclickButton);		
			postureUI.learnUprightButton.buttonMode = true;
			
			postureUI.backButton.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);
			postureUI.backButton.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			postureUI.backButton.addEventListener(MouseEvent.MOUSE_UP,backButtonHandler);
			postureUI.backButton.buttonMode = true;				
		
			
			//RRtimer.addEventListener(TimerEvent.TIMER, RRtimerHandler);	
			//whenBreathsEnd[0] = 0; // AUG 1st REMOVED
			
			addChild(breathGraph);	
			addChild(topReversalLine);					
			addChild(zeroLine);	
			addChild(bottomReversalLine);
			addChild(endBreathLine);
			addChild(showDebugUI);							
			addChild(postureUI);
			
			
		}
		
		//function enterFrameHandler (e:Event):void {   May 19th, REMOVED THIS LINE					
			
			//timeElapsed = timeElapsed + (1/60.0);	May 19th, REMOVED THIS LINE					
			
		//} May 19th, REMOVED THIS LINE
		
		
		function resetBreathTrackingVariables():void {				
			
			timeElapsed = 0;
			count = -1;		
			
			breathSensor = [];						
			graphYSeries = [];			
			relativePosturePositionFiltered = [];
			dampHistory = [];			
			rotationSensor = [];
			guidedPath = [];
			//whenBreathsEnd = []; //AUG 1st REMOVED
			//whenBreathsEnd[0] = 0; //AUG 1st removed
			xSensor = [];
			ySensor = [];
			zSensor = [];
			currentPostureAngle = [];			
			
			bottomReversalLine.y = 500;
			topReversalLine.y = 0;
			endBreathLine.y = 5000; //hide it initially
			zeroLine.y = 501;
			testUI.visible = false;
			
			//breathGraph = new MovieClip();			
			//xCoord = 840;
			//scrollX = breathGraph.x;			
			//breathGraph.x = scrollX;			
			//breathGraph.graphics.lineStyle(2,0x3300FF);	
			//breathGraph.graphics.moveTo(xCoord,500);		
			
			upStreak = 0;
			downStreak = 0;
			upStreakStart = 0;
			downStreakStart = 0;	
			useRotationSensor = 0;
			dampingLevel = 0;
			postureAttenuatorLevel = 0;
			noisyMovements = 0;
			topReversalFound = 0;
			bottomReversalFound = 0;
			bottomReversalY = 500;
			topReversalY = 0;
			stuckBreaths = 0;
			endBreathY = 0;
			lightBreathsInARow = 0;
			deepBreathsInARow = 0;	
			breathTopExceeded = 0;
			respRate = 0;
			breathCount = 0;
			
						
		}
	
		public function displayDebugStats():void  {
			
			testUI.indicator1.txt1.text = "strainGauge = " + String(roundNumber(strainGauge,100000)) + "  magneticAngle = " + String(roundNumber(rotationSensor[count],1000)) + "  " + String(useRotationSensor);
			testUI.indicator2.txt1.text = "Z axis = " + String(roundNumber(calibrationRR,1000)) + "  Y axis = " + String(roundNumber(ySensor[count],1000)) + "       X axis = " + String(roundNumber(xSensor[count],1000)) + "     " + String(roundNumber(currentPostureAngle[count],1000)) + " breaths =  " + String(breathCount);
			testUI.indicator3.txt1.text = String(roundNumber(currentStrainGaugeHighest,100000)) + "  " + String(roundNumber(currentStrainGaugeLowest,100000)) + "  " + String(roundNumber(currentStrainGaugeHighest - currentStrainGaugeLowest,100000)) + "  " + String(breathTopExceeded) + "  " + String(lightBreathsInARow) + " noisy " + String(dampingLevel) + " stuck " + String(stuckBreaths);
			//testUI.indicator4.txt1.text =  " dampX = " + roundNumber(dampX,10) + " dampY = " + roundNumber(dampY,10) + " dampZ = " + roundNumber(dampY,10) + "  dampHistory = " + roundNumber(dampHistory[count],10);
			
		}
		
		
		public function resetCount():void
		{		
			if (count == 12000) { //***march18
				
				for (var i:int = 500; i <= 600; i++)  
				{					
					
					xSensor[i-500] = xSensor[i];
					ySensor[i-500] = ySensor[i];
					zSensor[i-500] = zSensor[i];
					currentPostureAngle[i-500] = currentPostureAngle[i];
					rotationSensor[i-500] = rotationSensor[i];
					breathSensor[i-500] = breathSensor[i];				
					graphYSeries[i-500] = graphYSeries[i];
					dampHistory[i-500] = dampHistory[i];
					relativePosturePositionFiltered[i-500] = relativePosturePositionFiltered[i];			
					
				}
				
				count = 100;			
				
			}
		}
		
		public function roundSensorArrays():void { //***march18
			
			xSensor[count] = roundNumber(xSensor[count], 1000000000); //***march18
			ySensor[count] = roundNumber(ySensor[count], 1000000000); //***march18
			zSensor[count] = roundNumber(zSensor[count], 1000000000); //***march18		 	
			rotationSensor[count] = roundNumber(rotationSensor[count], 1000000000); //***march18
			breathSensor[count] = roundNumber(breathSensor[count], 1000000000); //***march18
			currentPostureAngle[count] = roundNumber(currentPostureAngle[count], 1000000000); //***march18
			
		} //***march18
		
		
		public function storeSensorData(sensorData:Array):void  {			
			
			dataArray = sensorData;				
				
			count++;	
			
			storedXSensor[count] = Number(dataArray[3]); //***March28
			storedYSensor[count] = Number(dataArray[2]); //***March28
			storedZSensor[count] = Number(dataArray[4]); //***March28
			storedRSensor[count] = Number(dataArray[5]); //***March28
			storedBSensor[count] = Number(dataArray[1]); //***March28
			
			resetCount();
						
			if (count < 8) { //JULY 13:Change1m  
				
				xSensor[count] = Number(dataArray[3]);
				ySensor[count] = Number(dataArray[2]);
				zSensor[count] = Number(dataArray[4]);					
				
				if (xSensor[count] == 0 && ySensor[count] == 0) {
					currentPostureAngle[count] = 2*(Math.asin(zSensor[count])/Math.PI);				
				}
				else {
					currentPostureAngle[count] = 2*(Math.atan(zSensor[count]/Math.sqrt(Math.pow(xSensor[count],2)+Math.pow(ySensor[count],2)))/Math.PI);				
				}			
				
				rotationSensor[count] = -Number(dataArray[5]);
				breathSensor[count] = 2 - Number(dataArray[1]);	 //strainGauge = Number(dataArray[4]); Use this version instead if signal INCREASES when inhaling
				
				graphYSeries[count] = yStartPos;				
				dampHistory[count] = 1;	
				relativePosturePositionFiltered[count] = currentPostureAngle[count];
				currentStrainGaugeLowest = strainGauge;				
				currentStrainGaugeHighest = currentStrainGaugeLowest + 0.003;
				currentStrainGaugeHighestPrev = currentStrainGaugeHighest;
				
				
			}
			
			else {
				
				xSensor[count] = 0.50 * Number(dataArray[3]) + (1.0 - 0.50) * xSensor[count-1];
				ySensor[count] = 0.50 * Number(dataArray[2]) + (1.0 - 0.50) * ySensor[count-1];
				zSensor[count] = 0.50 * Number(dataArray[4]) + (1.0 - 0.50) * zSensor[count-1];	
				
				if (xSensor[count] == 0 && ySensor[count] == 0) {
					currentPostureAngle[count] = 2*(Math.asin(zSensor[count])/Math.PI);				
				}
				else {
					currentPostureAngle[count] = 2*(Math.atan(zSensor[count]/Math.sqrt(Math.pow(xSensor[count],2)+Math.pow(ySensor[count],2)))/Math.PI);				
				}
				
				rotationSensor[count] = 0.50 * (-Number(dataArray[5])) + (1.0 - 0.50) * rotationSensor[count-1];	
				//breathSensor[count] = 0.5 * (Number(dataArray[1])) + (1.0 - 0.5) * breathSensor[count-1];
				breathSensor[count] = 0.5 * (2 - Number(dataArray[1])) + (1.0 - 0.5) * breathSensor[count-1];
				//breathSensor[count] = 2 - Number(dataArray[4]);	 //strainGauge = Number(dataArray[4]); Use this version instead if signal INCREASES when inhaling

			}	
			
			
			roundSensorArrays(); //***march18
			
			strainGauge = breathSensor[count];											
		
				
			if (count == 8) { //JULY 13:Change1m  				
				
				currentStrainGaugeHighest = currentStrainGaugeLowest + 0.003;
				currentStrainGaugeHighestPrev = currentStrainGaugeHighest;
				
			}	
			
			if (count > 6) {	
				
				if (Math.abs(rotationSensor[count] - rotationSensor[count-6]) > 0.3) {									
						
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

		
		public function setSmoothingAndDamping():void  {			
						
			dampX = 0.005/Math.abs(xSensor[count] - xSensor[count-3]);
			dampY = 0.005/Math.abs(ySensor[count] - ySensor[count-3]);			
			dampZ = 0.005/Math.abs(zSensor[count] - zSensor[count-3]);		
			
			damp = Math.min(dampX, dampY, dampZ);			
			//damp = 0.005/Math.abs(currentPostureAngle[count] - currentPostureAngle[count-3]);	
																		
			if (damp > 1) {
				damp = 1;
			}			
					
			dampHistory[count] = damp;			
			
			if (dampHistory[count] < 0.4) {				
				dampingLevel++;
			}
			
			else {				
				dampingLevel--;
			}
			
			if (dampingLevel > 10) {
				dampingLevel = 10;
			}
			else if (dampingLevel < 0) {
				dampingLevel = 0;				
			}	
			
			if (DC.appMode != 3) {  //Don't set noisyMovements during Buzzer Training, because a noisy movement is almost gauranteed during a breath cycle due to the buzzer occuring at some point (hard to be sure isBuzzing would eliminate that, really need to add a buzzer flag status to the datastream to be sure).
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
			
			
			if (DC.objBuzzerTraining.isBuzzing == 0) {

				var a:Number = 0;
				
				if (dampingLevel > 0) {
					
					smoothBreathingCoef = smoothBreathingCoef * Math.pow(0.80, dampingLevel);	
					
					a = (currentStrainGaugeHighest - currentStrainGaugeLowest)/0.015; //to further dampen when the range is very sensitive
					
					if (a > 0  && a < 1) {
						smoothBreathingCoef = smoothBreathingCoef * a;
					}
					
				}
			
			}
			
			else if (DC.objBuzzerTraining.isBuzzing == 1) { //May 19 ADDED
				
				smoothBreathingCoef = smoothBreathingCoef * 0.5; //May 19 ADDED
				
			} //May 19 ADDED

		
		}
		
		
		
		
		public function setRelativeInhaleLevelStrainGauge():void  {				
			
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
				
				if (DC.appMode != 3) { // JULY 13:Change1n  (all the rest of the code below in this function was updated, about 20 lines) 
				
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
			
		
		
				
		public function displayBreathingGraph():void  {				
			
			var i:int;
						
			graphY = (-fullBreathGraphHeight*relativeInhaleLevelSG) + yStartPos;			
			graphYSeries[count] = smoothBreathingCoef*graphY + (1.0 - smoothBreathingCoef)*graphYSeries[count-1]; //dampen the sensor signal					
		
			breathGraph.graphics.lineStyle(4,0x3300FF);
			breathGraph.graphics.moveTo(xCoord-3,Math.round(graphYSeries[count-1]));
			breathGraph.graphics.lineTo(xCoord,Math.round(graphYSeries[count]));
			
			//breathGraph.graphics.lineStyle(2,0xD31810);
			//breathGraph.graphics.moveTo(xCoord-3,19500-Math.round(20000*(breathSensor[count-1])));
			//breathGraph.graphics.lineTo(xCoord,19500-Math.round(20000*(breathSensor[count])));					
			
			xCoord = xCoord + 3;					
			scrollX = scrollX - 3;				
			breathGraph.x = scrollX;	
		
			
			 if (scrollX < -7200) {	
				
				removeChild(breathGraph);
				breathGraph = new MovieClip();
				addChildAt(breathGraph, 0);
				scrollX = 0;
				breathGraph.x = scrollX;
				xCoord = 840;
			} 
	
			
			//testUI.indicator4.txt1.text = String(count) + "  " + String(scrollX);
			
			//Guided path			
			
			if (DC.appMode == 2) {
							
				guidedPath = [];
				
				var nextPoint:Number = 0;			
				
				birdDeltaY = (graphYSeries[count] - DC.objGame.balloon.y)/birdIncrements;	
				//birdDeltaY = (graphYSeries[count] - graphYSeries[count-1])/2.0;
								
				for (i = 1; i <= (birdIncrements * 2); i++) {
					
					nextPoint = DC.objGame.balloon.y + birdDeltaY*i;				
					//nextPoint = graphYSeries[count-1] + birdDeltaY*i;
					
					if (nextPoint < (yStartPos-fullBreathGraphHeight)) {
						nextPoint = yStartPos-fullBreathGraphHeight;
					}
					else if (nextPoint > yStartPos) {
						nextPoint = yStartPos;
					}
					
					guidedPath.push(Math.round(nextPoint));		
					
									
				}
			
			}		
			
		}
		
		
		public function displayPostureIndicator():void  {
		
			if (uprightSet == 1) {						
				
				if (DC.objBuzzerTraining.isBuzzing == 1) { //Don't evaluate posture if buzzer is buzzing! The buzzer TOTALLY messes up the accelerometer signal
					postureAttenuator = 0;
				}
				else {
					postureAttenuator = 0.10;
				}
				
					
				if (useRotationSensor == 1) {	
					
					postureAttenuatorLevel++;
					
					if (postureAttenuatorLevel > 5) {
						postureAttenuatorLevel = 5;
					}			
					
				}
				
				else {
					
					postureAttenuatorLevel--;
					if (postureAttenuatorLevel < 0) {
						postureAttenuatorLevel = 0;
					}
					
				}
				
				
				switch (postureAttenuatorLevel) {

					case 1:
					postureAttenuator = postureAttenuator *0.70;					
					break;

					case 2:
					postureAttenuator = postureAttenuator *0.70 * 0.80;					
					break;

					case 3:
					postureAttenuator = postureAttenuator *0.70 * 0.80 * 0.80;					
					break;
					
					case 4:
					postureAttenuator = postureAttenuator *0.70 * 0.80 * 0.80 * 0.80;					
					break;
					
					case 5:
					postureAttenuator = postureAttenuator *0.70 * 0.80 * 0.80 * 0.80 * 0.80;					
					break;
				} 
					
				relativePosturePositionFiltered[count] = Number(postureAttenuator*currentPostureAngle[count] + (1-postureAttenuator)*relativePosturePositionFiltered[count-1]);
															
				xPos = int(598*(1 - (Math.abs(relativePosturePositionFiltered[count] - uprightPostureAngle)/postureRange)));
				//note, the absolute value here is needed because we don't know for sure antomy of user! For example,if you wear on belly, then angle goes other way when leaning forward, and without absolute value, it does not work.

					
															
				if (xPos > 598) {
					xPos = 598;
				}
					
				if (xPos < 2) {
					xPos = 2;
				}					
					
				postureUI.sliderGraph.postureMarker.x = xPos;			
					
				whichPostureFrame = Math.round(30*((598 - xPos)/598));
			
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
				
				if (DC.objGame.trainingPosture == 1 || DC.objGame.trainingPosture == 2) {
					DC.objGame.gamePanel.postureState.gotoAndStop(whichPostureFrame);	
					DC.objBuzzerTraining.buzzerTrainingUI.postureState.gotoAndStop(whichPostureFrame);
					DC.objPassiveTracking.passiveTrackingUI.postureState.gotoAndStop(whichPostureFrame);
				}
				else if (DC.objGame.trainingPosture == 3) {
					DC.objGame.gamePanel.postureState.gotoAndStop(whichPostureFrame + 30);
					DC.objBuzzerTraining.buzzerTrainingUI.postureState.gotoAndStop(whichPostureFrame + 30);
					DC.objPassiveTracking.passiveTrackingUI.postureState.gotoAndStop(whichPostureFrame + 30);
				}
					
			}
				
			else {
					
				if (xSensor[count] == 0 && ySensor[count] == 0) {
					relativePosturePositionFiltered[count] = 2*(Math.asin(zSensor[count])/Math.PI);				
				}
				else {
					relativePosturePositionFiltered[count] = 2*(Math.atan(zSensor[count]/Math.sqrt(Math.pow(xSensor[count],2)+Math.pow(ySensor[count],2)))/Math.PI);				
				}				
				
					
			}					
			
		}
		
		
		public function processBreathingandPosture(sensorData:Array):void  {	
			
			timeElapsed = timeElapsed + (1/20.0);	// May 19th, ADDED THIS LINE, note it is 1/20, not 1/60 as previously in enterFrameHandler
			
			enterFrameCount++; //AUG 1st NEW
			
			if (enterFrameCount >= 20) {  //AUG 1st NEW
				enterFrameCount = 0; //AUG 1st NEW
				if (timeElapsed >= 60) { //AUG 1st NEW
					postureUI.oneMinuteRespirationRateIndicator.text = String(calculateOneMinuteRespRate()); //AUG 1st NEW
				} //AUG 1st NEW
				
			} //AUG 1st NEW
			
			
									
			if (DC.objBuzzerTraining.isBuzzerTrainingActive == 1) {  // May 19th, ADDED THIS LINE
				DC.objBuzzerTraining.buzzerTrainingMainLoop()  // May 19th, ADDED THIS LINE
			}  // May 19th, ADDED THIS LINE
			
			if (DC.objPassiveTracking.isPassiveTrackingActive == 1) {  // May 19th, ADDED THIS LINE
				DC.objPassiveTracking.passiveTrackingMainLoop()  // May 19th, ADDED THIS LINE
			}  // May 19th, ADDED THIS LINE
					
			storeSensorData(sensorData);
			
			if (count < 8) { //JULY 13:Change1m   Changed 5 to 8 here. This could have been causing crashes. For example, in setRelativeInhaleLevelStrainGauge(), I was accessing arrays based on count-6, which is a negative index value when count = 5  (and now I have count-8 there)
				return;
			}				
									
			setSmoothingAndDamping();					
			setRelativeInhaleLevelStrainGauge();				
			displayPostureIndicator();
			displayBreathingGraph();	
			reversalDetector();					
			displayDebugStats();
			
			if (breathEnding == 1) {				
				
				if (graphYSeries[count] > endBreathY) { 
					
					if (EIGoodToMeasure == 1 && exhaleCorrectionFactor < 1.3 && stuckBreaths == 0 && (inhaleEndTime - inhaleStartTime > 0)) {  // AUG 1st CHANGED, if stuckBreaths > 0, then EIRatio can sometimes be negative
						
						exhaleEndTime = timeElapsed; //May 31st ADDED						
						//EIRatio[EIRatioCount] = [(exhaleCorrectionFactor*(exhaleEndTime - inhaleEndTime))/((1-(0.05/smoothBreathingCoefBaseLevel))*(inhaleEndTime - inhaleStartTime)),timeElapsed]; // JULY 13th:CHANGE1c  REMOVED
						EIRatio[EIRatioCount] = [(exhaleCorrectionFactor*(exhaleEndTime - inhaleEndTime))/(inhaleEndTime - inhaleStartTime),timeElapsed]; // JULY 13th:NEW1c
						
						EIRatio[EIRatioCount][0] = roundNumber(EIRatio[EIRatioCount][0],10); // May 31st ADDED
						EIAvgSessionSummation = EIAvgSessionSummation + EIRatio[EIRatioCount][0]; // AUG 1st NEW
						EIAvgSessionRatio = roundNumber(EIAvgSessionSummation/EIRatio.length,10); // AUG 1st CHANGED						
						EIRatioCount++;  // May 31st ADDED	
						EIGoodToMeasure = 0; //May31st ADDED
						
					}  // May 31st ADDED
				
					endBreathLine.y = 5000;	
					//stuckBreaths = 0;  JULY 13th REMOVED	
					breathEnding = 0;						
					//breathCount++;  //Aug 1st REMOVED						
					//calculateRealTimeRR();	//Aug 1st REMOVED
					
					
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
						
						currentStrainGaugeHighestPrev = currentStrainGaugeHighest; // //AUG 1st NEW	 only set this when the breath is not stuck! Otherwise it could be set much higher (to the value which exceeded the ceiling)
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
		
		
			
		public function calculateOneMinuteEI():void { //JULY 13th:CHANGE1b
			
			EI1Minute = 0;  //JULY 13th:CHANGE1b
			var breathsInLastMinute:int = 0; // May 31st ADDED
			
			for (var i:int = EIRatio.length-1; i > 0; i--)  { // May 31st ADDED
				
				if (EIRatio[i][1] >= (timeElapsed - 60)) { // May 31st ADDED
					EI1Minute = EI1Minute + EIRatio[i][0]; // May 31st ADDED
					breathsInLastMinute++; // May 31st ADDED
				} // May 31st ADDED
				else { // May 31st ADDED
					break; // May 31st ADDED
				} // May 31st ADDED
			} // May 31st ADDED
			
			if (breathsInLastMinute > 0) { // May 31st ADDED
				EI1Minute = roundNumber(EI1Minute / breathsInLastMinute,10); // May 31st ADDED
			} // May 31st ADDED
			else { // May 31st ADDED
				EI1Minute = 1; // May 31st ADDED
			} // May 31st ADDED
			
			//return(EI1Minute); //JULY 13th:CHANGE1b  REMOVE THIS LINE
			
		} // May 31st ADDED	
	
		
		//Aug 1st New Function
		public function calculateRealTimeAndSessionAverageRR():void {			
			
			whenBreathsStart.push(timeElapsed);					
			
			if (whenBreathsStart.length == 1) {
				if ((whenBreathsStart[0] - 0) > 0) {
					respRate = 1 * (60.0 / (whenBreathsStart[lastIndex] - 0)); 
					respRate = roundNumber(respRate, 10);
				}	
			}
			
			else if (whenBreathsStart.length >= 2) {
				var lastIndex:int = whenBreathsStart.length-1;
				breathCount++; //only start to increment this when there are at least 2 breath starts (as complete breath is defined by 2 breath starts), Big bug previously, not counting stuck breaths towards breathCount, so every time there is a VALID inhale, increase this count even if stuck
				
				if ((whenBreathsStart[lastIndex] - whenBreathsStart[lastIndex-1]) > 0) {
					respRate = 1 * (60.0 / (whenBreathsStart[lastIndex] - whenBreathsStart[lastIndex-1])); 
				}				
								
				if (timeElapsed > 0) {
					avgRespRate = 60*(breathCount/timeElapsed);
					
				}
				
				if (DC.appMode == 2 && DC.objGame.calibrationBreathsDone == 0) {  //Aug 1st  NEW
					if (timeElapsed-timeElapsedAtCalibrationStart > 0) { //Aug 1st  NEW
						calibrationRR = 60*((breathCount-breathCountAtCalibrationStart)/(timeElapsed-timeElapsedAtCalibrationStart)); //Aug 1st  NEW
						calibrationRR = roundNumber(calibrationRR, 10); //Aug 1st  NEW
					} //Aug 1st  NEW
				} //Aug 1st  NEW
				
				respRate = roundNumber(respRate, 10);
				avgRespRate = roundNumber(avgRespRate, 10);
				
				postureUI.respirationRateIndicator.text = String(respRate);					
			
			}	
			
			if (DC.appMode == 2) { //Aug 12th  NEW
				actualBreathsWithinAPattern.push([roundNumber(timeElapsed-DC.objGame.graphStartTime,10), respRate]); //Aug 12th  NEW
			} //Aug 12th  NEW
			else if (DC.appMode == 3) { //AUG 1st NEW for BT
				actualBreathsWithinAPattern.push([roundNumber(timeElapsed-DC.objBuzzerTraining.graphStartTime,10), respRate]); //Aug 12th  NEW
			} //Aug 12th  NEW
				
		}	
		
		
		//AUG 1st This entire function is removed
		//public function calculateRespRate():void {					
			
			//whenBreathsEnd[breathCount] = timeElapsed;		
						
			//if (breathCount > 0) {
				
				//respRate = 1 * (60.0 / (whenBreathsEnd[breathCount] - whenBreathsEnd[breathCount-1]));	//AUG 1st CHANGED					
			//}
			
			//else if (breathCount >= 5) {	//AUG 1st REMOVED			
				//respRate = 4 * (60.0 / (whenBreathsEnd[breathCount] - whenBreathsEnd[breathCount-4]));  //AUG 1st REMOVED
				//avgRespRate = 60*(breathCount/timeElapsed);  //AUG 1st REMOVED
			//}	  //AUG 1st REMOVED
			
			//if (timeElapsed > 0) {  //AUG 1st NEW
				//avgRespRate = 60*(breathCount/timeElapsed); //AUG 1st NEW				
			//} //AUG 1st NEW
			
			//if (DC.appMode == 2 && DC.objGame.calibrationBreathsDone == 0) {  //Aug 1st  NEW
			//	if (timeElapsed-timeElapsedAtCalibrationStart > 0) { //Aug 1st  NEW
					//calibrationRR = 60*((breathCount-breathCountAtCalibrationStart)/(timeElapsed-timeElapsedAtCalibrationStart)); //Aug 1st  NEW
					//calibrationRR = roundNumber(calibrationRR, 10); //Aug 1st  NEW
				//} //Aug 1st  NEW
			//} //Aug 1st  NEW
			
			//respRate = roundNumber(respRate, 10);
			//avgRespRate = roundNumber(avgRespRate, 10);
			
			//postureUI.respirationRateIndicator.text = String(respRate);
			//postureUI.howManyBreaths.text = String(breathCount); //AUG 1st REMOVED	
			
		//}
		
		
		public function calculateOneMinuteRespRate():Number {	//JULY 13th:NEW1d  New FUNCTION	
			
			var breathsInLastMinute:int = 0;   
			
			for (var i:int = whenBreathsStart.length-1; i >= 0; i--)  { //AUG 1st CHANGED
				
				if (whenBreathsStart[i] >= (timeElapsed - 60)) { 	//AUG 1st CHANGED				
					breathsInLastMinute++; 
				} 
				else { 
					break; 
				} 
			} 
			return(breathsInLastMinute-1);  //AUG 1st CHANGED, it's -1 because it takes 2 breath starts to enclose the first breath
			
		}
		
		
		public function setNewStrainGaugeRange():void {	//JULY 13th:NEW1e  (This entire function updated on many lines, please see)	
					
			if (noisyMovements == 1 || stuckBreaths > 0) {	//AUG 1st CHANGED		
				
				//currentStrainGaugeHighest = (currentStrainGaugeHighestPrev - currentStrainGaugeLowest) + strainGauge; // //AUG 1st REMOVED Since currentStrainGaugeLowest is being set to strainGauge below, this preserves the range but relative to the new floor.
				
				currentStrainGaugeLowest = strainGauge; //AUG 1st NEW
				currentStrainGaugeHighest = currentStrainGaugeLowest + strainGaugeRangePrev; //AUG 1st NEW
				
				//if ( (currentStrainGaugeHighest - currentStrainGaugeLowest) < strainGaugeMinRange) { //AUG 1st REMOVED
					//currentStrainGaugeHighest = currentStrainGaugeLowest + strainGaugeMinRange; //AUG 1st REMOVED
				//}	//AUG 1st REMOVED
				
				return;
			}
			
			newStrainGaugeRange = currentStrainGaugeHighestNew - currentStrainGaugeLowestNew;		
					
			if (newStrainGaugeRange < (0.65*(currentStrainGaugeHighest - currentStrainGaugeLowest))) {						
					
				lightBreathsInARow++;	
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
						
					
			if ( (currentStrainGaugeHighest-currentStrainGaugeLowest) > 1.25*(currentStrainGaugeHighestPrev-currentStrainGaugeLowest)) {	//AUG 1st change
				
				breathTopExceeded++;
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
	
		
		
		public function reversalDetector():void {			
			
			if (count <= reversalThreshold + 1) {
				return;
			}			
			
			var up:int = 0;
			var down:int = 0;			
			var i:int = 0;			
			
			if (bottomReversalFound == 1) {  //AUG 1st NEW
				
				if ( (breathEnding == 1 && (bottomReversalY - graphYSeries[count] > (minBreathRangeForStuck))) || (breathEnding == 0 && (yStartPos - graphYSeries[count] > minBreathRange)) ) { //This means the breath is not a false positive breath (not due to noise)  //AUG 1st NEW
					
					if (inhaleIsValid == 0) { //AUG 1st NEW
						
						inhaleIsValid = 1; //AUG 1st NEW
						
						calculateRealTimeAndSessionAverageRR(); //AUG 1st NEW					
						
						postureUI.howManyBreaths.text = String(breathCount); //AUG 1st NEW REMOVE THIS, for testing only
						
						bottomReversalLine.y = bottomReversalY; //AUG 1st NEW
						
						endBreathLine.y = 5000; //AUG 1st NEW, Hide this end breath line (for case when stuck breaths and a new valid inhale is happening)
						
						if (breathEnding == 1) {  // //AUG 1st NEW This means a bottom reversal occured BEFORE the previous breath ended! (ie before the previous breath crossed the endBreathLine) 
						
							stuckBreaths++; //AUG 1st NEW
							
						} //AUG 1st NEW					
										
						
					} //AUG 1st NEW
				} //AUG 1st NEW				
			} //AUG 1st NEW	
			
									
			if (upStreak == 0) {
			
				for (i = 0; i <= reversalThreshold; i++)  {
				
					if (graphYSeries[count-i] < graphYSeries[count-i-1]) {
						up++; //BECAUSE graph is negative going up!!!!!!!!!!!!!!!
						if (up == reversalThreshold+1) {
							upStreak = 1;								
							upStreakStart = count-(reversalThreshold+1);
						}
					}
				}
			}
			
			
			if (downStreak == 0) {
			
				for (i = 0; i <= reversalThreshold; i++)  {
				
					if (graphYSeries[count-i] > graphYSeries[count-i-1]) {
						down++; //BECAUSE graph is positive going down!!!!!!!!!!!!!!!
						if (down == reversalThreshold+1) {
							downStreak = 1;	
							downStreakStart = count-(reversalThreshold+1);
						}
						
					}
				}
			}
			

			if (up == reversalThreshold+1) { 			
				
				if (downStreak == 1) { //downStreak must have been previously set, thus a bottom reversal has just been found
					
					downStreak = 0;
					bottomReversalFound = 1;	
					inhaleIsValid = 0; //AUG 1st NEW
					inhaleStartTime = timeElapsed - (reversalThreshold+1)*(1/20); //May 31st ADDED									
					
					bottomReversalY = graphYSeries[downStreakStart];					
					
					currentStrainGaugeLowestNew = breathSensor[count-(reversalThreshold+2)];					
							
					for (i = downStreakStart; i <= upStreakStart; i++) { //This is needed because upStreakStart could conceivably be higher than downStreakStart
						
						if (graphYSeries[i] > bottomReversalY){ //Find the lowest point on the graph within the bounds
							bottomReversalY = graphYSeries[i];								
						}
						
					}																
					
					//bottomReversalLine.y = bottomReversalY; // AUG 1st REMOVED
					
					topReversalLine.y = 5000;								
					
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
					
					for (i = upStreakStart; i <= downStreakStart; i++) {
						
						if (graphYSeries[i] < topReversalY){
							topReversalY = graphYSeries[i];								
						}						
					}			
					
					//if (DC.appMode != 3 && DC.appMode != 1 ) { // AUG 1st REMOVED
					//if ( ((bottomReversalY - topReversalY < minBreathRange) && stuckBreaths > 0) || (yStartPos - topReversalY < minBreathRange) ) { //AUG 1st REMOVED, minBreathRange/3 changed to just minBreathRange (now just setting minBreathRange in BT and VT and PT)
					if (inhaleIsValid == 0) {  //AUG 1st ADDED		
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
					
					//topReversalLine.y = topReversalY;	//AUG 1st REMOVED (no longer showing the top reversal line, since the peak of the graph already indicates that)
					
					
										
					if (bottomReversalFound == 1 || breathCount < 2) {	
											
						if (bottomReversalFound == 1 && breathCount >= 2 ) { //May 31st ADDED
							inhaleEndTime = timeElapsed - (reversalThreshold+1)*(1/20); //May 31st ADDED
							EIGoodToMeasure = 1; //May 31st ADDED
						} //May 31st ADDED
						
						bottomReversalFound = 0;						
						breathEnding = 1;	
						exhaleCorrectionFactor = 1; //May 31st ADDED
						
						//DC.objStartConnection.socket.writeUTFBytes("Buzz,0.2" + "\n");			
						//DC.objStartConnection.socket.flush();
						
						if (breathCount < 2 && DC.appMode != 2) { //***March16Change	May 30th Change
							endBreathY = bottomReversalY - 0.95*(bottomReversalY - topReversalY); //***March16Change, This addresses scnenario if user plugs in belt AFTER starting LiveGraph which can cause strainGauge value to suddenly greatly jump, and create situation where breath graph is stuck far above the yellow line	
							exhaleCorrectionFactor = 1/(1-0.95); //May 31st ADDED
						} //***March16Change	
						
						else if (DC.appMode == 2) { //***March16Change  (else added)
							
							if (DC.objGame.calibrationBreathsDone == 1) {
								endBreathY = yStartPos + int(0.20*(-fullBreathGraphHeight));
								exhaleCorrectionFactor = 1/(1-0.20); //May 31st ADDED
							}
							else if (DC.objGame.calibrationBreathsDone == 0) {
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
						
						else if (DC.appMode == 1 || DC.appMode == 3) {
							
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
					
						
						endBreathLine.y = endBreathY;		
						bottomReversalLine.y = 5000; //AUG 1st NEW  Hide this line when endBreath line appears, idea is green line appears when valid breath starts, and yellow line appears then when exhale starts (and green line disappears)
													
					}	
						
				}					
					
				
			}
				
		}		
		
		
		
		function unclickButton(evt:MouseEvent)  {	
		
			evt.currentTarget.gotoAndStop(1);
		}
		
		function clickButton(evt:MouseEvent)  {	
		
			evt.currentTarget.gotoAndStop(2);
		}
		
		
		
		function showDebugUIHandler(evt:MouseEvent)  {			
			
			if (testUI.visible == false) {
				testUI.visible = true;
			}
			else {
				testUI.visible = false;
			}
		}
		
		
		function postureSelectorHandler(evt:MouseEvent)  {			
			
			if (postureUI.postureSelector.level1.selected == true) {  //AUG 1st CHANGE (just changed the property name to level1, but this may not affect you Luccas)
				
				//postureRange = 0.25;
				postureRange = 0.15;
				postureLevel = 1;  // AUG 1st NEW
			}
			else if (postureUI.postureSelector.level2.selected == true) {  //AUG 1st CHANGE (just changed the property name to level2, but this may not affect you Luccas)
				//postureRange = 0.15;
				postureRange = 0.10;
				postureLevel = 2;  // AUG 1st NEW
			}
			else if (postureUI.postureSelector.level3.selected == true) {  //AUG 1st CHANGE (just changed the property name to level3, but this may not affect you Luccas)
				//postureRange = 0.08;
				postureRange = 0.05;
				postureLevel = 3;  // AUG 1st NEW
			}					
					
		}
		
		function breathSelectorHandler(evt:MouseEvent)  {			
			
			if (postureUI.breathSelector.level1.selected == true) {  //AUG 1st CHANGED name
				smoothBreathingCoefBaseLevel = 0.15;
				reversalThreshold = 6; 
				birdIncrements = 24;	
				breathLevel = 1;  // AUG 1st NEW
				minBreathRange = (fullBreathGraphHeight/16); //AUG 1st NEW, make even less prone to noise for level 1
				minBreathRangeForStuck = (fullBreathGraphHeight/16); //AUG 1st NEW
				
			}
			else if (postureUI.breathSelector.level2.selected == true) {  //AUG 1st CHANGED name
				smoothBreathingCoefBaseLevel = 0.4;
				reversalThreshold = 5;
				birdIncrements = 20;
				breathLevel = 2;  // AUG 1st NEW
				minBreathRange = (fullBreathGraphHeight/16)/2; //AUG 1st NEW, make even less prone to noise for level 1
				minBreathRangeForStuck = (fullBreathGraphHeight/16); //AUG 1st NEW
			}
			else if (postureUI.breathSelector.level3.selected == true) { //AUG 1st CHANGED name
				smoothBreathingCoefBaseLevel = 0.6;
				reversalThreshold = 3;
				birdIncrements = 12;
				breathLevel = 3;  // AUG 1st NEW
				minBreathRange = (fullBreathGraphHeight/16)/2; //AUG 1st NEW, make even less prone to noise for level 1
				minBreathRangeForStuck = (fullBreathGraphHeight/16); //AUG 1st NEW
			}					
					
		}
		
		
			
		function learnUprightAngleHandler(evt:MouseEvent)  {	
			
			uprightSet = 1;	
			
			evt.currentTarget.gotoAndStop(2);			
			
			if (xSensor[count] == 0 && ySensor[count] == 0) {
				uprightPostureAngle = 2*(Math.asin(zSensor[count])/Math.PI);				
			}
			else {
				uprightPostureAngle = 2*(Math.atan(zSensor[count]/Math.sqrt(Math.pow(xSensor[count],2)+Math.pow(ySensor[count],2)))/Math.PI);				
			}
		
		}
		
		
		function setUprightButtonPush(a:Array)  {	
			
			uprightSet = 1;	
			
			a[1] = Number(a[1]);
			a[2] = Number(a[2]);
			a[3] = Number(a[3]);
			
			if (a[1] == 0 && a[2] == 0) {
				uprightPostureAngle = 2*(Math.asin(a[3])/Math.PI);				
			}
			else {
				uprightPostureAngle = 2*(Math.atan(a[3]/Math.sqrt(Math.pow(a[1],2)+Math.pow(a[2],2)))/Math.PI);				
			}
			
			if (DC.objGame.hasUprightBeenSet == 0 && DC.appMode == 2) {
				
				DC.objGame.uprightHasBeenSet();
				DC.objGame.hasUprightBeenSet = 1;
			}
			
			if (DC.objBuzzerTraining.hasUprightBeenSet == 0 && DC.appMode == 3) {
				
				DC.objBuzzerTraining.uprightHasBeenSetHandler();
				
			}
			
			
		
		}
	
		
		/*
		
		function a8Handler(evt:MouseEvent)  {	
			
			DC.objStartConnection.socket.writeUTFBytes("Buzz,1" + "\n");			
			DC.objStartConnection.socket.flush();			
			
		}
		
		function a9Handler(evt:MouseEvent)  {	
			
			DC.objStartConnection.socket.writeUTFBytes("FirmwareUpdate" + "\n");			
			DC.objStartConnection.socket.flush();			
			
		}
		
		function a10Handler(evt:MouseEvent)  {	
			
			DC.objStartConnection.socket.writeUTFBytes("Sleep" + "\n");			
			DC.objStartConnection.socket.flush();			
			
		}  */	
		
		
		function backButtonHandler(evt:MouseEvent)  {			
			
			evt.currentTarget.gotoAndStop(1);			
			DC.objModeScreen.stopData();
			DC.removeChild(DC.objLiveGraph);
			DC.addChild(DC.objModeScreen);	
			DC.appMode = 0;	
			//RRtimer.stop();
			//removeEventListener(Event.ENTER_FRAME, enterFrameHandler);  May 19th, REMOVED THIS LINE
			saveData(); //***march18
		
		}	
		
		
		function roundNumber(numb:Number, decimal:Number):Number {
		
			return Math.round(numb*decimal)/decimal;
		}
		
		
		
		
		function saveData():void {	//***march18	 	
		
			//return; //AUG 1st ADDED (not using this)
			var myXML:XML = new XML( <objects /> );	//***march18
			var XMLName:String = "TestData";	//***march18
			var XMLEntry:XML = new XML( <{XMLName} /> );	//***march18
			XMLEntry.@xSensor = storedXSensor;	//***march18	
			XMLEntry.@ySensor = storedYSensor;	//***march18
			XMLEntry.@zSensor = storedZSensor;	//***march18
			XMLEntry.@BreathSensor = storedBSensor;	//***march18
			XMLEntry.@RotationSensor = storedRSensor;	//***march18
			XMLEntry.@Count = count;	//***march19
			myXML.appendChild(XMLEntry); 	//***march18
			var f:FileReference = new FileReference;	//***march18
			f.save(myXML, "myXML1.xml"); 		//***march18		
			
		}	//***march18
		
		
		function resetBreathRange():void {	 //JULY 13:New1k  
			
			currentStrainGaugeHighest = currentStrainGaugeLowest + 0.003; //JULY 13:New1k  
			currentStrainGaugeHighestPrev = currentStrainGaugeHighest;  //JULY 13:New1k   
			currentStrainGaugeLowestNew = currentStrainGaugeLowest; //JULY 13:New1k   
			currentStrainGaugeHighestNew = currentStrainGaugeHighest;	//JULY 13:New1k    
			
		} //JULY 13:New1k  
		
		
		function startMode():void {			
			
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
			
			breathsForGraph = []; //AUG 12th NEW
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
			currentStrainGaugeHighestNew = currentStrainGaugeHighest;	///AUG 1st ADDED
			strainGaugeRangePrev = 0.003; //AUG 1st NEW
			
			relativeInhaleLevelSG = 0; //AUG 1st NEW	
			currentStrainGaugeHighest = (currentStrainGaugeHighest - currentStrainGaugeLowest) + strainGauge; //AUG 1st NEW						
			currentStrainGaugeLowest = strainGauge;		//AUG 1st NEW			
			if ( (currentStrainGaugeHighest - currentStrainGaugeLowest) < strainGaugeMinRange) { //AUG 1st NEW	
				currentStrainGaugeHighest = currentStrainGaugeLowest + strainGaugeMinRange; //AUG 1st NEW	
			} //AUG 1st NEW	
			
			postureUI.respirationRateIndicator.text = "";
			postureUI.oneMinuteRespirationRateIndicator.text = ""; //JULY 13th:NEW1d
			postureUI.howManyBreaths.text = "";
			
			DC.objModeScreen.startData();
			//RRtimer.start();	
			//addEventListener(Event.ENTER_FRAME, enterFrameHandler);  May 19th, REMOVED THIS LINE
			stuckBreathsThreshold = 3; //AUG 1st CHANGED
			breathTopExceededThreshold = 1;		
			lightBreathsThreshold = 1; //JULY 13th:NEW1i
			lightBreathsInARow = 0; //JULY 13th:NEW1i
			breathTopExceeded = 0; //JULY 13th:NEW1i
			stuckBreaths = 0; //JULY 13th:NEW1i
			//minBreathRange = (fullBreathGraphHeight/16)/2; //AUG 1st REMOVED (setting it below),  This is important because resolutions on devices are different. Previously it was set to 25, which is an absolute value. Now it is set relative to the fullBreathGraphHeight (whatever that is set to for the particular device, it was 400 on desktop)
					
			
			if (postureLevel == 1) {  //AUG 1st NEW 
				postureUI.postureSelector.level1.selected = true; //AUG 1st NEW 
			} //AUG 1st NEW 
			else if (postureLevel == 2) { //AUG 1st NEW 
				postureUI.postureSelector.level2.selected = true; //AUG 1st NEW 
			} //AUG 1st NEW 
			else if (postureLevel == 3) { //AUG 1st NEW 
				postureUI.postureSelector.level3.selected = true; //AUG 1st NEW 
			} //AUG 1st NEW 
			
			
			if (breathLevel == 1) {  //AUG 1st NEW 
				postureUI.breathSelector.level1.selected = true; //AUG 1st NEW 
				smoothBreathingCoefBaseLevel = 0.15;  //AUG 1st NEW 
				reversalThreshold = 6;   //AUG 1st NEW 
				birdIncrements = 24;	 //AUG 1st NEW 
				minBreathRange = (fullBreathGraphHeight/16); //AUG 1st NEW, make even less prone to noise for level 1
				minBreathRangeForStuck = (fullBreathGraphHeight/16); //AUG 1st NEW
			} //AUG 1st NEW 
			else if (breathLevel == 2) { //AUG 1st NEW 
				postureUI.breathSelector.level2.selected = true; //AUG 1st NEW 
				smoothBreathingCoefBaseLevel = 0.4; //AUG 1st NEW 
				reversalThreshold = 5; //AUG 1st NEW 
				birdIncrements = 20; //AUG 1st NEW 
				minBreathRange = (fullBreathGraphHeight/16)/2; //AUG 1st NEW
				minBreathRangeForStuck = (fullBreathGraphHeight/16); //AUG 1st NEW
			} //AUG 1st NEW 
			else if (breathLevel == 3) { //AUG 1st NEW 
				postureUI.breathSelector.level3.selected = true; //AUG 1st NEW 
				smoothBreathingCoefBaseLevel = 0.6; //AUG 1st NEW 
				reversalThreshold = 3; //AUG 1st NEW 
				birdIncrements = 12; //AUG 1st NEW 
				minBreathRange = (fullBreathGraphHeight/16)/2; //AUG 1st NEW
				minBreathRangeForStuck = (fullBreathGraphHeight/16); //AUG 1st NEW
			}	 //AUG 1st NEW 
					
		}			

	}
	
}
