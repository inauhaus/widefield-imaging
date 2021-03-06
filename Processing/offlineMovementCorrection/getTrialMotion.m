function [Pxhat Pyhat] = getTrialMotion2(CH,TTL)

global ACQinfo
% 
% tf = imformats('tif');
% info = feval(tf.info, filepath);
% infoH = info(1).ImageDescription;
% imgHeader = parseHeaderNew(infoH);
% ACQinfo = imgHeader.acq;

Idim = [ACQinfo.linesPerFrame ACQinfo.pixelsPerLine];
Fperiod = ACQinfo.msPerLine*ACQinfo.linesPerFrame; %frame period in ms


%Light smoothing of the data across time
tkern = [0 1 0];
tkern = tkern/sum(tkern);
kern = zeros(Idim(1),Idim(2),length(tkern));
for i = 1:length(tkern)
    kern(:,:,i) = ones(Idim(1),Idim(2))*tkern(i);
end

smoother = zeros(size(CH));
smoother(:,:,1:length(tkern)) = kern;

smoother = abs(fft(smoother,[],3));
CHsfilt = ifft(fft(CH,[],3).*smoother,[],3);



%Smooth data in space
skern = hann(10)';
skern = skern'*skern;
skern = skern/sum(skern(:));
smoother = zeros(Idim(1),Idim(2));
smoother(1:length(skern(:,1)),1:length(skern(1,:))) = skern;
smoother = abs(fft2(smoother));

CHsfilt(:,1) = CHsfilt(:,3);
CHsfilt(:,2) = CHsfilt(:,3);
CHsfilt(:,end) = CHsfilt(:,end-1);
CHsfilt(1,:) = CHsfilt(2,:);
CHsfilt(end-2:end,:) = ones(3,1)*CHsfilt(end-3,:);
for i = 1:length(CHsfilt(1,1,:))
    CHsfilt(:,:,i) = ifft2(fft2(CHsfilt(:,:,i)).*smoother);
end


%CHsfilt = CH;

%Get spatio-temporal gradient 
fstart = 2;
Chdum = CHsfilt(:,:,fstart:end-1);

[dFdx dFdy dFdt] = gradient(Chdum); %change per pixel, and change per frame
% dFdt = diff(Chdum,[],3);
% dFdx = dFdx(:,:,1:end-1);
% dFdy = dFdy(:,:,1:end-1);

lperbin = 17; %lines per section
Nbins = ceil(Idim(1)/lperbin);

for i = 1:Nbins
    
    yran = ((i-1)*lperbin+1):lperbin*i;    
    tensX = dFdx(yran,:,:);
    tensY = dFdy(yran,:,:);
    tensT = dFdt(yran,:,:);

    for tau = 1:length(tensT(1,1,:))
%         xdum = tensX(:,:,tau);
%         ydum = tensY(:,:,tau);
%         tdum = tensT(:,:,tau);
        xdum = tensX(1:end-1,1:end,tau);
        ydum = tensY(1:end-1,1:end,tau);
        tdum = tensT(1:end-1,1:end,tau);
%         H = [xdum(:) ydum(:)];  %plane should go through the origin: time derivative is zero when spatial derivs are zero        
%         Vxy = inv(H'*H)*H'*tdum(:);     
        
        pc = princomp([xdum(:) ydum(:) tdum(:)]);

        pc12 = pc(:,1:2)';
        H = pc12(:,1:2); y = pc12(:,3);
        Vxy = inv(H'*H)*H'*y;

        VxMat(i,tau) = Vxy(1);  %pixels per frame
        VyMat(i,tau) = Vxy(2);
    end
%     if i == 2
%         figure, plot(ydum(:),tdum(:),'.')
%         hold on
%         plot([-3000 3000],[-3000 3000]*Vxy(2))
%         xlim([-500 500]),ylim([-500 500])
%         Vxy(2)
%         xlabel('space derivative')
%         ylabel('time derivative')
%         asdf
%     end
    
end

%Estimate the initial condition for each bin
Pyo = linspace(0,mean([VyMat(1,1) VyMat(2,1)]),Nbins+1)';
Pyo = Pyo(1:end-1);
Pxo = linspace(0,mean([VxMat(1,1) VxMat(2,1)]),Nbins+1)';
Pxo = Pxo(1:end-1);

VxMat(:,1) = Pxo;
VyMat(:,1) = Pyo;

PxMat = -cumsum(VxMat,2);
PyMat = -cumsum(VyMat,2);

%Interleave the bins to create the continuous sequence
Px = zeros(1,numel(PxMat));
Py = zeros(1,numel(PyMat));
for i = 1:length(VxMat(:,1))
    
    Px(i:Nbins:end) = PxMat(i,:);
    Py(i:Nbins:end) = PyMat(i,:);
    
end

sp = lperbin*ACQinfo.msPerLine/1000;
tdom = (0:length(Px)-1)*sp;

%fit a sine wave
fdom = linspace(0,1/sp,length(Px)+1);
fdom = fdom(1:end-1);
Px = Px-median(Px); Py = Py-median(Py);
Hx = fft(Px); Hy = fft(Py);
startf = .4; endf = 4;  %A liberal range for where the harmonic is
endf = min([fdom(floor(end/2)) endf]);
idfrange = find(fdom>=startf & fdom<=endf); 
if max(abs(Hx(idfrange))) > max(abs(Hy(idfrange)))
    H = Hx;
else
    H = Hy;
end
figure,stem(fdom,abs(H),'.')

id1 = find(H == max(H(idfrange)));
id2 = find(H == max(H(idfrange)));
fo = fdom(id1);

% Perform a more fine search of the right frequency than the sampling of the
% Fourier basis.  i.e. when the "best" freq does not have an integer number
% of periods within the trial, it will mess things up.
fp = fdom(2)-fdom(1);
fsearch = linspace(fo-fp/2,fo+fp/2,20);
for i = 1:length(fsearch)
    harmR = cos(2*pi*fsearch(i)*tdom);
    harmI = -sin(2*pi*fsearch(i)*tdom);
    
    harmR = harmR/sum(harmR.^2);
    harmI = harmI/sum(harmI.^2);
    harm = 1i*harmI + harmR;
    
    Hxlocal(i) = sum(harm.*Px);
    Hylocal(i) = sum(harm.*Py);
end

[dum id] = max(abs(Hylocal));

%Resample such that each sample is for each line scanned during the trial
sphat = ACQinfo.msPerLine/1000;
tdomhat = (0:Idim(1)*length(CH(1,1,:))-1)*sphat;
tdomhat = tdomhat - (Idim(1)*sphat)*(fstart-1);
Pxhat = abs(Hxlocal(id))*cos(2*pi*fsearch(id)*tdomhat + angle(Hxlocal(id)));
Pyhat = abs(Hylocal(id))*cos(2*pi*fsearch(id)*tdomhat + angle(Hylocal(id)));

% Hxfilt = zeros(1,length(H));
% Hxfilt([id1 id2]) = Hx([id1 id2]);
% Pxhat = ifft(Hxfilt);
% Hyfilt = zeros(1,length(H));
% Hyfilt([id1 id2]) = Hy([id1 id2]);
% Pyhat = ifft(Hyfilt);

figure,plot(tdom,[Px' Py'])
hold on
plot(tdomhat,[Pxhat' Pyhat'])
xlabel('seconds'),ylabel('pixels')
legend('x position','y position')
