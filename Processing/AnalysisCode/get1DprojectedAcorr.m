function [odacorr sfacorr dom] = get1DprojectedAcorr(imod,imsf,mask)

%Use principle axis of the ocular dominance map, get projection of OD and
%SF map along that axis, then take autocorrelation
%%
% imod = imod.*mask;
% imsf = imsf.*mask;

[xmicperpix ymicperpix] = getImResolution(1);
micperpix = (xmicperpix+ymicperpix)/2;

Win = hann(size(imod,1))*hann(size(imod,2))';

imoddum = imod-mean(imod(:));
imoddum = imoddum.*Win;
OD_Pow = fftshift(fftshift(abs(fft2(imoddum)),1),2).^2;

odradon = radon(imoddum,[0:10:170]);
[dum idproj] = max(var(odradon));


imsfdum = imsf-mean(imsf(:));
imsfdum = imsfdum.*Win;
SF_Pow = fftshift(fftshift(abs(fft2(imsfdum+100000000)),1),2).^2;
[idyDC idxDC] = find(SF_Pow == max(SF_Pow(:)));
xdom = (1:size(SF_Pow,2));
ydom = (1:size(SF_Pow,1));

xdom = xdom-xdom(idxDC);
ydom = ydom-ydom(idyDC);

SF_Pow(idyDC,idxDC) = 0;
OD_Pow(idyDC,idxDC) = 0;

sfradon = radon(imsfdum,[0:10:170]);

figure
subplot(1,2,1)
imagesc(xdom,ydom,OD_Pow), axis image
subplot(1,2,2)
imagesc(xdom,ydom,SF_Pow), axis image


odacorr = odradon(:,idproj)/max(odradon(:,idproj));
sfacorr = sfradon(:,idproj)/max(sfradon(:,idproj));

id = find(odacorr == 0);
odacorr(id) = [];
sfacorr(id) = [];

odacorr = xcorr(odacorr,odacorr,'coeff');
sfacorr = xcorr(sfacorr,sfacorr,'coeff');
dom = (1:length(odacorr))*micperpix;
id = find(odacorr == max(odacorr));
dom = dom-dom(id);
figure,plot(dom,odacorr)
hold on,plot(dom,sfacorr,'r')
xlim([0 800])

legend('OD autocorrelation','SF autocorrelation'), 