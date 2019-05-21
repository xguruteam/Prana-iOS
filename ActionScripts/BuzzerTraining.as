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
			
			DC.objLiveGraph.startMode(); //Need this here because user needs to be able set posture before timer starts!
			
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
			
			inhalationTimeEnd = DC.objGame.patternSequence[whichPattern][subPattern][0] * 60;
			retentionTimeEnd = inhalationTimeEnd + DC.objGame.patternSequence[whichPattern][subPattern][1] * 60;
			exhalationTimeEnd = retentionTimeEnd + DC.objGame.patternSequence[whichPattern][subPattern][2] * 60;
			timeBetweenBreathsEnd = exhalationTimeEnd + DC.objGame.patternSequence[whichPattern][subPattern][3] * 60;
			
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
			
			
			if (DC.objLiveGraph.postureUI.postureSelector.postureLevel1.selected == true) {				
				buzzerTrainingUI.postureResponse.level1.selected = true;
			}
			else if (DC.objLiveGraph.postureUI.postureSelector.postureLevel2.selected == true) {				
				buzzerTrainingUI.postureResponse.level2.selected = true;
			}
			else if (DC.objLiveGraph.postureUI.postureSelector.postureLevel3.selected == true) {				
				buzzerTrainingUI.postureResponse.level3.selected = true;
			}					
				
			
			if (DC.objLiveGraph.postureUI.breathSelector.breathLevel1.selected == true) {
				buzzerTrainingUI.breathResponse.level1.selected = true;
			}
			else if (DC.objLiveGraph.postureUI.breathSelector.breathLevel2.selected == true) {
				buzzerTrainingUI.breathResponse.level2.selected = true;
			}
			else if (DC.objLiveGraph.postureUI.breathSelector.breathLevel3.selected == true) {
				buzzerTrainingUI.breathResponse.level3.selected = true;
			}		
			
			
		}
		
		
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
				addEventListener(Event.ENTER_FRAME, enterFrameHandler);
				
			}
			
			else if (buzzerTrainingUI.startBuzzerTrainingButton.currentFrame == 2) {
				
				clearBuzzerTraining();
			
			}
		}		
		
		
		function enterFrameHandler(e:Event):void {			
			
			buzzerTrainingUI.status.text = String(breathTime) + "  " + String(numOfInhales) +  "  " + String(numOfExhales) + "  " + String(whichPattern) + "  " + String(subPattern) + "  " + String(breathsOnCurrentLevel);

			buzzerTimerHandler();		
			
			buzzerTrainingUI.actualRR.text = String(DC.objLiveGraph.respRate);
			
			totalElapsedTime++;
		
			
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
					
					if (breathTime == -160) { //so that any guidance buzzing doesn't interfere with bad breath buzzing. Allows any guidance buzzing time to clear first.
						DC.objStartConnection.socket.writeUTFBytes("Buzz,1.2" + "\n");			
						DC.objStartConnection.socket.flush();	
						isBuzzing = 1;
						buzzCount = 90;
					}
				}
				
				else if (buzzReason == 2) { //due to bad posture
					
					if (breathTime == -280) { //so that any guidance buzzing doesn't interfere with bad breath buzzing. Allows any guidance buzzing time to clear first.
						DC.objStartConnection.socket.writeUTFBytes("Buzz,1" + "\n");			
						DC.objStartConnection.socket.flush();	
						isBuzzing = 1;
						buzzCount = 190;
					}
					
					if (breathTime == -190) { //so that any guidance buzzing doesn't interfere with bad breath buzzing. Allows any guidance buzzing time to clear first.
						DC.objStartConnection.socket.writeUTFBytes("Buzz,1" + "\n");			
						DC.objStartConnection.socket.flush();	
						
					}
				}
				return; // if breath was bad, breatTime is set to -90, and needs time to clear bad breath buzzer indicator before proceeding
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
				
				if (cycles > 2) {
					mindfulBreathsCount++;	
					
					if (whichPattern == 0) {
						goodBreaths++; //For breath pattern 0, for keeping track of 4 out of 5 good breaths to advance or recede
					}
					buzzerTrainingUI.mindfulBreaths.text = String(mindfulBreathsCount) + " of " + String(totalBreaths);		
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
				
				inhalationTimeEnd = DC.objGame.patternSequence[whichPattern][subPattern][0] * 60;
				retentionTimeEnd = inhalationTimeEnd + DC.objGame.patternSequence[whichPattern][subPattern][1] * 60;
				exhalationTimeEnd = retentionTimeEnd + DC.objGame.patternSequence[whichPattern][subPattern][2] * 60;
				timeBetweenBreathsEnd = exhalationTimeEnd + DC.objGame.patternSequence[whichPattern][subPattern][3] * 60;
				
				buzzerTrainingUI.buzzerReason.text = "";
				
				buzzerTrainingUI.targetRR.text = String(roundNumber(3600/timeBetweenBreathsEnd,10));
				
				isBuzzing = 1;
				buzzCount = 30;
				numOfInhales = 0;
				numOfExhales = 0;	
				
				if (cycles >= 2) {
					
					totalBreaths++;
					
					if (whichPattern == 0) {
						breathsOnCurrentLevel++;
						
						if (breathsOnCurrentLevel == 6) {
							breathsOnCurrentLevel = 1;
							goodBreaths = 0;				
						}				
						
						if (breathsOnCurrentLevel == 5) {				
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
						}
					
					}
					
				}				
				
				//buzzerTrainingUI.status0.text = "New Breath Start";
			}
			
			if (breathTime == inhalationTimeEnd) {
				DC.objStartConnection.socket.writeUTFBytes("Buzz,0.10" + "\n");			
				DC.objStartConnection.socket.flush();
				isBuzzing = 1;
				buzzCount = 30;
				

			}	
			
			
			if (breathTime == exhalationTimeEnd) {
				DC.objStartConnection.socket.writeUTFBytes("Buzz,0.10" + "\n");			
				DC.objStartConnection.socket.flush();
				isBuzzing = 1;
				buzzCount = 40;
			}	
			
			if (breathTime == exhalationTimeEnd + 20) {
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
						
			breathTime = -180;
			hasInhaled = 0;
			hasExhaled = 0;
			numOfInhales = 0;
			numOfExhales = 0;
			takenFirstBreath = 0;
			whenInhaled = 0;
			whenExhaled = 0;
			buzzReason = 1;
			buzzerTrainingUI.mindfulBreaths.text = String(mindfulBreathsCount) + " of " + String(totalBreaths);	
			
		}
		
		function badPosture():void {			
			
			breathTime = -300;
			hasInhaled = 0;
			hasExhaled = 0;
			numOfInhales = 0;
			numOfExhales = 0;
			takenFirstBreath = 0;
			whenInhaled = 0;
			whenExhaled = 0;
			buzzReason = 2;
			
		}
		
		
		function backToBreathingAndPostureMenuHandler(evt:MouseEvent):void  {	
			
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
			
			if (enterFrameCount < 60) {
				return;				
			}
			
			enterFrameCount = 0;
					
			trainingDuration--;
			
			buzzerTrainingUI.elapsedTime.text = DC.objGame.convertTime(trainingDuration);			
					
				
			if (DC.objLiveGraph.postureIsGood == 1) {
				uprightPostureTime++;
			}
			
			if (prevPostureState == 1) {
				if (DC.objLiveGraph.postureIsGood == 0) {
					slouchesCount++;					
				}
			}
			
			buzzerTrainingUI.timeUpright.text = String(uprightPostureTime) + " of " + String(gameSetTime - trainingDuration);
			buzzerTrainingUI.slouches.text = String(slouchesCount);								
			
			prevPostureState = DC.objLiveGraph.postureIsGood;
			
			
			
			if (trainingDuration == 0) {
				
				buzzerTrainingUI.sessionCompleteIndicator.visible = true;
				
				clearBuzzerTraining();							
				
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
			
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			
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
				DC.objLiveGraph.postureUI.postureSelector.postureLevel1.selected = true;
				DC.objLiveGraph.postureRange = 0.15;
			}
			
			else if (buzzerTrainingUI.postureResponse.level2.selected == true) {
				DC.objLiveGraph.postureUI.postureSelector.postureLevel2.selected = true;
				DC.objLiveGraph.postureRange = 0.10;
			}
			
			else if (buzzerTrainingUI.postureResponse.level3.selected == true) {
				DC.objLiveGraph.postureUI.postureSelector.postureLevel3.selected = true;
				DC.objLiveGraph.postureRange = 0.05;
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
				DC.objLiveGraph.postureUI.breathSelector.breathLevel1.selected = true;
				DC.objLiveGraph.smoothBreathingCoefBaseLevel = 0.15;
				DC.objLiveGraph.reversalThreshold = 6;
				DC.objLiveGraph.birdIncrements = 24;
			}
			
			else if (buzzerTrainingUI.breathResponse.level2.selected == true) {
				DC.objLiveGraph.postureUI.breathSelector.breathLevel2.selected = true;
				DC.objLiveGraph.smoothBreathingCoefBaseLevel = 0.4;
				DC.objLiveGraph.reversalThreshold = 5;
				DC.objLiveGraph.birdIncrements = 20;
			}
			
			else if (buzzerTrainingUI.breathResponse.level3.selected == true) {
				DC.objLiveGraph.postureUI.breathSelector.breathLevel3.selected = true;
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
