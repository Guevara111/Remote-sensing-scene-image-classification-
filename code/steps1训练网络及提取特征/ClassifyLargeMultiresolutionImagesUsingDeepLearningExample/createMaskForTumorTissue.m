function createMaskForTumorTissue(tumorDir,annotationDir,maskDir,resolutionLevel)
% Write blockedImage masks at the specified resolution level, resolutionLevel
% for tumor regions in images in the directory tumorDir. The tumor regions
% (lesion annotations) are specified in the XML files in the directory
% annotationDir. The masks are written to disk at the specified location,
% maskDir.
%
% The lesion annotations in XML files are read and converted to polygons.
% The polygons are used to create image masks on a block-by-block basis.
% The masks are written to disk and used during training to read the image
% blocks containing tumor.

% Copyright 2019-2021 The MathWorks, Inc.

imds = imageDatastore(tumorDir,'FileExtensions',{'.tif'});
for idx = 1:length(imds.Files)
    [~,name] = fileparts(imds.Files{idx});
    maskImageDir = strcat(name,'_mask');
    if ~exist(fullfile(maskDir,maskImageDir),'dir')
        xmlName = strcat(name,'.xml');
        xmlFullPath = fullfile(annotationDir,xmlName);
        
        [cancer,noncancer] = readLesionAnnotations(xmlFullPath);
        roiCancer = createPolygonROIsFromAnnotations(cancer);
        roiNonCancer = createPolygonROIsFromAnnotations(noncancer);
        
        im = blockedImage(imds.Files{idx});
        ref = setSpatialReferencingForCamelyon16(imds.Files{idx});
        numSpatialDiff = im.NumLevels - numel(ref);
        refIdx = 1;
        for imRefIdx = 1:im.NumLevels
            if imRefIdx == 7 && numSpatialDiff > 0
                % Skip level 7 as this is not image data
                continue;
            end
            
            if imRefIdx == 9
                continue
            end
            
            if refIdx <= numel(ref)
                im.WorldStart(imRefIdx,:) = [ref(refIdx).YWorldLimits(:,1) ref(refIdx).XWorldLimits(:,1) 0.5];
                im.WorldEnd(imRefIdx,:) = [ref(refIdx).YWorldLimits(:,2) ref(refIdx).XWorldLimits(:,2) 3.5];
                refIdx = refIdx + 1;
            end
        end
        
        % Adjust the resolution level to skip the mask and read image data.
        % This typically affects resolution levels 7 and above.
        refAtResolutionLevel = ref(resolutionLevel);
        if (numSpatialDiff > 0 && resolutionLevel > 6 ) || ...
                (resolutionLevel >= 9)
            resolutionLevel = resolutionLevel + 1;
        end
        
        % Create and write masks at resolution level
        blockSizeAtResolutionLevel = im.BlockSize(resolutionLevel,1:2);
        maskImage = createMaskFromPolygonData(refAtResolutionLevel, blockSizeAtResolutionLevel, roiCancer,roiNonCancer);
        maskImageDirPathName = fullfile(maskDir,maskImageDir);
        
        % Restore the resolution level
        if (numSpatialDiff > 0 && resolutionLevel > 6 ) || ...
                (resolutionLevel >= 9)
            resolutionLevel = resolutionLevel - 1;
        end
        
        maskImage = adjustBlockedImageSize(maskImage,im,resolutionLevel);
        write(maskImage,maskImageDirPathName);
        fprintf('Done with %s\n',name);
    end
end
end


function [maskROICancer,maskROINonCancer] = readLesionAnnotations(xmlFilename)
% Read lesion annotation postions from the XML file, xmlFilename and return
% the cell arrays of region positions containing cancer in maskROICancer
% and region positions of normal tissue within cancer regions in
% maskROINonCancer

maskROINonCancer = {};
maskROICancer = {};

if ~exist(xmlFilename,'file')
    warning('The lesion annotaions XML file, %s does not exist.\n',xmlFilename);
    return
end

s = xml2struct(xmlFilename);
annotations = s.ASAP_Annotations.Annotations.Annotation;
if ~iscell(annotations)
    annotations = {annotations};
end

numAnnotations = length(annotations);

for idx = 1:numAnnotations
    out = cellfun(@(c) [str2double(c.Attributes.X),str2double(c.Attributes.Y)],annotations{idx}.Coordinates.Coordinate,'UniformOutput',false);
    if strcmp(annotations{idx}.Attributes.PartOfGroup,'_2')
        maskROINonCancer{end+1} = cat(1,out{:});
    else
        maskROICancer{end+1} = cat(1,out{:});
    end
end
end

function roiOut = createPolygonROIsFromAnnotations(annotationCell)
% Create images.roi.Polygon objects from lesion annotation positions

numPolygons = length(annotationCell);
roiOut = repmat(images.roi.Polygon.empty(),numPolygons,1);
for idx = 1:numPolygons
    roiOut(idx) = images.roi.Polygon('Position',annotationCell{idx},'Visible','off');
end

end


function imageMask = createMaskFromPolygonData(inputSpatialRef, blockSize, roiCancerArray, roiNonCancerArray)
% Create blockedImage masks for the blockedImage input, imageInput from the lesion
% annotations represented as polygons using images.roi.Polygon objects at
% the specified resolution level, resolutionLevel. The polygons are
% provided for cancer and non-cancer regions within the cancer regions. The
% non-cancer regions have to be excluded when present from the mask.

pixelExtent = [inputSpatialRef.PixelExtentInWorldX, inputSpatialRef.PixelExtentInWorldY];

imageMask = blockedImage([], [inputSpatialRef.ImageSize(1) inputSpatialRef.ImageSize(2)], blockSize, false, "Mode", "w");

for cStart = 1:imageMask.BlockSize(2):inputSpatialRef.ImageSize(2)
    for rStart = 1:imageMask.BlockSize(1):inputSpatialRef.ImageSize(1)
        % Center of top left pixel of this block in world units
        rcStart = [rStart, cStart];
        crStart = fliplr(rcStart);
        xyStart = crStart.* pixelExtent;
        
        % Center of bottom right pixel of this block in world units
        bsize = fliplr(imageMask.BlockSize);
        xyEnd = (crStart + (bsize-1)).* pixelExtent;
        
        % Meshgrid in world units for all pixels in this block.
        [xgrid, ygrid] = meshgrid(xyStart(1):inputSpatialRef.PixelExtentInWorldX:xyEnd(1),...
            xyStart(2):inputSpatialRef.PixelExtentInWorldY:xyEnd(2));
        
        blockMask = false(imageMask.BlockSize);
        % Check if any cancer ROIs fall within the block
        for rInd = 1:length(roiCancerArray)
            roiPositions = (roiCancerArray(rInd).Position);
            blockMask = blockMask | inpolygon(xgrid, ygrid, roiPositions(:,1), roiPositions(:,2));
            % If any cancer ROIs are within the block, don't use the mask.
            if any(blockMask(:))
                fprintf('Found tumors in the image block with extents, X = [%d, %d] and Y = [%d, %d]\n',xgrid(1,1),xgrid(end,end),ygrid(1,1),ygrid(end,end));
            end
        end
        
        % The dataset includes a set of non-cancer ROI regions within tumor
        % annotations which need to be excluded.
        blockExcludeMask = false(imageMask.BlockSize);
        for rInd = 1:length(roiNonCancerArray)
            roiPositions = (roiNonCancerArray(rInd).Position);
            blockExcludeMask = blockExcludeMask | inpolygon(xgrid, ygrid, roiPositions(:,1), roiPositions(:,2));
        end
        blockMask(blockExcludeMask) = false;
        
        pixelRCStart = sub2blocksub(imageMask, rcStart);
        setBlock(imageMask, pixelRCStart, blockMask);
    end
end

% Switch to read mode
imageMask.Mode = 'r';

end
