# uhaul-panic
This is Ethan Lee's repository for ECE 1895's Final Project.

# Organization
This repository consists of the "Software_Design_Files" folder, the "Released_Game_Builds" folder, the game credit list, and this README.md file.

# Software Design Files
The "Software_Design_Files" folder contains all of the Godot Project files, used to design and create the game. To open up the project, you will need to install Godot from their website:
https://godotengine.org/
Once you do and open the program, it will show a screen containing Local Projects. Press the "Import" button. From there, you have two options to import the project - you can either download the UHaul folder, then open the "project.godot" file within the folder to import the project, or you can download the UHaul file as a .zip file and import it into Godot.

The main files of interest are the "project.godot" file, as well as the "scenes" folder - which contains the smaller subcomponent "scenes" and .gd files (which are the GDScript code files attached to scenes).
Additionally, the "assets" folder contains all the assets used (e.g. .png files) in the creation of the game.
The project should automatically have "Silentwolf" as an installed add-on, but if not, you can get the add-on here:
https://silentwolf.com/features.
Follow the guide in the "Set up your leaderboard" section if necessary.

# Released Game Builds
The "Released_Game_Builds" folder contains the exports of the game for both Windows and Android.

"UhaulPanic.exe" contains the latest build of the game, exported for use on Windows machines. 
To run the game on PC without looking at the project itself, run "UhaulPanic.exe."

"UhaulPanic.apk" contains a .apk file that can be installed on Android devices, creating an app.
Note that the game does not successfully function in this .apk, as noted in the final report. Thus, while the game will open on an Android device, it will not play properly.
To open the game on an Android device, copy the .apk file and open it on an Android device.

# Credit List
"Game_Credit_List.txt" contains a credit list listing the community assets that I used, as well as the various tutorials and documentation I read or watched while developing the game.
The main item of interest is the link under "Gameplay Loop Development Help", which points to a tutorial demonstrating how to make a 2D runner in Godot. This was the most helpful resource in terms of developing the game, and is the primary tutorial that I used.
However, all of the video tutorials and documentation that I mentioned in the final report are located here as YouTube links.
