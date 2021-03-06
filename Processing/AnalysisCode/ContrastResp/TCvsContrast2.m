function [OSIMag BW kernPopmod_pk kernPopmod] = TCvsContrast2

%2 uses the cell time courses/tuning curves generated during process .raw.
%It gives error bars to make better data selection

global cellS maskS Analyzer

getCellStats  %reset the the mean based on time window

%%%Get rid of the glia:
masklabel1 = bwlabel(maskS.bwCell{1},4);
masklabel2 = bwlabel(maskS.bwCell{2},4);
celldom = unique(masklabel1);
k1 = 1; k2 = 1;
for i = 2:length(celldom)  %Don't use neuropil
    id = find(masklabel1 == celldom(i));
    if sum(masklabel2(id))==0  %if there is no overlap
        nID(k1) = i;
        k1 = k1+1;
    else
        gID(k2) = i;
        k2 = k2+2;
    end
end
%%%


Nsym = length(Analyzer.loops.conds{1}.symbol);  %number of looping params
for idsym = 1:Nsym
    if strcmp('ori',Analyzer.loops.conds{1}.symbol{idsym})
        oriid = idsym;
    elseif strcmp('contrast',Analyzer.loops.conds{1}.symbol{idsym})
        contid = idsym;
    end
end

oridom = eval(Analyzer.L.param{oriid}{2});
dori = oridom(2)-oridom(1);

orthD = round(90/dori)+1; %index of baseline
slopeD1 = 2; %index for beginning of slope
slopeD2 = 3; %index for end of slope

mu = oridom(round(end/2));
sig = 10;
smoother = exp(-(oridom-mu).^2/(2*sig^2));
smoother = smoother/sum(smoother);
smoother = abs(fft(smoother));

Nsym = length(Analyzer.loops.conds{1}.symbol);  %number of looping parameters

for i = 1:Nsym
    allDom{i} = getdomain(Analyzer.loops.conds{1}.symbol{i});
end

nc = getnoconditions;
bflag = stimblank(getnoconditions); %if a blank exists in this experiment
if bflag
    nc = nc-1;
end

lcID = 1;  %low contrast ID

k = 1;
for i = 1:length(nID)   %loop through each neuron
    
    kern = zeros(length(allDom{1}),length(allDom{2}));
    kernSig = zeros(length(allDom{1}),length(allDom{2}));

    for c = 1:nc
        for s = 1:Nsym       
            val = Analyzer.loops.conds{c}.val{s};
            idsym(s) = find(Analyzer.loops.conds{c}.val{s} == allDom{s});            
        end
        kern(idsym(1),idsym(2)) = cellS.mu{c}(nID(i),:);
        kernSig(idsym(1),idsym(2)) = cellS.sig{c}(nID(i),:);
    end

    if oriid == 1
        kern = kern';
        kernSig = kernSig';
        dim(1:2) = size(kern);
    end
    
    blankMu = cellS.mu{end}(nID(i));
    blankSig = cellS.sig{end}(nID(i));
    
    %Control by shuffling
%     [dum id] = sort(rand(1,length(kern(1,:))));
%     kern(1,:) = kern(1,id);
%     [dum id] = sort(rand(1,length(kern(1,:))));
%     kern(2,:) = kern(2,id);

    for c = 1:dim(1)
        kern(c,:) = squeeze(kern(c,:));
        kern(c,:) = ifft(fft(kern(c,:)).*smoother);
    end
    
    [ma idma] = max(kern(lcID,:));
    
    dprime = (ma-blankMu)/(kernSig(lcID,idma)+blankSig);
    %dprime = (ma-blankMu)/(kernSig(lcID,idma)*sqrt(getnorepeats(1))+blankSig*sqrt(getnorepeats(getnoconditions)));

    [mag pref1] = OSI(kern(end,:),dori);
    [mag pref2] = OSI(kern(lcID,:),dori);    
    dpref = exp(1i*2*(pref1-pref2)*pi/180);
    dpref = abs(angle(dpref))*180/pi/2;

    if dprime > 1 && dpref<dori
        
        %kern = kern - blankMu;  

        for c = 1:dim(1)  %each contrast           

            kernC = squeeze(kern(c,:));           

            tcdum = kernC;
            [dum idma] = max(tcdum);
            kernC = circshift(kernC,[0 1-idma]);

            k1 = kernC(1:end/2+1);
            k2 = [kernC(end/2+1:end) kernC(1)];
            k2 = fliplr(k2);
            kernC_wrap = (k1 + k2)/2;
            %kernC_wrap = kernC_wrap + fliplr(kernC_wrap);
            
            kernC_peak = [kernC(end-orthD+2:end) kernC(1:orthD)];
            kernC_peak2 = kernC(orthD:end-orthD+2);
            %kernC_peak = kernC_peak + kernC_peak2;  
 
            [BW{c}(k) tcI domI] = FWHM(kernC_wrap(1:orthD),dori);


%            oridomI = linspace(0,oridom(length(kernC_peak)),100);            
%             kernC_peakI = interp1(oridom(1:length(kernC_peak)),kernC_peak,oridomI);
%             [param ffit varacc] = Gaussfit(1,kernC_peakI,1);
%             doriI = oridomI(2)-oridomI(1);
% % 
%             if varacc > .0 && param(2)*doriI < 80
%                 BW{c}(k) = param(2)*doriI;
%                 %BW{c}(k) = param(3);
%                 %figure,plot(kernC_peak)
%             else
%                 BW{c}(k) = NaN;
%             end

            Mag{c}(k,1) = log10(abs(kernC_wrap(1)/kernC_wrap(2)));
            Mag{c}(k,2) = log10(abs(kernC_wrap(2)/kernC_wrap(4)));
%                        
              %This one seems to be biased for lower gain (when I ran noise through it)
%             Mag{c}(k,1) = (kernC_wrap(1)-kernC_wrap(2))/(kernC_wrap(1)+kernC_wrap(2)); 
%             Mag{c}(k,2) = (kernC_wrap(2)-kernC_wrap(4))/(kernC_wrap(2))+kernC_wrap(4);
%            

            %            base = kern(c,orthD);

            %kern(c,:) = kern(c,:) - base;  %Subtract response to orthogonal oris
            %
            %             kern(c,:) = kern(c,:)/kern(c,1); %Normalize the amplitude

            %             for s = 1:orthD-1
            %                 Mag{c}(k,s) = log10(kern(c,s)/kern(c,s+1));  %Get slope
            %             end

            kernPopmod_full(c,:,k) = kern(c,:);
            kernPopmod(c,:,k) = kernC_wrap;
            kernPopmod_pk(c,:,k) = kernC_peak;
            
        end


        %     else
        %         Mag{c}(k) = NaN;
        %     end

        k = k+1;

    end

end


figure,plot(BW{lcID},BW{end},'.'), hold on, plot([0 150],[0 150],'k')
xlabel('FWHM (low contrast)'), ylabel('FWHM (high contrast)')

dim = size(kernPopmod);
oridomTrunc = oridom(1:dim(2));

mukern = mean(kernPopmod,3)';
sigkern = std(kernPopmod,[],3)';
ma = max(mukern);
ma = ones(dim(2),1)*ma;
% mukern = mukern./ma;
% sigkern = sigkern./ma;
%mukern = mukern(:,end-1:end);
%sigkern = sigkern(:,end-1:end);
figure,
errorbar(oridomTrunc'*ones(1,length(mukern(1,:))),mukern,sigkern/sqrt(dim(3)));
legend('low contrast','high contrast')
xlabel('orientation')



% for c = 1:dim(1)
%     id = find(Mag{end-1} > 1.2 | Mag{end-1} < 0 | Mag{end} > 1.2 | Mag{end} < 0);
%     Mag{end-1}(id) = [];
%     Mag{end}(id) = [];
% end




figure,
Nslopes = length(Mag{1}(1,:));
for s = 1:Nslopes
    subplot(1,Nslopes,s)
    plot(Mag{lcID}(:,s),Mag{end}(:,s),'.'), hold on
    plot([-1 4], [-1 4],'r')
    xlabel('Response Ratio (low contrast)'), ylabel('Response Ratio (high contrast)')
    hold off
    %xlim([-1 5]), ylim([-1 5])
end



%%%%%%%%%%
%%%%%%%%%%
h = exp(1i*oridom(1:end/2)*2*pi/180)';
for i = 1:dim(1)
    kdum = squeeze(kernPopmod_pk(i,1:end-1,:))'; %Don't take last orientation
    normer = sum((kdum),2);
    pol = (kdum*h)./normer;
    Mag{i} = abs(pol);
end

% h = exp(1i*oridom*2*pi/180)';
% for i = 1:dim(1)
%     kdum = squeeze(kernPopmod_full(i,:,:))';
%     normer = sum((kdum),2);
%     pol = (kdum*h)./normer;
%     Mag{i} = abs(pol);
% end
%id = find(Mag{end-1} > 1 | Mag{end} > 1);
%Mag{end-1}(id) = []; Mag{end}(id) = [];

% clear Mag
% p = 1;
% h = exp(1i*oridom*2*pi/180)';
% for i = 1:length(kernPop(1,1,:))  
%     
%     kern = kernPop(:,:,i);
%     if max(kern(:))>.0
%         for k = 1:2
%             
%             tc = squeeze(kern(:,end-k+1))';
%             
%             pol = (tc*h)./sum(tc);
%             Mag(p,k) = abs(pol);
%         end
%         p = p+1;
%     end
% end
% id = find(Mag{end-1} > 1 | Mag{end} > 1);
% Mag{end-1}(id) = []; Mag{end}(id) = [];


figure,scatter(Mag{lcID},Mag{end},'.'), hold on
plot([0 1.5], [0 1.5],'r')
xlabel('OSI (low contrast)'), ylabel('OSI (high contrast)')
hold off
%xlim([0 1.2]), ylim([0 1.2])

%figure,hist(Mag{end})


function [BW tcI domI id] = FWHM(tc,dori)

I = 20;

dom = linspace(0,dori*(length(tc)-1),length(tc));
domI = linspace(0,dori*(length(tc)-1),length(tc)*I);

tcI = interp1(dom,tc,domI);

tcdum = tcI-min(tcI);
%tcdum = tcI;
tcdum = tcdum/max(tcdum);

%tcdum = tcI/max(tcI)

[dum id] = min(abs(tcdum-1/sqrt(2)));
%[dum id] = min(abs(tcdum-.5));

BW = 2*domI(id)+ randn(1)*.1;



function [mag pref] = OSI(tc,dori)

oridom = linspace(0,dori*(length(tc)-1),length(tc));

h = exp(1i*oridom*2*pi/180)';

vec = tc(:)'*h(:)/sum(tc);

mag = abs(vec);
pref = angle(vec)*180/pi;

    