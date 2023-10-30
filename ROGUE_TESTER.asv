% 
% 
%   images = imageDatastore(fullfile(toolboxdir('vision'),'visiondata', ...
%       'calibration', 'slr'));
% 
%   [imagePoints,boardSize] = detectCheckerboardPoints(images.Files);
% 
%  squareSize = 29;
% worldPoints = generateCheckerboardPoints(boardSize, squareSize);
% 
% I = readimage(images,1); 
% imageSize = [size(I,1), size(I,2)];
% cameraParams = estimateCameraParameters(imagePoints,worldPoints, ...
%                               'ImageSize',imageSize);
% imOrig = imread(fullfile(matlabroot,'toolbox','vision','visiondata', ...
%     'calibration','slr','image9.jpg'));
% figure 
% imshow(imOrig);
% title('Input Image');
% [im,newOrigin] = undistortImage(imOrig,cameraParams,'OutputView','full');
% 
% [imagePoints,boardSize] = detectCheckerboardPoints(im);
% 
% imagePoints = [imagePoints(:,1) + newOrigin(1), ...
%              imagePoints(:,2) + newOrigin(2)];
% 
% [rotationMatrix, translationVector] = extrinsics(...
% imagePoints,worldPoints,cameraParams);
% 
% [orientation, location] = extrinsicsToCameraPose(rotationMatrix, ...
%   translationVector);
% figure
% plotCamera('Location',location,'Orientation',orientation,'Size',20);
% hold on
% pcshow([worldPoints,zeros(size(worldPoints,1),1)], ...
%   'VerticalAxisDir','down','MarkerSize',40);
% 
% 
% 


% Create a webcam object for the Surface Camera Front
cam = webcam('Surface Camera Front');

images = imageDatastore(fullfile("C:\Users\61459\OneDrive - UTS (1)\2023 sem 2\Sensors and Control\visual_servoing_project\Hamish_Test_Calib"));

[imagePoints, boardSize] = detectCheckerboardPoints(images.Files);

squareSize = 27.5;
worldPoints = generateCheckerboardPoints(boardSize, squareSize);

I = readimage(images, 1);
imageSize = [size(I, 1), size(I, 2)];
cameraParams = estimateCameraParameters(imagePoints, worldPoints, ...
    'ImageSize', imageSize);

% Create a figure for displaying the live camera feed
liveFeedFig = figure;
set(liveFeedFig, 'Name', 'Live Camera Feed', 'NumberTitle', 'Off');

% Create a figure for displaying the simulated camera pose
poseFig = figure;
set(poseFig, 'Name', 'Simulated Camera Pose', 'NumberTitle', 'Off');
updateCounter = 0;


while ishandle(liveFeedFig) && ishandle(poseFig)
    % Capture an image from the webcam
    img = snapshot(cam);
    grayImg = rgb2gray(img);

    % Close the webcam object
    imOrig = grayImg;

    % Display live camera feed
    figure(liveFeedFig);
    imshow(img);
    title('Live Camera Feed');

    [imagePoints, boardSize] = detectCheckerboardPoints(imOrig);

    [rotationMatrix, translationVector] = extrinsics(...
        imagePoints, worldPoints, cameraParams);

    [orientation, location] = extrinsicsToCameraPose(rotationMatrix, ...
        translationVector);

    % Check if the counter reaches 5 to update the simulated camera pose
    if updateCounter == 5
        % Display the simulated camera pose
        figure(poseFig);
        plotCamera('Location', location, 'Orientation', orientation, 'Size', 20);
        title('Pose Plot');
        hold on
        pcshow([worldPoints, zeros(size(worldPoints, 1), 1)], ...
                'VerticalAxisDir', 'down', 'MarkerSize', 40);
       hold off

        % Reset the counter
        updateCounter = 0;
    end

    % Increment the counter
    updateCounter = updateCounter + 1;
    drawnow;
end


% Clean up
clear cam;
% 




