function Imtokern

global kernels kernelsIm maskS domains

oridom = domains.oridom;
sfdom = domains.sfdom;
phasedom = domains.phasedom;
colordom = domains.colordom;

smoothflag = 1;
sig = 1;
if smoothflag == 1
    smoother = fspecial('gaussian',size(maskS.im{1}),sig);
    smoother = abs(fft2(smoother));
    for ori = 1:length(oridom)
        for sf = 1:length(sfdom)
            for phase = 1:length(phasedom)
                for color = 1:length(colordom)
                    kdum = kernelsIm{ori,sf,phase,color};
                    id = find(isnan(kdum));  %NaNs come from movement correction interpolation
                    kdum(id) = 0;
                    
                    kernelsImF{ori,sf,phase,color} = zeros(size(kdum));
                    for tau = 1:length(kdum(1,1,:))
                        dum = kdum(:,:,tau);
                        kernelsImF{ori,sf,phase,color}(:,:,tau) = ifft2(fft2(dum).*smoother);
                    end
                end
            end
        end
    end
else
    kernelsImF = kernelsIm;
end

masklabel = bwlabel(maskS.bwCell{1},4);
celldom = unique(masklabel);
Ncell = length(celldom);

kernels = cell(1,Ncell);
for p = 3:Ncell
    p
    kernels{p} = zeros(length(oridom),length(sfdom),length(phasedom),length(colordom),length(kernelsIm{1,1,1,1}(1,1,:)));
    idcell = find(masklabel(:) == celldom(p))-0;
    for ori = 1:length(oridom)
        for sf = 1:length(sfdom)
            for phase = 1:length(phasedom)
                for color = 1:length(colordom)
                    for tau = 1:length(kernelsIm{ori,sf,phase,color}(1,1,:))
                        dum = kernelsImF{ori,sf,phase,color}(:,:,tau);
                        dum = dum(idcell);
                        %dum = dum(find(dum > prctile(dum,80)));
                        kernels{p}(ori,sf,phase,color,tau) = max((dum));
                    end
                end
            end
        end
    end
end


figure
for p = 3:Ncell
    subplot(ceil(sqrt(Ncell)),ceil(sqrt(Ncell)),p)
    
    kernplot = kernels{p}(:,1:3,:,:,:);
    kernplot = mean(kernplot,3);  %mean across phase
    kernplot = mean(kernplot,4); %mean across color
    
    kernplot = squeeze(nanmean(kernplot,2));  %mean across spatial freqency
    %blankmat = ones(length(kernplot(:,1)),1)*kernblank{p}(:)';

    %kernplot = (kernplot-blankmat);
    %kernplot = [kernplot; kernblank{p}(:)'];

    imagesc(real(kernplot))
    drawnow
end


