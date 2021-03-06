function [rrad rall rdom] = circcorr2D(im,mask,circflag)

dim = size(im);

r = zeros(size(im));
for i = 1:dim(1)
    i
    for j = 1:dim(2)
        
         pc1 = im(i:end,j:end);
         pc2 = im(1:end-i+1,1:end-j+1);
         msk1 = mask(i:end,j:end);
         msk2 = mask(1:end-i+1,1:end-j+1);
         
         id = find(msk1(:) & msk2(:));         
         
         if circflag
             r(i,j) = cxcorr2(pc1(id),pc2(id),180); %coherence projection
         else
             R = corrcoef(pc1(id),pc2(id));
             if length(R(:))>1
                 r(i,j) = R(1,2);
             end
         end
        
    end
end

r2 = zeros(size(im));
for i = 1:dim(1)
    i
    for j = 1:dim(2)
        
         pc1 = im(i:end,1:end-j+1);
         pc2 = im(1:end-i+1,j:end);
         
         msk1 = mask(i:end,1:end-j+1);
         msk2 = mask(1:end-i+1,j:end);
         
         id = find(msk1(:) & msk2(:)); 
         
         if circflag
             r2(i,j) = cxcorr2(pc1(id),pc2(id),180); %coherence projection
         else
             R = corrcoef(pc1(id),pc2(id));
             if length(R(:))>1
                 r2(i,j) = R(1,2);
             end
         end
        
    end
end

botom = [fliplr(r) r2(:,2:end)];
rall = [flipud(botom); fliplr(botom(2:end,:))];
%%
[xmicperpix ymicperpix] = getImResolution(1);
xdom = 0:(size(rall,1)-1); ydom = 0:(size(rall,2)-1);
xdom = xdom-xdom(end)/2; ydom = ydom-ydom(end)/2;
xdom = xdom*xmicperpix; ydom = ydom*ymicperpix;


figure,imagesc(xdom,ydom,rall), colorbar
xlabel('um'),ylabel('um')
axis square

[x y] = meshgrid(xdom,ydom);
R = sqrt(x.^2 + y.^2);

rdom = 0:5:max(R(:));
clear rrad
for i = 1:(length(rdom)-1)
    
   id = find(R(:)>=rdom(i) & R(:)<rdom(i+1));    
   rrad(i) = nanmean(rall(id));
    
end
rdom = rdom(1:end-1);
figure,plot(rdom,rrad)
xlim([0 1000]),ylim([-.2 1])
xlabel('um')