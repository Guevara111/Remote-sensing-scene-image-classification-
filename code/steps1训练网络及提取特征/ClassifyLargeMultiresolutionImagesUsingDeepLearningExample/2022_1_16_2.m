net = googlenet;
inputSize = net.Layers(1).InputSize;
imdsTrain= imageDatastore({'E:\遥感\acode\yaogan\UCMercedLand256\airplane\airplane00.tif'});
augimdsTrain = augmentedImageDatastore(inputSize(1:2),imdsTrain);
options = trainingOptions('sgdm', ...
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs',10, ...
    'InitialLearnRate',3e-4, ...
    'Verbose',1, ...
    'Plots','none');

net = trainNetwork(augimdsTrain,lgraph,options);

layer = 2;
name = net.Layers(layer).Name;
channels = 1:36;
I = deepDreamImage(net,name,channels, ...
    'PyramidLevels',1);
figure
I = imtile(I,'ThumbnailSize',[64 64]);
imshow(I)
title(['Layer ',name,' Features'],'Interpreter','none')