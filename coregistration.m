%% Setting up
clear
clf
load("fluorescence_data.mat")
auto = false; % Temporary, set processing mode

opusImage = imread(fullfile('imgs', 'slope_image.png'));
if ndims(opusImage) == 3 && size(opusImage, 3) == 3 % If image is RGB convert to greyscale
    opusImage = rgb2gray(opusImage);
end

%% Finding surface layer
threshold = 50; % Greyscale value threshold
y_threshold = 25; % Crosstalk depth threshold

peakPos = zeros(size(opusImage)); % Empty matrix to store surface positions
for col = 1:length(opusImage(1, :))
    peakFound = false;
    for row = y_threshold:length(opusImage(:, 1))
        if opusImage(row, col) > threshold % Considers pixels above threshold on greyscale image
            peakPos(row, col) = 1;
            peakFound = true;
        elseif peakFound % Breaks if a second layer is found
            break;
        end
    end
end

%% Normalisation
data_array = data_plot;
max_length = 30; % length of scan in cm
max_depth = 30;

fluorescence_array(:, 1) = [(max_length / length(data_array)) : (max_length / length(data_array)) : max_length]; % Distance in cm
fluorescence_array(:, 2) = data_array; % Fluorescence in au

peakPos = imresize(peakPos, [length(data_array) length(data_array)]); % THIS IS MESSY FIX IT
peakPos(peakPos ~= 0) = 1;

us_depth_array = [(max_depth / length(opusImage(:, 1))) : (max_depth / length(opusImage(:, 1))) : max_depth]';

for k = 1:length(peakPos(1, :)) % Depth at given distance in cm
    pos(k, :) = find(peakPos(:, k) == 1, 1);
    fluorescence_array(k, 3) = us_depth_array(pos(k));
end

for k = 1:length(fluorescence_array) % Normalised fluorescence in au
    fluorescence_array(k, 4) = fluorescence_array(k, 2) * 1/(0.06323*exp(-1.013*fluorescence_array(k,3)) + 0.3203*exp(-0.002938*fluorescence_array(k,3)));
end

shift = fluorescence_array(1,4)-fluorescence_array(1,2); % Normalised fluorescence shifted to origin in au
for k = 1:length(fluorescence_array)
    fluorescence_array(:,5) = fluorescence_array(:,4) - shift;
end

peakPos = imresize(peakPos, [length(opusImage(:,1)) length(opusImage(1,:))]); % THIS IS MESSY FIX IT
peakPos(peakPos ~= 0) = 1;
%% Create colourmap
clims = [min(fluorescence_array(:, 2)) max(fluorescence_array(:, 2))]; % Set scale to original data
norm = imagesc(fluorescence_array(:, 5)', clims); % Create scaled colourmap
cmaps = hot(256);
colormap(cmaps);
cb = colorbar;

% Converting colourbar into processable rgb image
cdata = norm.CData; % Colourmap data
cmap = colormap(norm.Parent);
num = size(cmap, 1); % Number of colours in colourmap
c = linspace(norm.Parent.CLim(1), norm.Parent.CLim(2), num); % Intensity range
idx = reshape(interp1(c, 1:num, cdata(:), 'nearest'), size(cdata)); % Indexed image
fluorescenceImage = ind2rgb(idx, cmap);
fluorescenceImage = imresize(fluorescenceImage, [size(opusImage, 1), size(opusImage, 2)]); % Scale image

%% Coregistration
figure
if auto % Automatic selection mode
    imshow(opusImage)
    hold on
    fl = imshow(fluorescenceImage);
    selection = opusImage .* uint8(peakPos);
    set(fl, 'AlphaData', selection);
else % Manual selection mode
    imshowpair(opusImage, uint8(peakPos), 'blend');
    selection = opusImage .* uint8(roipoly); % Create region of interest using polygonal lasso

    usimage = imshow(opusImage);
    hold on
    fl = imshow(fluorescenceImage);
    set(fl, 'AlphaData', selection);
end
colorbar
%{
TO DO:
- Fix colorbar on second figure: a new colorbar is created, the colorbar on
figure 1 should be displayed on figure 2
- Fix selection mode: adjust normalisation calculations based on selection
boundaries
- Fix overlay on manual mode: alpha layer is not being considered
%}