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
	  
	
	public class PassiveTracking extends MovieClip {		
		
		var DC:Main;	
		var passiveTrackingUI:PassiveTrackingUI = new PassiveTrackingUI();		
		//var isBuzzing:int = 0; May 19th  REMOVE (we are now using isBuzzing in BuzzerTraining class as a global variable)
		var buzzCount:int = 0;		
		var hasUprightBeenSet:int = 0;
		var trainingDuration:int = 0;
		var slouchesCount:int = 0;
		var uprightPostureTime:int = 0;		
		var gameSetTime:int = 0;
		var prevPostureState:int = 0;
		var enterFrameCount:int = 0;		
		var totalBreaths:int = 0;			
		var useBuzzerForPosture:int = 1;
		var isPassiveTrackingActive:int = 0;  // May 19th, ADDED THIS LINE
		var currentSlouchPostureTime:int = 0; // May 31st ADDED THIS LINE
		var buzzTimeTrigger:int = 0;  // May 31st ADDED THIS LINE
		//var secondsElapsed:int = 0; //JULY 13th:CHANGE1b  REMOVE THIS LINE
	
		
		public function PassiveTracking(main:Main) {
				
			DC = main; //to have access to the document class	
			
			passiveTrackingUI.backToBreathingAndPostureMenu.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);
			passiveTrackingUI.backToBreathingAndPostureMenu.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			passiveTrackingUI.backToBreathingAndPostureMenu.addEventListener(MouseEvent.MOUSE_UP,backToBreathingAndPostureMenuHandler);
			passiveTrackingUI.backToBreathingAndPostureMenu.buttonMode = true;
					
			passiveTrackingUI.startPassiveTrackingButton.addEventListener(MouseEvent.MOUSE_UP,startPassiveTrackingButtonHandler);
			passiveTrackingUI.startPassiveTrackingButton.buttonMode = true;
			
			passiveTrackingUI.setUprightButton.addEventListener(MouseEvent.MOUSE_DOWN,setUprightButtonHandler);
			passiveTrackingUI.setUprightButton.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			passiveTrackingUI.setUprightButton.addEventListener(MouseEvent.MOUSE_UP,unclickButton);		
			passiveTrackingUI.setUprightButton.buttonMode = true;	
			
			passiveTrackingUI.postureResponse.level1.addEventListener(MouseEvent.CLICK,postureSelectorHandler);
			passiveTrackingUI.postureResponse.level2.addEventListener(MouseEvent.CLICK,postureSelectorHandler);
			passiveTrackingUI.postureResponse.level3.addEventListener(MouseEvent.CLICK,postureSelectorHandler);	
			
			passiveTrackingUI.breathResponse.level1.addEventListener(MouseEvent.CLICK,breathSelectorHandler);
			passiveTrackingUI.breathResponse.level2.addEventListener(MouseEvent.CLICK,breathSelectorHandler);
			passiveTrackingUI.breathResponse.level3.addEventListener(MouseEvent.CLICK,breathSelectorHandler);
			
			passiveTrackingUI.buzzerForPosture.level1.addEventListener(MouseEvent.CLICK,buzzerForPostureHandler);
			passiveTrackingUI.buzzerForPosture.level2.addEventListener(MouseEvent.CLICK,buzzerForPostureHandler);
						
			passiveTrackingUI.buzzTimeSelector.buzz0.addEventListener(MouseEvent.CLICK,buzzTimeSelectorHandler);  // May 31st ADDED THIS LINE
			passiveTrackingUI.buzzTimeSelector.buzz3.addEventListener(MouseEvent.CLICK,buzzTimeSelectorHandler);  // May 31st ADDED THIS LINE
			passiveTrackingUI.buzzTimeSelector.buzz5.addEventListener(MouseEvent.CLICK,buzzTimeSelectorHandler);  // May 31st ADDED THIS LINE
			passiveTrackingUI.buzzTimeSelector.buzz10.addEventListener(MouseEvent.CLICK,buzzTimeSelectorHandler);  // May 31st ADDED THIS LINE
			passiveTrackingUI.buzzTimeSelector.buzz15.addEventListener(MouseEvent.CLICK,buzzTimeSelectorHandler);  // May 31st ADDED THIS LINE
			passiveTrackingUI.buzzTimeSelector.buzz20.addEventListener(MouseEvent.CLICK,buzzTimeSelectorHandler);  // May 31st ADDED THIS LINE
			passiveTrackingUI.buzzTimeSelector.buzz30.addEventListener(MouseEvent.CLICK,buzzTimeSelectorHandler);  // May 31st ADDED THIS LINE
						
			addChild(passiveTrackingUI);		
			
			passiveTrackingUI.postureState.gotoAndStop(1);
		}		
			
		
		function startMode():void  {			
			
			addChild(DC.objLiveGraph); //***May 31st ADDED
			DC.objLiveGraph.scaleX = 0.5;  //***May 31st ADDED
			DC.objLiveGraph.scaleY = 0.5;  //***May 31st ADDED
			DC.objLiveGraph.postureUI.visible = false;  //***May 31st ADDED
			
			currentSlouchPostureTime = 0; //***May 31st ADDED
			//secondsElapsed = 0; //JULY 13th:CHANGE1b  REMOVE THIS LINE
			passiveTrackingUI.lastMinuteEI.text = ""; //***May 31st ADDED
			passiveTrackingUI.realTimeEI.text = "";//***May 31st ADDED
			passiveTrackingUI.sessionAvgEI.text = "";//***May 31st ADDED			
					
			DC.objLiveGraph.startMode(); //Need this here because user needs to be able set posture before timer starts!
			
			passiveTrackingUI.buzzerForPosture.level1.selected = true;
			useBuzzerForPosture = 1;
			
			passiveTrackingUI.buzzTimeSelector.buzz5.selected = true; // May 31st ADDED THIS LINE
			buzzTimeTrigger = 5; // May 31st ADDED THIS LINE
			
			passiveTrackingUI.averageRR.text = "";
			passiveTrackingUI.currentRR.text = "";
			passiveTrackingUI.oneMinuteRR.text = ""; //JULY 13th:NEW1d
			passiveTrackingUI.howManyBreaths.text = "";
			
			if (DC.objGame.trainingPosture == 1) {
				passiveTrackingUI.postureType.text = "LOWER BACK SEATED";
			}
			else if (DC.objGame.trainingPosture == 2) {
				passiveTrackingUI.postureType.text = "UPPER BACK SEATED";
			}
			
			else if (DC.objGame.trainingPosture == 3) {
				passiveTrackingUI.postureType.text = "UPPER BACK STANDING";
			}
						
			slouchesCount = 0;			
			uprightPostureTime = 0;
			hasUprightBeenSet = 0;
			totalBreaths = 0;			
			
			trainingDuration = DC.objGame.trainingDuration;
			gameSetTime = trainingDuration;		
			
			passiveTrackingUI.timeUpright.text = String("--");
			passiveTrackingUI.slouches.text = String(slouchesCount);		
			
			passiveTrackingUI.uprightPostureNotification.visible = true;		
			passiveTrackingUI.elapsedTime.visible = false;
			
			passiveTrackingUI.backToBreathingAndPostureMenu.visible = true;
			
			passiveTrackingUI.sessionCompleteIndicator.visible = false;
			passiveTrackingUI.startPassiveTrackingButton.visible = false;
			
			passiveTrackingUI.startPassiveTrackingButton.gotoAndStop(1);			
			
			if (DC.objLiveGraph.postureUI.postureSelector.postureLevel1.selected == true) {				
				passiveTrackingUI.postureResponse.level1.selected = true;
			}
			else if (DC.objLiveGraph.postureUI.postureSelector.postureLevel2.selected == true) {				
				passiveTrackingUI.postureResponse.level2.selected = true;
			}
			else if (DC.objLiveGraph.postureUI.postureSelector.postureLevel3.selected == true) {				
				passiveTrackingUI.postureResponse.level3.selected = true;
			}					
				
			
			if (DC.objLiveGraph.postureUI.breathSelector.breathLevel1.selected == true) {
				passiveTrackingUI.breathResponse.level1.selected = true;
			}
			else if (DC.objLiveGraph.postureUI.breathSelector.breathLevel2.selected == true) {
				passiveTrackingUI.breathResponse.level2.selected = true;
			}
			else if (DC.objLiveGraph.postureUI.breathSelector.breathLevel3.selected == true) {
				passiveTrackingUI.breathResponse.level3.selected = true;
			}					
			
		}
		
		
		function startPassiveTrackingButtonHandler(evt:MouseEvent):void  {			
			
			if (passiveTrackingUI.startPassiveTrackingButton.currentFrame == 1) {		
				
				passiveTrackingUI.backToBreathingAndPostureMenu.visible = false; //You MUST end the session first before the back button re-appears.
				
				passiveTrackingUI.startPassiveTrackingButton.gotoAndStop(2);	
								
				DC.objBuzzerTraining.isBuzzing = 0; //May 19th Changed
				buzzCount = 0;
				//addEventListener(Event.ENTER_FRAME, enterFrameHandler);  // May 19th, REMOVED THIS LINE
				isPassiveTrackingActive = 1; // May 19th, ADDED THIS LINE
				
				DC.objLiveGraph.whenBreathsEnd = [];
				DC.objLiveGraph.whenBreathsEnd[0] = 0;
				DC.objLiveGraph.breathCount = 0;
				DC.objLiveGraph.timeElapsed = 0;
				DC.objLiveGraph.respRate = 0;
				DC.objLiveGraph.avgRespRate = 0;				
				
			}
			
			else if (passiveTrackingUI.startPassiveTrackingButton.currentFrame == 2) {
				
				clearPassiveTracking();
			
			}
		}		
		
		
		//function enterFrameHandler(e:Event):void {   May 19th, REMOVED THIS LINE
		  function passiveTrackingMainLoop():void { //May 19th, ADDED THIS LINE
			
			passiveTrackingUI.currentRR.text = String(DC.objLiveGraph.respRate);	
			  
			if (DC.objLiveGraph.timeElapsed >= 60) { //JULY 13th:NEW1d
				passiveTrackingUI.oneMinuteRR.text = String(DC.objLiveGraph.calculateOneMinuteRespRate()); //JULY 13th:NEW1d
			} //JULY 13th:NEW1d
			
			passiveTrackingUI.howManyBreaths.text = String(DC.objLiveGraph.breathCount);
			passiveTrackingUI.averageRR.text = String(DC.objLiveGraph.avgRespRate);
			
			timerHandler();
			
			if (buzzCount > 0) {
				
				buzzCount--; 
				
				//if (buzzCount == 0) { //May 19th REMOVED
					//DC.objBuzzerTraining.isBuzzing = 0; May 19th REMOVED
					//DC.objLiveGraph.dampingLevel = 0;  May 19th REMOVED
					//DC.objLiveGraph.postureAttenuatorLevel = 0;  May 19th REMOVED
				//}		
				
			}					
						
			
			if (buzzCount == 0 && DC.objLiveGraph.postureIsGood == 0 && useBuzzerForPosture == 1 && DC.objBuzzerTraining.isBuzzing == 0 && currentSlouchPostureTime >= buzzTimeTrigger)  { //May 31st Changed
				
				DC.objStartConnection.socket.writeUTFBytes("Buzz,1" + "\n"); //May 19th Changed			
				DC.objStartConnection.socket.flush();	
				DC.objBuzzerTraining.isBuzzing = 1; //May 19th Changed
				buzzCount = 150; //May 19th Change
			}
			
			if (buzzCount == 120) { //May 19th ADDED LINE				
			
				DC.objStartConnection.socket.writeUTFBytes("Buzz,1" + "\n"); //May 19th ADDED LINE				
				DC.objStartConnection.socket.flush(); //May 19th ADDED LINE		
				
			} //May 19th ADDED LINE	
				
			if (buzzCount == 90) { //May 19th ADDED LINE	
				DC.objBuzzerTraining.isBuzzing = 0; //May 19th ADDED LINE
				DC.objLiveGraph.dampingLevel = 0; //May 19th ADDED LINE
				DC.objLiveGraph.postureAttenuatorLevel = 0; //May 19th ADDED LINE
			} //May 19th ADDED LINE
										
		}	
		

		
		function backToBreathingAndPostureMenuHandler(evt:MouseEvent):void  {	
			
			DC.objLiveGraph.postureUI.visible = true;  //May 31st ADDED, YOU may not need this Luccas, in BT and PT, I hide the postureUI when displaying the live graph (because the postureUI component is part of Live graph but unecessary when viewed in BT and PT, because those already separately display the posture details), but you probably organized the structure differently
			DC.objLiveGraph.scaleX = 1;  //***May 31st ADDED  YOU may not need this Luccas
			DC.objLiveGraph.scaleY = 1;  //***May 31st ADDED  YOU may not need this Luccas
			
			
			DC.removeChild(DC.objPassiveTracking);
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
		
		
				
		function timerHandler():void {		
			
			enterFrameCount++;
			
			if (enterFrameCount < 20) {  //May 19th, changed from 60 to 20
				return;				
			}
			
			enterFrameCount = 0;
			
			if (DC.objLiveGraph.EIRatio.length > 0) {  //May 31st ADDED
				passiveTrackingUI.realTimeEI.text = String(DC.objLiveGraph.EIRatio[DC.objLiveGraph.EIRatio.length-1][0]);   //May 31st ADDED
				passiveTrackingUI.sessionAvgEI.text = String(roundNumber(DC.objLiveGraph.EIAvgSessionRatio/DC.objLiveGraph.EIRatio.length,10));   //May 31st ADDED
			}
			
			//secondsElapsed++;  //JULY 13th:CHANGE1b  REMOVE THIS LINE
			
			if (DC.objLiveGraph.timeElapsed >= 60) {  //JULY 13th:CHANGE1b 
				//secondsElapsed = 0; //JULY 13th:CHANGE1b  REMOVE THIS LINE
				passiveTrackingUI.lastMinuteEI.text = String(DC.objLiveGraph.EI1Minute); //JULY 13th:CHANGE1b, this is a global variable now in LiveGraph class
			} 
			
					 
			trainingDuration--;
			
			passiveTrackingUI.elapsedTime.text = DC.objGame.convertTime(trainingDuration);			
					
				
			if (DC.objLiveGraph.postureIsGood == 1) {
				uprightPostureTime++;
				currentSlouchPostureTime = 0; // May 31st ADDED THIS 
			}
			else {  // May 31st ADDED THIS 
				currentSlouchPostureTime++;  // May 31st ADDED THIS 
			}  // May 31st ADDED THIS 
			
			
			if (prevPostureState == 1) {
				if (DC.objLiveGraph.postureIsGood == 0) {
					slouchesCount++;					
				}
			}
			
			passiveTrackingUI.timeUpright.text = String(uprightPostureTime) + " of " + String(gameSetTime - trainingDuration);
			passiveTrackingUI.slouches.text = String(slouchesCount);								
			
			prevPostureState = DC.objLiveGraph.postureIsGood;
			
			
			
			if (trainingDuration == 0) {
				
				passiveTrackingUI.sessionCompleteIndicator.visible = true;
				
				clearPassiveTracking();							
				
			}
			
		}	
		
		
		function setUprightButtonHandler(evt:MouseEvent)  {	
			
			DC.objLiveGraph.learnUprightAngleHandler(evt);
			
			if (hasUprightBeenSet == 0) {
				
				uprightHasBeenSetHandler();				
				
			}				
			
		}
		
		function uprightHasBeenSetHandler():void {
			
			passiveTrackingUI.startPassiveTrackingButton.visible = true;
			passiveTrackingUI.uprightPostureNotification.visible = false;
			passiveTrackingUI.elapsedTime.visible = true;
			passiveTrackingUI.elapsedTime.text = DC.objGame.convertTime(trainingDuration);
			hasUprightBeenSet = 1;
						
		}
		
		
		function clearPassiveTracking():void  {				
			
			//removeEventListener(Event.ENTER_FRAME, enterFrameHandler);  // May 19th, REMOVED THIS LINE
			isPassiveTrackingActive = 0; // May 19th, ADDED THIS LINE
			
			DC.objBuzzerTraining.isBuzzing = 0; //May 19th Changed
			buzzCount = 0;				
			prevPostureState = 0;
			DC.objModeScreen.stopData();			
			
			passiveTrackingUI.startPassiveTrackingButton.visible = false;
			passiveTrackingUI.backToBreathingAndPostureMenu.visible = true; 
		}
		
		
		function postureSelectorHandler(evt:MouseEvent)  {
			
			if (passiveTrackingUI.postureResponse.level1.selected == true) {
				DC.objLiveGraph.postureUI.postureSelector.postureLevel1.selected = true;
				DC.objLiveGraph.postureRange = 0.15;
			}
			
			else if (passiveTrackingUI.postureResponse.level2.selected == true) {
				DC.objLiveGraph.postureUI.postureSelector.postureLevel2.selected = true;
				DC.objLiveGraph.postureRange = 0.10;
			}
			
			else if (passiveTrackingUI.postureResponse.level3.selected == true) {
				DC.objLiveGraph.postureUI.postureSelector.postureLevel3.selected = true;
				DC.objLiveGraph.postureRange = 0.05;
			}
			
		}
		
		
		function buzzTimeSelectorHandler(evt:MouseEvent)  {  // May 31st ADDED THIS LINE
			
			if (passiveTrackingUI.buzzTimeSelector.buzz0.selected == true) {  // May 31st ADDED THIS LINE				
				buzzTimeTrigger = 0; // May 31st ADDED THIS LINE
			}	 // May 31st ADDED THIS LINE
			
			else if (passiveTrackingUI.buzzTimeSelector.buzz3.selected == true) {	 // May 31st ADDED THIS LINE			
				buzzTimeTrigger = 3; // May 31st ADDED THIS LINE
			}	 // May 31st ADDED THIS LINE
			
			else if (passiveTrackingUI.buzzTimeSelector.buzz5.selected == true) { // May 31st ADDED THIS LINE				
				buzzTimeTrigger = 5; // May 31st ADDED THIS LINE
			}	 // May 31st ADDED THIS LINE
			
			else if (passiveTrackingUI.buzzTimeSelector.buzz10.selected == true) {	 // May 31st ADDED THIS LINE			
				buzzTimeTrigger = 10; // May 31st ADDED THIS LINE
			}	 // May 31st ADDED THIS LINE
			
			else if (passiveTrackingUI.buzzTimeSelector.buzz15.selected == true) {	 // May 31st ADDED THIS LINE			
				buzzTimeTrigger = 15; // May 31st ADDED THIS LINE
			}	 // May 31st ADDED THIS LINE
			
			else if (passiveTrackingUI.buzzTimeSelector.buzz20.selected == true) {	 // May 31st ADDED THIS LINE			
				buzzTimeTrigger = 20; // May 31st ADDED THIS LINE
			}	 // May 31st ADDED THIS LINE
			
			else if (passiveTrackingUI.buzzTimeSelector.buzz30.selected == true) {	 // May 31st ADDED THIS LINE			
				buzzTimeTrigger = 30; // May 31st ADDED THIS LINE
			}	 // May 31st ADDED THIS LINE			
			
		}	 // May 31st ADDED THIS LINE	
		
		
		function buzzerForPostureHandler(evt:MouseEvent)  {
			
			if (passiveTrackingUI.buzzerForPosture.level1.selected == true) {
				useBuzzerForPosture = 1;
			}
			else if (passiveTrackingUI.buzzerForPosture.level2.selected == true) {
				useBuzzerForPosture = 0;
			}
				
		}
		
		
		
		function breathSelectorHandler(evt:MouseEvent)  {
			
			if (passiveTrackingUI.breathResponse.level1.selected == true) {
				DC.objLiveGraph.postureUI.breathSelector.breathLevel1.selected = true;
				DC.objLiveGraph.smoothBreathingCoefBaseLevel = 0.15;
				DC.objLiveGraph.reversalThreshold = 6;
				DC.objLiveGraph.birdIncrements = 24;
			}
			
			else if (passiveTrackingUI.breathResponse.level2.selected == true) {
				DC.objLiveGraph.postureUI.breathSelector.breathLevel2.selected = true;
				DC.objLiveGraph.smoothBreathingCoefBaseLevel = 0.4;
				DC.objLiveGraph.reversalThreshold = 5;
				DC.objLiveGraph.birdIncrements = 20;
			}
			
			else if (passiveTrackingUI.breathResponse.level3.selected == true) {
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
