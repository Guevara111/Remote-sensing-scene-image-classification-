function [out,info] = augmentAndLabelCamelyon16(im,info,labelStr)
% Function to create augmented versions of the original patch. The original
% patch is color deconvolved using Macenko's method to get individual H and
% E stains which are re-mixed to get the color normalized image. The data
% is converted to the range [0 1] and 5 augmented versions are created. The
% augmented images are labelled with the label in labelStr.

% Copyright 2020 The MathWorks, Inc.

if strcmpi(labelStr,'normal')
    labelValue = 0;
else
    labelValue = 1;
end

%% Stain Data Augmentation
out = cell(5,2);
[imNormalized, H, E] = normalizeStaining(im{1},true,255);

% Normalize values of color stain, H and E images to the range [0 1]
imNormalized = im2double(imNormalized)/255;
H = im2double(H)/255;
E = im2double(E)/255;

out{1,1} = imNormalized;
out{1,2} = categorical(labelValue,[0,1],{'normal','tumor'});

% Add color jitter 
imNormalized = jitterColorHSV(imNormalized,'Contrast',[0.5,1.5],'Hue',[-0.05, 0.05],'Saturation',[-0.2,0.2],'Brightness',[0.65,1.0]);

out{2,1} = imNormalized;
out{2,2} = categorical(labelValue,[0,1],{'normal','tumor'});

% Random augmentation to color jittered input
r = randi(3,1);
switch r
    case 1
        imNormalized = fliplr(imNormalized);
    case 2
        imNormalized = rot90(imNormalized);
    case 3
        imNormalized = fliplr(rot90(imNormalized));
    otherwise
end

out{3,1} = imNormalized;
out{3,2} = categorical(labelValue,[0,1],{'normal','tumor'});

% Random augmentation to H channel
r = randi(4,1);
switch r
    case 1
        H = fliplr(H);
    case 2
        H = rot90(H);
    case 3
        H = fliplr(rot90(H));
    otherwise
        H = H;
end

out{4,1} = (H);
out{4,2} = categorical(labelValue,[0,1],{'normal','tumor'});

% Random augmentation to E channel
r = randi(4,1);
switch r
    case 1
        E = fliplr(E);
    case 2
        E = rot90(E);
    case 3
        E = fliplr(rot90(E));
    otherwise
        E = E;
end

out{5,1} = (E);
out{5,2} = categorical(labelValue,[0,1],{'normal','tumor'});
