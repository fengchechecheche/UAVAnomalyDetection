%% ALFA Dataset Trajectory Visulization

%% Iterate through each subfolder in our directory
folder_dir = "processed"
Y_labels = [];
D = dir(folder_dir);
figure;
for k = 3:length(D) % Avoid using the first 2 files ('.' and '..')
    currF = D(k).name;
    disp("Loading: " + currF)
    % Load the MAT File
    load(folder_dir + "/" + currF + "/" + currF + ".mat");
    % Get the X row feature vector and Y row label
    [lat, long] = getLatLong(Sequence, currF);
    legend_label = currF;
    hold on;
    plot(long, lat)
    Y_labels = [Y_labels; convertCharsToStrings(legend_label)];

end




%% Helper Functions
function [lat, long] = getLatLong(Sequence, filename)
    % Get Lat and Long Mean and First, also save to variable to plot later
    long = Sequence.Topics.mavros_global_position_global.longitude;
    lat = Sequence.Topics.mavros_global_position_global.latitude;
end