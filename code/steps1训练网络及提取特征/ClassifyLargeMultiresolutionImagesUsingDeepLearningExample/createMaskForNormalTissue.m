function createMaskForNormalTissue(normalDir,maskDir,resolutionLevel)
% Write blockedImage masks to disk at the specified resolution level,
% resolutionLevel for tissue regions in images in the directory normalDir.
% The masks are written to disk at the specified location, maskDir. The
% masks are used during training to read the image blocks containing
% tissue.
%
% The function gets the image at the specified resolution level, converts
% the image to the L*a*b* color space, and performs Otsu thresholding of
% the a* channel.
%
% The Camelyon16 normal training file "normal_144.tif" cannot be read by a
% |blockedImage| object, so do not create a mask for this image.

% Copyright 2019-2021 The MathWorks, Inc.

imds = imageDatastore(normalDir,'FileExtensions',{'.tif'});
for idx = 1:length(imds.Files)
    [~,name] = fileparts(imds.Files{idx});
    
    if strcmp(name,"normal_144")
        continue
    end
    
    maskImageDirName = strcat(name,'_mask');
    if ~exist(fullfile(maskDir,maskImageDirName),'dir')
        im = blockedImage(imds.Files{idx});
        ref = setSpatialReferencingForCamelyon16(imds.Files{idx});
        numSpatialDiff = im.NumLevels - numel(ref);
        refIdx = 1;
        for imRefIdx = 1:im.NumLevels
            if imRefIdx == 7 && numSpatialDiff > 0 && ~strcmp(name,"normal_114")...
                    && ~strcmp(name,"normal_145")
                % Skip level 7 as this is not image data. Some images are
                % exceptions. For example: "normal_114.tif" does not have
                % extra levels so no need to skip
                continue;
            end
            
            if (strcmp(name,"normal_114") || strcmp(name,"normal_145")) && imRefIdx == 9
                continue
            end
            
            if refIdx <= numel(ref)
                im.WorldStart(imRefIdx,:) = [ref(refIdx).YWorldLimits(:,1) ref(refIdx).XWorldLimits(:,1) 0.5];
                im.WorldEnd(imRefIdx,:) = [ref(refIdx).YWorldLimits(:,2) ref(refIdx).XWorldLimits(:,2) 3.5];
                refIdx = refIdx + 1;
            end
        end
        
        % Process the full image at specified level. If the resolution
        % level does not fit in memory, then throw an error.
        if resolutionLevel <= 4
            error('Cannot load the image in memory. Specify resolutionLevel greater than or equal to 5.');
        end
        
        % Adjust the resolution level to skip the mask and read image data.
        % This typically affects resolution levels 7 and above.
        if (numSpatialDiff > 0 && resolutionLevel > 6 && ~strcmp(name,"normal_114")...
                && ~strcmp(name,"normal_145")) || ...
                ((strcmp(name,"normal_114") || strcmp(name,"normal_145")) && resolutionLevel >= 9)
            resolutionLevel = resolutionLevel + 1;
        end
        
        I = gather(im, 'Level', resolutionLevel);
        
        % Create a mask for normal tissue.
        Ilab = rgb2lab(I);
        A = Ilab(:,:,2);
        
        AScaled = rescale(A);
        AThreshold = imbinarize(AScaled);
        
        se = strel('disk',10);
        mask = imopen(AThreshold,se);
        
        % Make a blockedImage out of the image mask and set its spatial reference
        maskImage = blockedImage(mask);
        maskImage.WorldStart = im.WorldStart(resolutionLevel,1:2);
        maskImage.WorldEnd = im.WorldEnd(resolutionLevel,1:2);
        
        maskImageDirPathName = fullfile(maskDir,maskImageDirName);
        
        % Restore the resolution level        
        if (numSpatialDiff > 0 && resolutionLevel > 6 && ~strcmp(name,"normal_114")...
                && ~strcmp(name,"normal_145")) || ...
                ((strcmp(name,"normal_114") ||strcmp(name,"normal_145")) && resolutionLevel >= 9)
            resolutionLevel = resolutionLevel - 1;
       end
        
        maskImage = adjustBlockedImageSize(maskImage,im,resolutionLevel);
        write(maskImage,maskImageDirPathName);
        fprintf('Done with %s\n',name);
    end
end
end