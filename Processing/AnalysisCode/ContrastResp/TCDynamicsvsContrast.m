function TCDynamicsvsContrast

global Tens bwCell1 ACQinfo bw
tic
kernPop = GetCellTimeKernels(Tens,bwCell1.*bw);
toc
Flim = [7 22];


tdom = 0:length(Tens{1}(1,1,:))-1;
tdom = tdom*ACQinfo.msPerLine/1000*ACQinfo.linesPerFrame;
if isfield(ACQinfo,'stimPredelay')
    predelay = ACQinfo.stimPredelay;
    trialtime = ACQinfo.stimTrialtime;    
    tdom = tdom-predelay;
end

%Get rid of frames when the shutter closes
shbad = 3;
tdom = tdom(1:end-shbad);
for i = 1:length(kernPop)
    kernPop{i} = kernPop{i}(:,:,1:end-shbad);
end

dim = size(kernPop{1});

dori = 360/dim(2);
oridom = (0:dim(2)-1)*dori;

h = exp(1i*oridom*2*pi/180)';
kernPopmod = cell(1,length(kernPop));
hsmooth = zeros(dim(2),dim(3));
sdum = ones(dim(2),1)*[.5 1 .5];
hsmooth(:,1:length(sdum(1,:))) = sdum/sum(sdum(1,:));
hsmooth = abs(fft(hsmooth'));
k = 1;
for i = 1:length(kernPop)  %loop through each cell
    
    if max(kernPop{i}(:)) > .05

        kern = kernPop{i};
        kdum = mean(kern(:,:,Flim(1):Flim(2)),3);
        tcdum = mean(kdum(2:end,:));
        idma = find(tcdum == max(tcdum));
        kern = circshift(kern,[0 round(dim(2)/2)-idma 0]);
        kernPopmod{i} = kern;
        idma = round(dim(2)/2);

        for c = 1:dim(1)  %loop through each contrast

            tctaumat = squeeze(kernPopmod{i}(c,:,:))';
            
            tctaumat = ifft(fft(tctaumat).*hsmooth);
            
            tcourseBest{c}(:,k) = tctaumat(:,idma);  %Take timecourse from best condition
            tcourseFlank{c}(:,k) = (tctaumat(:,idma-1) + tctaumat(:,idma+1))/2;  %Take timecourse from adjacent
            tcourseOrth{c}(:,k) = (tctaumat(:,idma-2) + tctaumat(:,idma+2))/2;  %Take timecourse from best orth


            base = (tctaumat(:,idma-2) + tctaumat(:,idma+2))/2;
            base = base*ones(1,dim(2));
            tctaumat = tctaumat - base;

            amp = tctaumat(:,idma);
            amp = amp*ones(1,dim(2));
            tctaumat = tctaumat./amp;

            flank = (tctaumat(:,idma-1) + tctaumat(:,idma+1))/2;

            Slopetau{c}(:,k) = tctaumat(:,idma) - flank;

            normer = sum(tctaumat,2);
            pol = tctaumat*h;
            Magtau{c}(:,i) = abs(pol)./normer;



        end

        k = k+1;

    end
      
end

%Magtau = Slopetau;

%Plot timecourses for high contrast



figure
for c = 1:dim(1)

    tb = tcourseBest{c};
    tf = tcourseFlank{c};
    to = tcourseOrth{c};

%     ma = max(tb);
%     ma = ones(length(tb(:,1)),1)*ma;
%     tb = tb./ma;
%     ma = max(tf);
%     ma = ones(length(tf(:,1)),1)*ma;
%     tf = tf./ma;
%     ma = max(to);
%     ma = ones(length(to(:,1)),1)*ma;
%     to = to./ma;

    mutb = mean(tb,2);
    mutf = mean(tf,2);
    muto = mean(to,2);
    sigtb = std(tb,[],2);
    sigtf = std(tf,[],2);
    sigto = std(to,[],2);

    mutb = mutb/max(mutb);
    sigtb = sigtb/max(mutb);
    mutf = mutf/max(mutf);
    sigtf = sigtf/max(mutf);
    muto = muto/max(muto);
    sigto = sigto/max(muto);

    %figure,
    subplot(1,dim(1),c)
    errorbar(tdom,mutb,sigtb/sqrt(length(tb(:,1))))
    hold on
    errorbar(tdom,mutf,sigtf/sqrt(length(tf(:,1))),'g')
    errorbar(tdom,muto,sigto/sqrt(length(to(:,1))),'r')
    plot([0 trialtime],[0 0],'k')
    xlabel('sec')
    ylabel('dF/F')
    legend('peak','flank','orth')
    hold off

end

figure
for c = 1:dim(1)

    tb = tcourseBest{c};
    tf = tcourseFlank{c};
    to = tcourseOrth{c};
    %muslope{c} = mean(tb,2)./mean(tf,2);
    tb = tb-to;
    tf = tf-to;
    slope = (tb-tf)./tb;
    %slope = tb./tf;
    
    id = find(slope <= 0 | slope > 30);
    slope(id) = NaN;
    
    muslope{c} = nanmean((slope),2);
    sigslope{c} = nanstd((slope),[],2);
    sigslope{c} = sigslope{c}/sqrt(length(slope(1,:)));
    
    subplot(1,dim(1),c)
    plot(tdom,muslope{c})
    hold on
    plot([0 trialtime],[0 0],'k')
    
end

figure,errorbar(tdom,muslope{3},sigslope{3},'r')
hold on
errorbar(tdom,muslope{2},sigslope{2})
xlim([0 4])

%%%
%%%


magtauHi = Magtau{3};
magtauLo = Magtau{2};

mutcHi = mean(magtauHi,2);
mutcLo = mean(magtauLo,2);
sigtcHi = std(magtauHi,[],2);
sigtcLo = std(magtauLo,[],2);
figure,errorbar(tdom,mutcHi,sigtcHi/sqrt(length(magtauHi(1,:))))
hold on
errorbar(tdom,mutcLo,sigtcLo/sqrt(length(magtauHi(1,:))),'r')
plot([0 trialtime],[0 0],'k')
xlabel('sec')
ylabel('OSI')
legend('hi contrast','lo contrast')
hold off


