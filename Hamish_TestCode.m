
% Define your camera calibration parameters
% Replace these values with your actual calibration data
fx = 2603.90493 ;  % Focal length in x-axis
fy = 2603.63735;  % Focal length in y-axis
cx = 1594.21893;  % Principal point in x-axis
cy = 949.73370 ;  % Principal point in y-axis
k1 =  0.16657;  % Radial distortion coefficient 1
k2 = -0.24939;   % Radial distortion coefficient 2
p1 = 0.00710;   % Tangential distortion coefficient 1
p2 = -0.00879;   % Tangential distortion coefficient 2
k3 = 0.0;        % Radial distortion coefficient 3

% Setup Camera Access and define variables
% Create a camera object using your laptop's front-facing camera
vid = webcam("Surface Camera Rear"); % Change the camera index if necessary

% Create a figure for displaying the video feed and results
fig = figure;
set(fig, 'Name', 'Visual Servoing', 'NumberTitle', 'Off');

% Initialize variables to store points, original start position, and initial depth
points = [0,0];
initialDepth = 0;  % Initialize the initial depth to zero
originalStart = []; % Initial Display Position, local coordinate frame (initial position of checkerboard logging)
initialX = 0;  % Initialize the initial X position to zero
initialY = 0;  % Initialize the initial Y position to zero
initialZ = 0;
z_mm_values = [];
prevZ = z_values(1);

% Main loop for visual servoing
while ishandle(fig)
    % Capture a frame from the camera
    img = snapshot(vid);

    % Flip the image horizontally (ONLY NEEDED FOR FRONT FACING CAM)
    %img = flip(img, 2);
    
    % Convert the image to grayscale for checkerboard detection
    grayImg = rgb2gray(img);
    
    % Detect the checkerboard pattern and find its corners
    [imagePoints, boardSize] = detectCheckerboardPoints(grayImg);
    
    % Clear the points variable to prevent a buildup
    points = [];
    
    % Check for checkerboard recognition, process vertex points
    if ~isempty(imagePoints)
        % Store the detected points
        points = [points; imagePoints];
        
        % Filter out NaN values from points
        points = points(~any(isnan(points), 2), :);
        
        % Calculate the average position of the points in pixels
        avgPosition = mean(points);

        % if checkerboard is recognised, set point as the startPos and run calculations
        if isempty(originalStart)
            originalStart = avgPosition;
        end
% DEPTH TESTING £££££££££££££££££££££££££££££££££
    % Define your points matrix where each row contains (x, y) coordinates

    % Choose a reference point (a)
    a = points(1, :);  % You can choose any point as a reference
    % Initialize variables to store the other two points (b and c)
    b = [];
    c = [];

    % Find two points (b and c) that form a triangle with the reference point
    for i = 2:size(points, 1)
        if ~isequal(points(i, :), a)
            b = points(i, :);
            break;
        end
    end
    
    for i = 2:size(points, 1)
        if ~isequal(points(i, :), a) && ~isequal(points(i, :), b)
            c = points(i, :);
            break;
        end
    end
    
    % Verify that you have three non-collinear points
    if isempty(b) || isempty(c)
        error('Unable to find three non-collinear points.');
    end
    % Define the vectors (r, s) and (t, u) based on the checkerboard dimensions
    r = [27.5, 0];
    s = [0, 27.5];
    % Define the scalar factor t (you may need to adjust this)
    t = 1;
    % Initialize an empty array to store the calculated z-values
    z_values = [];
    z = 0;
    % Calculate z-values for each point
    for i = 2:size(points, 1)
        x = points(i, 1);
        y = points(i, 2);
        
        % Calculate the z-value using the formula
        % z = 1 / t * (r * a' + s * b' + t * c' - r * x - s * y);
        z = 1 / t * dot(r, a) + dot(s, b) + t * dot(c, [x; y]);
        
        % Append the result to the z_values array
        z_values = [z_values; z];

        
                % Calculate the change in X and Y positions
        deltaX = avgPosition(1) - originalStart(1);
        deltaY = avgPosition(2) - originalStart(2);
        deltaZ = z - prevZ; % Calculate the change in Z from prevZ

        % Update prevZ for the next iteration
        prevZ = z;


        % Convert the z-value to millimeters using the calibration data
        z_mm = (fx * fy) / deltaZ;

        % Append the result to the z_mm_values array
        z_mm_values = [z_mm_values; z_mm];
        
    end

    % Update the X and Y positions based on the changes
    currentX = initialX + deltaX;
    currentY = initialY - deltaY;
    currentZ = initialZ + deltaZ

    % Display the average position
    % disp(['Position: X=', num2str(originalStart(1)), ', Y=', num2str(originalStart(2)),', Z= ', num2str(z)]);
    disp(['Position: X=', num2str(currentX), ', Y=', num2str(currentY),', Z= ', num2str(currentZ)]);
    % Display the depth in millimeters
    disp(['Depth (mm): ', num2str(z_mm)]);

        
        % Calculate the arrow vector pointing towards the original start position
        arrow = originalStart - avgPosition;

        if ~any(isnan(avgPosition))
            % Overlay the arrow on the image
            img = insertShape(img, 'Line', [avgPosition(1), avgPosition(2), ...
                avgPosition(1) + arrow(1), avgPosition(2) + arrow(2)], ...
                'Color', 'red', 'LineWidth', 2);
        end
        
        % Display detected points
        for i = 1 : length(points)
            if mod(i,2) == 0
                img = insertMarker(img, points(i,:), 'o', 'Color', 'green', 'Size', 5);
            else 
               img = insertMarker(img, points(i,:), 'o', 'Color', 'red', 'Size', 5);   
            end 
        end
        
        % Display the image with detected checkerboard, arrow, and points
        imshow(img);
        pause(0.25)
    end
end
% Release the camera when done
clear all;


%set initial position upon first sight of checkerboard. originalStart = avgPos
% display originalStart + avgPos = when avgPos + o +, when avgPos - o -



