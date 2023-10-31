# visual_servoing_project
Sensors and Control Project
hamish_IBVS MATLAB class code description
The final codes is a MATLAB class that implements image-based visual servoing (IBVS) for the potential application of a camera mounted on a robot arm. 
IBVS is a technique that uses the image features of a target object to control the motion of the robot. 
The code has the following features:

- It defines a class named `hamish_IBVS` that inherits from the `handle` class, which allows the object to be passed by reference.
- It declares several properties that store the information about the image points, the initial depth, the original position, the acceptable error, the figure handle, and the average position of the detected points.
- It defines a constructor method that calls the `main` method to run the IBVS algorithm.
- It defines a method named `zCalc` that calculates the depth of the target object using camera calibration data and three non-collinear points on the checkerboard pattern. It also converts the pixel coordinates to centimeters using the focal length and the depth value.
- It uses a loop to iterate over all the image points and store their x, y, and z values in centimeters in arrays.

finalapp app designer class code description
This code is a MATLAB app that implements image-based visual servoing (IBVS) for a camera mounted on a robot arm. IBVS is a technique that uses the image features of a target object to control the motion of the robot. The code has the following features:

- It defines a class named `finalapp` that inherits from the `matlab.apps.AppBase` class, which allows the creation of graphical user interfaces (GUIs).
- It declares several properties that correspond to the app components, such as buttons, edit fields, labels, and axes. It also declares some private properties that store the information about the camera, the image points, the world points, the camera parameters, and the acceptable error values.
- It defines several methods that handle the app events, such as starting, stopping, and simulating the IBVS algorithm. It also defines some helper methods that perform the calculations and display the results.
- It uses a method named `zCalc` that calculates the depth of the target object using camera calibration data and three non-collinear points on the checkerboard pattern. It also converts the pixel coordinates to centimeters using the focal length and the depth value.
- It uses a loop to iterate over all the image points and store their x, y, and z values in centimeters in arrays.
