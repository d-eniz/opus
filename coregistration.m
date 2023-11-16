%% Setting up
clear
clf
scan_depth = 30; % in milimetres

opusImage = imread(fullfile('imgs', 'slope_image.png'));
if ndims(opusImage) == 3 && size(opusImage, 3) == 3 % If image is RGB convert to greyscale
    opusImage = rgb2gray(opusImage);
end

fluorescenceImage = imread(fullfile('imgs', 'fluorescence.png'));
fluorescenceImage = imresize(fluorescenceImage, [size(opusImage, 1), size(opusImage, 2)]); % Normalize

peakPos = zeros(size(opusImage)); % Empty matrix to store surface positions

%% Finding surface layer
threshold = 50; % Greyscale value threshold

for col = 1:size(opusImage, 2)
    peakFound = false;
    for row = 1:size(opusImage, 1)
        if opusImage(row, col) > threshold % Considers pixels above threshold on greyscale image
            peakPos(row, col) = 1;
            peakFound = true;
        elseif peakFound % Breaks if a second layer is found
            break;
        end
    end
end

%% Image processing
imshowpair(opusImage, uint8(peakPos), 'blend');
selection = opusImage .* uint8(roipoly); % Create region of interest using polygonal lasso

imshow(opusImage)
hold on
fl = imshow(fluorescenceImage);
set(fl, 'AlphaData', selection)