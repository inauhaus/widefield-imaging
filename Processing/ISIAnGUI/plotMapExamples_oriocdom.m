function plotMapExamples_oriocdom(hh)

global f0m_var f0m Tens Tens_var Analyzer symbolInfo idExamp G_handles ACQinfo flipeyebit

%idExamp = [];

for i = 1:length(Analyzer.loops.conds{1}.symbol)
    if strcmp(Analyzer.loops.conds{1}.symbol{i},'Leye_bit');
        idsym = i;
        break
    end
end

symbolInfo.ID(1) = idsym;
set(G_handles.primSymbol,'value',idsym); 
if idsym == 1
    set(G_handles.secSymbol,'value',2);
else
    set(G_handles.secSymbol,'value',1);
end
    
setsymbolstruct

symID = symbolInfo.ID(1);
symID2 = symbolInfo.ID(2);

nc = length(Analyzer.loops.conds);

%if blank exists, it is always the last condition
bflag = 0;
if strcmp(Analyzer.loops.conds{nc}.symbol,'blank') 
    bflag = 1;
end

for i = 1:(nc-bflag)
    EYEcond(i) = Analyzer.loops.conds{i}.val{symID}; %eye bit for each condition    
    axiscond(i) = Analyzer.loops.conds{i}.val{symID2}; %Secondary parameter for each condition
end


if ~isempty(idExamp)
    figure
    
    %First the SF curve
    
    dim = size(f0m{1});
    
    f0varTens = zeros(dim(1),dim(2),length(f0m),'single'); %preallocate
    f0Tens = f0varTens;
    for k = 1:length(f0m)
        f0varTens(:,:,k) = f0m_var{k};
        f0Tens(:,:,k) = f0m{k}; 
    end
    
    [dum idma] = max(f0Tens,[],3);  %id the best condition
    [dum idmi] = min(f0Tens,[],3);  %id the best condition

    EYEdom = unique(EYEcond);
    tcEYETens = zeros(size(f0m{1},1), size(f0m{1},2), length(EYEdom));
    tcEYETensSE = zeros(size(f0m{1},1), size(f0m{1},2), length(EYEdom));
    for k = 1:length(EYEdom)

        id = find(EYEcond == EYEdom(k));
        imdum = mean(f0Tens(:,:,id),3);
        imdumSE = sqrt(mean(f0varTens(:,:,id),3)/(length(id)*getnorepeats(1)));
        
        imdumSE = imdumSE/sqrt(2);

        if ~isempty(hh)
            id = find(isnan(imdum.*imdumSE));
            imdum(id) = 0;
            imdumSE(id) = 0;
            
            imdum = ifft2(abs(fft2(hh)).*fft2(imdum));
            imdumSE = ifft2(abs(fft2(hh)).*fft2(imdumSE));
        end

        tcEYETens(:,:,k) = imdum;
        tcEYETensSE(:,:,k) = imdumSE;
    end
    
    for i = 1:length(idExamp(:,1))
        tcEYE{i} = squeeze(tcEYETens(idExamp(i,2),idExamp(i,1),:));
        tcEYESE{i} = squeeze(tcEYETensSE(idExamp(i,2),idExamp(i,1),:));
        
        subplot(length(idExamp(:,1)),3,3*i-2)
        
        if flipeyebit
            errorbar(fliplr(EYEdom),fliplr(tcEYE{i}),fliplr(tcEYESE{i}),'k')
        else
            errorbar(EYEdom,tcEYE{i},tcEYESE{i},'k')
        end
        %plot(EYEdom,tcEYE{i},'.-k')
        set(gca,'Xtick',[0 1],'XTickLabel',{'Ipsi','Contra'}),
        title(['xpos = ' num2str(idExamp(i,1)) ';  ypos = ' num2str(idExamp(i,2))])
        ylim([-.05 .1])
    end
    

    %Now the orientation
    
    axisdom = unique(axiscond);
    tcoriTens = zeros(size(f0m{1},1), size(f0m{1},2), length(axisdom));
    tcoriTensSE = zeros(size(f0m{1},1), size(f0m{1},2), length(axisdom));
    for k = 1:length(axisdom)

        id = find(axiscond == axisdom(k));
        imdum = mean(f0Tens(:,:,id),3);
        imdumSE = sqrt(mean(f0varTens(:,:,id),3)/(length(id)*getnorepeats(1)));
        
        imdumSE = imdumSE/sqrt(2);

        if ~isempty(hh)
            id = find(isnan(imdum.*imdumSE));
            imdum(id) = 0;
            imdumSE(id) = 0;
            imdum = ifft2(abs(fft2(hh)).*fft2(imdum));
            imdumSE = ifft2(abs(fft2(hh)).*fft2(imdumSE));
        end

        tcoriTens(:,:,k) = imdum;
        tcoriTensSE(:,:,k) = imdumSE;
    end
    

    for i = 1:length(idExamp(:,1))
        tcori{i} = squeeze(tcoriTens(idExamp(i,2),idExamp(i,1),:));
        tcoriSE{i} = squeeze(tcoriTensSE(idExamp(i,2),idExamp(i,1),:));

        subplot(length(idExamp(:,1)),3,3*i-1)
        errorbar(axisdom,tcori{i},tcoriSE{i},'k')
        %plot(axisdom,tcori{i},'.-k')
        set(gca,'Xtick',[0 90 180 270 360]),
        title(['xpos = ' num2str(idExamp(i,1)) ';  ypos = ' num2str(idExamp(i,2))])
        xlim([-10 360])
        ylim([-.05 .1])

    end 
    
    if ~isempty(Tens)
        for i = 1:length(idExamp(:,1))
            condma = idma(idExamp(i,2),idExamp(i,1));
            condmi = idmi(idExamp(i,2),idExamp(i,1));
            tcoursema = squeeze(Tens{condma}(idExamp(i,2),idExamp(i,1),:));
            tcoursemi = squeeze(Tens{condmi}(idExamp(i,2),idExamp(i,1),:));
            tcoursema_SE = squeeze(Tens_var{condma}(idExamp(i,2),idExamp(i,1),:));
            tcoursemi_SE = squeeze(Tens_var{condmi}(idExamp(i,2),idExamp(i,1),:));
            tcoursema_SE = sqrt(tcoursema_SE/getnorepeats(1));
            tcoursemi_SE = sqrt(tcoursemi_SE/getnorepeats(1));

            Fi = 1;
            tdom = (0:(length(tcoursema)-1))*ACQinfo.linesPerFrame*ACQinfo.msPerLine/1000;
            tdom = tdom-getparam('predelay');  tdom = tdom + idExamp(i,2)*ACQinfo.msPerLine/1000;
            subplot(length(idExamp(:,1)),3,3*i)
            
            fill([tdom(1:end-Fi) fliplr(tdom(1:end-Fi))],[tcoursemi(1:end-Fi)-tcoursemi_SE(1:end-Fi); flipud(tcoursemi(1:end-Fi)+tcoursemi_SE(1:end-Fi))]',[1 .0 .0])
            hold on
            plot(tdom(1:end-Fi),tcoursemi(1:end-Fi),'k'),xlabel('ms')
            
            fill([tdom(1:end-Fi) fliplr(tdom(1:end-Fi))],[tcoursema(1:end-Fi)-tcoursema_SE(1:end-Fi); flipud(tcoursema(1:end-Fi)+tcoursema_SE(1:end-Fi))]',[0 .0 1])
            hold on
            plot(tdom(1:end-Fi),tcoursema(1:end-Fi),'k'),xlabel('ms')
            title(['xpos = ' num2str(idExamp(i,1)) ';  ypos = ' num2str(idExamp(i,2))])
            xlim([-2 5])

        end
    end
    
end

