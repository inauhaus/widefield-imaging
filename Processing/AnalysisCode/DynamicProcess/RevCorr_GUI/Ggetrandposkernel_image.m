function [kernIm kernblank countmat countmatblank] = Ggetrandposkernel_image(trialdom,hh)

%Ian Nauhaus

%Keep cellMat as an input because it filters it, and I don't want to
%create a new variable of the same size

%3 takes the cell time courses as input, instead of all the images. 

global ACQinfo Analyzer G_RChandles G_handles domains mbestall nbestall

%%%%

blankNorm = get(G_RChandles.blankNorm,'value');

%%%%

%Get the time domain
eval(['kernDel = ' get(G_RChandles.kernelLength,'string')  ';']);
tauL = kernDel(2)-kernDel(1); %ms
acqPeriod = ACQinfo.linesPerFrame*ACQinfo.msPerLine; 
Ntau = round(tauL/acqPeriod)+1;
taudom = (0:Ntau-1)*acqPeriod + kernDel(1);  %it will start at exactly kernDel(1) with acqPeriod spacing, and end at an estimate of kernDel(2)


hper = getparam('h_per');
%hper = 1; %in my stimulus code, the sequences have only one value for each
%presentation, so you can't set hper to one

logfileroot = get(G_RChandles.logfilePath,'string');
expt = [Analyzer.M.anim '_' Analyzer.M.unit '_' Analyzer.M.expt];

load([logfileroot Analyzer.M.anim '\' expt])

rseeds = eval(Analyzer.L.param{1}{2});


for s = 1:length(rseeds)

    if exist(['rseed' num2str(s)])
        eval(['bwS = rseed' num2str(s) '.bwseq;']);
        eval(['xS = rseed' num2str(s) '.xseq;']);
        eval(['yS = rseed' num2str(s) '.yseq;']);
        eval(['oriS = rseed' num2str(s) '.oriseq;']);
        %eval(['colorS = rseed' num2str(s) '.colorseq;']);

        bwseq{s} = domains.bwdom(bwS);
        xseq{s} =  domains.xdom(xS);
        yseq{s} =  domains.ydom(yS);
        oriseq{s} =  domains.oridom(oriS);
        %colorseq{s} =  domains.colordom(colorS);
    end

end

oridom = domains.oridom;
xdom = domains.xdom;
ydom = domains.ydom;
bwdom = domains.bwdom;

DS = 1
if DS
   oridomD =  (oridom(1:2:end)+oridom(2:2:end))/2;
   xdomD =  (xdom(1:2:end)+xdom(2:2:end))/2;
   
   for s = 1:length(xseq)
       for x = 1:length(xdom)
           id = find(xseq{s} == xdom(x));
           xseq{s}(id) = xdomD(ceil(x/2));
       end
       
        for o = 1:length(oridom)
           id = find(oriseq{s} == oridom(o));
           oriseq{s}(id) = oridomD(ceil(o/2));
       end
       
   end
   oridom = oridomD;
   xdom = xdomD;
end

Tf = 1000/frate;  %Frame period in ms (frate obtained from log file) 
Tupdate = Tf*hper;

NT = getnotrials;

tau_xy = ACQinfo.linesPerFrame/2*ACQinfo.msPerLine;

countmat = zeros(length(oridom),length(xdom),length(ydom),length(bwdom));
kernIm = cell(length(oridom),length(xdom),length(ydom),length(bwdom));
% countmatblank = zeros(1,length(taudom));
% kernblank = zeros(1,length(taudom));

NT = getnotrials;

GcampFlag = 0;

alignCh = 1;
chvec = [0 0 0 0];
chvec(alignCh) = 1;
temp = GetTrialData(chvec,1);
Tdim = size(temp{1});

if GcampFlag
    temp = median(temp{1}(:,:,10:end-10),3);
else
    temp = mean(temp{1}(:,:,10:end-10),3);
end


if ~isempty(hh)
    hfilt = ones(Tdim(1),Tdim(2),length(hh));
    for m = 1:length(hh)
        hfilt(:,:,m) = hh(m)*hfilt(:,:,m);
    end
end

mbest = 0;
nbest = 0;
mbestall = [];
nbestall = [];

[xgrid ygrid] = meshgrid(1:length(temp(1,:)),1:length(temp(:,1)));
%xgrid = 1:length(temp(1,:));
%ygrid = (1:length(temp(:,1)))';

Fs = 1000*ACQinfo.pixelsPerLine/ACQinfo.msPerLine;


syncdiodeflag = ACQinfo.acquiringChannel3;

for trialid = 1:length(trialdom)

    T = trialdom(trialid);

T

    if syncdiodeflag
        CH = GetTrialData([1 0 1 0],trialdom(trialid));
        [frameid lineid synctimes] = getsyncFrameTime(CH{2});
        figure(99)
        stem(synctimes,'.')
        CH{2} = [];
    else
        CH = GetTrialData([1 0 0 0],trialdom(trialid));
    end

    
%     if get(G_handles.slowMotionFlag,'value');
%         imdum = mean(CH{2}(:,:,2:end-2),3);
%         [mbest nbest] = getShiftVals(imdum,temp,[mbest nbest]);  %get the transformation for this trial
% 
% %         for z = 1:length(CH{1}(1,1,:))
% %             
% %             %CH{1}(:,:,z) = griddata(xgrid,ygrid,double(CH{1}(:,:,z)),xgrid+nbest,ygrid+mbest);
% %             CH{1}(:,:,z) = interp2(xgrid,ygrid,double(CH{1}(:,:,z)),xgrid+nbest,ygrid+mbest);
% %         end
%         
%         CH{1} = circshift(CH{1},[-mbest -nbest 0]);
% 
%         mbestall = [mbestall mbest];
%         nbestall = [nbestall nbest];
%     end


    if get(G_handles.slowMotionFlag,'value');
        
        if GcampFlag
            imdum = median(CH{alignCh}(:,:,10:end-10),3);
        else
            imdum = mean(CH{alignCh}(:,:,10:end-10),3);
        end

        [mbest nbest] = getShiftVals(imdum.^2,temp.^2,[mbest nbest])  %get the transformation for this frame

        CH{1} = circshift(CH{1},[-round(mbest) -round(nbest) 0]);
        
        mbestall = [mbestall mbest];
        nbestall = [nbestall nbest];
    end
    
    if ~isempty(hh)
        CH{1}(:,:,1:end-1) = ifft(fft(CH{1}(:,:,1:end-1),[],3).*hfilt,[],3);
        CH{1}(:,:,1) = 0;
        CH{1}(:,:,end) = 0;
    end
    
    T = trialdom(trialid);
    [cond rep] = getcondrep(T);

    %         dsync = diff(cellS.synctimes{cond,rep});
    %         if any(abs(dsync-Tupdate/1000)>.100)
    %             'Warning: syncs may be messed up'
    %         end

    N = length(CH{1}(1,1,:));
    tdom = (0:N-1)*acqPeriod;
    %tdom_pix = tdom + tau_xy - ACQinfo.stimPredelay*1000;   %time domain of the pixel relative to onset of first stimulus
    tdom_pix = tdom + tau_xy;
    
    seedno = Analyzer.loops.conds{cond}.val{1};

    oriseqdum = oriseq{seedno};
    xseqdum = xseq{seedno};
    yseqdum = yseq{seedno};
    bwseqdum = bwseq{seedno};

    for ori = 1:length(oridom)
        for x = 1:length(xdom)
            for y = 1:length(ydom)
                for bw = 1:length(bwdom)

                    id = find(oriseqdum == oridom(ori) & xseqdum == xdom(x) & yseqdum == ydom(y) & bwseqdum == bwdom(bw));


                    if ~isempty(id)
                        
                        if isempty(kernIm{ori,x,y,bw})
                            kernIm{ori,x,y,bw} = 0;
                        end
                        
                        if syncdiodeflag      
                            stimes = synctimes(id)*1000;
                        else
                            stimes = (id-1)*Tupdate + getparam('predelay')*1000; %Stimulus times                            
                        end

                        for i = 1:length(stimes)
                            [dum idx1] = min(abs(tdom_pix - (stimes(i)+taudom(1)))); %find time sample that is closest to the beginning of response window
                            if ~isempty(idx1)
                                idx1 = idx1(1);
                                tpiece = idx1:idx1+length(taudom)-1;

                                if tpiece(1)>0 & tpiece(end)<N
                                    kernIm{ori,x,y,bw} = kernIm{ori,x,y,bw} + CH{1}(:,:,tpiece);
                                    countmat(ori,x,y,bw) = countmat(ori,x,y,bw) + 1;
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    %id = find(isnan(seqs{T}.oriseq));
    %stimes = (id-1)*Tupdate + getparam('predelay')*1000; %Stimulus times

    %stimes = cellS.synctimes{cond,rep}(id)*1000;

%     for i = 1:length(stimes)
% 
%         idx1 = find(tdom_pix>=stimes(i)+taudom(1)-dtau/2 & tdom_pix<stimes(i)+taudom(1)+dtau/2);
%         idx1 = idx1(1);
%         tpiece = idx1:idx1+length(taudom)-1;
% 
%         if tpiece(1)>0 & tpiece(end)<length(tcourse)
%             kernblank{p} = kernblank{p} + tcourse(tpiece);
%             countmatblank{p} = countmatblank{p} + 1;
%         end
%     end


end


for ori = 1:length(oridom)
    for x = 1:length(xdom)
        for y = 1:length(ydom)
            for bw = 1:length(bwdom)
                kernIm{ori,x,y,bw} = kernIm{ori,x,y,bw}/countmat(ori,x,y,bw);
                % kernblank = kernblank./countmatblank;
            end
        end
    end
end
kernblank = 0;
% kernblank{p} = kernblank{p}./countmatblank{p};
% 
% if blankNorm
%     for ori = 1:length(oridom)
%         for x = 1:length(xdom)
%             for y = 1:length(ydom)
%                 for bw = 1:length(bwdom)
% 
%                     kernIm{p}(ori,x,y,bw,:) = (squeeze(kernIm{p}(ori,x,y,bw,:)) - kernblank{p}(:));
% 
%                 end
%             end
%         end
%     end
% end

