function [newpath]=pathchange(oldpath,oldwenjianming,newwenjianming)
newpath={};
for i=1:length(oldpath)
    a=oldpath{i};
    old=oldwenjianming;
    new=newwenjianming;
    newpath{i}=strrep(a,old,new);
end
clear pathchange
end
