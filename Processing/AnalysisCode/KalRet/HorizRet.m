function HorizRet(saveFlag)
saveFlag;
%saveFlag = 1 or 0.  When equals 1, the figures will be automatically saved
%in fig, tif and eps formats.

global anim expt Conditions

% anim='j17';
% expt='006';
ExptID = strcat(anim,'_',expt); 

f1 = f1meanimage;  %Build F1 images (takes the longest)
L = fspecial('gaussian',15,1);  %make spatial filter
bw = ones(size(f1{1}));
[kmap_hor kmap_vert] = processkret(f1,bw,L);  %Make maps to plot, delete L if no smoothing

xsize = getparam('x_size');
horscfactor = xsize/360;
kmap_hor = kmap_hor*horscfactor;

HorizRet=figure('Name','Horizontal Retinotopy','NumberTitle','off');
    imagesc(kmap_hor,[-xsize/2 xsize/2])
    title('Horizontal Retinotopy ','FontSize',16)
    colorbar('SouthOutside')
    set(gcf,'Color','w')
    colormap hsv
    truesize

HorizRet_Contour=figure('Name','Horizontal Retinotopy- Contour','NumberTitle','off');
    [C,h]=contour(kmap_hor);
    contour(kmap_hor)
    clabel(C,'manual')
    title('Horizontal Retinotopy Contour  ','FontSize',16)
    set(gcf,'Color','w')
    axis ij
    
if saveFlag == 1
    %Paths for saving data and plots
    Root_AnalDir = 'I:\neurostuff\MapCortex\AnalyzedData\';
    AnalDir = strcat(Root_AnalDir,anim,'\',ExptID,'_HorizRet','\');
    if exist(AnalDir) == 0
        mkdir(AnalDir)
        ContinueTag = 1;
    elseif exist(AnalDir) == 7
        button = questdlg('Warning: The directory already exists for this experiment.  Hit Cancel to stop the save function.','Overwrite data?','Overwrite','Cancel','Cancel');
        if strcmp(button,'Overwrite') == 1
            ContinueTag = 1;
        elseif strcmp(button,'Cancel') == 1
            ContinueTag = 1;
            error('Save operation canceled by user. Consider renaming existing PopAnalysis directories and redoing the analysis.');
        end
    end
    if ContinueTag == 1
        saveas(HorizRet,strcat(AnalDir,ExptID,'_HorizRet.fig'))
        saveas(HorizRet,strcat(AnalDir,ExptID,'_HorizRet.tif'))
        HorizRetfilename=strcat(AnalDir,ExptID,'_HorizRet.eps')
        h = figure(HorizRet);
        print (h, '-depsc', HorizRetfilename)
        saveas(HorizRet_Contour,strcat(AnalDir,ExptID,'_HorizRet_Contour.fig'))
        saveas(HorizRet_Contour,strcat(AnalDir,ExptID,'_HorizRet_Contour.tif'))
        HorizRetContourfilename=strcat(AnalDir,ExptID,'_HorizRet_Contour.eps')
        h = figure(HorizRet_Contour);
        print (h, '-depsc', HorizRetContourfilename)    
end
% 
% FigureHandles = [HorizRet, HorizRet_Contour, Conditions];
% 
% button = questdlg('Would you like to close all the figure windows?','Close figures?','Close all','No','No');
% if strcmp(button, 'Close all')
%     close (FigureHandles)
% elseif strcmp(button, 'No')
end
