function [kmap_hor kmap_vert delay_hor delay_vert sh] = processkret2(f1,bw,varargin)

%f1 is a cell containing the result from 'f1meanimage'.  varargin is the optional
%filter kernel.  Each of the images are smoothed with a Gaussian with a std 
%dev of 'stdev' and a width of 'width'.

% ang1 = f1{1}; %for one axis
% ang3 = f1{2}; 
% 
% ang0 = f1{1};
% ang2 = f1{2};

ang1 = f1{2}; %for two axes
ang3 = f1{4}; 
ang0 = f1{1};
ang2 = f1{3};

% ang1 = f1{2}; %for two axes
% ang3 = f1{3}; 
% ang0 = f1{1};
% ang2 = f1{4};


%The negative is to show where it peeks in the range of -180 to 180.
%i.e. -180 is the left most side of the stimulus.  Without the negative,
%an angle of -180 would have been the middle of the stimulus.
%angle(FourierTX(cos(wt-0))) == 0
if ~isempty(varargin)
    h = varargin{1};
    ang1 = angle(roifilt2(h,ang1,bw,'same'));
    ang3 = angle(roifilt2(h,ang3,bw,'same'));
    ang0 = angle(roifilt2(h,ang0,bw,'same'));
    ang2 = angle(roifilt2(h,ang2,bw,'same'));
else
    ang1 = angle(ang1);
    ang3 = angle(ang3);
    ang0 = angle(ang0);
    ang2 = angle(ang2);
end

%For plotting purposes.  Angles are still the same..
ang0 = ang0 + pi*(1-sign(ang0));  
ang1 = ang1 + pi*(1-sign(ang1));
ang2 = ang2 + pi*(1-sign(ang2));
ang3 = ang3 + pi*(1-sign(ang3));

figure,
subplot(2,2,1),imagesc(ang1*180/pi,'AlphaData',bw,[0 360]), colorbar, colormap hsv, title('90')
%hold on, contour(ang1,'k')
subplot(2,2,2),imagesc(ang3*180/pi,'AlphaData',bw,[0 360]), colorbar, colormap hsv, title('270')
%hold on,contour(ang3,'k')

subplot(2,2,3),imagesc(ang2*180/pi,'AlphaData',bw,[0 360]), colorbar, colormap hsv, title('180')
%hold on, contour(ang2,'k')
subplot(2,2,4),imagesc(ang0*180/pi,'AlphaData',bw,[0 360]), colorbar, colormap hsv, title('0')
%hold on,contour(ang0,'k')

%Find delay as the sum of the 2 vectors
delay_hor = angle(exp(1i*(ang0+pi)) + exp(1i*(ang2+pi)));
delay_vert = angle(exp(1i*(ang1+pi)) + exp(1i*(ang3+pi)));

%Make delay go from 0 to pi and 0 to pi, instead of 0 to pi and 0 to -pi.
%The delay can't be negative.  If the delay vector is in the bottom two
%quadrants, it is assumed that the it started at -180.  The delay always
%pushes the vectors counter clockwise.
% delay_hor = delay_hor + pi/2*(1-sign(delay_hor));
% delay_vert = delay_vert + pi/2*(1-sign(delay_vert));

%Use delay vector to calculate retinotopy.
% kmap_hor = .5*(angle(exp(j*(ang0-delay_hor))) - angle(exp(j*(ang2-delay_hor))));
% kmap_vert = .5*(angle(exp(j*(ang1-delay_vert))) - angle(exp(j*(ang3-delay_vert))));

kmap_hor = angle(exp(1i*(ang0-delay_hor)) + exp(-1i*(ang2-delay_hor)));
kmap_vert = angle(exp(1i*(ang2-delay_vert)) + exp(-1i*(ang3-delay_vert)));

kmap_hor = kmap_hor + pi*(1-sign(kmap_hor));
kmap_vert = kmap_vert + pi*(1-sign(kmap_vert));


%radians to degrees
delay_hor = delay_hor*180/pi.*bw;
kmap_hor = kmap_hor*180/pi.*bw;
delay_vert = delay_vert*180/pi.*bw;
kmap_vert = kmap_vert*180/pi.*bw;

%Create shadow of ROI coverage.
x = bw.*floor(100/360*(kmap_hor+180))+1;
y = bw.*floor(100/360*(-kmap_vert+180))+1;
%sh = shadow(x,y,100,100);
sh = [];

