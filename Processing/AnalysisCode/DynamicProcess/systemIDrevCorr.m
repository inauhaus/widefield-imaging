function [yall HHall] = systemIDrevCorr(cellMat,trialdom,hh)

global ACQinfo maskS Analyzer G_RChandles

ARflag = 1;

nID = getNeuronMask;  %get the index values for the neurons
masklabel = bwlabel(maskS.neuronmask,4);
celldom = unique(masklabel);
Ncell = length(nID);

ptime = ACQinfo.msPerLine/ACQinfo.pixelsPerLine;  %pixel time (ms)

%Get the time domain
eval(['kernDel = ' get(G_RChandles.kernelLength,'string')  ';']);
tauL = kernDel(2)-kernDel(1); %ms
acqPeriod = ACQinfo.linesPerFrame*ACQinfo.msPerLine; 
Ntau = round(tauL/acqPeriod)+1;
taudom = (0:Ntau-1)*acqPeriod + kernDel(1);  %it will start at exactly kernDel(1) with acqPeriod spacing, and end at an estimate of kernDel(2)

hper = getparam('h_per');

expt = [Analyzer.M.anim '_' Analyzer.M.unit '_' Analyzer.M.expt];
load(['C:\2p_data\' Analyzer.M.anim '\log_files\' expt],'frate')

Tf = 1000/frate;  %Frame period in ms (frate obtained from log file) 
Tupdate = Tf*hper;

[domains seqs] = getSeqInfo;

%%%%%%%%%%%%%%%%%%%

oridom = domains{1}.oridom;
sfdom = domains{1}.sfdom;

paramP = length(oridom);
tauP = 5;
covMat = 0;
xCorr = cell(1,Ncell);
covMat = cell(1,Ncell);
for i = 1:Ncell
    xCorr{i} = 0;
    covMat{i} = 0;
end



p = 2;

pID = nID(p);
[idcelly idcellx] = find(masklabel == celldom(p));
CoM = [mean(idcelly) mean(idcellx)];  %center of mass
tau_xy = (CoM(1)-1)*ACQinfo.msPerLine + ptime*CoM(2);

HHall = [];
yall = [];

for trialid = 1:length(trialdom)

    T = trialdom(trialid);
    [cond rep] = getcondrep(T);

    y = squeeze(cellMat{cond}(pID,:,rep));

    %mu = mean(y);
    if ~isempty(hh)
        y = ifft(fft(y).*hh);
    end
    y = zscore(y);

    tdom = (0:length(y)-1)*acqPeriod;
    %tdom_pix = tdom + tau_xy - ACQinfo.stimPredelay*1000;   %time domain
    %of the pixel relative to onset of first stimulus
    tdom_pix = tdom + tau_xy;

    HHdum = zeros(length(y),length(oridom));
    for ori = 1:length(oridom)
        %for sf = 1:length(sfdom)

        %id = find(seqs{T}.oriseq == oridom(ori) & seqs{T}.sfseq == sfdom(sf));
        id = find(seqs{T}.oriseq == oridom(ori));

        if ~isempty(id)

            stimes = (id-1)*Tupdate + getparam('predelay')*1000; %Stimulus times (ms)

            for i = 1:length(stimes)

                [dum idx1] = min(abs(tdom_pix - (stimes(i)+taudom(1)))); %find time sample that is closest to the beginning of response window
                HHdum(idx1,ori) = 1;
            end
        end
        %end
    end

    HH = zeros(length(HHdum(:,1)),length(HHdum(1,:))*tauP); %preallocate
    HHdum = [zeros(tauP-1,length(HHdum(1,:))); HHdum];  %Pad with zeros
    for z = tauP:length(HHdum(:,1))
        chunk = squeeze(HHdum(z-tauP+1:z,:))';
        chunk = chunk(:)';
        HH(z-tauP+1,:) = chunk;
    end

    if ARflag
        HH = [HH [0; y(1:end-1)']];
    end
    
    HHall = [HHall; HH];
    yall = [yall; y(:)];

end

ustr = [];
for i = 1:length(HHall(1,:))
    
    ustr = [ustr ' unitgain'];
end

% data = iddata(yall,HHall,acqPeriod/1000)
% 
% 
% 
% 
% 
% 
% 
nc = 0;
nf = 0*ones(1,41);
nd = 0;
na = 0;
nb = 1*ones(1,41);
nk = 0*ones(1,41);
orders = [na nb nc nd nf nk];
% 
% pem(data,orders);
% 
% m=nlarx(data,[1 1 0])