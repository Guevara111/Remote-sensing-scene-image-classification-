function maskImageAdjusted = adjustBlockedImageSize(maskImage,inputImage,resolutionLevel)
% Crop the mask image so that both mask and original image are aligned
% correctly at different resolution levels

% Copyright 2019-2021 The MathWorks, Inc.

if resolutionLevel <= 4
    error('Cannot load the Set resolutionLevel to a value 5 and above');
else
    im = gather(maskImage,'Level',1);
end

% Subtract 2 because we added 1 to the resolution value already which
% should be removed.
numRowsToRemove = maskImage.Size(1,1) - inputImage.Size(1,1)/2^(resolutionLevel-1);
numColsToRemove = maskImage.Size(1,2) - inputImage.Size(1,2)/2^(resolutionLevel-1);

if numRowsToRemove < 0 || numColsToRemove < 0
    error('Expected to find rows or columns to remove');
end

imT = im(1:end-numRowsToRemove,1:end-numColsToRemove-1);
maskImageAdjusted = blockedImage(imT);

maskImageAdjusted.WorldStart(1,:) = inputImage.WorldStart(1,1:2);
maskImageAdjusted.WorldEnd(1,:) = inputImage.WorldEnd(1,1:2);

