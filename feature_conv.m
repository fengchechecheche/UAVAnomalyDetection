%% ALFA Dataset Feature Selection and Export
% take processed datafiles, extract necessary information. Export as CSV to
% make training set that can be used with Python

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

%%
% Iterate through files
folder_dir = "processed"

files = dir(folder_dir)

file_name = files(3).name

load(folder_dir + "/" + file_name + "/" + file_name + ".mat")

%% Create X training data set

% Create a row vector of all the features for the sample flight
% Now extract data
alt = Sequence.Topics.mavros_global_position_global.altitude;
rel_alt = Sequence.Topics.mavros_global_position_rel_alt.data;
% Get mean of baro altitude and rel altitude
x1_baro_alt_mean = mean(alt);
x1_rel_alt_mean = mean(rel_alt);
% Get 3 Axis longitudinal acceleration get mean and absolute max
imu_data = Sequence.Topics.mavros_imu_data.linear_acceleration;
x2_long_accel_x_mean = mean([imu_data.x].'); 
x2_long_accel_x_max = getAbsMax([imu_data.x].');
x2_long_accel_y_mean = mean([imu_data.y].');
x2_long_accel_y_max = getAbsMax([imu_data.y].');
x2_long_accel_z_mean = mean([imu_data.z].'); 
x2_long_accel_z_max = getAbsMax([imu_data.z].');
% Get heading
heading = Sequence.Topics.mavros_global_position_compass_hdg.data;
x3_heading_mean = mean(heading);
% Ground Velocity mean and max
x4_velocity_x_mean = mean(Sequence.Topics.mavros_nav_info_velocity.meas_x);
x4_velocity_x_max = max(Sequence.Topics.mavros_nav_info_velocity.meas_x);
x4_velocity_y_mean = mean(Sequence.Topics.mavros_nav_info_velocity.meas_y);
x4_velocity_y_max = max(Sequence.Topics.mavros_nav_info_velocity.meas_y);
% Pitch and Roll Mean and Abs Max
x5_roll_mean = mean(Sequence.Topics.mavros_nav_info_roll.measured);
x5_roll_max = getAbsMax(Sequence.Topics.mavros_nav_info_roll.measured);
x5_pitch_mean = mean(Sequence.Topics.mavros_nav_info_pitch.measured);
x5_pitch_max = getAbsMax(Sequence.Topics.mavros_nav_info_pitch.measured);
% Get Lat and Long Mean and First, also save to variable to plot later
long = Sequence.Topics.mavros_global_position_global.longitude;
lat = Sequence.Topics.mavros_global_position_global.latitude;
x6_long_first = long(1);
x6_lat_first = lat(1);
x6_long_mean = mean(long);
x6_lat_mean = mean(lat);
% Get Airspeed mean and max (not absolute max)
x7_airspeed_mean = mean(Sequence.Topics.mavros_nav_info_airspeed.measured);
x7_airspeed_max = max(Sequence.Topics.mavros_nav_info_airspeed.measured);
% Get Vertical Speed mean and absolute max
x8_velocity_z_mean = mean(Sequence.Topics.mavros_nav_info_velocity.meas_z);
x8_velocity_z_max = getAbsMax(Sequence.Topics.mavros_nav_info_velocity.meas_z);

% Lastly get the Y label (save the file name)
Y_label = files(3).name;

%% Iterate through each subfolder in our directory
folder_dir = "processed"
X_data = []; % Empty matrix for X data
Y_labels = [];
D = dir(folder_dir);
for k = 3:length(D) % Avoid using the first 2 files ('.' and '..')
    currF = D(k).name;
    disp("Loading: " + currF)
    % Load the MAT File
    load(folder_dir + "/" + currF + "/" + currF + ".mat");
    % Get the X row feature vector and Y row label
    [xrow, yrow] = extractFeatures(Sequence, currF);
    % Append rows to the matrices
    X_data = [X_data; xrow'];
    Y_labels = [Y_labels; convertCharsToStrings(yrow)];
end

%% Output Data as CSVs
writematrix(X_data, 'X_data.csv');
writematrix(Y_labels, 'Y_labels.csv');


%% Helper Functions
function max_val = getAbsMax(data)
    [A, X] = max(abs(data));
    max_val = A.*sign(data(X));
end

function [x_row, y_row] = extractFeatures(Sequence, filename)
    % Create a row vector of all the features for the sample flight
    % Now extract data
    alt = Sequence.Topics.mavros_global_position_global.altitude;
    rel_alt = Sequence.Topics.mavros_global_position_rel_alt.data;
    % Get mean of baro altitude and rel altitude
    x1_baro_alt_mean = mean(alt);
    x1_rel_alt_mean = mean(rel_alt);
    % Get 3 Axis longitudinal acceleration get mean and absolute max
    imu_data = Sequence.Topics.mavros_imu_data.linear_acceleration;
    x2_long_accel_x_mean = mean([imu_data.x].'); 
    x2_long_accel_x_max = getAbsMax([imu_data.x].');
    x2_long_accel_y_mean = mean([imu_data.y].');
    x2_long_accel_y_max = getAbsMax([imu_data.y].');
    x2_long_accel_z_mean = mean([imu_data.z].'); 
    x2_long_accel_z_max = getAbsMax([imu_data.z].');
    % Get heading
    heading = Sequence.Topics.mavros_global_position_compass_hdg.data;
    x3_heading_mean = mean(heading);
    % Ground Velocity mean and max
    x4_velocity_x_mean = mean(Sequence.Topics.mavros_nav_info_velocity.meas_x);
    x4_velocity_x_max = max(Sequence.Topics.mavros_nav_info_velocity.meas_x);
    x4_velocity_y_mean = mean(Sequence.Topics.mavros_nav_info_velocity.meas_y);
    x4_velocity_y_max = max(Sequence.Topics.mavros_nav_info_velocity.meas_y);
    % Pitch and Roll Mean and Abs Max
    x5_roll_mean = mean(Sequence.Topics.mavros_nav_info_roll.measured);
    x5_roll_max = getAbsMax(Sequence.Topics.mavros_nav_info_roll.measured);
    x5_pitch_mean = mean(Sequence.Topics.mavros_nav_info_pitch.measured);
    x5_pitch_max = getAbsMax(Sequence.Topics.mavros_nav_info_pitch.measured);
    % Get Lat and Long Mean and First, also save to variable to plot later
    long = Sequence.Topics.mavros_global_position_global.longitude;
    lat = Sequence.Topics.mavros_global_position_global.latitude;
    x6_long_first = long(1);
    x6_lat_first = lat(1);
    x6_long_mean = mean(long);
    x6_lat_mean = mean(lat);
    % Get Airspeed mean and max (not absolute max)
    x7_airspeed_mean = mean(Sequence.Topics.mavros_nav_info_airspeed.measured);
    x7_airspeed_max = max(Sequence.Topics.mavros_nav_info_airspeed.measured);
    % Get Vertical Speed mean and absolute max
    x8_velocity_z_mean = mean(Sequence.Topics.mavros_nav_info_velocity.meas_z);
    x8_velocity_z_max = getAbsMax(Sequence.Topics.mavros_nav_info_velocity.meas_z);

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