%% Setting up
opusImage = imread('test2.png');
if ndims(opusImage) == 3 && size(opusImage, 3) == 3 % If image is RGB convert to greyscale
    opusImage = rgb2gray(opusImage);
end

fluorescenceImage = imread('fluorescence.png');
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

%% Create image
peakPos = cast(peakPos, 'like', fluorescenceImage); % Change data type

maskedRgbImage = bsxfun(@times, fluorescenceImage, peakPos); % Create RGB mask

orgImage = opusImage;
opusImage(~peakPos) = 0; % Remove masked pixels

finalImage = orgImage - opusImage + maskedRgbImage;

imshow(finalImage)