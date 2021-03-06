function [y1 y2] = CondTensor(Tlim,b,shiftflag,normflag)

%old2 does not use predelay/postdelay, but has the image shift stuff.

%Compute the tensor for each condition
%
%b is a 2D vector corresponding the the beginning and end of
%the baseline subtraction images, in milliseconds. e.g. varargin = {[0 500]} sums
%the images from 0 to .5 seconds for each repetition and then subtracts it
%from the mean response in the repeat.
%
%Tlim is like b, but for the range over which images are averaged
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

% if normflag
%     [RGslope RGbase] = RtoG_trx;
%     idbw = find(bw);
% end

imsize = ACQinfo.pixelsPerLine*ACQinfo.linesPerFrame;

pepsetcondition(0)

y1 = cell(1,nc);
y2 = cell(1,nc);

%Get sample period (ms/pixel)
sp = ACQinfo.msPerLine/ACQinfo.pixelsPerLine; %(msPerLine is actually sec/line)

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

            CHs = GetTrialData([1 1 1]);
            

            
            %Apply movement correction
            if shiftflag
                if c == 0 && r == 0
                    temp = (CHs{1}(:,:,2) + CHs{2}(:,:,2))/2;  %set template image
                end
                for z = 1:length(CHs{1}(1,1,:))
                    imdum = (CHs{1}(:,:,z) + CHs{2}(:,:,z))/2;
                    [mbest nbest] = getShiftVals(imdum,temp);  %get the transformation
                    
                    CHs{1}(:,:,z) = ImShift(CHs{1}(:,:,z),mbest,nbest);  %transform
                    %CHs{2}(:,:,z) = ImShift(CHs{2}(:,:,z),mbest,nbest);  
                end
            end
            
            if normflag
                for z = 1:length(CHs{1}(1,1,:))
                    dumG = CHs{1}(:,:,z);
                    normer = prctile(dumG(:),10);
                    CHs{1}(:,:,z) = (dumG - normer)/normer;
                    %CHs{1}(:,:,z) = (dumG - min(dumG(:)))/min(dumG(:));
                end
            end
            
            
%             if normflag
%                 for z = 1:length(CHs{1}(1,1,:))
%                     dumG = CHs{1}(:,:,z);
%                     dumR = CHs{2}(:,:,z);
%                     dumG(idbw) = dumG(idbw) - (RGslope').*dumR(idbw) - RGbase';
%                     CHs{1}(:,:,z) = dumG;
%                 end
%             end
            
            
            for z = 1:length(CHs{3}(1,1,:))
                synctcourse(:,:,z) = CHs{3}(:,:,z)';
            end
            synctimes = reconstructSync(synctcourse(:));
            idstart = round(synctimes(1)/sp) + 1;  %index of the first sync (should be ~-50)

            
            if bsflag == 1

                avgstart = idstart+b(1)/sp;
                avgstop = idstart+b(2)/sp;

                imstart = round(avgstart/imsize)+1;
                imstart = max(1,imstart);
                imstop = round(avgstop/imsize);
                imstop = min(length(CHs{1}(1,1,:)),imstop);       
                
                bimg1 = mean(CHs{1}(:,:,imstart:imstop),3);
                bimg2 = mean(CHs{2}(:,:,imstart:imstop),3);
                
                for z = 1:length(CHs{1}(1,1,:))
                    CHs{1}(:,:,z) = CHs{1}(:,:,z) - bimg1;   %% baseline subtraction
                    CHs{2}(:,:,z) = CHs{2}(:,:,z) - bimg2;
                end
                
                for z = 1:length(y1{c+1}(1,1,:))
                    CHs{1}(:,:,z) = CHs{1}(:,:,z)./bimg1;   %% baseline division
                    CHs{2}(:,:,z) = CHs{2}(:,:,z)./bimg2;
                end

            end

            avgstart = idstart+Tlim(1)/sp;
            avgstop = idstart+Tlim(2)/sp;

            imstart = round(avgstart/imsize)+1;  
            if imstart < 0
                warning('Acquisition had large delay from sync onset')
            end
            imstart = max(1,imstart);
            imstop = round(avgstop/imsize);  
            imstop = min(length(CHs{1}(1,1,:)),imstop); 
            
            y1{c+1} = y1{c+1} + CHs{1}(:,:,imstart:imstop); %Add repeats
            y2{c+1} = y2{c+1} + CHs{2}(:,:,imstart:imstop);  
            
            clear CHs

        end
        
        
    end
end


