net = googlenet;
numClasses=1;
imdsTrain= imageDatastore({'E:\遥感\acode\yaogan\UCMercedLand256\airplane\airplane00.tif'});
addpath 'C:\Users\admin\Documents\MATLAB\Examples\R2021a\deeplearning_shared\ClassifyLargeMultiresolutionImagesUsingDeepLearningExample'
% Trainimage
% imdsTest

% net=googlenet;
if isa(net,'SeriesNetwork') 
  lgraph = layerGraph(net.Layers); 
else
  lgraph = layerGraph(net); 
end 

[learnableLayer,classLayer] = findLayersToReplace(lgraph);
inputSize = net.Layers(1).InputSize;
% numClasses = numel(categories(imdsTrain.Labels));

if isa(learnableLayer,'nnet.cnn.layer.FullyConnectedLayer')
    newLearnableLayer = fullyConnectedLayer(numClasses, ...
        'Name','new_fc', ...
        'WeightLearnRateFactor',10, ...
        'BiasLearnRateFactor',10);
    
elseif isa(learnableLayer,'nnet.cnn.layer.Convolution2DLayer')
    newLearnableLayer = convolution2dLayer(1,numClasses, ...
        'Name','new_conv', ...
        'WeightLearnRateFactor',10, ...
        'BiasLearnRateFactor',10);
end
lgraph = replaceLayer(lgraph,learnableLayer.Name,newLearnableLayer);
% analyzeNetwork
newClassLayer = classificationLayer('Name','new_classoutput');
lgraph = replaceLayer(lgraph,classLayer.Name,newClassLayer);


pixelRange = [-30 30];
scaleRange = [0.9 1.1];
imageAugmenter = imageDataAugmenter( ...
    'RandXReflection',true, ...
    'RandXTranslation',pixelRange, ...
    'RandYTranslation',pixelRange, ...
    'RandXScale',scaleRange, ...
    'RandYScale',scaleRange);


augimdsTrain = augmentedImageDatastore(inputSize(1:2),imdsTrain);
% augimdsValidation = augmentedImageDatastore(inputSize(1:2),imdsTest);
% augimdstrain = augmentedImageDatastore(inputSize(1:2),Trainimage);
miniBatchSize = 64;
% valFrequency = floor(numel(augimdsTrain.Files)/miniBatchSize);
% valFrequency = floor(numel(augimdsTrain.Files)/miniBatchSize);
options = trainingOptions('sgdm', ...
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs',10, ...
    'InitialLearnRate',3e-4, ...
    'Shuffle','every-epoch', ...
    'Verbose',1, ...
    'Plots','none');
net = trainNetwork(augimdsTrain,lgraph,options);
%    'ValidationData',augimdsValidation, ...

layer = 2;
name = net.Layers(layer).Name;
channels = 1:36;
I = deepDreamImage(net,name,channels, ...
    'PyramidLevels',1);
figure
I = imtile(I,'ThumbnailSize',[64 64]);
imshow(I)
title(['Layer ',name,' Features'],'Interpreter','none')