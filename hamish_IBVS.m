classdef hamish_IBVS < handle

    properties
        points;
        initialDepth;
        originalStart;
        acceptableError = 10;
        fig;
        avgPosition;
        originalZ;
        z_cm_values;
        y_cm_values;
        x_cm_values;
        z_values;     
        x_cm; y_cm; zCam_cm;
        GUI;
                    
    end

    methods       
        function self = hamish_IBVS
            % self.GUI = finalapp;
            self.main;           
        end

        function zCalc(self)
%% Camera Calibration Data and setting varaibles
            fx = 2603.90493;      % Focal length in x-axis
            fy = 2603.63735;      % Focal length in y-axis
            % cx = 1594.21893;    % Principal point in x-axis
            % cy = 949.73370 ;    % Principal point in y-axis
            % k1 =  0.16657;      % Radial distortion coefficient 1
            % k2 = -0.24939;      % Radial distortion coefficient 2
            % p1 = 0.00710;       % Tangential distortion coefficient 1
            % p2 = -0.00879;      % Tangential distortion coefficient 2
            % k3 = 0.0;           % Radial distortion coefficient 3
            
            r = [27.5, 0];        % Define the vectors (r, s) and (t, u) based on the checkerboard dimensions (THIS IS NO LONGER VALID WITH THE UPDATED CHECKERBOARD IM USING ON MY PHONE!)
            s = [0, 27.5];
            t = 3.5;              % Define the scalar factor t (you may need to adjust this, (3.5 works for the phone,1.7 for the big board) )

            self.z_cm_values = [];                                
            self.x_cm_values = [];
            self.y_cm_values = [];

            a = self.points(1, :);                                                  % choosing a reference point
            prevZ = 0;

%% Testing for 3 Points anywhere on checkerboard
            for i = 2:size(self.points, 1)                                          % Find two points (b and c) that form a triangle with the reference point
                if ~isequal(self.points(i, :), a)
                    b = self.points(i, :);
                    break;
                end
            end
            
            for i = 2:size(self.points, 1)
                if ~isequal(self.points(i, :), a) && ~isequal(self.points(i, :), b)
                    c = self.points(i, :);
                    break;
                end
            end

            if isempty(b) || isempty(c)                                              % Verify that you have three non-collinear points
                error('Unable to find three non-collinear points.');
            end
%% Calculating Z Value and converting X,Y,Z to cm values
            for i = 2:size(self.points, 1)
                x = self.points(i, 1);
                y = self.points(i, 2);
                                                                                
                z = 1 / t * dot(r, a) + dot(s, b) + t * dot(c, [x; y]);         % Calculate the z-value using the formula
                deltaX = self.avgPosition(1) - self.originalStart(1);           % Calculate the change in X and Y positions in pixels
                deltaY = self.avgPosition(2) - self.originalStart(2);
                deltaZ = z - prevZ;                                             % Calculate the change in Z from prevZ
                prevZ = z;                                                      % Update prevZ for the next iteration
                                                      
                if isempty(self.z_cm_values)                                    % Update the originalZ property if it's the first iteration
                    self.originalZ = z;
                end
                
                                                                                % Convert the z-value to centimeters using the calibration data
                self.zCam_cm = ((fx * fy) / deltaZ) / 10;                       % Divide by 10 to convert from cm to cm
                self.x_cm = ((fx * deltaX) / fx) / 10;                          % Convert pixel to cm for X-axis (assuming a square pixel)
                self.y_cm = ((fy * deltaY) / fy) / 10;                          % Convert pixel to cm for Y-axis (assuming a square pixel)
        
                self.z_cm_values = [self.z_cm_values; self.zCam_cm];
                self.x_cm_values = [self.x_cm_values; self.x_cm];
                self.y_cm_values = [self.y_cm_values; self.y_cm];
            end
        end
%% Main Function to run body of code
        function main(self)
                                                                                            % Define the acceptable error thresholds for X, Y, and Z
            acceptableErrorX = 3.0;                                                         % Adjust as needed
            acceptableErrorY = 3.0;                                                         % Adjust as needed
            acceptableErrorZ = 30.0;                                                        % Adjust as needed

            % vid = webcam("Integrated Webcam");                                           % Create a camera object using your laptop's front-facing camera
            vid = webcam("Surface Camera Front");
            self.fig = figure;                                                              % Create a figure for displaying the video feed and results
            set(self.fig, 'Name', 'Visual Servoing', 'NumberTitle', 'Off');
            isCalibrationStarted = false;  

    
            while ishandle(self.fig)                                                        % Main while loop to run visual servoing
                img = snapshot(vid);                                                        % Capture a frame from the camera
                img = flip(img, 2);                                                         % Flip the image horizontally (ONLY NEEDED FOR FRONT FACING CAM)
                grayImg = rgb2gray(img);                                                    % Convert the image to grayscale for checkerboard detection

                    
                if ~isCalibrationStarted                                                    % Checking if callibration has started to then wait for spacebar input                                               
                    imshow(img);
                    text(20, 20, 'Press space to start', 'Color', 'red', 'FontSize', 16);   % Display "Press space to start" text
                    k = waitforbuttonpress;                                                 % Wait for spacebar input to start calibration
                    
                    if k == 1 && strcmp(get(self.fig,'CurrentKey'), 'space')
                        self.originalStart = [];                                            % Reset original start position
                        isCalibrationStarted = true;
                    end
                    continue;                                                               % Skip the rest of the loop until calibration starts
                end
%% Setting up checkerboard point detection, values display
                [imagePoints, ~] = detectCheckerboardPoints(grayImg);                                                      % Detect the checkerboard pattern and find its corners
                self.points = [];                                                                                          % Clear the points variable to prevent a buildup
                dispMessage = false;
                
                if ~isempty(imagePoints)                                                                                   % Check for checkerboard recognition, process vertex points
                        self.points = [self.points; imagePoints];                                                          % Store the detected points
                        self.points = self.points(~any(isnan(self.points), 2), :);                                         % Filter out NaN values from points   
                        self.avgPosition = mean(self.points);                                                              % Calculate the average position of the points in pixels
        
                        if isempty(self.originalStart)                                                                     % if checkerboard is recognized, set point as the startPos and run calculations
                            self.originalStart = self.avgPosition;
                        end
                end 
    
                self.zCalc                                            
                errorX = abs(self.x_cm);                                                                                   % Calculate the errors
                errorY = abs(self.y_cm);
                errorZ = abs(self.zCam_cm);

                if errorX <= acceptableErrorX && errorY <= acceptableErrorY && errorZ <= acceptableErrorZ                  % Check if the errors are within acceptable thresholds
                    dispMessage = true;
                    overlayColor = 'green';                                                                                % Change the arrow color to green
                else  
                    overlayColor = 'red';                                                                                  % Arrow remains red
                end
    
                disp(['Position: X=', num2str(self.x_cm), ' cm, Y=', num2str(-self.y_cm)]);                                             % Display the average position
                disp(['Depth From Camera (cm): ', num2str(self.zCam_cm)]);                                                              % Display the depth in centimeters

    %% Display guidance arrow from avgPosition to original Position
                imshow(img);                                                                                                            % Display the image with detected checkerboard, arrow, and points
                hold on
                if ~any(isnan(self.avgPosition))                                                                                        % Calculate the arrow vector pointing towards the original start position
                    arrow = self.originalStart - self.avgPosition;
                    quiver(self.avgPosition(1), self.avgPosition(2), arrow(1), arrow(2), 0, 'r', 'LineWidth', 2,'Color',overlayColor);  
                end
                                                                                                                                        % Display the position information at the top left corner of the figure
                text(20, 20, sprintf('Depth (cm): %.2f ', self.zCam_cm), 'Color', overlayColor, 'FontSize', 12);
                text(20, 40, sprintf('X: %.2f cm, Y: %.2f cm', self.x_cm, -self.y_cm), 'Color', overlayColor, 'FontSize', 12);

                if dispMessage == true
                    text(20, 65, 'CAMERA LOCATED', 'Color', 'green', 'FontSize', 16);                                                   % Display "CAMERA LOCATED" text
                end
     
                for i = 1 : length(self.points)                                                                                         % Display detected points
                    if mod(i,2) == 0
                        img = insertMarker(img, self.points(i,:), 'o', 'Color', 'green', 'Size', 5);
                    else 
                       img = insertMarker(img, self.points(i,:), 'o', 'Color', 'red', 'Size', 5);   
                    end 
                end
               
                drawnow;
                pause(0.05)

            end
        end
    end
end 

%TO DO:
% RECALIBRATE CAMERA FOR BETTER ACCURACY - REVISIT MATHS TO FINE TUNE
% FIX THE ZFROMSTART VALUE (IS NOT SHOWING THE DISTANCE OF THE PATTERN FROMTHE ORIGINAL POSITION BUT RATHER SOME RANDOM NUMBER) - PROBALY NEED TO TAKE THE SECTION THAT SETS THE ORIGINAL Z POSITION OUT OF THE FOR LOOP.
