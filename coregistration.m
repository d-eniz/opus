%% Setting up
clear
clf
load("fluorescence_data.mat")
auto = true; % Temporary, set processing mode

opusImage = imread(fullfile('imgs', 'slope_image.png'));
if ndims(opusImage) == 3 && size(opusImage, 3) == 3 % If image is RGB convert to greyscale
    opusImage = rgb2gray(opusImage);
end
%% Experimental - manual mode
if auto == false
    imshow(opusImage);
    selects = opusImage .* uint8(roipoly);
else
    selects = opusImage;
end
%% Finding surface layer
threshold = 50; % Greyscale value threshold
y_percent = 2.85; % Crosstalk depth threshold (% of image height)
y_threshold = round(length(opusImage(:,1)) * (y_percent / 100));

peakPos = zeros(size(opusImage)); % Empty matrix to store surface positions
for col = 1:length(opusImage(1, :))
    peakFound = false;
    for row = y_threshold:length(opusImage(:, 1))
        if selects(row, col) > threshold % Considers pixels above threshold on greyscale image
            peakPos(row, col) = 1;
            peakFound = true;
        elseif peakFound % Breaks if a second layer is found
            break;
        end
    end
end

%% Setup normalisation calculation
data_array = data_plot;
max_length = 30; % length of scan in cm
max_depth = 30;

fluorescence_array(:, 1) = linspace((max_length / length(data_array)), max_length, length(data_array)); % Distance in cm
fluorescence_array(:, 2) = data_array; % Fluorescence in au

peakPosScaled = imresize(peakPos, [length(data_array) length(data_array)]); % THIS IS MESSY FIX IT
peakPosScaled(peakPosScaled ~= 0) = 1;

us_depth_array = linspace(max_depth / length(opusImage(:, 1)), max_length, length(opusImage(:, 1)))';

for k = 1:length(data_array) % Depth at given distance in cm
    if any(peakPosScaled(:, k) == 1)
        pos(k) = find(peakPosScaled(:, k) == 1, 1);
        fluorescence_array(k, 3) = us_depth_array(pos(k));
    end
end
%% Normalise
for k = 1:length(fluorescence_array) % Normalised fluorescence in au
    fluorescence_array(k, 4) = fluorescence_array(k, 2) * 1/(0.06323*exp(-1.013*fluorescence_array(k,3)) + 0.3203*exp(-0.002938*fluorescence_array(k,3)));
end

shift = fluorescence_array(1,4)-fluorescence_array(1,2); % Normalised fluorescence shifted to origin in au
for k = 1:length(fluorescence_array)
    fluorescence_array(:,5) = fluorescence_array(:,4) - shift;
end

%% Create colourmap
clims = [min(fluorescence_array(:, 2)) max(fluorescence_array(:, 2))]; % Set scale to original data
norm = imagesc(fluorescence_array(:, 5)', clims); % Create scaled colourmap
cmaps = jet(256);
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
- Change US image format
- Update normalisation model
- Integrate into indie's code
- Add crosstalk peak detection
%}