function kern = flashRep

global ACQinfo

trial = 3;
pepsettimetag(trial)
CHs{1} = GetTrialData([1 0 1]);
Nframes = length(CHs{1}{1}(1,1,:));
Tper = pepgetparam('t_period');  %stimulus period in frames
Tper = Tper(1)*.01*5/3;  %60Hz frame rate

synccourse = [];
for i = 1:Nframes
    dum = CHs{1}{2}(:,:,i)';
    synccourse = [synccourse; dum(:)];
end

synctimes = getsynctimes(synccourse);

rows = ACQinfo.linesPerFrame;
cols = ACQinfo.pixelsPerLine;
sp = ACQinfo.msPerLine*ACQinfo.linesPerFrame;

tdom = 0:Nframes-1;
tdom = tdom*ACQinfo.msPerLine*ACQinfo.linesPerFrame;
fdom = linspace(0,1,length(tdom)+1);
fdom = fdom(1:end-1)/sp*1000;

%pos = [81 69];
pos = [80 70];


W = 10;
xran = (pos(2)-floor(W/2)):(pos(2)+floor(W/2));
yran = (pos(1)-floor(W/2)):(pos(1)+floor(W/2));

tcourse = squeeze(mean(mean(CHs{1}{1}(yran,xran,:),1),2));
tcourse = zscore(tcourse);

%tcourse = LFPfilt(tcourse',0,1000/sp,0.8,0.2)';

fcourse = abs(fft(tcourse));


% hh = zeros(1,length(tcourse));
% hh(1:6) = ones(1,6);
% hh = hh/sum(hh);
% tcourse2 = ifft(fft(tcourse).*abs(fft(hh)));

figure,plot(tdom,tcourse,'r'),xlabel('sec')
figure,plot(fdom(1:length(fdom)/2),fcourse(1:length(fdom)/2)),xlabel('Hz')
hold on
plot([1/Tper 1/Tper],[0 max(fcourse)/10],'r')

ptime = ACQinfo.msPerLine/ACQinfo.pixelsPerLine;  %pixel time (ms)
tau_xy = (pos(1)-1)*ACQinfo.msPerLine + ptime*pos(2);
tdom_pix = tdom+tau_xy;   %time domain of the given pixel

dtau = 100;
taudom = -2000:dtau:2000;

for k = 1:length(taudom)
    
    ntrial = 0;
    kern(k) = 0;
    for j = 1:length(synctimes)
        id = find(tdom_pix>synctimes(j)+taudom(k)-dtau/2 & tdom_pix<synctimes(j)+taudom(k)+dtau/2);
        if ~isempty(id)
            kern(k) = kern(k) + tcourse(id(1));
            ntrial = ntrial+1;
        end

    end
    kern(k) = kern(k)/ntrial;
    
end

figure,plot(taudom,kern)
