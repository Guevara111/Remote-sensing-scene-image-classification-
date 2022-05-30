function downloadTrainedCamelyonNet(url,destination)
% DOWNLOADTRAINEDCAMELYONNET Helper function to download the pretrained 
% Inception-v3 network to classify Cameylon16 WSIs.
%

%   Copyright 2019 The MathWorks, Inc.

filename = 'trainedCamelyonNet.mat';
netDirFullPath = destination;
netFileFullPath = fullfile(destination,filename);

if ~exist(netFileFullPath,'file')
    fprintf('Downloading pretrained Inception-v3 network for Cameylon16 data.\n');
    fprintf('This can take several minutes to download...\n');
    if ~exist(netDirFullPath,'dir')
        mkdir(netDirFullPath);
    end
    websave(netFileFullPath,url);
    fprintf('Done.\n\n');
else
    fprintf('Pretrained Inception-v3 network for Cameylon16 data set already exists.\n\n');
end
end