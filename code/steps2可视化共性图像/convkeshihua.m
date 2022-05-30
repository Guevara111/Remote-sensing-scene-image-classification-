function convkeshihua(oldpath,net,drop1,drop2,newpath1,newpath2,newpath3)
for i=1:length(oldpath)
    im = imread(oldpath{i});
    %%
    act1 = activations(net,im,drop1);
    sz1 = size(act1);
    act1 = reshape(act1,[sz1(1) sz1(2) 1 sz1(3)]);
    [~,maxValueIndex1] = max(max(max(act1)));
    act1chMax1 = act1(:,:,:,maxValueIndex1);
    act1chMax1 = mat2gray(act1chMax1);
    act1chMax1 = imresize(act1chMax1,[600 600]);
    I1 = imtile({im,act1chMax1});
    imwrite(I1,newpath1{i})
    %%
    act2 = activations(net,im,drop2);
    sz2 = size(act2);
    act2 = reshape(act2,[sz2(1) sz2(2) 1 sz2(3)]);
    [~,maxValueIndex2] = max(max(max(act2)));
    act1chMax2 = act2(:,:,:,maxValueIndex2);
    act1chMax2 = mat2gray(act1chMax2);
    act1chMax2 = imresize(act1chMax2,[600 600]);
    I2 = imtile({act1chMax1,act1chMax2});
    
    imwrite(I2,newpath2{i})
    %%
    I3=act1chMax1+act1chMax2;
    imwrite(I3,newpath3{i})
    
    
    
end



end
    