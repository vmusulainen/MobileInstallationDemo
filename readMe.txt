How use this demo:

Start web server from Server directory by command 
	ruby web_server.rb "<your IP address here>"
If you use device emulator, you can use IP 127.0.0.1	
	

Go to HostApplication directory and set URL of web server in method download in /app/Host/controller.rb 
Build HostApplication and install it on device

Go to SubApplications directory and build partial upgrade bundle 
	rake build:iphone:upgrade_package_partial
Copy file to web server docs directory with name app_one.zip
	cp bin/target/iOS/upgrade_bundle_partial.zip ../Server/docs/app_one.zip

You can choose another name of downloading file if you correct http request handler at web_server.rb

Run Host Application on device and press "Update app" button.
Application should download file and install sub applications.
After installing update, Host application renders controls for start installed applications.

You can find detailed information about used features here:

http://docs.rhomobile.com/en/5.0.25/guide/app_upgrade
http://docs.rhomobile.com/en/5.0.25/guide/native_ui_elements
	
