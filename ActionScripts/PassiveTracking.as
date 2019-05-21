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
		var isBuzzing:int = 0;
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
						
			addChild(passiveTrackingUI);		
			
			passiveTrackingUI.postureState.gotoAndStop(1);
		}		
			
		
		function startMode():void  {				
					
			DC.objLiveGraph.startMode(); //Need this here because user needs to be able set posture before timer starts!
			
			passiveTrackingUI.buzzerForPosture.level1.selected = true;
			useBuzzerForPosture = 1;
			
			passiveTrackingUI.averageRR.text = "";
			passiveTrackingUI.currentRR.text = "";
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
								
				isBuzzing = 0;
				buzzCount = 0;
				addEventListener(Event.ENTER_FRAME, enterFrameHandler);
				
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
		
		
		function enterFrameHandler(e:Event):void {			
			
			passiveTrackingUI.currentRR.text = String(DC.objLiveGraph.respRate);	
			
			passiveTrackingUI.howManyBreaths.text = String(DC.objLiveGraph.breathCount);
			passiveTrackingUI.averageRR.text = String(DC.objLiveGraph.avgRespRate);
			
			timerHandler();
			
			if (buzzCount > 0) {
				
				buzzCount--;
				
				if (buzzCount == 0) {
					isBuzzing = 0;
					DC.objLiveGraph.dampingLevel = 0;
					DC.objLiveGraph.postureAttenuatorLevel = 0;
				}		
				
			}					
						
			
			if (DC.objLiveGraph.postureIsGood == 0 && useBuzzerForPosture == 1 && isBuzzing == 0)  {
				
				DC.objStartConnection.socket.writeUTFBytes("Buzz,0.5" + "\n");			
				DC.objStartConnection.socket.flush();	
				isBuzzing = 1;
				buzzCount = 300;
			}
										
		}	
		

		
		function backToBreathingAndPostureMenuHandler(evt:MouseEvent):void  {	
			
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
			
			if (enterFrameCount < 60) {
				return;				
			}
			
			enterFrameCount = 0;
					
			trainingDuration--;
			
			passiveTrackingUI.elapsedTime.text = DC.objGame.convertTime(trainingDuration);			
					
				
			if (DC.objLiveGraph.postureIsGood == 1) {
				uprightPostureTime++;
			}
			
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
			
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			
			isBuzzing = 0;
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
