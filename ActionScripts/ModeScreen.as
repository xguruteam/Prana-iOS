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
	import flash.net.Socket;
	import flash.net.XMLSocket;
	
	public class ModeScreen extends MovieClip {
		
		var startScreen1:StartScreen1 = new StartScreen1();	
		var startScreen2:StartScreen2 = new StartScreen2();
		var startScreen3:StartScreen3 = new StartScreen3();
		var startScreen4:StartScreen4 = new StartScreen4();
		var DC:Main;
		
		var VTLauncher1:VisualTrainingLauncher1 = new VisualTrainingLauncher1();
		var VTLauncher2:VisualTrainingLauncher2 = new VisualTrainingLauncher2();
		
		
		public function ModeScreen(main:Main) {
			
			DC = main; //to have access to the document class	
			addChild(startScreen1);	
			addChild(startScreen2);	
			addChild(startScreen3);	
			addChild(startScreen4);	
			addChild(VTLauncher1);	
			addChild(VTLauncher2);	
			
			startScreen1.visible = true;
			startScreen2.visible = false;
			startScreen3.visible = false;
			startScreen4.visible = false;
			VTLauncher1.visible = false;
			VTLauncher2.visible = false;
			
			startScreen1.nextButton1.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);
			startScreen1.nextButton1.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			startScreen1.nextButton1.addEventListener(MouseEvent.MOUSE_UP,nextButton1Handler);
			startScreen1.nextButton1.buttonMode = true;	
			
			startScreen2.nextButton2.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);
			startScreen2.nextButton2.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			startScreen2.nextButton2.addEventListener(MouseEvent.MOUSE_UP,nextButton2Handler);
			startScreen2.nextButton2.buttonMode = true;				
			
			startScreen3.breathingAndPostureButton.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);
			startScreen3.breathingAndPostureButton.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			startScreen3.breathingAndPostureButton.addEventListener(MouseEvent.MOUSE_UP,breathingAndPostureButtonHandler);
			startScreen3.breathingAndPostureButton.buttonMode = true;
			
			startScreen3.bodyMeasurementsButton.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);
			startScreen3.bodyMeasurementsButton.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			startScreen3.bodyMeasurementsButton.addEventListener(MouseEvent.MOUSE_UP,bodyMeasurementsButtonHandler);
			startScreen3.bodyMeasurementsButton.buttonMode = true;		
			
			startScreen4.liveGraphButton.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);
			startScreen4.liveGraphButton.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			startScreen4.liveGraphButton.addEventListener(MouseEvent.MOUSE_UP,liveGraphButtonHandler);
			startScreen4.liveGraphButton.buttonMode = true;	
			
			startScreen4.visualTrainingButton.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);
			startScreen4.visualTrainingButton.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			startScreen4.visualTrainingButton.addEventListener(MouseEvent.MOUSE_UP,exerciseSelectionHandler);
			startScreen4.visualTrainingButton.buttonMode = true;	
			
			startScreen4.buzzerTrainingButton.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);
			startScreen4.buzzerTrainingButton.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			startScreen4.buzzerTrainingButton.addEventListener(MouseEvent.MOUSE_UP,exerciseSelectionHandler2);
			startScreen4.buzzerTrainingButton.buttonMode = true;
			
			startScreen4.passiveTrackingButton.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);
			startScreen4.passiveTrackingButton.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			startScreen4.passiveTrackingButton.addEventListener(MouseEvent.MOUSE_UP,passiveTrackingButtonHandler);
			startScreen4.passiveTrackingButton.buttonMode = true;
						
			startScreen4.backToMainMenuButton.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);
			startScreen4.backToMainMenuButton.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			startScreen4.backToMainMenuButton.addEventListener(MouseEvent.MOUSE_UP,backToMainMenuButtonHandler);
			startScreen4.backToMainMenuButton.buttonMode = true;				
			
						
			VTLauncher1.slowButton1.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);
			VTLauncher1.slowButton1.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			VTLauncher1.slowButton1.addEventListener(MouseEvent.MOUSE_UP,p1);
			VTLauncher1.slowButton1.buttonMode = true;
			
			VTLauncher1.meditationButton1.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);
			VTLauncher1.meditationButton1.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			VTLauncher1.meditationButton1.addEventListener(MouseEvent.MOUSE_UP,p2);
			VTLauncher1.meditationButton1.buttonMode = true;
			
			VTLauncher1.meditationButton2.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);
			VTLauncher1.meditationButton2.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			VTLauncher1.meditationButton2.addEventListener(MouseEvent.MOUSE_UP,p3);
			VTLauncher1.meditationButton2.buttonMode = true;
			
			VTLauncher1.focusButton1.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);
			VTLauncher1.focusButton1.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			VTLauncher1.focusButton1.addEventListener(MouseEvent.MOUSE_UP,p4);
			VTLauncher1.focusButton1.buttonMode = true;
			
			VTLauncher1.focusButton2.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);
			VTLauncher1.focusButton2.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			VTLauncher1.focusButton2.addEventListener(MouseEvent.MOUSE_UP,p5);
			VTLauncher1.focusButton2.buttonMode = true;
			
			VTLauncher1.focusButton3.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);
			VTLauncher1.focusButton3.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			VTLauncher1.focusButton3.addEventListener(MouseEvent.MOUSE_UP,p6);
			VTLauncher1.focusButton3.buttonMode = true;
			
			VTLauncher1.focusButton4.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);
			VTLauncher1.focusButton4.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			VTLauncher1.focusButton4.addEventListener(MouseEvent.MOUSE_UP,p7);
			VTLauncher1.focusButton4.buttonMode = true;
			
			VTLauncher1.focusButton5.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);
			VTLauncher1.focusButton5.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			VTLauncher1.focusButton5.addEventListener(MouseEvent.MOUSE_UP,p8);
			VTLauncher1.focusButton5.buttonMode = true;
			
			VTLauncher1.relaxButton1.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);
			VTLauncher1.relaxButton1.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			VTLauncher1.relaxButton1.addEventListener(MouseEvent.MOUSE_UP,p9);
			VTLauncher1.relaxButton1.buttonMode = true;
			
			VTLauncher1.relaxButton2.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);
			VTLauncher1.relaxButton2.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			VTLauncher1.relaxButton2.addEventListener(MouseEvent.MOUSE_UP,p10);
			VTLauncher1.relaxButton2.buttonMode = true;
			
			VTLauncher1.relaxButton3.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);
			VTLauncher1.relaxButton3.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			VTLauncher1.relaxButton3.addEventListener(MouseEvent.MOUSE_UP,p11);
			VTLauncher1.relaxButton3.buttonMode = true;
			
			VTLauncher1.relaxButton4.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);
			VTLauncher1.relaxButton4.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			VTLauncher1.relaxButton4.addEventListener(MouseEvent.MOUSE_UP,p12);
			VTLauncher1.relaxButton4.buttonMode = true;
			
			VTLauncher1.relaxButton5.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);
			VTLauncher1.relaxButton5.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			VTLauncher1.relaxButton5.addEventListener(MouseEvent.MOUSE_UP,p13);
			VTLauncher1.relaxButton5.buttonMode = true;
			
			VTLauncher1.sleepButton1.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);
			VTLauncher1.sleepButton1.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			VTLauncher1.sleepButton1.addEventListener(MouseEvent.MOUSE_UP,p14);
			VTLauncher1.sleepButton1.buttonMode = true;
			
			VTLauncher1.sleepButton2.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);
			VTLauncher1.sleepButton2.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			VTLauncher1.sleepButton2.addEventListener(MouseEvent.MOUSE_UP,p15);
			VTLauncher1.sleepButton2.buttonMode = true;
			
			VTLauncher1.sleepButton3.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);
			VTLauncher1.sleepButton3.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			VTLauncher1.sleepButton3.addEventListener(MouseEvent.MOUSE_UP,p16);
			VTLauncher1.sleepButton3.buttonMode = true;			
			
			VTLauncher1.backToBreathingAndPostureMenu.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);
			VTLauncher1.backToBreathingAndPostureMenu.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			VTLauncher1.backToBreathingAndPostureMenu.addEventListener(MouseEvent.MOUSE_UP,breathingAndPostureButtonHandler);
			VTLauncher1.backToBreathingAndPostureMenu.buttonMode = true;	
			
			VTLauncher2.backToExerciseSelectionScreen.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);
			VTLauncher2.backToExerciseSelectionScreen.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			VTLauncher2.backToExerciseSelectionScreen.addEventListener(MouseEvent.MOUSE_UP,exerciseSelectionHandler3);
			VTLauncher2.backToExerciseSelectionScreen.buttonMode = true;	
			
			VTLauncher2.pose1.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);			
			VTLauncher2.pose1.addEventListener(MouseEvent.MOUSE_UP,pose1ButtonHandler);
			VTLauncher2.pose1.buttonMode = true;				
			
			VTLauncher2.pose2.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);			
			VTLauncher2.pose2.addEventListener(MouseEvent.MOUSE_UP,pose2ButtonHandler);
			VTLauncher2.pose2.buttonMode = true;				
			
			VTLauncher2.pose3.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);			
			VTLauncher2.pose3.addEventListener(MouseEvent.MOUSE_UP,pose3ButtonHandler);
			VTLauncher2.pose3.buttonMode = true;	
			
			VTLauncher2.goToTrainingButton.addEventListener(MouseEvent.MOUSE_DOWN,clickButton);	
			VTLauncher2.goToTrainingButton.addEventListener(MouseEvent.MOUSE_UP,goToTrainingButtonHandler);
			VTLauncher2.goToTrainingButton.addEventListener(MouseEvent.ROLL_OUT,unclickButton);
			VTLauncher2.goToTrainingButton.buttonMode = true;				
			
			VTLauncher2.durationSelector.time1.addEventListener(MouseEvent.CLICK,durationSelectorHandler);
			VTLauncher2.durationSelector.time2.addEventListener(MouseEvent.CLICK,durationSelectorHandler);
			VTLauncher2.durationSelector.time3.addEventListener(MouseEvent.CLICK,durationSelectorHandler);
			VTLauncher2.durationSelector.time4.addEventListener(MouseEvent.CLICK,durationSelectorHandler);
			VTLauncher2.durationSelector.time5.addEventListener(MouseEvent.CLICK,durationSelectorHandler);
			VTLauncher2.durationSelector.time6.addEventListener(MouseEvent.CLICK,durationSelectorHandler);
			VTLauncher2.durationSelector.time7.addEventListener(MouseEvent.CLICK,durationSelectorHandler);
			VTLauncher2.durationSelector.time8.addEventListener(MouseEvent.CLICK,durationSelectorHandler);
			VTLauncher2.durationSelector.time9.addEventListener(MouseEvent.CLICK,durationSelectorHandler);
			VTLauncher2.durationSelector.time10.addEventListener(MouseEvent.CLICK,durationSelectorHandler);
			VTLauncher2.durationSelector.time11.addEventListener(MouseEvent.CLICK,durationSelectorHandler);
			VTLauncher2.durationSelector.time12.addEventListener(MouseEvent.CLICK,durationSelectorHandler);
					
		}		
		
		function p1(evt:MouseEvent)  {
			
			DC.objGame.whichPattern = 0;
			if (DC.appMode == 3) {
				DC.objGame.subPattern = DC.objGame.startSubPattern; //may 8th
			}
			else {
				DC.objGame.subPattern = 0;
			}
			postureSelectScreen();
			
		}
		
		function p2(evt:MouseEvent)  {
			
			DC.objGame.whichPattern = 1;	
			DC.objGame.subPattern = 0; //AUG 1st ADDED, THIS WAS MISSING! Was creating a bug
			postureSelectScreen();
			
		}

		function p3(evt:MouseEvent)  {
			
			DC.objGame.whichPattern = 2;
			DC.objGame.subPattern = 0;
			postureSelectScreen();
			
		}
		
		function p4(evt:MouseEvent)  {
			
			DC.objGame.whichPattern = 3;
			DC.objGame.subPattern = 0;
			postureSelectScreen();
			
		}
		
		function p5(evt:MouseEvent)  {
			
			DC.objGame.whichPattern = 4;
			DC.objGame.subPattern = 0;
			postureSelectScreen();
			
		}
		
		function p6(evt:MouseEvent)  {
			
			DC.objGame.whichPattern = 5;
			DC.objGame.subPattern = 0;
			postureSelectScreen();
			
		}
		
		function p7(evt:MouseEvent)  {
			
			DC.objGame.whichPattern = 6;
			DC.objGame.subPattern = 0;
			postureSelectScreen();
			
		}
		
		function p8(evt:MouseEvent)  {
			
			DC.objGame.whichPattern = 7;
			DC.objGame.subPattern = 0;
			postureSelectScreen();
			
		}
		
		function p9(evt:MouseEvent)  {
			
			DC.objGame.whichPattern = 8;
			DC.objGame.subPattern = 0;
			postureSelectScreen();
			
		}
		
		function p10(evt:MouseEvent)  {
			
			DC.objGame.whichPattern = 9;
			DC.objGame.subPattern = 0;
			postureSelectScreen();
			
		}
		
		function p11(evt:MouseEvent)  {
			
			DC.objGame.whichPattern = 10;
			DC.objGame.subPattern = 0;
			postureSelectScreen();
			
		}
		
		function p12(evt:MouseEvent)  {
			
			DC.objGame.whichPattern = 11;
			DC.objGame.subPattern = 0;
			postureSelectScreen();
			
		}
		
		function p13(evt:MouseEvent)  {
			
			DC.objGame.whichPattern = 12;
			DC.objGame.subPattern = 0;
			postureSelectScreen();
			
		}
		
		function p14(evt:MouseEvent)  {
			
			DC.objGame.whichPattern = 13;
			DC.objGame.subPattern = 0;
			postureSelectScreen();
			
		}
		
		function p15(evt:MouseEvent)  {
			
			DC.objGame.whichPattern = 14;
			DC.objGame.subPattern = 0;
			postureSelectScreen();
			
		}
		
		function p16(evt:MouseEvent)  {
			
			DC.objGame.whichPattern = 15;
			DC.objGame.subPattern = 0;
			postureSelectScreen();
			
		}
		
		function postureSelectScreen():void {			
			
			VTLauncher1.visible = false;
			VTLauncher2.visible = true;
			
			VTLauncher2.pose1.gotoAndStop(1);			
			VTLauncher2.pose2.gotoAndStop(1);
			VTLauncher2.pose3.gotoAndStop(1);
			
			DC.objGame.trainingPosture = 0;	
			DC.objGame.trainingDuration = 0;
			
			VTLauncher2.durationSelector.time1.selected = false;
			VTLauncher2.durationSelector.time2.selected = false;
			VTLauncher2.durationSelector.time3.selected = false;
			VTLauncher2.durationSelector.time4.selected = false;
			VTLauncher2.durationSelector.time5.selected = false;
			VTLauncher2.durationSelector.time6.selected = false;
			VTLauncher2.durationSelector.time7.selected = false;
			VTLauncher2.durationSelector.time8.selected = false;
			VTLauncher2.durationSelector.time9.selected = false;
			VTLauncher2.durationSelector.time10.selected = false;
			VTLauncher2.durationSelector.time11.selected = false;
			VTLauncher2.durationSelector.time12.selected = false;
			VTLauncher2.durationSelector.time13.selected = true;
			
			VTLauncher2.goToTrainingButton.visible = false;
			
		}
		
		function showGotoTrainingButton():void {
			
			if (DC.objGame.trainingPosture != 0 && DC.objGame.trainingDuration != 0) {
				VTLauncher2.goToTrainingButton.visible = true;
			}			
			
		}
				
				
		function pose1ButtonHandler(evt:MouseEvent)  {				
				
			VTLauncher2.pose1.gotoAndStop(2);			
			VTLauncher2.pose2.gotoAndStop(1);
			VTLauncher2.pose3.gotoAndStop(1);
			DC.objGame.trainingPosture = 1;
			showGotoTrainingButton();
		
			
		}
		
		function pose2ButtonHandler(evt:MouseEvent)  {				
				
			VTLauncher2.pose1.gotoAndStop(1);			
			VTLauncher2.pose2.gotoAndStop(2);
			VTLauncher2.pose3.gotoAndStop(1);
			DC.objGame.trainingPosture = 2;
			showGotoTrainingButton();
			
			
		}
		
		function pose3ButtonHandler(evt:MouseEvent)  {				
				
			VTLauncher2.pose1.gotoAndStop(1);			
			VTLauncher2.pose2.gotoAndStop(1);
			VTLauncher2.pose3.gotoAndStop(2);
			DC.objGame.trainingPosture = 3;
			showGotoTrainingButton();
			
		}
		
		
		function nextButton1Handler(evt:MouseEvent)  {				
				
			evt.currentTarget.gotoAndStop(1);	
			DC.objStartConnection.IPAddress = startScreen1.iP4.text;			
			
			startScreen1.visible = false;
			startScreen2.visible = true;	
			
		}
		
		function nextButton2Handler(evt:MouseEvent)  {				
				
			evt.currentTarget.gotoAndStop(1);	
			DC.objStartConnection.connectToPhone();	
			startScreen2.deviceConnectionStatus.text = "Attempting to connect....";			
		}
		
		
		function goToMainMenu():void {
			
			startScreen2.visible = false;
			startScreen3.visible = true;			
		}
		
		
		function goToTrainingButtonHandler(evt:MouseEvent):void {
			
			evt.currentTarget.gotoAndStop(1);
			
			VTLauncher2.durationSelector.time1.selected = false;
			VTLauncher2.durationSelector.time2.selected = false;
			VTLauncher2.durationSelector.time3.selected = false;
			VTLauncher2.durationSelector.time4.selected = false;
			VTLauncher2.durationSelector.time5.selected = false;
			VTLauncher2.durationSelector.time6.selected = false;
			VTLauncher2.durationSelector.time7.selected = false;
			VTLauncher2.durationSelector.time8.selected = false;
			VTLauncher2.durationSelector.time9.selected = false;
			VTLauncher2.durationSelector.time10.selected = false;
			VTLauncher2.durationSelector.time11.selected = false;
			VTLauncher2.durationSelector.time12.selected = false;
			VTLauncher2.durationSelector.time13.selected = true;			
			
			VTLauncher2.visible = false;			
			DC.removeChild(DC.objModeScreen);	
			
			if (DC.appMode == 2) {
				DC.addChild(DC.objGame);				
				DC.objGame.startMode();	
			}
			else if (DC.appMode == 3) {				
				DC.addChild(DC.objBuzzerTraining);				
				DC.objBuzzerTraining.startMode();	
			}
			else if (DC.appMode == 1) {				
				DC.addChild(DC.objPassiveTracking);				
				DC.objPassiveTracking.startMode();	
			}
			
		} 
			
		
		function backToMainMenuButtonHandler(evt:MouseEvent):void {
			
			startScreen3.visible = true;
			startScreen4.visible = false;			
			
		}
		
		function breathingAndPostureButtonHandler(evt:MouseEvent)  {			
					
			evt.currentTarget.gotoAndStop(1);
			
			startScreen3.visible = false;
			startScreen4.visible = true;
			VTLauncher1.visible = false;
			
			VTLauncher2.durationSelector.time1.selected = false;
			VTLauncher2.durationSelector.time2.selected = false;
			VTLauncher2.durationSelector.time3.selected = false;
			VTLauncher2.durationSelector.time4.selected = false;
			VTLauncher2.durationSelector.time5.selected = false;
			VTLauncher2.durationSelector.time6.selected = false;
			VTLauncher2.durationSelector.time7.selected = false;
			VTLauncher2.durationSelector.time8.selected = false;
			VTLauncher2.durationSelector.time9.selected = false;
			VTLauncher2.durationSelector.time10.selected = false;
			VTLauncher2.durationSelector.time11.selected = false;
			VTLauncher2.durationSelector.time12.selected = false;
			VTLauncher2.durationSelector.time13.selected = true;
			
			DC.objGame.trainingDuration = 0;
			
		}
		
		
		function bodyMeasurementsButtonHandler(evt:MouseEvent)  {				
				
			evt.currentTarget.gotoAndStop(1);	
			DC.removeChild(DC.objModeScreen);				
			DC.addChild(DC.objBodyMeasurements);
			DC.appMode = 5;	
			DC.objBodyMeasurements.startMode();	
			
		}		
		
		function liveGraphButtonHandler(evt:MouseEvent)  {	
			
			evt.currentTarget.gotoAndStop(1);	
			DC.removeChild(DC.objModeScreen);
			DC.addChild(DC.objLiveGraph);
			DC.appMode = 1;				
			DC.objLiveGraph.startMode();
		}		
		
		
		function exerciseSelectionHandler(evt:MouseEvent)  {				
				
			evt.currentTarget.gotoAndStop(1);		
				
			startScreen4.visible = false;
			VTLauncher1.visible = true;
			VTLauncher2.visible = false;	
			
			VTLauncher1.sleepButton1.visible = true;
			VTLauncher1.sleepButton2.visible = true;
			VTLauncher1.sleepButton3.visible = true;
			VTLauncher1.label1.visible = true;
			VTLauncher1.label2.visible = true;
			VTLauncher1.label3.visible = true;
			VTLauncher1.label4.visible = true;
			
			DC.appMode = 2;	
			
		}
		
		function exerciseSelectionHandler3(evt:MouseEvent)  {				
				
			evt.currentTarget.gotoAndStop(1);		
				
			startScreen4.visible = false;
			VTLauncher1.visible = true;
			VTLauncher2.visible = false;	
			
			if (DC.appMode == 2) {
				
				VTLauncher1.sleepButton1.visible = true;
				VTLauncher1.sleepButton2.visible = true;
				VTLauncher1.sleepButton3.visible = true;
				VTLauncher1.label1.visible = true;
				VTLauncher1.label2.visible = true;
				VTLauncher1.label3.visible = true;
				VTLauncher1.label4.visible = true;
			}
			else if (DC.appMode == 3) {
				
				VTLauncher1.sleepButton1.visible = false;
				VTLauncher1.sleepButton2.visible = false;
				VTLauncher1.sleepButton3.visible = false;
				VTLauncher1.label1.visible = false;
				VTLauncher1.label2.visible = false;
				VTLauncher1.label3.visible = false;
				VTLauncher1.label4.visible = false;

			}
			
			else if (DC.appMode == 1) {				
				
				startScreen4.visible = true;
				VTLauncher1.visible = false;
				VTLauncher2.visible = false;			
				
			}
			
		}
		
		function passiveTrackingButtonHandler(evt:MouseEvent)  {	
			
			evt.currentTarget.gotoAndStop(1);
			DC.appMode = 1;
			startScreen4.visible = false;
			postureSelectScreen();
		}
		
		
		function exerciseSelectionHandler2(evt:MouseEvent)  {				
				
			evt.currentTarget.gotoAndStop(1);		
				
			startScreen4.visible = false;
			VTLauncher1.visible = true;
			VTLauncher2.visible = false;
			
			//sleep patterns not available for buzzer training due to the retention
			VTLauncher1.sleepButton1.visible = false;
			VTLauncher1.sleepButton2.visible = false;
			VTLauncher1.sleepButton3.visible = false;
			VTLauncher1.label1.visible = false;
			VTLauncher1.label2.visible = false;
			VTLauncher1.label3.visible = false;
			VTLauncher1.label4.visible = false;
			
			DC.appMode = 3;	
			
		}
		
		function durationSelectorHandler(evt:MouseEvent)  {			
			
			if (VTLauncher2.durationSelector.time1.selected == 1) {
				DC.objGame.trainingDuration = 120;
			}
			else if (VTLauncher2.durationSelector.time2.selected == 1) {
				DC.objGame.trainingDuration = 180;
			}
			else if (VTLauncher2.durationSelector.time3.selected == 1) {
				DC.objGame.trainingDuration = 240;
			}	
			else if (VTLauncher2.durationSelector.time4.selected == 1) {
				DC.objGame.trainingDuration = 300;
			}					
			else if (VTLauncher2.durationSelector.time5.selected == 1) {
				DC.objGame.trainingDuration = 360;
			}					
			else if (VTLauncher2.durationSelector.time6.selected == 1) {
				DC.objGame.trainingDuration = 420;
			}					
			else if (VTLauncher2.durationSelector.time7.selected == 1) {
				DC.objGame.trainingDuration = 480;
			}					
			else if (VTLauncher2.durationSelector.time8.selected == 1) {
				DC.objGame.trainingDuration = 540;
			}					
			else if (VTLauncher2.durationSelector.time9.selected == 1) {
				DC.objGame.trainingDuration = 600;
			}					
			else if (VTLauncher2.durationSelector.time10.selected == 1) {
				DC.objGame.trainingDuration = 720;
			}					
			else if (VTLauncher2.durationSelector.time11.selected == 1) {
				DC.objGame.trainingDuration = 900;
			}					
			else if (VTLauncher2.durationSelector.time12.selected == 1) {
				DC.objGame.trainingDuration = 1200;
			}	
			else if (VTLauncher2.durationSelector.time13.selected == 1) {
				DC.objGame.trainingDuration = 1200;
			}
			
			showGotoTrainingButton();
					
		}
		
		
		
		function unclickButton(evt:MouseEvent)  {	
		
			evt.currentTarget.gotoAndStop(1);
		}
		
		function clickButton(evt:MouseEvent)  {	
		
			evt.currentTarget.gotoAndStop(2);
		}
		
		
		function startData():void {			
			
			DC.objStartConnection.socket.writeUTFBytes("start20hzdata" + "\n");				
			DC.objStartConnection.socket.flush();	
			
		}
		
		function stopData():void {			
			
			DC.objStartConnection.socket.writeUTFBytes("stopData" + "\n");			
			DC.objStartConnection.socket.flush();	
			
		}
		

	}
	
}
