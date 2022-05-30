function [biaoqian]=databig2(src,des,toTrain,beishu,leibie,noises)


% %图片路径
% src='F:\yaogan\Train21';
% %存取路径
% des='F:\yaogan\Train21save';
pathlist1=dir(src);
filenum1=length(pathlist1);
filenamelist1={pathlist1.name};
gammma=[5 5 5 5 0.8 1.2 0.6 1.4 0.9 1.1];
%%

%
%  load('toTrain.mat')
%%

biaoqian={1,leibie};
for iikk=3:filenum1
    biaoqian(1,iikk-2)=filenamelist1(1,iikk);
end
%%
%由于得到的filenamelist第一个是.第二个是..第三个才是文件夹名，
%故i从3开始
for iiii=0:beishu
    jsq=1;
    leijia=0;
    for i=3:filenum1
        %做一次嵌套，目的是读取子文件夹中的图片
        imgsrcpath=[src,'\',filenamelist1{i}];
        imgdespath=[des,'\',filenamelist1{i}];
        mkdir(imgdespath);         %%%%%%%%%%%创建同名文件夹
        pathlist2=dir(imgsrcpath);
        filenum2=length(pathlist2);
        %     filenamelist2={pathlist2.name};
%         filenamelist2={};
%         filenamelist2(1,1)={pathlist2(1).name};
%         filenamelist2(1,2)={pathlist2(2).name};
        
        
        
 
        count=0;
        
        %    for i=1:1000
        %    a=sprintf('%04.0f',aa(i))
        %    a=strcat(a,'.jpg')
        %     end
        
        
        for ik=3:filenum2
%             kp=sprintf('%02.0f',count);
            %         kq=sprintf('%04.0f',count+100);
            kq=sprintf('%04.0f',count+iiii*100);
            %         bq=sprintf(biaoqian);
%             filenamelist2(1,ik)=cellstr(strcat(biaoqian(1,jsq),kp,'.tif'));
            filenamelist3(1,ik)=cellstr(strcat(biaoqian(1,jsq),kq,'.tif'));
            count=count+1;
        end
        jsq=jsq+1;
        
        
        for j=3:filenum2
            %         imgsrcpath1=[imgsrcpath,'\',filenamelist2{j}];
            %         imgsrcpath1=[imgsrcpath,'\',filenamelist2{j}];
            imgdespath1=[imgdespath,'\',filenamelist3{j}];
            leijia=leijia+1;
            imgsrc=imread(toTrain{leijia});
            %imgdes=imresize(imgsrc,[160,160],'bilinear');
            %imgdes=imresize(imgsrc,[227,227]);%切割
            %         imgdes=mirror(imgsrc,1);%水平旋转
            
            if iiii==0
                imgdes=imgsrc;
            elseif (0<iiii)&&(iiii<=3)
                imgdes=flipdim(imgsrc,iiii);%水平旋转
            elseif iiii==4
                imgdes=imnoise(imgsrc,'gaussian',0,noises);
            else
                (5<=iiii)&&(iiii<=beishu)
                imgdes=imadjust(imgsrc,[],[],gammma(1,iiii));
            end
            %         imgdes=imgsrc;
            
            imwrite(imgdes,imgdespath1);
        end
        %这个i用来看处理到第几个文件夹了
        % % %     imwrite(imgdes,imgdespath1);
        i
    end
end
clc
clear databig2
end
