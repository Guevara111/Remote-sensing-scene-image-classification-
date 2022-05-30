function [bigImages,bigMasks] = createBlockedImageAndMaskArrays(imageDir,maskDir)
% Create an array of blockedImage objects and corresponding blockedImage masks from
% the input folders, imageFolder and maskFolder respectively for the
% specified image indices in imgIdx. The imgIdx corresponds to the index of
% the image file in the folder.
%
% The Camelyon16 normal training file "normal_144.tif" cannot be read by a
% |blockedImage| object, so do not create a blockedImage from this file.

% Copyright 2019-2021 The MathWorks, Inc.

imds = imageDatastore(imageDir,'FileExtensions',{'.tif'});

bigArrayIdx = 1;
for imgIdx = 1:length(imds.Files)
    imageFullFileName = imds.Files{imgIdx};
    [~,name] = fileparts(imageFullFileName);
    
    if strcmp(name,"normal_144")
        continue
    end
    
    maskImageDirName = strcat(name,'_mask');
    
    bigImages(bigArrayIdx) = blockedImage(imageFullFileName);
    ref = setSpatialReferencingForCamelyon16(imageFullFileName);
    numSpatialRef = numel(ref);
    numSpatialDiff = bigImages(bigArrayIdx).NumLevels - numSpatialRef;
    refIdx = 1;
        for imRefIdx = 1:bigImages(bigArrayIdx).NumLevels
            if imRefIdx == 7 && numSpatialDiff > 0 && ~strcmp(name,"normal_114")...
                    && ~strcmp(name,"normal_145")
                % For example: "normal_101.tif" does not have extra levels so no need to
                % skip
                % Skip level 7 as this is not image data
                continue;
            end
            
            if (strcmp(name,"normal_114") ||strcmp(name,"normal_145")) && imRefIdx == 9
                continue
            end
            
            if refIdx <= numel(ref)
                bigImages(bigArrayIdx).WorldStart(imRefIdx,:) = [ref(refIdx).YWorldLimits(:,1) ref(refIdx).XWorldLimits(:,1) 0.5];
                bigImages(bigArrayIdx).WorldEnd(imRefIdx,:) = [ref(refIdx).YWorldLimits(:,2) ref(refIdx).XWorldLimits(:,2) 3.5];
                refIdx = refIdx + 1;
            end
        end
    
    bigMasks(bigArrayIdx) = blockedImage(fullfile(maskDir,maskImageDirName));
    bigArrayIdx = bigArrayIdx+1;
end