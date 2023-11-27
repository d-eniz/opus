%% Setting up
clear
clf
load("fluorescence_data.mat")
auto = true; % Temporary, set processing mode

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

fluorescence_array(:, 1) = [(max_length / length(data_array)) : (max_length / length(data_array)) : max_length];
fluorescence_array(:, 2) = data_array;

for k = 1:length(fluorescence_array)
    fluorescence_array(k, 3) = fluorescence_array(k ,2) * 1/(-0.04315 * (1-exp(-0.2237 * fluorescence_array(k, 1))) + 0.3545);
end

shift = fluorescence_array(1, 3) - fluorescence_array(1, 2); % Shift normalised data to origin
for k = 1:length(fluorescence_array)
    fluorescence_array(:, 4) = fluorescence_array(:, 3) - shift;
end

%% Create colourmap
clims = [min(fluorescence_array(:, 2)) max(fluorescence_array(:, 2))]; % Set scale to original data
norm = imagesc(fluorescence_array(:, 4)', clims); % Create scaled colourmap
cmaps = hot(256);
colormap(cmaps);
cb = colorbar;

%% Coregistration
% Converting colourbar into processable rgb image
cdata = norm.CData; % Colourmap data
cmap = colormap(norm.Parent);
num = size(cmap, 1); % Number of colours in colourmap
c = linspace(norm.Parent.CLim(1), norm.Parent.CLim(2), num); % Intensity range
idx = reshape(interp1(c, 1:num, cdata(:), 'nearest'), size(cdata)); % Indexed image
fluorescenceImage = ind2rgb(idx, cmap);
fluorescenceImage = imresize(fluorescenceImage, [size(opusImage, 1), size(opusImage, 2)]); % Scale image

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

    usimage = imshow(opusImage)
    hold on
    fl = imshow(fluorescenceImage);
    set(fl, 'AlphaData', selection);
end
colorbar;