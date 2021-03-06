function [y1 y2] = CondTensor(b,shiftflag,normflag)

%Compute the tensor for each condition

%The new version builds the entire Tensor, as opposed to truncating within a time interval 
%
%b is a 2D vector corresponding the the beginning and end of
%the baseline subtraction images, in milliseconds. e.g. varargin = {[0 500]} sums
%the images from 0 to .5 seconds for each repetition and then subtracts it
%from the mean response in the repeat.
%
%shiftflag performs movement correction 
%Rflag fits a line to the red/green scatter plot and subtracts this trend
%from the data in the green channel

global ACQinfo bsflag bcond bw

nc = pepgetnoconditions;

%Find blank condition:
bcond = []; 
for(i=0:nc-1)
    pepsetcondition(i)
    if(pepblank)       %Identify blank
       bcond = i;
       break
    end
end

temp = [];
if shiftflag
    pepsetcondition(0)
    pepsetrepeat(0)
    CHs = GetTrialData([1 1 0]);
    temp = CHs{2}(:,:,2);  %Use second channel for alignment
end

mbest = [];
if normflag
    [RGslope RGbase mbest nbest] = RtoG_trx2(shiftflag,temp);
    sigIm = 0;
    nIm = 0;
end

imsize = ACQinfo.pixelsPerLine*ACQinfo.linesPerFrame;

pepsetcondition(0)

y1 = cell(1,nc);
y2 = cell(1,nc);

%Get sample period (ms/pixel)
sp = ACQinfo.msPerLine/ACQinfo.pixelsPerLine; 

for c = 0:nc-1
 
    if c == bcond

        y1{c+1} = [];
        y2{c+1} = [];

    else

        y1{c+1} = 0;
        y2{c+1} = 0;

        pepsetcondition(c);
        nr = pepgetnorepeats;

        for r = 0:nr-1
            
            pepsetrepeat(r);

            CHs = GetTrialData([1 1 0]);  %don't use syncs here
            
            %Apply movement correction
            if shiftflag
                
                for z = 1:length(CHs{1}(1,1,:))        
                    if isempty(mbest)
                        imdum = CHs{2}(:,:,z);  %Use second channel for alignment
                        [mbest nbest] = getShiftVals(imdum,temp);  %get the transformation                    
                        CHs{1}(:,:,z) = ImShift(CHs{1}(:,:,z),mbest,nbest);  %transform
                        %CHs{2}(:,:,z) = ImShift(CHs{2}(:,:,z),mbest,nbest);  
                    else
                        CHs{1}(:,:,z) = ImShift(CHs{1}(:,:,z),mbest(c+1,r+1,z),nbest(c+1,r+1,z));  %transform
                        %CHs{2}(:,:,z) = ImShift(CHs{2}(:,:,z),mbest(c+1,r+1,z),nbest(c+1,r+1,z)); 
                    end
                end
            end
            
            if normflag
                for z = 1:length(CHs{1}(1,1,:))
                    %dumG = CHs{1}(:,:,z);
                    %normer = prctile(dumG(:),50);
                    
%                     gain = CHs{1}(:,:,z)./CHs{2}(:,:,z);
%                     gain = trimmean(gain(:),40);
%                     normer = CHs{2}(:,:,z)*gain;
%                     CHs{1}(:,:,z) = (CHs{1}(:,:,z) - normer);
                    
                    %CHs{1}(:,:,z) = (dumG - normer)/normer;
                    %CHs{1}(:,:,z) = (dumG - min(dumG(:)))/min(dumG(:));
                    
                    CHs{1}(:,:,z) = CHs{1}(:,:,z) - (CHs{2}(:,:,z).*RGslope + RGbase);
                    
                    sigIm = sigIm + CHs{1}(:,:,z).^2;
                    nIm = nIm + 1;
                    
                end
            end
            
          
            if bsflag == 1

                imstart = b(1);
                imstop = b(2);
                
                bimg1 = mean(CHs{1}(:,:,imstart:imstop),3);
                bimg2 = mean(CHs{2}(:,:,imstart:imstop),3);
                
                for z = 1:length(CHs{1}(1,1,:))
                    CHs{1}(:,:,z) = CHs{1}(:,:,z) - bimg1;   %% baseline subtraction
                    CHs{2}(:,:,z) = CHs{2}(:,:,z) - bimg2;
                end
                
                for z = 1:length(CHs{1}(1,1,:))
                    CHs{1}(:,:,z) = CHs{1}(:,:,z)./bimg1;   %% baseline division
                    CHs{2}(:,:,z) = CHs{2}(:,:,z)./bimg2;
                end

            end
            
            y1{c+1} = y1{c+1} + CHs{1}; %Add repeats
            y2{c+1} = y2{c+1} + CHs{2};  
            
            clear CHs

        end
        
    end
end


if normflag    
    sigIm = sqrt(sigIm/(nIm-1));
    for i = 1:length(y1)
        if ~isempty(y1{i})
            for j = 1:length(y1{i}(1,1,:))
                y1{i}(:,:,j) = y1{i}(:,:,j)./sigIm;
            end
        end
    end
end


