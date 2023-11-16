%% Setting up
clear

opusImage = imread(fullfile('imgs', 'test1.png'));
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
selected_pixels = opusImage .* uint8(roipoly); % Create region of interest using polygonal lasso
selected_pixels(selected_pixels > 0) = 1;
mask = bsxfun(@times, fluorescenceImage, selected_pixels); % Create mask

orgImage = opusImage;
opusImage(~selected_pixels) = 0; % Remove masked pixels
finalImage = orgImage - opusImage + mask;

imshow(finalImage)