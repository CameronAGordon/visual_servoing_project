% Create a webcam object for your integrated webcam
vid = webcam("Integrated Camera");

% Create a figure for displaying the live video
hFig = figure;
set(hFig, 'Name', 'Live Pattern Detection', 'NumberTitle', 'off');

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

while ishandle(hFig)
    % Capture a frame from the webcam
    frame = snapshot(vid);
    
    % Flip the captured frame horizontally
    frame = flip(frame, 2);  % Flip along the second dimension (horizontal)

    % Convert the captured frame to grayscale
    frame_gray = rgb2gray(frame);
    
    % Create a SURF object for the frame with custom threshold
    customThreshold = 1000;  % Adjust this threshold value as needed
    frameSURF = detectSURFFeatures(frame_gray, 'MetricThreshold', customThreshold);
    
    % Extract feature descriptors for the frame
    [frameFeatures, framePoints] = extractFeatures(frame_gray, frameSURF);
    
    % Match features between the template and frame
    indexPairs = matchFeatures(templateFeatures, frameFeatures);
    
    % Display the original frame
    imshow(frame);
    hold on;
    
    % Plot the matched points on the frame
    if ~isempty(indexPairs)
        matchedTemplatePoints = templatePoints(indexPairs(:, 1));
        matchedFramePoints = framePoints(indexPairs(:, 2));
        plot(matchedFramePoints);
        
        % Calculate the average position of matched points
        avgX = mean(matchedFramePoints.Location(:, 1));
        avgY = mean(matchedFramePoints.Location(:, 2));
        
        % Get the center of the image
        [imageHeight, imageWidth, ~] = size(frame);
        centerX = imageWidth / 2;
        centerY = imageHeight / 2;
        
        % Draw an arrow from the average of matched points to the center
        quiver(avgX, avgY, centerX - avgX, centerY - avgY, 0, 'r', 'LineWidth', 2);
        
        legend('Matched Points', 'Arrow');
        text(20, imageHeight - 20, sprintf('X: %.2f, Y: %.2f', avgX - centerX, avgY - centerY), 'Color', 'r', 'FontSize', 12);
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