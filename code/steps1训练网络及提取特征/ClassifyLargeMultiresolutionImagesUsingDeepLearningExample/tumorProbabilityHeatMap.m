function out = tumorProbabilityHeatMap(im,trainedNet)
% Create a tumor probability heat map. Use the tumor probability score
% output of calling predict() for each image block to create a heat map.
% The output heatmap has the same spatial dimensions as the input image
% block (patch). Before inference, apply the same stain normalization and
% convert the data range to [0 1] just as we did while training.

% Copyright 2019-2021 The MathWorks, Inc. 

if size(im.Data,1)< 299 || size(im.Data,2) < 299
    disp(['Block size is ' num2str(size(im.Data,1)) ' x ' num2str(size(im.Data,2)) ]);
    % Set the heat map to zeros at the bigimage boundaries
    out = zeros(size(im.Data,1:2));
    return
end

probScores = predict(trainedNet,im2double(normalizeStaining(im.Data,true,255))/255);

% Create a heat map based on the tumor probability score
out = ones(size(im.Data,1:2)).*probScores(2);