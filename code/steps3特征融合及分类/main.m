

%%提取共性特征
scrtrain=* %路径
imageSize = 256;
hsize=50;
[featuretrain_hog,~]=hogfeature(scrtrain,imageSize,hsize);
[featuretest_hog,~]=hogfeature(scrtest,imageSize,hsize);  %提取特征，输入路径为划分的训练集就为提取训练集特征，注意与标签一致

%%共性与特性特征融合
feature_train=[mapminmax(features_train_juanji,0,1),mapminmax(features_train_lbp,0,1)];
feature_test=[mapminmax(features_test_juanji,0,1),mapminmax(features_test_lbp,0,1)];

%%对融合的特征分类
[label_lbp,score_lbp,accuracy_lbp]= svmfenlei(featuretrain_lbp,labeltrainnum,featuretest_lbp,labeltestnum);
[label_train,score_test,accuracy_all]= svmfenlei(feature_train,labeltrainnum,feature_test,labeltestnum);