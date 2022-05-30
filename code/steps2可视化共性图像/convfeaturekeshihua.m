%%
net=*  %训练好的网络
pathTrain = imageDatastore('D:\daima\vitfeature\6_AID Data Set', ...
    'IncludeSubfolders',true, ...
    'LabelSource','foldernames');
% imgallpath=imds.Files;
%%
oldpath=pathTrain.Files;
oldwenjianming='6_AID Data Set';
newwenjianming1='AID Data Set Featurelow';
newwenjianming2='AID Data Set Featurehign';
newwenjianming3='AID Data Set Featuresum';
%%
[newpath1]=pathchange(oldpath,oldwenjianming,newwenjianming1);
[newpath2]=pathchange(oldpath,oldwenjianming,newwenjianming2);
[newpath3]=pathchange(oldpath,oldwenjianming,newwenjianming3);
%%  路径转换为原图：D:\daima\vitfeature\6_AID Data Set，newwenjianming1='AID Data Set Featurelow';
%%   则newpath为D:\daima\vitfeature\AID Data Set Featurelow\...
% deepNetworkDesigner
drop1='conv1'    %提取特征图的层名，可于命令行窗口输入AID Data Set Featurelow查看网络结构
drop2='res4b9'   %
% res5c

%%将特征图移动到对应路径
convkeshihua(oldpath,net,drop1,drop2,newpath1,newpath2,newpath3)
%%


