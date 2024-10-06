%% ALFA Dataset Feature Selection and Export
% take processed datafiles, extract necessary information. Export as CSV to
% make training set that can be used with Python
% 获取处理过的数据，提取必要的信息。导出为CSV，使训练集可以与Python一起使用

% Necessary Features:
%{

Retained Features:
BARO_ALT: Barometric Altitude, Mean
REL_ALT: Relative Altitude, Mean
LONG_ACCEL: Longitudinal Accleration, Mean, absolute Max
HEAD: Heading, Mean
IVV: Vertical Speed, mean and absoluate max
PITCH: Pitch, Mean, absolute Max
ROLL: Roll, Mean, absoluate max
LATPC: Corrected Latitude, Mean and First
LONGPC: Corrected Longitude, Mean and First
CASC: Corrected Airspeed, mean, max
GCS: Corrected ground speed X and Y, mean, max
25 Features, 47 flights
X: 47x25
Y: 47x1

Labels:
Non-failure
Failure

47 Flights, ~80% expected outliers

%}

%% Iterate through each subfolder in our directory
folder_dir = "piac2"
X_data = []; % Empty matrix for X data
Y_labels = [];
D = dir(folder_dir);
for k = 3:length(D) % Avoid using the first 2 files ('.' and '..')
    currF = D(k).name;
    disp("Loading: " + currF)
    % Load the MAT File
    load(folder_dir + "/" + currF);
    % Get the X row feature vector and Y row label
    % Create a row vector of all the features for the sample flight
    % Now extract data
    alt = BARO(:,3);
    rel_alt = POS(:,5);
    % Get mean of baro altitude and rel altitude
    x1_baro_alt_mean = mean(alt);
    x1_rel_alt_mean = mean(rel_alt);
    % Get 3 Axis longitudinal acceleration get mean and absolute max
    x2_long_accel_x_mean = mean(IMU(:,6)); 
    x2_long_accel_x_max = getAbsMax(IMU(:,6));
    x2_long_accel_y_mean = mean(IMU(:,7));
    x2_long_accel_y_max = getAbsMax(IMU(:,7));
    x2_long_accel_z_mean = mean(IMU(:,8)); 
    x2_long_accel_z_max = getAbsMax(IMU(:,8));
    % Get heading
    heading = GPS(:,14);
    x3_heading_mean = mean(heading);
    % Ground Velocity mean and max
    x4_velocity_x_mean = mean(NKF1(:, 6));
    x4_velocity_x_max = max(NKF1(:, 6));
    x4_velocity_y_mean = mean(NKF1(:, 7));
    x4_velocity_y_max = max(NKF1(:, 7));
    % Pitch and Roll Mean and Abs Max
    x5_roll_mean = mean(ATT(:,4));
    x5_roll_max = getAbsMax(ATT(:,4));
    x5_pitch_mean = mean(ATT(:,6));
    x5_pitch_max = getAbsMax(ATT(:,6));
    % Get Lat and Long Mean and First, also save to variable to plot later
    long = POS(:, 4);
    lat = POS(:, 3);
    x6_long_first = long(1);
    x6_lat_first = lat(1);
    x6_long_mean = mean(long);
    x6_lat_mean = mean(lat);
    % Get Airspeed mean and max (not absolute max)
    x7_airspeed_mean = mean(ARSP(:, 3));
    x7_airspeed_max = max(ARSP(:, 3));
    % Get Vertical Speed mean and absolute max
    x8_velocity_z_mean = mean(GPS(:,13));
    x8_velocity_z_max = getAbsMax(GPS(:,13));

    % Lastly get the Y label (save the file name)
    y_row = currF;
    % Create a Row Vector for the feature data
    x_row = [
        x1_baro_alt_mean, 
        x1_rel_alt_mean,
        x2_long_accel_x_mean,
        x2_long_accel_x_max,
        x2_long_accel_y_mean,
        x2_long_accel_y_max,
        x2_long_accel_z_mean,
        x2_long_accel_z_max,
        x3_heading_mean,
        x4_velocity_x_mean,
        x4_velocity_x_max,
        x4_velocity_y_mean,
        x4_velocity_y_max,
        x5_roll_mean,
        x5_roll_max,
        x5_pitch_mean,
        x5_pitch_max,
        x6_long_first,
        x6_long_mean,
        x6_lat_first,
        x6_lat_mean,
        x7_airspeed_mean,
        x7_airspeed_max,
        x8_velocity_z_mean,
        x8_velocity_z_max
        ];
    % Append rows to the matrices
    X_data = [X_data; x_row'];
    Y_labels = [Y_labels; convertCharsToStrings(y_row)];
end

%% Output Data as CSVs
writematrix(X_data, 'X_data_Val2.csv');
writematrix(Y_labels, 'Y_labels_Val2.csv');


%% Helper Functions
function max_val = getAbsMax(data)
    [A, X] = max(abs(data));
    max_val = A.*sign(data(X));
end

function [x_row, y_row] = extractFeatures(filename)
    % Create a row vector of all the features for the sample flight
    % Now extract data
    alt = BARO(:,3);
    rel_alt = POS(:,5);
    % Get mean of baro altitude and rel altitude
    x1_baro_alt_mean = mean(alt);
    x1_rel_alt_mean = mean(rel_alt);
    % Get 3 Axis longitudinal acceleration get mean and absolute max
    imu_data = Sequence.Topics.mavros_imu_data.linear_acceleration;
    x2_long_accel_x_mean = mean(IMU(:,6)); 
    x2_long_accel_x_max = getAbsMax(IMU(:,6));
    x2_long_accel_y_mean = mean(IMU(:,7));
    x2_long_accel_y_max = getAbsMax(IMU(:,7));
    x2_long_accel_z_mean = mean(IMU(:,8)); 
    x2_long_accel_z_max = getAbsMax(IMU(:,8));
    % Get heading
    heading = GPS(:,14);
    x3_heading_mean = mean(heading);
    % Ground Velocity mean and max
    x4_velocity_x_mean = mean(NKF1(:, 6));
    x4_velocity_x_max = max(NKF1(:, 6));
    x4_velocity_y_mean = mean(NKF1(:, 7));
    x4_velocity_y_max = max(NKF1(:, 7));
    % Pitch and Roll Mean and Abs Max
    x5_roll_mean = mean(ATT(:,4));
    x5_roll_max = getAbsMax(ATT(:,4));
    x5_pitch_mean = mean(ATT(:,6));
    x5_pitch_max = getAbsMax(ATT(:,6));
    % Get Lat and Long Mean and First, also save to variable to plot later
    long = POS(:, 4);
    lat = POS(:, 3);
    x6_long_first = long(1);
    x6_lat_first = lat(1);
    x6_long_mean = mean(long);
    x6_lat_mean = mean(lat);
    % Get Airspeed mean and max (not absolute max)
    x7_airspeed_mean = mean(ARSP(:, 3));
    x7_airspeed_max = max(ARSP(:, 3));
    % Get Vertical Speed mean and absolute max
    x8_velocity_z_mean = mean(GPS(:,13));
    x8_velocity_z_max = getAbsMax(GPS(:,13));

    % Lastly get the Y label (save the file name)
    y_row = filename;
    % Create a Row Vector for the feature data
    x_row = [
        x1_baro_alt_mean, 
        x1_rel_alt_mean,
        x2_long_accel_x_mean,
        x2_long_accel_x_max,
        x2_long_accel_y_mean,
        x2_long_accel_y_max,
        x2_long_accel_z_mean,
        x2_long_accel_z_max,
        x3_heading_mean,
        x4_velocity_x_mean,
        x4_velocity_x_max,
        x4_velocity_y_mean,
        x4_velocity_y_max,
        x5_roll_mean,
        x5_roll_max,
        x5_pitch_mean,
        x5_pitch_max,
        x6_long_first,
        x6_long_mean,
        x6_lat_first,
        x6_lat_mean,
        x7_airspeed_mean,
        x7_airspeed_max,
        x8_velocity_z_mean,
        x8_velocity_z_max
        ];
end