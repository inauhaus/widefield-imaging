function playRedGreenTens(Tens,fp)

dim = size(Tens{1})

plotter = zeros(dim(1),dim(2),3);

figure(1)


for i = dim(3):-1:1;

    imG = Tens{1}(:,:,i);
    imR = Tens{2}(:,:,i);

    imG = imG-min(imG(:));
    imG = imG/max(imG(:));
    imR = imR-min(imR(:));
    imR = imR/max(imR(:));

    plotter(:,:,1) = imR;
    plotter(:,:,2) = imG;

    depth = (5*dim(3) - 5*i) + 100;
    
    image(plotter), title(['depth = ' num2str(depth) ' microns'],'Fontsize',14), drawnow
    
    if i == dim(3)
        input('')
        
    end
    
    pause(fp)  
     

end
