function Gplotaxismap_Gfit(mag,ang,anatflag)

global fh G_handles
%mag = log(mag)

%This is because of the funny stuff with bidirectional scanning
mag = mag(3:end-2,3:end-2); ang = ang(3:end-2,3:end-2);

mag = mag-min(mag(:));
mag = mag/max(mag(:));

dim = size(ang);
set(gcf,'Color',[1 1 1]);

if anatflag
    
    CH = GetTrialData([1 0 0 0],1);
%     if get(G_handles.fastMotionFlag,'Value')
%         [Px_fast Py_fast] = getTrialMotion3(CH{1});
%         CH{1} = makeGeoTrx(CH{1},Px_fast,Py_fast);
%     end
    imanat = mean(CH{1}(:,:,2:end-1),3);
    
    imanat = imanat(3:end-2,3:end-2);
    
    mi = prctile(imanat(:),0);    
    imanat = phi(imanat-mi);
    ma = prctile(imanat(:),100);
    imanat = imanat/ma;
    
    %%%
    mag = sqrt(imanat.*mag);
    %%%
    
    imfunc = ang;
    imfunc = imfunc/180;
    imfunc = round(imfunc*63+1);
    %imanat = round(imanat*63+1);

    hsvid = hsv;
    imout = zeros(dim(1),dim(2),3);
    for i = 1:dim(1)
        for j = 1:dim(2)            
            imout(i,j,:) = mag(i,j)*hsvid(imfunc(i,j),:);
        end
    end
    
    imanat(:,:,2) = imanat;
    imanat(:,:,3) = imanat(:,:,1);
    
    imout = imout+(imanat).^.3;

    imout = imout/max(imout(:));
    
    %imout = imout(1:end-4,8:end,:);
    
    x = image(imout,'CDataMapping','direct','AlphaDataMapping','none');

else
    imout = ang;
    imout = imout/180;
    imout = round(imout*63+1);
    x = image(1:length(ang(1,:)),1:length(ang(:,1)),imout,'CDataMapping','direct','AlphaData',mag,'AlphaDataMapping','none');
    
end

axis image;

fh = gcf;

colormap hsv
%colorbar('YTick',[1 16:16:64],'YTickLabel',{'0','45','90','135','180'})

%Create the orientation legend%%%%%%%%%%%%%%%%%%
legdom = 0:30:180;
hsvdom = hsv;
id = round(linspace(1,64,length(legdom)));
hsvdom = hsvdom(id,:);
R = 4;
rid = linspace(1,length(imout(:,1,1)),length(legdom));
cid = length(imout(1,:,1)) + 8;
xpts_o = [0 0];
ypts_o = [1-R 1+R];

for i = 1:length(legdom)
   
    xpts = xpts_o*cos(legdom(i)*pi/180) + ypts_o*sin(legdom(i)*pi/180);
    ypts = xpts_o*sin(legdom(i)*pi/180) - ypts_o*cos(legdom(i)*pi/180);
    ypts = ypts + rid(i);
    xpts = xpts + cid;
    hold on
    line(xpts,ypts,'Color',hsvdom(i,:),'Clipping','off','LineWidth',3);
    
end
hold off

%%%%%%%%%%%%%%%


datacursormode on;
dcm_obj = datacursormode(fh);
set(dcm_obj,'DisplayStyle','window','SnapToDataVertex','on','UpdateFcn',@myupdatefcn);


function txt = myupdatefcn(empt,event_obj)

%Matlab doesn't like it when I try to input other things into myupdatefcn,
%this is why I have these globals
 
global ACQinfo Tens Tens_var Flim TCWin Fsymbol G_handles oppCollapse

figure(99)

W = TCWin;

varflag = get(G_handles.EbarFlag,'Value');
    
tdom = 0:length(Tens{1}(1,1,:))-1;
tdom = tdom*ACQinfo.msPerLine/1000*ACQinfo.linesPerFrame;

predelay = getparam('predelay');
trialtime = getparam('stim_time');
tdom = tdom-predelay;

nr = getnorepeats(1);

SEn = sqrt(length(Flim(1):Flim(2))*nr);  %standard error normalizer for tuning curve
%  
pos = round(get(event_obj,'Position')); %pos(1) is column dimension

%%%

[tc tcourseHi tcourseLo axisdom blank legStr] = getpixeldata(pos,W);  %This does the work
%%%


tau = pos(2)*ACQinfo.msPerLine/1000;  
tdom = tdom + tau;

subplot(2,1,1)
if ~isempty(blank)
    plot([axisdom(1) axisdom(end)],[blank blank],'k'), hold on
else 
    %Even if no blank was shown we put a line at zero. 
    plot([axisdom(1) axisdom(end)],[0 0],'k'), hold on  
end

dori = axisdom(2)-axisdom(1);
orthD = round(90/dori)+1;
tc_pk = [tc(end-orthD+2:end) tc(1:orthD)];
dom_pk = (0:length(tc_pk)-1)*dori;

domI = linspace(dom_pk(1),dom_pk(end),3*length(dom_pk));
[tc_pkI] = interp1(dom_pk,tc_pk,domI,'spline');

[param ffit varacc ffitI domIfit] = Gaussfit(domI,tc_pkI,1);

plot(domIfit,ffitI,'k')
hold on
plot(0:dori:dori*(length(tc_pk)-1),tc_pk,'.')
axis off
title(num2str(round(param(2))))
hold off
legend(legStr)

xlabel(Fsymbol)


%Get 'orientation selectivity index' and put into the title
% if ~isempty(blank)
%     tc = tc-blank;
% end

d = size(tc);
if d(1) == 1 || d(2) == 1
    tcdum = tc;
else
    [y x] = find(tc == max(tc(:)));
    tcdum = tc(:,x);
end



TCSel = abs(tc'*exp(1i*2*axisdom'*pi/180));
TCSel = TCSel./sum((tc))';
TCSel =  round(TCSel*100)/100;
title(['OSI = ' num2str(TCSel')])

Fi = 1;

subplot(2,1,2)
if varflag
    dum_var = squeeze(sum(sum(Tens_var{idma}(yran,xran,:),1),2))/nopix/nr;
    errorbar(tdom(1:end-Fi),tcourseHi(1:end-Fi),sqrt(dum_var(1:end-Fi))), hold on 
else
    plot(tdom(1:end-Fi),tcourseHi(1:end-Fi),'-o'), hold on
end

if varflag
    dum_var = squeeze(sum(sum(Tens_var{idmi}(yran,xran,:),1),2))/nopix/nr;
    errorbar(tdom(1:end-Fi),tcourseLo(1:end-Fi),sqrt(dum_var(1:end-Fi)),'r')
else
    plot(tdom(1:end-Fi),tcourseLo(1:end-Fi),'-or')
end

ylimits = get(gca,'Ylim');
plot([0 trialtime],[ylimits(1) ylimits(1)]+(ylimits(2)-ylimits(1))/10,'k')

hold off
xlabel('sec')


tar = get(get(event_obj,'Target'));
data = tar.CData;

txt = {['X: ',num2str(pos(1))],...
       ['Y: ',num2str(pos(2))],...
       ['Ori: ' sprintf('%2.1f %%',data(round(pos(2)),round(pos(1)))/64*180) ' deg']};
       