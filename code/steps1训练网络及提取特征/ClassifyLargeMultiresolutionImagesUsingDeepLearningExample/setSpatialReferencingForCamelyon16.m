function spatialRefOut = setSpatialReferencingForCamelyon16(fileName)
% setSpatialReferencingForCamelyon16 Gets the spatial referencing
% information for each resolution level from the image file metadata

% Copyright 2019 The MathWorks, Inc.

metadata = extractMetadataFromTiff(fileName);

pixelDataMetadata = metadata.PIM_DP_SCANNED_IMAGES.Item_1.PIIM_PIXEL_DATA_REPRESENTATION_SEQUENCE;
numLevels = numel(fields(pixelDataMetadata));
spatialRefOut = repmat(imref2d.empty(),numLevels,1);


numRowsBase = pixelDataMetadata.Item_1.PIIM_PIXEL_DATA_REPRESENTATION_ROWS;
numColsBase = pixelDataMetadata.Item_1.PIIM_PIXEL_DATA_REPRESENTATION_COLUMNS;
spatialRefOut(1) = imref2d([numRowsBase,numColsBase]);
spatialRefOut(1).XWorldLimits = [0 spatialRefOut(1).ImageSize(2)];
spatialRefOut(1).YWorldLimits = [0 spatialRefOut(1).ImageSize(1)];


for levels = 2:numLevels
    item = pixelDataMetadata.(sprintf('Item_%d',levels));
    
    numRows = double(item.PIIM_PIXEL_DATA_REPRESENTATION_ROWS);
    numCols = double(item.PIIM_PIXEL_DATA_REPRESENTATION_COLUMNS);
    
    XSpacing = double(item.DICOM_PIXEL_SPACING(2)) ./ double(pixelDataMetadata.Item_1.DICOM_PIXEL_SPACING(2));
    YSpacing = double(item.DICOM_PIXEL_SPACING(1)) ./ double(pixelDataMetadata.Item_1.DICOM_PIXEL_SPACING(1));

    % Make sure that all referencing objects are aligned to left edge
    ref = imref2d([numRows,numCols],XSpacing,YSpacing);
    ref.XWorldLimits = [0 ref.ImageSize(2)*XSpacing];
    ref.YWorldLimits = [0 ref.ImageSize(1)*YSpacing];    
    
    spatialRefOut(levels) = ref;
end

end

function metadata = extractMetadataFromTiff(filename)

info = imfinfo(filename);
if (isfield(info, 'ImageDescription'))
    T = Tiff(filename, 'r');
    rawMetadataChar = T.getTag(Tiff.TagID.ImageDescription);
else
    metadata = struct([]);
    return
end

if strfind(rawMetadataChar, '<?xml')
    isInArray = false;
    rawMetadataStr = string(rawMetadataChar);
    metadata = convertXML(rawMetadataStr, isInArray);
else
    metadata = struct([]);
end

end


function [metadata, s] = convertXML(s, isInArray)

openings = strfind(s, "<");
closings = strfind(s, ">");

assert(numel(openings) == numel(closings));

metadata = struct([]);
attributeName = [];
attributeType = [];

itemNumber = 0;

while (strlength(s) > 0) && (numel(openings) > 0)
    substr = extractBetween(s, openings(1)+1, closings(1)-1);
    
    if isempty(substr) || isequal(substr{1}(1), '?')
        % No-op
    else
        parts = split(substr, " ");
        tagName = parts(1);

        switch tagName
        case "Attribute"
            isName = startsWith(parts, "Name");
            namePart = parts(isName);
            attributeName = extractBetween(namePart, '"', '"');

            isType = startsWith(parts, "PMSVR");
            typePart = parts(isType);
            attributeType = extractBetween(typePart, '"', '"');
        case "/Attribute"
            if attributeType ~= "IDataObjectArray"
                attributeValueEnd = openings(1) - 1;
                attributeValue = s{1}(1:attributeValueEnd);
                value = convert(attributeValue, attributeType);
                if isInArray
                    metadata(1).("Item_" + itemNumber).(attributeName) = value;
                else
                    metadata(1).(attributeName) = value;
                end
            end
        case "Array"
            % Recurse
            willBeInArray = true;
            s = extractAfter(s, closings(1));
            if itemNumber > 0
                [metadata(1).("Item_" + itemNumber).(attributeName), s] = convertXML(s, willBeInArray);
            else
                [metadata(1).(attributeName), s] = convertXML(s, willBeInArray);
            end
            
            openings = strfind(s, "<");
            closings = strfind(s, ">");
            continue  % Don't update openLocs, closeLocs twice
        case "/Array"
            % Leave array context
            s = extractAfter(s, closings(1));
            break
        case "DataObject"
            if isInArray
                itemNumber = itemNumber + 1;
            end
        case "/DataObject"
            % No-op
        otherwise

        end
    end
    
    newStart = closings(1);
    s = extractAfter(s, closings(1));
    openings = openings - newStart;
    closings = closings - newStart;
    openings(1) = [];
    closings(1) = [];
end

end


function value = convert(rawValue, attributeType)

switch attributeType
    case "IString"
        value = string(rawValue);
    case "IDataObjectArray"
        assert(false)
    case "IUInt16"
        value = uint16(sscanf(rawValue, '%d'));
    case "IDoubleArray"
        rawValue = strrep(rawValue, '&quot;', '');
        value = sscanf(rawValue, '%f')';
    case "IUInt32"
        value = uint32(sscanf(rawValue, '%d'));
    case "IStringArray"
        rawValue = strrep(rawValue, '&quot;', '"');
        rawValue = strrep(rawValue, '" ', '"\');
        rawValue = string(rawValue);
        value = split(rawValue, "\");
        value = strrep(value, """", "");
end
end
