% Create a webcam object for the integrated webcam
>>>>>>> Stashed changes
vid = webcam("Webcam");

% Physical size of the squares on the checkerboard (in centimeters)
squareSizeCM = 2.75;  % Each square is 2.75 cm by 2.75 cm

% Create a figure for displaying the live video
hFig = figure;
set(hFig, 'Name', 'Live Pattern Detection', 'NumberTitle', 'off');
<<<<<<< HEAD:SarahWorkingfolder/visualServoingProjectSA.m

% Load the PNG image as grayscale (if it's not already in grayscale)
template_path = fullfile('Pattern Images', 'Checkerboard.jpg');
template_gray = imread(template_path);

% Check if the template image is not in grayscale
if size(template_gray, 3) == 3
    template_gray = rgb2gray(template_gray);
end

% Create a SURF object for the template
templateSURF = detectSURFFeatures(template_gray);

% Extract feature descriptors for the template
[templateFeatures, templatePoints] = extractFeatures(template_gray, templateSURF);

=======
tts('Hello');
>>>>>>> 0246464886fdde4516c2261df7e4d09cdeb34c97:visualServoingProject.m
while ishandle(hFig)
    % Capture a frame from the webcam
    frame = snapshot(vid);
    
    % Flip the captured frame horizontally
    frame = flip(frame, 2);  % Flip along the second dimension (horizontal)

    % Convert the captured frame to grayscale
    frame_gray = rgb2gray(frame);
    
    % Detect checkerboard corners
    [imagePoints, boardSize] = detectCheckerboardPoints(frame_gray, 'MinCornerMetric', 0.1);
    
    % Display the original frame
    imshow(frame);
    hold on;
    
    % Check if checkerboard corners were found
    if ~isempty(imagePoints)
        % Plot the detected checkerboard corners
        plot(imagePoints(:, 1), imagePoints(:, 2), 'ro', 'MarkerSize', 5);
        title('Navigate Towards the Middle');
        
        % Calculate the size of the checkerboard in pixels
        checkerboardWidthPixels = max(imagePoints(:, 1)) - min(imagePoints(:, 1));
        checkerboardHeightPixels = max(imagePoints(:, 2)) - min(imagePoints(:, 2));
        
        % Calculate the distance of the checkerboard from the camera (arbitrary unit)
        % You can use the formula: distance = (known size / perceived size) * arbitrary scale
        knownSize = squareSizeCM * boardSize(1);  % Total width of checkerboard in centimeters
        perceivedSize = max(checkerboardWidthPixels, checkerboardHeightPixels);
        arbitraryScale = 100;  % Arbitrary scale factor (adjust as needed)
        distance = (knownSize / perceivedSize) * arbitraryScale;
        
        % Calculate the X and Y positions of the checkerboard center relative to the image center
        centerX = size(frame, 2) / 2;
        centerY = size(frame, 1) / 2;
        avgX = mean(imagePoints(:, 1));
        avgY = mean(imagePoints(:, 2));
        deltaX = avgX - centerX;
        deltaY = avgY - centerY;
        
        % Draw an arrow from the average of matched points to the center
        quiver(avgX, avgY, centerX - avgX, centerY - avgY, 0, 'r', 'LineWidth', 2);
        
        if abs(deltaX) < 20 && abs(deltaY) < 20
            title('You are Awesome!');
            message = 'You are awesome!';
            tts(message);
        end

        % Display the estimated distance, X, and Y positions
        text(20, 20, sprintf('Distance: %.2f arbitrary units', distance), 'Color', 'r', 'FontSize', 12);
        text(20, 50, sprintf('X: %.2f pixels, Y: %.2f pixels', deltaX, deltaY), 'Color', 'r', 'FontSize', 12);
    else
        title('Checkerboard Not Detected');
    end
    
    hold off;
    
    % Pause briefly to display the frame
    pause(0.5);
end

% Clean up and close the webcam object
clear vid;
%%
cameraList = webcamlist;
disp(cameraList);