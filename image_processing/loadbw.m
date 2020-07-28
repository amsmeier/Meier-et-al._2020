%%%% load bw image indicating region of interest
% [img imfile] = loadbw(imfile)
% imfileIn can be either filename or image
%%%%% updated 5/23/18

function [img imfile] = loadbw(imfileIn)


if ischar(imfileIn)
    input_is_filename = 1; 
    imfile = imfileIn;
    img = imread(imfileIn);
else
    input_is_filename = 0; 
    imfile = '';
    img = imfileIn;
end
    
img = img(:,:,1); % in case image is rgb, take only first channel
if numel(unique(img(img~=0))) ~= 1
    error('More or less than 1 unique non-zero pixel value found in ROI file.')
end
img = img>0; 

if input_is_filename %%% if image is from file, check for border artifacts
    if any(find(img(:,1))) || any(find(img(:,end))) || any(find(img(1,:))) || any(find(img(end,:)))
        f = figure('units','normalized','outerposition',[0 0 1 1]);
        imagesc(img)
        pause(.1)
        commandwindow
        go_on = input(['Warning: BW image ' imfile ' has nonzero pixels along a border. Enter ''y'' to continue.'],'s');
        close(f)
        if ~strcmp(go_on,'y')
            error('quitting loadbw')
        end
    end
end