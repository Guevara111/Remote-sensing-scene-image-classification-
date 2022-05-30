clc
clear
addpath 'C:\Users\admin\Documents\MATLAB\Examples\R2019b\deeplearning_shared\BigimageClassificationUsingDeepLearningExample'
imgpath='D:\acode\yaogan\UCMercedLand256';
Trainpath='D:\acode\yaogan\Train21';
Testpath='D:\acode\yaogan\Test21';
des='D:\acode\yaogan\Train21save';
dms='D:\acode\yaogan\Test21save';
%%
qz=0.3;
beishu=1;
net=googlenet;
%%
imds = imageDatastore(imgpath, ...
    'IncludeSubfolders',true, ...
    'LabelSource','foldernames');
[imdsTrain,imdsTest] = splitEachLabel(imds,qz,'randomized');
%%
numImages = numel(imds.Labels);
numClasses = numel(categories(imds.Labels));
%%
rmdir D:\acode\yaogan\Test21 s
rmdir D:\acode\yaogan\Train21 s
mkdir D:\acode\yaogan\Train21
mkdir D:\acode\yaogan\Test21
cjwenjian(imgpath,Trainpath,Testpath);
%%
numTestImages = numel(imdsTest.Labels);
numTrainImages = numel(imdsTrain.Labels);
toTrain=imdsTrain.Files;
toTest=imdsTest.Files;
%%
for iTrain=1:numTrainImages
    pathTrain1=toTrain{iTrain};
    savepath=strrep(pathTrain1,imgpath,'Train21');
    copyfile(pathTrain1,savepath);
end

for iTest=1:numTestImages
    pathTrain1=toTest{iTest};
    savepath=strrep(pathTrain1,imgpath,'Test21');
    copyfile(pathTrain1,savepath);
end
%%
rmdir D:\acode\yaogan\Train21save s
rmdir D:\acode\yaogan\Test21save s
mkdir D:\acode\yaogan\Train21save
mkdir D:\acode\yaogan\Test21save
%%
numTestImages = numel(imdsTest.Labels);
numTrainImages = numel(imdsTrain.Labels);
idmTrain = imageDatastore(Trainpath, ...
    'IncludeSubfolders',true, ...
    'LabelSource','foldernames');
idmTest = imageDatastore(Testpath, ...
    'IncludeSubfolders',true, ...
    'LabelSource','foldernames');
%%
toTrain=idmTrain.Files;
toTest=idmTest.Files;
[houz]=houzuitiqu(toTrain);
%%
noises=0.0001;
[biaoqian]=databig2(Trainpath,des,toTrain,beishu,numClasses,noises);
%%
Trainsaveimage= imageDatastore(des, ...
    'IncludeSubfolders',true, ...
    'LabelSource','foldernames');
Trainimage = imageDatastore(Trainpath, ...
    'IncludeSubfolders',true, ...
    'LabelSource','foldernames');
Testimage = imageDatastore(Testpath, ...
    'IncludeSubfolders',true, ...
    'LabelSource','foldernames');
%%
[netTransfer,label_juanji,score_juanji,features_train_juanji,features_test_juanji,times]=googlenet21(net,numClasses,Trainsaveimage,Trainimage,Testimage);
% [~,   ~,  accuracy_all]=  qishifenlei(featuresTrain_juanji,labeltrainnum,featuresTest_juanji,labeltestnum)
%%
labels = imds.Labels;
labelsTrain1 = imdsTrain.Labels;
labelsTest1 = imdsTest.Labels;

[labelstrian_num,labelstest_num]=labelsnumbers2(qz,numClasses,numImages);





% [label_juanji,score_juanji]=classify(netTransfer,Testimage);
accuracy_juanji = sum(label_juanji == labelsTest1)/numel(labelsTest1);
sum(score_juanji(:)>=0.9999)
%%

scrtrain=Trainimage.Files;
scrtest=Testimage.Files;

imageSize = length(imread(toTrain{1}));%%%%%%%%%%%%%
hsize=imageSize/2;%hog尺寸64-1680;128-256
[features_train_lbp,features_train_hog]=lbpandhogfeature(scrtrain,imageSize,hsize);
[features_test_lbp,features_test_hog]=lbpandhogfeature(scrtest,imageSize,hsize);
% [featuretrain_lbphog,~]=hoglbp2(scrtrain,imageSize,hsize);
% [featuretest_lbphog,~]=hoglbp2(scrtest,imageSize,hsize);
%%
trainfilename='Train21';
testfilename='Test21';
% [featurecolor]=colorfeaturehsv(allpath);
[features_train_color]=colorhsvhouz(biaoqian,numClasses,trainfilename,houz);
[features_test_color]=colorhsvhouz(biaoqian,numClasses,testfilename,houz);
 %%
 feature_train=[mapminmax(features_train_juanji,0,1),mapminmax(features_train_lbp,0,1),mapminmax(features_train_hog,0,1),mapminmax(features_train_color,0,1)];
 feature_test=[mapminmax(features_test_juanji,0,1),mapminmax(features_test_lbp,0,1),mapminmax(features_test_hog,0,1),mapminmax(features_test_color,0,1)];