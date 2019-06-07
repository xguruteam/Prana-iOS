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
		var whenBreathsEnd:Array = new Array;		
		var respRate:Number = 0;
		var breathCount:int = 0;
		var stuckBreathsThreshold:int = 1;
		var breathTopExceededThreshold:int = 1;
		var smoothBreathingCoefBaseLevel:Number = 0.40;
		var postureIsGood:int = 1;
		var minBreathRange:Number;  //***March16Change
		var reversalThreshold:int = 6;
		var birdIncrements:int = 20;
		var avgRespRate:Number = 0;	
		
		var EIRatio:Array = new Array; // May31st ADDED
		var exhaleCorrectionFactor:Number = 0; // May31st ADDED
		var inhaleStartTime:Number = 0; // May31st ADDED
		var inhaleEndTime:Number = 0; // May31st ADDED
		var exhaleEndTime:Number = 0; // May31st ADDED
		var EIAvgSessionRatio:Number = 0; // May31st ADDED
		var EIRatioCount:int = 0; // May31st ADDED
		var EIGoodToMeasure:int = 0; // May31st ADDED
		
		public function LiveGraph(main:Main) {
			
			DC = main; //to have access to the document class				
			
			breathGraph.graphics.lineStyle(4,0x3300FF);	
			breathGraph.graphics.moveTo(xCoord,500);			
			
			showDebugUI.x = 70;
			showDebugUI.y = 1000;				
			
			postureUI.postureSelector.postureLevel2.selected = true;		
			postureUI.breathSelector.breathLevel2.selected = true;	
			
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
			
			postureUI.postureSelector.postureLevel1.addEventListener(MouseEvent.CLICK,postureSelectorHandler);
			postureUI.postureSelector.postureLevel2.addEventListener(MouseEvent.CLICK,postureSelectorHandler);
			postureUI.postureSelector.postureLevel3.addEventListener(MouseEvent.CLICK,postureSelectorHandler);	
			
			postureUI.breathSelector.breathLevel1.addEventListener(MouseEvent.CLICK,breathSelectorHandler);
			postureUI.breathSelector.breathLevel2.addEventListener(MouseEvent.CLICK,breathSelectorHandler);
			postureUI.breathSelector.breathLevel3.addEventListener(MouseEvent.CLICK,breathSelectorHandler);	
			
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
			whenBreathsEnd[0] = 0;
			
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
			whenBreathsEnd = [];
			whenBreathsEnd[0] = 0;
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
			testUI.indicator2.txt1.text = "Z axis = " + String(roundNumber(zSensor[count],1000)) + "  Y axis = " + String(roundNumber(ySensor[count],1000)) + "       X axis = " + String(roundNumber(xSensor[count],1000)) + "     " + String(roundNumber(currentPostureAngle[count],1000));
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
						
			if (count < 5) {
				
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
		
				
			if (count == 5) {				
				
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
				
				currentStrainGaugeHighest = 0.5*strainGauge + (1-0.5)*currentStrainGaugeHighest;	
				
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
				
			else if (relativeInhaleLevelSG < 0.05 && !((breathSensor[count] > breathSensor[count-1]) && (breathSensor[count-1] > breathSensor[count-2]) && (breathSensor[count-2] > breathSensor[count-3]) && (breathSensor[count-3] > breathSensor[count-4]) && (breathSensor[count-4] > breathSensor[count-5]) && (breathSensor[count-5] > breathSensor[count-6]) ) ) { //***March16Change

			//else if (relativeInhaleLevelSG < 0.05 && !((breathSensor[count] > breathSensor[count-1]) && (breathSensor[count-1] > breathSensor[count-2]) && (breathSensor[count-2] > breathSensor[count-3]) && (breathSensor[count-3] > breathSensor[count-4]) && (breathSensor[count-4] > breathSensor[count-5]) ) ) {
	
				//If breath signal is below a low threshold (5%), AND user is NOT inhaling consistently, then treat as noise, and make relativeInhaleLevel = 0	
				
				relativeInhaleLevelSG = 0;		
				//upStreak = 0;  //Idea is reversalThreshold could be smaller than the up streak test above, and it could be triggered even though this resets, which could create a conflict
				currentStrainGaugeHighest = (currentStrainGaugeHighest - currentStrainGaugeLowest) + strainGauge; //Since currentStrainGaugeLowest is being set to strainGauge below, this preserves the range but relative to the new floor.

				
				currentStrainGaugeLowest = strainGauge;				
				if ( (currentStrainGaugeHighest - currentStrainGaugeLowest) < strainGaugeMinRange) {
						currentStrainGaugeHighest = currentStrainGaugeLowest + strainGaugeMinRange;
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
	
			
			testUI.indicator4.txt1.text = String(count) + "  " + String(scrollX);
			
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
			
			if (DC.objBuzzerTraining.isBuzzerTrainingActive == 1) {  // May 19th, ADDED THIS LINE
				DC.objBuzzerTraining.buzzerTrainingMainLoop()  // May 19th, ADDED THIS LINE
			}  // May 19th, ADDED THIS LINE
			
			if (DC.objPassiveTracking.isPassiveTrackingActive == 1) {  // May 19th, ADDED THIS LINE
				DC.objPassiveTracking.passiveTrackingMainLoop()  // May 19th, ADDED THIS LINE
			}  // May 19th, ADDED THIS LINE
					
			storeSensorData(sensorData);
			
			if (count < 5) {		
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
					
					if (EIGoodToMeasure == 1 && exhaleCorrectionFactor < 1.3) {  // May 31st ADDED, only when this is low, can E/I be accurate
						
						exhaleEndTime = timeElapsed; //May 31st ADDED						
						EIRatio[EIRatioCount] = [(exhaleCorrectionFactor*(exhaleEndTime - inhaleEndTime))/((1-(0.05/smoothBreathingCoefBaseLevel))*(inhaleEndTime - inhaleStartTime)),timeElapsed]; // May 31st ADDED
						EIRatio[EIRatioCount][0] = roundNumber(EIRatio[EIRatioCount][0],10); // May 31st ADDED
						EIAvgSessionRatio = EIAvgSessionRatio + EIRatio[EIRatioCount][0]; // May 31st ADDED
						EIRatioCount++;  // May 31st ADDED	
						EIGoodToMeasure = 0; //May31st ADDED
						
					}  // May 31st ADDED
				
					endBreathLine.y = 5000;	
					stuckBreaths = 0;					
					breathEnding = 0;						
					breathCount++;						
					calculateRespRate();										
					setNewStrainGaugeRange();
					
					noisyMovements = 0; //This is where to reset this. Thus, ANY noisy movement during inhalation will trigger a higher endBreathY
					currentStrainGaugeLowest = strainGauge;	
					
				}
			}												
	
		}
		
		
			
		public function calculateOneMinuteEI():Number { // May 31st ADDED
			
			var EI1Minute:Number = 0;  // May 31st ADDED
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
			
			return(EI1Minute); // May 31st ADDED
			
		} // May 31st ADDED
		
		
		
		public function calculateRespRate():void {
			
					
			
			whenBreathsEnd[breathCount] = timeElapsed;		
						
			if (breathCount > 2 && breathCount < 5) {
				
				respRate = 2 * (60.0 / (whenBreathsEnd[breathCount] - whenBreathsEnd[breathCount-2]));						
			}
			
			else if (breathCount >= 5) {				
				respRate = 4 * (60.0 / (whenBreathsEnd[breathCount] - whenBreathsEnd[breathCount-4]));
				avgRespRate = 60*(breathCount/timeElapsed);
			}
			
			respRate = roundNumber(respRate, 10);
			avgRespRate = roundNumber(avgRespRate, 10);
			
			postureUI.respirationRateIndicator.text = String(respRate);
			postureUI.howManyBreaths.text = String(breathCount);
			
			
		}
		
		
		public function setNewStrainGaugeRange():void {			
			
			var rangeSet:int = 0;
			
			newStrainGaugeRange = currentStrainGaugeHighestNew - currentStrainGaugeLowestNew;							
				
				if (noisyMovements == 0) { //do not set the range to be more sensitive when noisy movements
					
					if (newStrainGaugeRange < (0.70*(currentStrainGaugeHighest - currentStrainGaugeLowest))) {						
							
						lightBreathsInARow++;	
						breathTopExceeded = 0;
								
						if (lightBreathsInARow > 1) {											
							
							rangeSet = 1;
							currentStrainGaugeLowest = 0.5*currentStrainGaugeLowestNew + (1-0.5)*currentStrainGaugeLowest;		
							currentStrainGaugeHighest = 0.5*currentStrainGaugeHighestNew + (1-0.5)*currentStrainGaugeHighest;										
							
							if ( (currentStrainGaugeHighest - currentStrainGaugeLowest) < strainGaugeMinRange) {
								currentStrainGaugeHighest = currentStrainGaugeLowest + strainGaugeMinRange;
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
						
						breathTopExceeded++;
						lightBreathsInARow = 0;
						
						if (breathTopExceeded > breathTopExceededThreshold) {	
							currentStrainGaugeHighest = ((0.3*currentStrainGaugeHighest + (1-0.3)*currentStrainGaugeHighestPrev) - currentStrainGaugeLowest) + strainGauge;
						}
						else {
							currentStrainGaugeHighest = (currentStrainGaugeHighestPrev - currentStrainGaugeLowest) + strainGauge; //Since currentStrainGaugeLowest is being set to strainGauge below, this preserves the range but relative to the new floor.
						}
					}
					
					else {
						breathTopExceeded = 0;
					}
				}
				else {
					currentStrainGaugeHighest = (currentStrainGaugeHighestPrev - currentStrainGaugeLowest) + strainGauge; //Since currentStrainGaugeLowest is being set to strainGauge below, this preserves the range but relative to the new floor.
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
					inhaleStartTime = timeElapsed - (reversalThreshold+1)*(1/20); //May 31st ADDED
					//DC.objStartConnection.socket.writeUTFBytes("Buzz,2" + "\n");			
					//DC.objStartConnection.socket.flush();
					bottomReversalY = graphYSeries[downStreakStart];					
					
					currentStrainGaugeLowestNew = breathSensor[count-(reversalThreshold+2)];					
							
					for (i = downStreakStart; i <= upStreakStart; i++) { //This is needed because upStreakStart could conceivably be higher than downStreakStart
						
						if (graphYSeries[i] > bottomReversalY){ //Find the lowest point on the graph within the bounds
							bottomReversalY = graphYSeries[i];								
						}
						
					}																	
										
					bottomReversalLine.y = bottomReversalY;	
					
					topReversalLine.y = 5000;
					
					//endBreathLine.y = 5000; //hide it, breath shouldn't count if it never crossed this line!				
					
					if (breathEnding == 1) {  //This means a bottom reversal occured BEFORE the previous breath ended! (ie before the previous breath crossed the endBreathLine)
						
						//bottomReversalFound = 0; //!!! if a breath does a bottom reversal before it ends normally, then by setting this to 0, range will not change at next top reversal 
						stuckBreaths++;
					}
					
					if (stuckBreaths == 0) {						
						
						currentStrainGaugeHighestPrev = currentStrainGaugeHighest; //only set this when the breath is not stuck! Otherwise it could be set much higher (to the value which exceeded the ceiling)
					} 				
																
					topReversalFound = 0;	
					//breathEnding = 0;
																				
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
					
					//if (DC.appMode != 3) {
						if ( ((bottomReversalY - topReversalY < minBreathRange) && stuckBreaths > 0) || (yStartPos - topReversalY < (minBreathRange/3)) ) { //***March16Change Just changed to divided by 3 here from 2 to allow smaller breaths from baseline to be detected
							return; // Require a min breath range when breath is stuck, otherwise breath holding does not work and breath range sensitivity can artificially spike due to noise
						}
					//}
					
					topReversalFound = 1;	
					
					currentStrainGaugeHighestNew = breathSensor[count-(reversalThreshold+2)];
					
					topReversalLine.y = topReversalY;	
					
					
										
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
			
			if (postureUI.postureSelector.postureLevel1.selected == true) {
				
				//postureRange = 0.25;
				postureRange = 0.15;
			}
			else if (postureUI.postureSelector.postureLevel2.selected == true) {
				//postureRange = 0.15;
				postureRange = 0.10;
			}
			else if (postureUI.postureSelector.postureLevel3.selected == true) {
				//postureRange = 0.08;
				postureRange = 0.05;
			}					
					
		}
		
		function breathSelectorHandler(evt:MouseEvent)  {			
			
			if (postureUI.breathSelector.breathLevel1.selected == true) {
				smoothBreathingCoefBaseLevel = 0.15;
				reversalThreshold = 6;
				birdIncrements = 24;
			}
			else if (postureUI.breathSelector.breathLevel2.selected == true) {
				smoothBreathingCoefBaseLevel = 0.4;
				reversalThreshold = 5;
				birdIncrements = 20;
			}
			else if (postureUI.breathSelector.breathLevel3.selected == true) {
				smoothBreathingCoefBaseLevel = 0.6;
				reversalThreshold = 3;
				birdIncrements = 12;
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
		
		
		function startMode():void {			
			
			exhaleCorrectionFactor = 0; //May 31st ADDED
			EIAvgSessionRatio = 0; //May 31st ADDED
			EIRatio = [];  //May 31st ADDED
			inhaleStartTime = 0; //May 31st ADDED
			inhaleEndTime = 0; //May 31st ADDED
			exhaleEndTime = 0; //May 31st ADDED
			EIRatioCount = 0; //May 31st ADDED
			whenBreathsEnd = [];
			whenBreathsEnd[0] = 0;
			breathCount = 0;
			timeElapsed = 0;
			respRate = 0;
			avgRespRate = 0;
			currentStrainGaugeHighest = currentStrainGaugeLowest + 0.003;
			currentStrainGaugeHighestPrev = currentStrainGaugeHighest;
			currentStrainGaugeLowestNew = currentStrainGaugeLowest;
			currentStrainGaugeHighestNew = currentStrainGaugeHighest;		
			
			postureUI.respirationRateIndicator.text = "";
			postureUI.howManyBreaths.text = "";
			
			DC.objModeScreen.startData();
			//RRtimer.start();	
			//addEventListener(Event.ENTER_FRAME, enterFrameHandler);  May 19th, REMOVED THIS LINE
			stuckBreathsThreshold = 1; 
			breathTopExceededThreshold = 1;		
			minBreathRange = fullBreathGraphHeight/16; //***March16Change This is important because resolutions on devices are different. Previously it was set to 25, which is an absolute value. Now it is set relative to the fullBreathGraphHeight (whatever that is set to for the particular device, it was 400 on desktop)
					
		}			

	}
	
}
