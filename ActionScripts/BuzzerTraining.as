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
	  
	
	public class BuzzerTraining extends MovieClip {
		
		
		var DC:Main;	
		var buzzerTrainingUI:BuzzerTrainingUI = new BuzzerTrainingUI();
		var totalElapsedTime:int = 0;  //(in 1/60 of a second, or 1/FPS movie frame rate)
		var breathTime:int = -1;
		
		var inhalationTimeEnd:int = 0;
		var retentionTimeEnd:int = 0;
		var exhalationTimeEnd:int = 0;
		var timeBetweenBreathsEnd:int = 0;
		
		var whichPattern:int = 0;
		var subPattern:int = 0;		
		
		var hasInhaled:int = 0;	
		var hasExhaled:int = 0;	
		var numOfInhales:int = 0;	
		var numOfExhales:int = 0;	
		var whenExhaled:int = 0;
		var whenInhaled:int = 0;
		
		var isBuzzing:int = 0;
		var buzzCount:int = 0;
		
		var takenFirstBreath:int = 0;
		
		var buzzReason:int = 0;
		
		var cycles:int = 0;
		
		var hasUprightBeenSet:int = 0;
		var trainingDuration:int = 0;
		var slouchesCount:int = 0;
		var uprightPostureTime:int = 0;
		var mindfulBreathsCount:int = 0;
		var gameSetTime:int = 0;
		var prevPostureState:int = 0;
		var enterFrameCount:int = 0;
		
		var totalBreaths:int = 0;
		
		var breathsOnCurrentLevel:int = 0;
		var goodBreaths:int = 0;
		
		var useBuzzerForPosture:int = 1;
		
		var buzzerTrainingForPostureOnly:int = 0; //****** May 8th 2019 changes
		
		var isBuzzerTrainingActive:int = 0; // May 19th, ADDED THIS LINE
		
		var doWarningBuzzesforUnmindful:int = 1; //JULY 13:New1p   Set this to 0 when on/off switch is off  to not buzz for warning buzzes when unmindful breathing, should be on by default
		
		var graphStartTime:Number = 0;  //AUG 12th New		
		var previousExpectedBreathStartTime:Number = 0; //AUG 12th NEW
		var previousExpectedBreathRR:Number = 0; //AUG 12th NEW	 
		var breathingGraph:MovieClip = new MovieClip(); //AUG 12th NEW
		var lastXForActualBreath:Number = 0; //AUG 12th NEW
		var	lastYForActualBreath:Number = 0; //AUG 12th NEW	
		var breathInterrupted:int = 0; //AUG 12th NEW
		var postureGraph:MovieClip = new MovieClip(); //AUG 12th NEW
		var postureSessionTime:int = 0; //AUG 12th NEW
		
		
		public function BuzzerTraining(main:Main) {
				
			DC = main; //to have access to the document class	
			
			buzzerTrainingUI.backToBreathingAndPostureMenu.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);
			buzzerTrainingUI.backToBreathingAndPostureMenu.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			buzzerTrainingUI.backToBreathingAndPostureMenu.addEventListener(MouseEvent.MOUSE_UP,backToBreathingAndPostureMenuHandler);
			buzzerTrainingUI.backToBreathingAndPostureMenu.buttonMode = true;
					
			buzzerTrainingUI.startBuzzerTrainingButton.addEventListener(MouseEvent.MOUSE_UP,startBuzzerTrainingButtonHandler);
			buzzerTrainingUI.startBuzzerTrainingButton.buttonMode = true;
			
			buzzerTrainingUI.setUprightButton.addEventListener(MouseEvent.MOUSE_DOWN,setUprightButtonHandler);
			buzzerTrainingUI.setUprightButton.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			buzzerTrainingUI.setUprightButton.addEventListener(MouseEvent.MOUSE_UP,unclickButton);		
			buzzerTrainingUI.setUprightButton.buttonMode = true;	
			
			buzzerTrainingUI.postureResponse.level1.addEventListener(MouseEvent.CLICK,postureSelectorHandler);
			buzzerTrainingUI.postureResponse.level2.addEventListener(MouseEvent.CLICK,postureSelectorHandler);
			buzzerTrainingUI.postureResponse.level3.addEventListener(MouseEvent.CLICK,postureSelectorHandler);	
			
			buzzerTrainingUI.breathResponse.level1.addEventListener(MouseEvent.CLICK,breathSelectorHandler);
			buzzerTrainingUI.breathResponse.level2.addEventListener(MouseEvent.CLICK,breathSelectorHandler);
			buzzerTrainingUI.breathResponse.level3.addEventListener(MouseEvent.CLICK,breathSelectorHandler);
			
			buzzerTrainingUI.buzzerForPosture.level1.addEventListener(MouseEvent.CLICK,buzzerForPostureHandler);
			buzzerTrainingUI.buzzerForPosture.level2.addEventListener(MouseEvent.CLICK,buzzerForPostureHandler);	
			
									
			addChild(buzzerTrainingUI);
			
			buzzerTrainingUI.status.visible = false;
			buzzerTrainingUI.status0.visible = false;
			
			buzzerTrainingUI.postureState.gotoAndStop(1);
		}		
			
		
		function startMode():void  {		
			
			addChild(DC.objLiveGraph); //***march19
			DC.objLiveGraph.scaleX = 0.5;  //***march19
			DC.objLiveGraph.scaleY = 0.5;  //***march19
			DC.objLiveGraph.postureUI.visible = false;  //***march19
			
			graphStartTime = 0;  //AUG 12th New	
			
			DC.objLiveGraph.startMode(); //Need this here because user needs to be able set posture before timer starts!
			
			DC.objLiveGraph.breathTopExceededThreshold = 0; //AUG 1st NEW
			DC.objLiveGraph.lightBreathsThreshold = 0; //AUG 1st NEW
			DC.objLiveGraph.minBreathRange = DC.objLiveGraph.fullBreathGraphHeight/16; //AUG 1st 	
			DC.objLiveGraph.minBreathRangeForStuck = (DC.objLiveGraph.fullBreathGraphHeight/16); //AUG 1st 
			
			if (DC.objLiveGraph.postureLevel == 1) {  //AUG 1st NEW 
				buzzerTrainingUI.postureResponse.level1.selected = true; //AUG 1st NEW 
			} //AUG 1st NEW 
			else if (DC.objLiveGraph.postureLevel == 2) { //AUG 1st NEW 
				buzzerTrainingUI.postureResponse.level2.selected = true; //AUG 1st NEW 
			} //AUG 1st NEW 
			else if (DC.objLiveGraph.postureLevel == 3) { //AUG 1st NEW 
				buzzerTrainingUI.postureResponse.level3.selected = true; //AUG 1st NEW 
			} //AUG 1st NEW 
			
			buzzerTrainingUI.breathResponse.level1.selected = true; //AUG 1st NEW			
			DC.objLiveGraph.smoothBreathingCoefBaseLevel = 0.15; //AUG 1st NEW
			DC.objLiveGraph.reversalThreshold = 9; //AUG 1st NEW
			DC.objLiveGraph.birdIncrements = 24; //AUG 1st NEW
			
			buzzerTrainingUI.buzzerForPosture.level1.selected = true;
			useBuzzerForPosture = 1;
			
			buzzerTrainingUI.targetRR.text = "";
			buzzerTrainingUI.actualRR.text = "";
			
			if (DC.objGame.trainingPosture == 1) {
				buzzerTrainingUI.postureType.text = "LOWER BACK SEATED";
			}
			else if (DC.objGame.trainingPosture == 2) {
				buzzerTrainingUI.postureType.text = "UPPER BACK SEATED";
			}
			
			else if (DC.objGame.trainingPosture == 3) {
				buzzerTrainingUI.postureType.text = "UPPER BACK STANDING";
			}
			
			var nameOfPattern:String;
			
			if (DC.objGame.whichPattern != 0) {
			
				nameOfPattern = DC.objGame.patternSequence[DC.objGame.whichPattern][0][4];
			
			}
		
			else {
			
				nameOfPattern = "SLOWING PATTERN";
			}
		
			buzzerTrainingUI.patternName.text = nameOfPattern;	
			
			
			whichPattern = DC.objGame.whichPattern;
			subPattern = DC.objGame.subPattern;			
			
			inhalationTimeEnd = DC.objGame.patternSequence[whichPattern][subPattern][0] * 20; //May 19th changed from 60 to 20
			retentionTimeEnd = inhalationTimeEnd + DC.objGame.patternSequence[whichPattern][subPattern][1] * 20; //May 19th changed from 60 to 20
			exhalationTimeEnd = retentionTimeEnd + DC.objGame.patternSequence[whichPattern][subPattern][2] * 20; //May 19th changed from 60 to 20
			timeBetweenBreathsEnd = exhalationTimeEnd + DC.objGame.patternSequence[whichPattern][subPattern][3] * 20; //May 19th changed from 60 to 20
			
			slouchesCount = 0;			
			uprightPostureTime = 0;
			hasUprightBeenSet = 0;
			totalBreaths = 0;
			
			mindfulBreathsCount = 0;
			
			trainingDuration = DC.objGame.trainingDuration;
			gameSetTime = trainingDuration;		
			
			buzzerTrainingUI.timeUpright.text = String("--");
			buzzerTrainingUI.slouches.text = String(slouchesCount);
			buzzerTrainingUI.mindfulBreaths.text = String("--");
			
			buzzerTrainingUI.uprightPostureNotification.visible = true;		
			buzzerTrainingUI.elapsedTime.visible = false;
			
			buzzerTrainingUI.backToBreathingAndPostureMenu.visible = true;
			
			buzzerTrainingUI.sessionCompleteIndicator.visible = false;
			buzzerTrainingUI.startBuzzerTrainingButton.visible = false;
			
			buzzerTrainingUI.startBuzzerTrainingButton.gotoAndStop(1);
			
			//AUG 1st Block of code below removed
			//if (DC.objLiveGraph.postureUI.postureSelector.postureLevel1.selected == true) {			
				//buzzerTrainingUI.postureResponse.level1.selected = true;
			//}
			//else if (DC.objLiveGraph.postureUI.postureSelector.postureLevel2.selected == true) {				
				//buzzerTrainingUI.postureResponse.level2.selected = true;
			//}
			//else if (DC.objLiveGraph.postureUI.postureSelector.postureLevel3.selected == true) {				
				//buzzerTrainingUI.postureResponse.level3.selected = true;
			//}					
				
			
			//if (DC.objLiveGraph.postureUI.breathSelector.breathLevel1.selected == true) {
				//buzzerTrainingUI.breathResponse.level1.selected = true;
			//}
			//else if (DC.objLiveGraph.postureUI.breathSelector.breathLevel2.selected == true) {
				//buzzerTrainingUI.breathResponse.level2.selected = true;
			//}
			//else if (DC.objLiveGraph.postureUI.breathSelector.breathLevel3.selected == true) {
				//buzzerTrainingUI.breathResponse.level3.selected = true;
			//}		
			
			
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
		
		
				
		
		//AUG 12th NEW FUNCTION
		function buildJudgedBreaths(breathStatus:int):void {										
			
			if (DC.objLiveGraph.actualBreathsWithinAPattern.length == 0) { //AUG 12th NEW					
				
				DC.objLiveGraph.actualBreathsWithinAPattern = [[previousExpectedBreathStartTime, breathStatus]]; //AUG 12th NEW  If user did not breathe at all during the target breath, create a breath with 0 RR
										
			}	//AUG 12th NEW		
			
			
			if (DC.objLiveGraph.judgedBreaths.length == 1) {
				
				DC.objLiveGraph.judgedBreaths.push([ [], DC.objLiveGraph.actualBreathsWithinAPattern.concat(), breathStatus]); //AUG 12th NEW the .concat() is to copy the array (to avoid reference problem), this is for the first pattern breath in the training, which cannot yet have a target RR (since that can only come at the end of the breath)

			}
			else {
				
				DC.objLiveGraph.judgedBreaths.push([ [previousExpectedBreathStartTime,previousExpectedBreathRR], DC.objLiveGraph.actualBreathsWithinAPattern.concat(), breathStatus]); //AUG 12th NEW the .concat() is to copy the array (to avoid reference problem)

			}
			
			previousExpectedBreathStartTime = roundNumber((DC.objLiveGraph.timeElapsed-graphStartTime)+0.5,10); //AUG 12th NEW, the 0.5 here is to add back the 1/2 second due to 320+xStep above THIS IS THE EXPECTED OR TARGET breath	
			if (timeBetweenBreathsEnd > 0) { //AUG 12th NEW
				previousExpectedBreathRR = roundNumber((3600/timeBetweenBreathsEnd)/3,10); //AUG 12th NEW
			} //AUG 12th NEW
				
			DC.objLiveGraph.actualBreathsWithinAPattern = []; //AUG 12th NEW	
			
			
			
		}  //AUG 12th NEW	
		
		
		
		function startBuzzerTrainingButtonHandler(evt:MouseEvent):void  {			
			
			if (buzzerTrainingUI.startBuzzerTrainingButton.currentFrame == 1) {		
				
				buzzerTrainingUI.backToBreathingAndPostureMenu.visible = false; //You MUST end the session first before the back button re-appears.
				
				buzzerTrainingUI.startBuzzerTrainingButton.gotoAndStop(2);	
				
				breathTime = -1;
				totalElapsedTime = 0;			
				hasInhaled = 0;
				hasExhaled = 0;
				numOfInhales = 0;
				numOfExhales = 0;
				takenFirstBreath = 0;
				isBuzzing = 0;
				buzzCount = 0;
				//addEventListener(Event.ENTER_FRAME, enterFrameHandler); May 19th, REMOVED THIS LINE
				isBuzzerTrainingActive = 1; // May 19th, ADDED THIS LINE
				//DC.objLiveGraph.minBreathRange = DC.objLiveGraph.fullBreathGraphHeight/5.33; //AUG 1st REMOVED
				//DC.objLiveGraph.minBreathRangeForStuck = (DC.objLiveGraph.fullBreathGraphHeight/5.33); //AUG 1st REMOVED
				
				graphStartTime = DC.objLiveGraph.timeElapsed;  //AUG 12th New				
				DC.objLiveGraph.judgedBreaths = []; //AUG 12th NEW	
				DC.objLiveGraph.judgedPosture = []; //AUG 12th NEW					
				DC.objLiveGraph.actualBreathsWithinAPattern = [] //AUG 12th NEW
				postureSessionTime = 0; //AUG 12th NEW
				addChild(breathingGraph); //AUG 12th NEW
				addChild(postureGraph); //AUG 12th NEW
				breathInterrupted = 0; //AUG 12th NEW
				DC.objLiveGraph.judgedPosture.push([0,DC.objLiveGraph.postureIsGood]); //AUG 12th NEW  Record the initial posture state, NOTE: this array only records CHANGES in posture, not every second of posture state

				
			}
			
			else if (buzzerTrainingUI.startBuzzerTrainingButton.currentFrame == 2) {
				
				clearBuzzerTraining();
			
			}
		}		
		
		
		//function enterFrameHandler(e:Event):void {  May 19th, REMOVED THIS LINE			
		  function buzzerTrainingMainLoop():void { // May 19th, ADDED THIS LINE	
			
			buzzerTrainingUI.status.text = String(breathTime) + "  " + String(numOfInhales) +  "  " + String(numOfExhales) + "  " + String(whichPattern) + "  " + String(subPattern) + "  " + String(breathsOnCurrentLevel);

			buzzerTimerHandler();		
			
			buzzerTrainingUI.actualRR.text = String(DC.objLiveGraph.respRate);
			
			totalElapsedTime++;  //May 19th, this does NOT seem to be used
		
			
			if (buzzCount > 0) {
				
				buzzCount--;  
				
				if (buzzCount == 0) {  
					isBuzzing = 0;
					DC.objLiveGraph.dampingLevel = 0;
					DC.objLiveGraph.postureAttenuatorLevel = 0;
				}		
				
			}						
			
			breathTime++; 				
			
			if (breathTime < 0) {
				
				if (buzzReason == 1) { //due to bad breathing
					
					if (breathTime == -53) { // May 19th, Changed from -160      so that any guidance buzzing doesn't interfere with bad breath buzzing. Allows any guidance buzzing time to clear first.
						
						if (doWarningBuzzesforUnmindful == 1) { //JULY 13:New1p  
							
							DC.objStartConnection.socket.writeUTFBytes("Buzz,1.2" + "\n");			
							DC.objStartConnection.socket.flush();	
							isBuzzing = 1; //JULY 13:New1p
							buzzCount = 30; //JULY 13:New1p
						} //JULY 13:New1p  
						
						//isBuzzing = 1; //JULY 13:Change1p  REMOVED
						//buzzCount = 30; //JULY 13:Change1p  REMOVED
					}
				}
				
				else if (buzzReason == 2) { //due to bad posture
					
					if (breathTime == -93) { // May 19th, Changed from -280         so that any guidance buzzing doesn't interfere with bad breath buzzing. Allows any guidance buzzing time to clear first.
						DC.objStartConnection.socket.writeUTFBytes("Buzz,1" + "\n");			
						DC.objStartConnection.socket.flush();	
						isBuzzing = 1;
						buzzCount = 63; //May 19th changed from 190
					}
					
					if (breathTime == -63) { //May 19th, Changed from -190        so that any guidance buzzing doesn't interfere with bad breath buzzing. Allows any guidance buzzing time to clear first.
						DC.objStartConnection.socket.writeUTFBytes("Buzz,1" + "\n");			
						DC.objStartConnection.socket.flush();	
						
					}
				}
				return; // May 19th comment change, if breath was bad, breatTime is set to -30, and needs time to clear bad breath buzzer indicator before proceeding
			}
			
			if (buzzerTrainingForPostureOnly == 1) {
				if (DC.objLiveGraph.postureIsGood == 0 && useBuzzerForPosture == 1)  {   //****** May 8th 2019 changes
					buzzerTrainingUI.buzzerReason.text = "Slouching Posture";	//****** May 8th 2019 changes				
					badPosture();	//****** May 8th 2019 changes					
				}   //****** May 8th 2019 changes	
				return;  //****** May 8th 2019 changes	
			}   //****** May 8th 2019 changes	
			
			
			
			if (breathTime >= timeBetweenBreathsEnd) {		
				
				cycles++;
				breathTime = 0;
				hasInhaled = 0;
				hasExhaled = 0;
				numOfInhales = 0;
				numOfExhales = 0;
				whenInhaled = 0;
				whenExhaled = 0;	
				buzzReason = 0;
				
				if (cycles == 2) { //AUG 1st NEW 
					DC.objLiveGraph.breathTopExceededThreshold = 1; //AUG 1st NEW  
					DC.objLiveGraph.lightBreathsThreshold = 1; //AUG 1st NEW  
					DC.objLiveGraph.minBreathRange = DC.objLiveGraph.fullBreathGraphHeight/5.33; //AUG 1st NEW
					DC.objLiveGraph.minBreathRangeForStuck = (DC.objLiveGraph.fullBreathGraphHeight/5.33); //AUG 1st NEW
					
					DC.objLiveGraph.judgedBreaths.push([ [],DC.objLiveGraph.actualBreathsWithinAPattern.concat(),-1]); //AUG 12th NEW the concat() here is to copy the array (to avoid possible reference problem),saving all non-judged breaths here during 15 second calibration	
					DC.objLiveGraph.actualBreathsWithinAPattern = []; //AUG 12th NEW	
					previousExpectedBreathStartTime = roundNumber((DC.objLiveGraph.timeElapsed-graphStartTime)+0.5,10); //AUG 12th NEW, the 0.5 here is to add back the 1/2 second due to 320+xStep above THIS IS THE EXPECTED OR TARGET breath	
			
					
				} //AUG 1st NEW 
				
				if (cycles > 2) {					
								
					buildJudgedBreaths(1); // AUG 12th NEW, since breath reached the end in BT, then must be a good breath (otherwise it would be interrupted by badBreath())
					
					if (DC.objLiveGraph.judgedBreaths.length > 2) { //AUG 12th NEW
						drawBreathingGraph(); //AUG 12th NEW
					} //AUG 12th NEW
				
					mindfulBreathsCount++;										
					
					if (whichPattern == 0) {
						goodBreaths++; //For breath pattern 0, for keeping track of 4 out of 5 good breaths to advance or recede
					}
					
					buzzerTrainingUI.mindfulBreaths.text = String(mindfulBreathsCount) + " of " + String(totalBreaths); //AUG 1st changed
							
				}
				
					
				if (whichPattern != 0) {				
				
					if (DC.objGame.patternSequence[whichPattern].length > 1) {
						subPattern++;
					
						if (subPattern > DC.objGame.patternSequence[whichPattern].length - 1) {
							subPattern = 0;
						}
					}
				}				
			
				
			}	
			
			
			/* if (takenFirstBreath == 0 && (DC.objLiveGraph.bottomReversalFound == 1 || DC.objLiveGraph.breathEnding == 1)) {
				return; //don't start buzzer training until user finishes the breath they were in (if any), same after bad breath
			}
			else {
				takenFirstBreath = 1;
				
			} */
			
			
			if (breathTime == 0) {

				DC.objStartConnection.socket.writeUTFBytes("Buzz,0.10" + "\n");			
				DC.objStartConnection.socket.flush();
				
				if (breathInterrupted == 1) {
					breathInterrupted = 0;
					DC.objLiveGraph.actualBreathsWithinAPattern = []; //AUG 12th NEW  To erase any actual inhales occuring after a bad breath warning but before the start of the next breath
					previousExpectedBreathStartTime = roundNumber((DC.objLiveGraph.timeElapsed-graphStartTime)+0.5,10); //AUG 12th NEW
				}
				
				inhalationTimeEnd = DC.objGame.patternSequence[whichPattern][subPattern][0] * 20; //May 19th changed from 60 to 20
				retentionTimeEnd = inhalationTimeEnd + DC.objGame.patternSequence[whichPattern][subPattern][1] * 20; //May 19th changed from 60 to 20
				exhalationTimeEnd = retentionTimeEnd + DC.objGame.patternSequence[whichPattern][subPattern][2] * 20; //May 19th changed from 60 to 20
				timeBetweenBreathsEnd = exhalationTimeEnd + DC.objGame.patternSequence[whichPattern][subPattern][3] * 20; //May 19th changed from 60 to 20
				
				buzzerTrainingUI.buzzerReason.text = "";
				
				if (timeBetweenBreathsEnd > 0) { //AUG 12th NEW
					buzzerTrainingUI.targetRR.text = String(roundNumber((3600/timeBetweenBreathsEnd)/3,10)); //May 19th changed
				} //AUG 12th NEW
				
				isBuzzing = 1;
				buzzCount = 10; //May 19th changed from 30
				numOfInhales = 0;
				numOfExhales = 0;	
				
				if (cycles >= 2) { //JULY				
					
					totalBreaths++;
					
					if (whichPattern == 0) {
						breathsOnCurrentLevel++; 
						
						//if (breathsOnCurrentLevel == 6) {//JULY 13:Change1r REMOVED
						//	breathsOnCurrentLevel = 1;//JULY 13:Change1r REMOVED
							//goodBreaths = 0;		//JULY 13:Change1r REMOVED		
						//}			//JULY 13:Change1r REMOVED
						
						if (breathsOnCurrentLevel == 6) {				
							if (goodBreaths >= 4) {				
								subPattern++;
								if (subPattern > DC.objGame.maxSubPattern) { //may 8th  maxSubPattern is representing the minimum target respiration rate
									subPattern = DC.objGame.maxSubPattern;  //may 8th
								}	//may 8th		
							}
							else {					
								subPattern--;
								if (subPattern < 3) {
									subPattern = 3; //minimum is 15bmp for buzzer training
								}				
							}	
							breathsOnCurrentLevel = 1; //JULY 13:NEW1r 
							goodBreaths = 0;	 //JULY 13:NEW1r 
							
						}
					
					}
					
				}				
				
				//buzzerTrainingUI.status0.text = "New Breath Start";
			}
			
			if (breathTime == inhalationTimeEnd) {  
				DC.objStartConnection.socket.writeUTFBytes("Buzz,0.10" + "\n");			
				DC.objStartConnection.socket.flush();
				isBuzzing = 1;
				buzzCount = 10; //May 19th changed from 30
				

			}	
			
			
			if (breathTime == exhalationTimeEnd) { 
				DC.objStartConnection.socket.writeUTFBytes("Buzz,0.10" + "\n");			
				DC.objStartConnection.socket.flush();
				isBuzzing = 1;
				buzzCount = 14; //May 19th changed from 40
			}	
			
			if (breathTime == exhalationTimeEnd + 6) { // May 19th, Changed from 20 to 6
				DC.objStartConnection.socket.writeUTFBytes("Buzz,0.10" + "\n");			
				DC.objStartConnection.socket.flush();
				
			}
			
			if (cycles < 2) {
				return;
			}
			
			if (DC.objLiveGraph.postureIsGood == 0 && useBuzzerForPosture == 1)  {
				buzzerTrainingUI.buzzerReason.text = "Slouching Posture";
				totalBreaths--; //necessary to return to previous count if posture was the cause
				breathsOnCurrentLevel--; //necessary to return to previous count if posture was the cause
				badPosture();	
				return;				
			}
			
			if (DC.objLiveGraph.bottomReversalFound == 1 && hasInhaled == 0) {	
				hasInhaled = 1;
				hasExhaled = 0;
				numOfInhales++;				
			}
			
			if (DC.objLiveGraph.topReversalFound == 1 && hasExhaled == 0) {	
				if (numOfInhales > 0) { //idea is that an inhale must have occured first (within the breath window). This helps prevent exhales carrying into the start of a breath after a bad breath.
					hasExhaled = 1;
					hasInhaled = 0;
					numOfExhales++;		
				}
			}
			
			if (numOfInhales > 1) {
				buzzerTrainingUI.buzzerReason.text = "Multiple inhales";
				//buzzerTrainingUI.status0.text = "numOfInhales > 1";
				badBreath();	
				return;
			}
			
			if (breathTime >= inhalationTimeEnd) {				
				if (numOfInhales == 0) {	
					buzzerTrainingUI.buzzerReason.text = "Inhalation late";
					//buzzerTrainingUI.status0.text = "No inhale by inhalationTimeEnd";
					badBreath();
					return;
				}				
			}		
			
			if (breathTime < retentionTimeEnd) {
				if (numOfExhales > 0) {	
					buzzerTrainingUI.buzzerReason.text = "Exhalation early";
					//buzzerTrainingUI.status0.text = "Exhalation before retentionTimeEnd";
					badBreath();
					return;					
				}				
			}
			
			if (breathTime >= exhalationTimeEnd) {
				if (numOfExhales == 0) {		
					buzzerTrainingUI.buzzerReason.text = "Exhalation late";
					//buzzerTrainingUI.status0.text = "No exhalation by exhalationTimeEnd";
					badBreath();
					return;					
				}				
			}
					
		
		}
		
		
		function badBreath():void {
			
			buildJudgedBreaths(0); //AUG 12th NEW 
			
			if (DC.objLiveGraph.judgedBreaths.length > 2) { //AUG 12th NEW
				drawBreathingGraph(); //AUG 12th NEW
			} //AUG 12th NEW
			
			breathTime = -60;  //May 19th Changed to -60 from -180
			hasInhaled = 0;
			hasExhaled = 0;
			numOfInhales = 0;
			numOfExhales = 0;
			takenFirstBreath = 0;
			whenInhaled = 0;
			whenExhaled = 0;
			buzzReason = 1;
			breathInterrupted = 1; //AUG 12th NEW
			
			buzzerTrainingUI.mindfulBreaths.text = String(mindfulBreathsCount) + " of " + String(totalBreaths); //AUG 1st changed
			
		}
		
		function badPosture():void {			
			
			breathTime = -100;  //May 19th Changed to -100 from -300
			hasInhaled = 0;
			hasExhaled = 0;
			numOfInhales = 0;
			numOfExhales = 0;
			takenFirstBreath = 0;
			whenInhaled = 0;
			whenExhaled = 0;
			buzzReason = 2;
			breathInterrupted = 1; //AUG 12th NEW
			
		}
		
		
		function backToBreathingAndPostureMenuHandler(evt:MouseEvent):void  {	
			
			DC.objLiveGraph.postureUI.visible = true;  //May 31st ADDED, YOU may not need this Luccas, in BT and PT, I hide the postureUI when displaying the live graph (because the postureUI component is part of Live graph but unecessary when viewed in BT and PT, because those already separately display the posture details), but you probably organized the structure differently
			DC.objLiveGraph.scaleX = 1;  //***May 31st ADDED  YOU may not need this Luccas
			DC.objLiveGraph.scaleY = 1;  //***May 31st ADDED  YOU may not need this Luccas
			
			DC.removeChild(DC.objBuzzerTraining);
			DC.addChild(DC.objModeScreen);	
			
			DC.objModeScreen.startScreen3.visible = false;
			DC.objModeScreen.startScreen4.visible = true;
			DC.objModeScreen.VTLauncher1.visible = false;
			DC.appMode = 0;			
			
		}
		
		function unclickButton(evt:MouseEvent)  {	
		
			evt.currentTarget.gotoAndStop(1);
		}
		
		function clickButton(evt:MouseEvent)  {	
		
			evt.currentTarget.gotoAndStop(2);
		}
		
		
				
		function buzzerTimerHandler():void {		
			
			enterFrameCount++;
			
			if (enterFrameCount < 20) {  // May 19th, changed to 20
				return;				
			}
			
			enterFrameCount = 0;
					
			trainingDuration--;
			postureSessionTime++; //AUG 1st NEW (measured in seconds, int)
			
			buzzerTrainingUI.elapsedTime.text = DC.objGame.convertTime(trainingDuration);			
					
				
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
			
			buzzerTrainingUI.timeUpright.text = String(uprightPostureTime) + " of " + String(gameSetTime - trainingDuration);
			buzzerTrainingUI.slouches.text = String(slouchesCount);								
			
			prevPostureState = DC.objLiveGraph.postureIsGood;
			
			
			
			if (trainingDuration == 0) {
				
				buzzerTrainingUI.sessionCompleteIndicator.visible = true;			
				
				clearBuzzerTraining();			
				
				DC.objStartConnection.socket.writeUTFBytes("Buzz,2.5" + "\n"); //JULY 13:New1q  		
				DC.objStartConnection.socket.flush(); //JULY 13:New1q  
				
			}
			
		}	
		
		
		function setUprightButtonHandler(evt:MouseEvent)  {	
			
			DC.objLiveGraph.learnUprightAngleHandler(evt);
			
			if (hasUprightBeenSet == 0) {
				
				uprightHasBeenSetHandler();				
				
			}				
			
		}
		
		function uprightHasBeenSetHandler():void {
			
			buzzerTrainingUI.startBuzzerTrainingButton.visible = true;
			buzzerTrainingUI.uprightPostureNotification.visible = false;
			buzzerTrainingUI.elapsedTime.visible = true;
			buzzerTrainingUI.elapsedTime.text = DC.objGame.convertTime(trainingDuration);
			hasUprightBeenSet = 1;
						
		}
		
		
		function clearBuzzerTraining():void  {		 		
			
			//removeEventListener(Event.ENTER_FRAME, enterFrameHandler);  May 19th, REMOVED THIS LINE
			isBuzzerTrainingActive = 0; //May 19th, ADDED THIS LINE
			
			isBuzzing = 0;
			buzzCount = 0;
			cycles = 0;
			buzzReason = 0;			
			prevPostureState = 0;
			breathsOnCurrentLevel = 0;
			goodBreaths = 0;
			DC.objModeScreen.stopData();			
			
			buzzerTrainingUI.startBuzzerTrainingButton.visible = false;
			buzzerTrainingUI.backToBreathingAndPostureMenu.visible = true; 
			
			DC.objLiveGraph.saveData(); //***march19
		}
		
		
		function postureSelectorHandler(evt:MouseEvent)  {
			
			if (buzzerTrainingUI.postureResponse.level1.selected == true) {
				//DC.objLiveGraph.postureUI.postureSelector.postureLevel1.selected = true;  // AUG 1st REMOVED
				DC.objLiveGraph.postureRange = 0.15;
				DC.objLiveGraph.postureLevel = 1;  // AUG 1st NEW
			}
			
			else if (buzzerTrainingUI.postureResponse.level2.selected == true) {
				//DC.objLiveGraph.postureUI.postureSelector.postureLevel2.selected = true;  // AUG 1st REMOVED
				DC.objLiveGraph.postureRange = 0.10;
				DC.objLiveGraph.postureLevel = 2;  // AUG 1st NEW
			}
			
			else if (buzzerTrainingUI.postureResponse.level3.selected == true) {
				//DC.objLiveGraph.postureUI.postureSelector.postureLevel3.selected = true;  // AUG 1st REMOVED
				DC.objLiveGraph.postureRange = 0.05;
				DC.objLiveGraph.postureLevel = 3;  // AUG 1st NEW
			}
			
		}
		
		function buzzerForPostureHandler(evt:MouseEvent)  {
			
			if (buzzerTrainingUI.buzzerForPosture.level1.selected == true) {
				useBuzzerForPosture = 1;
			}
			else if (buzzerTrainingUI.buzzerForPosture.level2.selected == true) {
				useBuzzerForPosture = 0;
			}
				
		}
		
		
		
		function breathSelectorHandler(evt:MouseEvent)  {
			
			if (buzzerTrainingUI.breathResponse.level1.selected == true) {
				//DC.objLiveGraph.postureUI.breathSelector.breathLevel1.selected = true; // AUG 1st REMOVED
				DC.objLiveGraph.smoothBreathingCoefBaseLevel = 0.15;
				DC.objLiveGraph.reversalThreshold = 9;
				DC.objLiveGraph.birdIncrements = 24;

			}
			
			else if (buzzerTrainingUI.breathResponse.level2.selected == true) {
				//DC.objLiveGraph.postureUI.breathSelector.breathLevel2.selected = true;  // AUG 1st REMOVED
				DC.objLiveGraph.smoothBreathingCoefBaseLevel = 0.4;
				DC.objLiveGraph.reversalThreshold = 5;
				DC.objLiveGraph.birdIncrements = 20;
			}
			
			else if (buzzerTrainingUI.breathResponse.level3.selected == true) {
				//DC.objLiveGraph.postureUI.breathSelector.breathLevel3.selected = true;  // AUG 1st REMOVED
				DC.objLiveGraph.smoothBreathingCoefBaseLevel = 0.6;
				DC.objLiveGraph.reversalThreshold = 3;
				DC.objLiveGraph.birdIncrements = 12;
			}
			
		}
		
		
		function roundNumber(numb:Number, decimal:Number):Number {
		
			return Math.round(numb*decimal)/decimal;
		}
		
		
					

	}
	
}
