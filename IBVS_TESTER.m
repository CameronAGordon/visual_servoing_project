% % % Create a video input object for the webcam (assuming you have MATLAB's Image Acquisition Toolbox)
% % vid = videoinput('winvideo', 1,'YUY2_1280x720');  % Adjust the device name and resolution as needed
% % set(vid, 'FramesPerTrigger', 1);
% % set(vid, 'TriggerRepeat', inf);
% % triggerconfig(vid, 'manual');
% 
% vid = webcam("Surface Camera Front");                                           % Create a camera object using your laptop's front-facing camera
% 
% try
%     % start(vid);  % Start the webcam
% 
%     % Capture an image from the webcam to determine its size
%     img = snapshot(vid);
%     img = flip(img, 1);                                                         % Flip the image horizontally (ONLY NEEDED FOR FRONT FACING CAM)
%     grayImg = rgb2gray(img);  
% 
% 
%     % Create a figure to display the camera feed
%     fig = figure;                                                              % Create a figure for displaying the video feed and results
%     set(fig, 'Name', 'Visual Servoing', 'NumberTitle', 'Off');
%     % figure;
%     % hImage = imshow(zeros(1280, 720, 3), 'InitialMagnification', 'fit');
%     % title('Camera Feed');
% 
%     % Define checkerboard parameters
%     checkerboardSize = [7, 9];  % Modify according to your checkerboard
%     squareSize = 27.5;  % Size of squares in millimeters
% 
%     while ishandle(fig)
%         % trigger(vid);  % Trigger a new frame capture
%         % img = getdata(vid, 1);  % Capture an image from the webcam
% 
%         img = snapshot(vid);
%         img = flip(img, 1);                                                         % Flip the image horizontally (ONLY NEEDED FOR FRONT FACING CAM)
%         grayImg = rgb2gray(img);  
% 
%         % Detect checkerboard corners
%         [imagePoints, boardSize] = detectCheckerboardPoints(img);
%         if ~isempty(imagePoints)
%             % Generate world coordinates of checkerboard corners
%             worldPoints = generateCheckerboardPoints(boardSize, squareSize);
% 
%             % Estimate camera intrinsics
%             cameraParams = estimateCameraParameters(imagePoints, worldPoints);
% 
%             % Estimate camera extrinsics
%             camExtrinsics = estimateExtrinsics(imagePoints, worldPoints, cameraParams.Intrinsics);
% 
%             % Calculate the camera pose
%             camPose = extr2pose(camExtrinsics);
% 
%             % Display the camera feed with overlay
%             img = insertMarker(img, imagePoints, 'o', 'Color', 'r', 'Size', 10);
%             set(fig, 'CData', img);
% 
%             % Display the camera pose in a new figure
%             figure;
%             plotCamera('Location', camPose.Translation', 'Orientation', camPose.RotationMatrix);
%             title('Camera Pose');
%         end
% 
%         pause(0.25);  % Capture a new image every 0.25 seconds
%     end
% 
% catch ME
%     disp('An error occurred.');
%     disp(getReport(ME));
% end
% 
% % stop(vid);  % Stop the video input object
% delete(vid);  % Delete the video input object
% clear vid;  % Clear the video input object from the workspace

vid = webcam("Surface Camera Front");

try
    img = snapshot(vid);
    img = flip(img, 1);
    grayImg = rgb2gray(img);

    checkerboardSize = [7, 9];
    squareSize = 27.5;

    fig = figure;
    set(fig, 'Name', 'Visual Servoing', 'NumberTitle', 'Off');

    hImage = imshow(zeros(size(img)), 'InitialMagnification', 'fit');
    title('Camera Feed');
    
    while ishandle(fig)
        img = snapshot(vid);
        img = flip(img, 1);
        grayImg = rgb2gray(img);

        [imagePoints, boardSize] = detectCheckerboardPoints(img);
        
        if size(imagePoints, 1) >= 2  % Check if enough image points were detected
            worldPoints = generateCheckerboardPoints(boardSize, squareSize);
            cameraParams = estimateCameraParameters(imagePoints, worldPoints);
            camExtrinsics = estimateExtrinsics(imagePoints, worldPoints, cameraParams.Intrinsics);

            camPose = extr2pose(camExtrinsics);

            % Display the camera feed with overlay
            set(hImage, 'CData', img);
            hold on;
            plot(imagePoints(:, 1), imagePoints(:, 2), 'ro', 'MarkerSize', 10);
            hold off;

            % Display the camera pose in a new figure
            figure;
            plotCamera('Location', camPose.Translation', 'Orientation', camPose.RotationMatrix);
            title('Camera Pose');
        else
            disp('Checkerboard not detected.');
        end

        pause(0.25);
    end

catch ME
    disp('An error occurred.');
    disp(getReport(ME));
end

delete(vid);
clear vid;
