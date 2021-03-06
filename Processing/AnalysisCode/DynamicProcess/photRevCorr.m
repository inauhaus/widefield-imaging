function [out] = photRevCorr(tau)

global ACQinfo

acqPeriod = ACQinfo.linesPerFrame*ACQinfo.msPerLine;  %msec per acquired frame
Npix = ACQinfo.linesPerFrame*ACQinfo.pixelsPerLine;

%oriseq = stimseq(0:pepgetnoconditions-1);  %Get stimulus sequence
oriseq = stimseq(0:4);  %Get stimulus sequence

oridom = unique([oriseq{1} oriseq{2} oriseq{3}]);

% if oridom(end) == 999
%     oridom = oridom(1:end-1);
% end

%%%%%%%%%%%%%%%%%%%
sp = tau(2)-tau(1);
last = -acqPeriod-sign(rem(acqPeriod,sp))*sp;
dumtau = fliplr(tau(1):-sp:last);
tauBuild = [dumtau tau(2:end)];

out = cell(1,2);
out{1} = cell(1,length(oridom));
for i = 1:length(oridom)
    out{1}{i} = zeros(Npix,length(tauBuild));  %Initialize for accumulation
end
out{2} = out{1};
countmat = zeros(length(oridom),length(tauBuild));


counter = 0;

for chan = 1:1  %Loop through both channels because of Matlab memory limits
    for k = 1:length(oriseq)
k
        %pepsetcondition(k-1)

        if chan == 1
            CHsdum = GetTrialData([1 0 0],k);
            for i = 1:length(CHsdum{1}(1,1,:))
                dum = CHsdum{1}(:,:,i)';
                CHs{1}(:,i) = dum(:);
            end
            clear CHsdum
        elseif chan == 2
            CHsdum = GetTrialData([0 1 0],k);
            for i = 1:length(CHsdum{1}(1,1,:))
                dum = CHsdum{1}(:,:,i)';
                CHs{2}(:,i) = dum(:);
            end
            clear CHsdum
        end


        %Tf = 1000/pepParam('refresh');  %Frame period in ms (CRT)
        Tf = 1000/59.94;  %Frame period in ms  (LCD monitor)

        hper = pepgetparam('h_period');
        hper = hper(1);
        %hper = 1;
        Tupdate = Tf*hper;

        respDomain = (0:length(CHs{chan}(1,:))-1)*acqPeriod;

        oriseqdum = oriseq{k}(1:hper:end);

        for ori = 1:length(oridom)

            id = find(oriseqdum == oridom(ori));

            stimes = (id-1)*Tupdate; %Stimulus times

            for i = 1:length(stimes)

                idx = find(respDomain > (stimes(i)+tauBuild(1)) & respDomain <= (stimes(i)+tauBuild(end)));
                if ~isempty(idx)
                    domidx = round((respDomain(idx)-(stimes(i)+tauBuild(1)))/sp) + 1; %domain indices within time domain
                    out{chan}{ori}(:,domidx) = out{chan}{ori}(:,domidx) + CHs{chan}(:,idx);
                    countmat(ori,domidx) = countmat(ori,domidx) + 1;                    
                end

            end
        end
    end
    clear CHs

end
%countmat = countmat/2;   %It was doubled by looping through the 2 channels

for i = 1:length(oridom)
    for j = 1:length(tauBuild)
        out{1}{i}(:,j) = out{1}{i}(:,j)/countmat(i,j);  
        out{2}{i}(:,j) = out{2}{i}(:,j)/countmat(i,j); 
    end
end



delPix = ACQinfo.msPerLine/ACQinfo.pixelsPerLine; %ms per pixel
iddel = (0:(Npix-1))*delPix;
iddel = round(iddel/sp);
iddel = [0 diff(iddel)];
iddel = find(iddel~=0);  %These are the indices to make a new time shift
L = length(tau);
LB = length(tauBuild);


%Shift each pixel in time

%First chunk
alp = LB-L+1;
ome = alp+L-1;
for i = 1:length(oridom)
    outshift{1}{i}(1:iddel(1)-1,:) = out{1}{i}(1:iddel(1)-1,alp:ome);
    outshift{2}{i}(1:iddel(1)-1,:) = out{2}{i}(1:iddel(1)-1,alp:ome);
end

%Middle chunks
for j = 1:length(iddel)-1
    alp = (LB-L+1)-j;
    ome = alp+L-1;
    for i = 1:length(oridom)
        outshift{1}{i}(iddel(j):iddel(j+1)-1,:) = out{1}{i}(iddel(j):iddel(j+1)-1,alp:ome);  
        outshift{2}{i}(iddel(j):iddel(j+1)-1,:) = out{2}{i}(iddel(j):iddel(j+1)-1,alp:ome); 
    end
end

%Last chunk
alp = (LB-L+1)-length(iddel);
ome = alp+L-1;
for i = 1:length(oridom)
    outshift{1}{i}(iddel(end):Npix,:) = out{1}{i}(iddel(end):Npix,alp:ome);
    outshift{2}{i}(iddel(end):Npix,:) = out{2}{i}(iddel(end):Npix,alp:ome);
end

clear out
for i = 1:length(outshift{1})
    for j = 1:length(outshift{1}{i}(1,:))
        out{1}{i}(:,:,j) = reshape(outshift{1}{i}(:,j),ACQinfo.linesPerFrame,ACQinfo.pixelsPerLine)';
    end
end

