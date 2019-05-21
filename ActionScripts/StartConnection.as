package  {
	

	import flash.display.MovieClip;	
	import flash.net.Socket;
	import flash.net.XMLSocket;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.DataEvent;
	  
	
	public class StartConnection extends MovieClip {
		
		var sensorData:String = "";
		var DC:Main;					
		var socket:Socket = new Socket();
		var IPAddress:String;
		
		
		public function StartConnection(main:Main) {
				
			DC = main; //to have access to the document class			
		}
			
			
		public function connectToPhone():void {					
			
			socket.addEventListener(ProgressEvent.SOCKET_DATA,testConnection);
			socket.addEventListener(Event.CONNECT, connectHandler);
			//IPAddress = "172.20.10.8";
			//IPAddress = "192.168.1.104";
			//IPAddress = "192.168.1.146";
			socket.connect(IPAddress, 12345);				
			
		}
		
			 
		
		public function connectHandler(event:Event):void {	
			
			DC.objStartConnection.socket.writeUTFBytes("start20hzdata" + "\n");				
			DC.objStartConnection.socket.flush();	
		}
		
		
		function testConnection(e:ProgressEvent):void {
			
			sensorData = socket.readUTFBytes(socket.bytesAvailable);				
				
			socket.removeEventListener(ProgressEvent.SOCKET_DATA,testConnection);
			socket.addEventListener(ProgressEvent.SOCKET_DATA,dataArrived);
			
			DC.objModeScreen.startScreen2.deviceConnectionStatus.text = "Connection Successful";
			
			DC.objModeScreen.goToMainMenu();
			
			socket.writeUTFBytes("stopData" + "\n");				
			socket.flush();				
			
			
			
		}
						

			
		function dataArrived(e:ProgressEvent):void
		{				
			
			var sensorDataAsArray:Array = new Array;
			var sensorDataVerified:Array = new Array;			
			
			sensorData = socket.readUTFBytes(socket.bytesAvailable);			
			sensorDataAsArray = sensorData.split(',');		
			
			//DC.objLiveGraph.testUI.indicator4.txt1.text = String(sensorData);			
				
			var a:int = sensorDataAsArray.indexOf("20hz");
		
			if (a != -1) {
				sensorDataVerified[0] = sensorDataAsArray[a];
				sensorDataVerified[1] = sensorDataAsArray[a+1];
				sensorDataVerified[2] = sensorDataAsArray[a+2];
				sensorDataVerified[3] = sensorDataAsArray[a+3];
				sensorDataVerified[4] = sensorDataAsArray[a+4];
				sensorDataVerified[5] = sensorDataAsArray[a+5];
				sensorDataVerified[6] = sensorDataAsArray[a+6];
				
				if (DC.appMode == 1 || DC.appMode == 2 || DC.appMode == 3) {
					DC.objLiveGraph.processBreathingandPosture(sensorDataVerified);	
				}
				else if (DC.appMode == 5) {					
					DC.objBodyMeasurements.storeSensorData(sensorDataVerified);	
				}
			}
			
			a = sensorDataAsArray.indexOf("Upright");	
									
				if (a != -1) {
					sensorDataVerified[0] = sensorDataAsArray[a];
					sensorDataVerified[1] = sensorDataAsArray[a+1];
					sensorDataVerified[2] = sensorDataAsArray[a+2];
					sensorDataVerified[3] = sensorDataAsArray[a+3];					
					
					DC.objLiveGraph.setUprightButtonPush(sensorDataVerified);		
										
					//DC.objLiveGraph.testUI.indicator3.txt1.text = "  count = " + String(DC.objLiveGraph.count) + "  " + String(sensorData);
				}
	
		
			}				
						
			//if (sensorData == ("EndSessionEarly" + "\n") && DC.objBodyMeasurements.bodyMeasurementsMode == 0) {
				//socket.writeUTFBytes("Sleep" + "\n");			
				//socket.flush();
			//}
			

	}
	
}
