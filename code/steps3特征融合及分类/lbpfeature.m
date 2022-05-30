%% 利用HOG + LBP分类
function [hogfeature,hoglabel]=lbpfeature(scr,imageSize,hsize)
%% 1 数据集，包括训练的和测试的 
% currentPath = pwd;  % 获得当前的工作目录
filename=char(scr);
trianhog = imageDatastore(fullfile(pwd,filename),... 
    'IncludeSubfolders',true,... 
    'LabelSource','foldernames');   % 载入图片集合
 
% testhog = imageDatastore(fullfile(pwd,'Test21'),... 
%     'IncludeSubfolders',true,... 
%     'LabelSource','foldernames');
 
% imdsTrain = imageDatastore('C:\Program Files\MATLAB\R2017a\bin\proj_xiangbin\train_images',... 
%     'IncludeSubfolders',true,... 
%     'LabelSource','foldernames'); 
% imdsTest = imageDatastore('C:\Program Files\MATLAB\R2017a\bin\proj_xiangbin\test_image'); 
   
%%   2 对训练集中的每张图像进行hog特征提取，测试图像一样 
% 预处理图像,主要是得到features特征大小，此大小与图像大小和Hog特征参数相关 
 
% %% LBP参数
imageSize = [imageSize,imageSize];% 对所有图像进行此尺寸的缩放 
% I = readimage(trianhog,1);
% I = imresize(I,imageSize); 
% I = rgb2gray(I);
% lbpFeatures = extractLBPFeatures(I,'CellSize',[32 32],'Normalization','None');
% numNeighbors = 8;
% % Upright = false;
% numBins = numNeighbors*(numNeighbors-1)+3; % numNeighbors+2;
% lbpCellHists = reshape(lbpFeatures,numBins,[]);
% lbpCellHists = bsxfun(@rdivide,lbpCellHists,sum(lbpCellHists));
% lbpFeatures = reshape(lbpCellHists,1,[]);
% % 对所有训练图像进行特征提取 
numImages = length(trianhog.Files); 
% featuresTrain1 = zeros(numImages,size(lbpFeatures,2),'single'); % featuresTrain为单精度
% % featuresTest1 = zeros(numImages,size(lbpFeatures,2),'single'); 
   
% scaleImage = imresize(I,imageSize); 
% [features, visualization] = extractHOGFeatures(scaleImage,'CellSize',[8,8]);
% featuresTrain2 = zeros(numImages,size(features,2),'single'); % featuresTrain为单精度
% featuresTrain1 = zeros(numImages,size(features,2),'single'); % featuresTrain为单精度
for i = 1:numImages 
    imageTrain = readimage(trianhog,i); 
    imageTrain = imresize(imageTrain,imageSize); 
    % LBP
    I = rgb2gray(imageTrain);
    lbpFeatures = extractLBPFeatures(I,'CellSize',[hsize hsize],'Normalization','None');
%     numNeighbors = 8;
%     numBins = numNeighbors*(numNeighbors-1)+3;
%     lbpCellHists = reshape(lbpFeatures,numBins,[]);
%     lbpCellHists = bsxfun(@rdivide,lbpCellHists,sum(lbpCellHists));
%     lbpFeatures = reshape(lbpCellHists,1,[]);
    
    featuresTrain1(i,:) = lbpFeatures; 
     
    % HOG
%     featuresTrain2(i,:) = extractHOGFeatures(imageTrain,'CellSize',[hsize,hsize]);   
     
end 
 
% 特征合并
featuresTrain = featuresTrain1;
% featuresTrain = featuresTrain2;
% featuresTrain = featuresTrain1;
% 所有训练图像标签 

trainLabels = trianhog.Labels; 
% for ihog=1:numClasses
%     for jhog=1:(numImages/numClasses)
%         hog{1,i}=featuresTrain(jhog+((numImages/numClasses)*ihog),:);
%         hog{2,i}=cellstr(trainLabels(jhog((numImages/numClasses)*ihog),1));
%     end
% end
for ihog=1:numImages
    hog{1,ihog}=featuresTrain(ihog,:);
    hog{2,ihog}=cellstr(trainLabels(ihog,1));
end
for ijsq=1:numImages
    kp=hog{1,ijsq};
    hogfeature(ijsq,:)=kp;
    hoglabel(1,ijsq)=hog{2,ijsq};
end

% save('hog.mat',hog)
clear lbpfeature
end

        
% 开始svm多分类训练，注意：fitcsvm用于二分类，fitcecoc用于多分类,1 VS 1方法 
% classifer = fitcecoc(featuresTrain,trainLabels); 
% %    
% correctCount = 0;
% % 预测并显示预测效果图 
% numTest = length(testhog.Files); 
% for i = 1:numTest 
%     testImage = readimage(testhog,i);  %  imdsTest.readimage(1)
%     scaleTestImage = imresize(testImage,imageSize); 
%     % LBP
%     I = rgb2gray(scaleTestImage);
%     lbpFeatures = extractLBPFeatures(I,'CellSize',[16 16],'Normalization','None');
%     numNeighbors = 8;
%     numBins = numNeighbors*(numNeighbors-1)+3;
%     lbpCellHists = reshape(lbpFeatures,numBins,[]);
%     lbpCellHists = bsxfun(@rdivide,lbpCellHists,sum(lbpCellHists));
%     featureTest1 = reshape(lbpCellHists,1,[]);
%      
%     % HOG
%     featureTest2 = extractHOGFeatures(scaleTestImage,'CellSize',[8,8]);
%     %合并
%     featureTest = featureTest2;
%     
%     [predictIndex,score] = predict(classifer,featureTest); 
%    % figure;imshow(imresize(testImage,[256 256]));
%      
%     imgName = testhog.Files(i);
%     tt = regexp(imgName,'\','split');
%     cellLength =  cellfun('length',tt);
%     tt2 = char(tt{1}(1,cellLength));
%         % 统计正确率
%     if strfind(tt2,char(predictIndex))==1
%         correctCount = correctCount+1;
%     end
%     title(['predictImage: ',tt2,'--',char(predictIndex)]); 
%     fprintf('%s == %s\n',tt2,char(predictIndex));
% end
%  
% % 显示正确率
% fprintf('分类结束，正确了为：%.3f%%\n',correctCount * 100.0 / numTest);