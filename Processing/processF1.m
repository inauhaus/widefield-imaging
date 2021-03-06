function varargout = processF1(varargin)
%PROCESSF1 M-file for processF1.fig
%      PROCESSF1, by itself, creates a new PROCESSF1 or raises the existing
%      singleton*.
%
%      H = PROCESSF1 returns the handle to a new PROCESSF1 or the handle to
%      the existing singleton*.
%
%      PROCESSF1('Property','Value',...) creates a new PROCESSF1 using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to processF1_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      PROCESSF1('CALLBACK') and PROCESSF1('CALLBACK',hObject,...) call the
%      local function named CALLBACK in PROCESSF1.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help processF1

% Last Modified by GUIDE v2.5 21-Jul-2021 14:10:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @processF1_OpeningFcn, ...
                   'gui_OutputFcn',  @processF1_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before processF1 is made visible.
function processF1_OpeningFcn(hObject, eventdata, handles, varargin)
global anadir datadir Analyzer f1m bw

% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to processF0 (see VARARGIN)

% Choose default command line output for processF0
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes processF0 wait for user response (see UIRESUME)
% uiwait(handles.figure1);

rmpath('C:\Stimulator_master\COM_acquisition')
rmpath('C:\Stimulator_master\COM_display')
rmpath('C:\Stimulator_master\Calibration')
rmpath('C:\Stimulator_master\DisplayCode')
rmpath('C:\Stimulator_master\GUIs')
rmpath('C:\Stimulator_master\formula functions')
rmpath('C:\Stimulator_master\onlineAnalysis')
rmpath('C:\Stimulator_master\sync_inputs')

path('C:\ISI acquisition and analysis\Processing\AnalysisCode',path)
path('C:\ISI acquisition and analysis\Processing\ISI_Processing',path)
path('C:\ISI acquisition and analysis\Processing\ISIAnGUI',path)
path('C:\ISI acquisition and analysis\Processing\ISIAnGUI\general',path)
path('C:\ISI acquisition and analysis\Processing\AnalysisCode\DynamicProcess',path)
path('C:\ISI acquisition and analysis\Processing\AnalysisCode\DynamicProcess\RevCorr_GUI',path)
path('C:\ISI acquisition and analysis\Processing\offlineMovementCorrection',path)
path('C:\ISI acquisition and analysis\Processing\F1analysis',path)
path('C:\ISI acquisition and analysis\Processing\F1analysis\generalfunc',path)
path('C:\ISI acquisition and analysis\Processing\getMouseAreas',path)




global GF1_handles

GF1_handles = handles;

clear f1m1 f1m2 funcmap1 funcmap2 bcond bsflag bwCell1 bwCell2

% --- Outputs from this function are returned to the command line.
function varargout = processF1_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in process.
function process_Callback(hObject, eventdata, handles)
global f1m signals bw Analyzer

nc = length(Analyzer.loops.conds);

if get(handles.pixflag,'Value') == 1;
    pixels = eval(get(handles.pixels,'String'));
    psize = str2double(get(handles.pixsize,'String'));
    np = length(pixels(:,1));    %%no. of pixels
    
    t0 = cputime;
    [f1m signals] = Gf1meanimage(pixels,psize);  %Compute mean f1 for each condition
    t1 = cputime-t0;
    
    for i = 1:nc
        for j = 1:np
            Fourier_plot(signals{i}(j,:));
        end
    end
else
    t0 = cputime;
    [f1m signals] = Gf1meanimage();
    t1 = cputime-t0;
end

set(handles.time,'string',num2str(t1))
if ~isempty(bw)
    set(handles.plot,'enable','on')
end
set(handles.save,'enable','on')

UE = get(handles.loadexp,'string');
AUE = strcat(Analyzer.M.anim,'_',UE);
set(handles.loaded,'string',AUE)


function analyzedir_Callback(hObject, eventdata, handles)
% hObject    handle to analyzedir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of analyzedir as text
%        str2double(get(hObject,'String')) returns contents of analyzedir as a double


% --- Executes during object creation, after setting all properties.
function analyzedir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to analyzedir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function loadexp_Callback(hObject, eventdata, handles)
% hObject    handle to loadexp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of loadexp as text
%        str2double(get(hObject,'String')) returns contents of loadexp as a double


% --- Executes during object creation, after setting all properties.
function loadexp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loadexp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in setdirs.
function setdirs_Callback(hObject, eventdata, handles) 
% hObject    handle to setdirs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Analyzer

anim = get(handles.loadana,'String');

dir = get(handles.analyzedir,'String'); %partial path for analyzer file
setAnalyzerDirectory_pF1([dir anim '\'])

expt = get(handles.loadexp,'String');
loadAnalyzer_pF1(expt)

dir = get(handles.datadir,'String'); %partial path for .mat files 
setISIDataDirectory_pF1([dir anim '\' expt '\']); %append with animal and expt

fno = str2double(get(handles.frameno,'String'));    %Get frame number
tno = str2double(get(handles.trialno,'String'));    %Get trial number

Im = getTrialFrame(fno,tno-1);

axes(handles.rimage);     %Make rimage current figure
cla
imagesc(Im), colormap gray        
set(handles.rimage,'xtick',[],'ytick',[])

conds = length(Analyzer.loops.conds);
reps = length(Analyzer.loops.conds{1}.repeats);
set(handles.nocond,'string',num2str(conds))
set(handles.norep,'string',num2str(reps))
set(handles.dirstatus,'string','Loaded')

set(handles.setROI,'enable','on')
set(handles.process,'enable','on')

function datadir_Callback(hObject, eventdata, handles)
% hObject    handle to datadir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of datadir as text
%        str2double(get(hObject,'String')) returns contents of datadir as a double


% --- Executes during object creation, after setting all properties.
function datadir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to datadir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in funcim.
function funcim_Callback(hObject, eventdata, handles)
% hObject    handle to funcim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of funcim


% --- Executes on button press in retcov.
function retcov_Callback(hObject, eventdata, handles)
% hObject    handle to retcov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of retcov


% --- Executes on button press in retcont.
function retcont_Callback(hObject, eventdata, handles)
% hObject    handle to retcont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of retcont


% --- Executes on button press in delayim.
function delayim_Callback(hObject, eventdata, handles)
% hObject    handle to delayim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of delayim


% --- Executes on button press in plot.
function plot_Callback(hObject, eventdata, handles)
global bw f1m kmap_hor kmap_vert delay_hor delay_vert kmap delay sh magS Analyzer

%This is a hack in case I only did one retinotopic axis
if length(f1m) == 2 
    f1m{3} = f1m{2};
    f1m{4} = f1m{3};
    f1m{2} = f1m{1};
end
    

%%Create filter

checkvect = [get(handles.F1im,'value') get(handles.funcim,'value') get(handles.delayim,'value') get(handles.retcont,'value') get(handles.retcov,'value')];

H = []; L = [];
if checkvect*[0 1 1 1 1]' >= 1
    togstateHP = get(handles.HPflag,'Value');
    togstateLP = get(handles.LPflag,'Value');

    if togstateHP == 1
        Hwidth = str2double(get(handles.Hwidth,'string'));
        ind = get(handles.HPWind,'value');

        switch ind
            case 1
                sizedum = 2.5*Hwidth;
                H = -fspecial('gaussian',sizedum,Hwidth);
                H(round(sizedum/2),round(sizedum/2)) = 1+H(round(sizedum/2),round(sizedum/2));
            case 2
                H = hann(Hwidth)*hann(Hwidth)';
                H = -H./sum(H(:));
                H(round(Hwidth/2),round(Hwidth/2)) = 1+H(round(Hwidth/2),round(Hwidth/2));
            case 3
                H = -fspecial('disk',round(Hwidth/2));
                H(round(Hwidth/2),round(Hwidth/2)) = 1+H(round(Hwidth/2),round(Hwidth/2));
        end

    end

    if togstateLP == 1
        Lwidth = str2double(get(handles.Lwidth,'string'));
        ind = get(handles.LPWind,'value');

        switch ind
            case 1
                sizedum = 5*Lwidth;
                %L = fspecial('gaussian',sizedum,Lwidth);
                
                xy = (0:sizedum-1) - sizedum/2;
                [xdom ydom] = meshgrid(xy,xy);
                r = sqrt(xdom.^2 + xdom.^2);
                L = exp(-r.^2/(2*Lwidth^2));
                L = L/sum(L(:));
                
            case 2
                L = hann(Lwidth)*hann(Lwidth)';
                L = L./sum(L(:));
            case 3
                L = fspecial('disk',round(Lwidth/2));
        end
    end
end

hh = [];
if ~isempty(L) && isempty(H)
    hh = L;
elseif isempty(L) && ~isempty(H)
    hh = H;
elseif ~isempty(L) && ~isempty(H)
    hh = conv2(H,L);
end

%%Done making filter

%%Filter raw F1 images with hh and create the maps.
funcflag = get(handles.func,'value');
adaptbit = get(handles.adaptive,'value');

if isempty(bw) || sum(size(bw) ~= size(f1m{1}))
    bw = ones(size(f1m{1}));
end

if funcflag == 1
    [kmap_hor kmap_vert delay_hor delay_vert sh magS] = Gprocesskret(f1m,bw,adaptbit,L,H);

    
    
    if get(handles.projectorAdjustment,'value')
        
        kmap_horx = kmap_hor;
        kmap_vertx = kmap_vert;
        kmap_hor = kmap_vertx; 
        kmap_vert = kmap_horx; %This should be negative if the LCD was rotated clockwise
        
        %N.B. this assumes that the left side of stimulus is lined up with the left
        %side of the screen
        sang = 30; %Screen angle from midline
        sd = Analyzer.M.screenDist;
        sw = 32;  %screen width
        Xleft = sw-sd*tan(sang*pi/180); %distance between perpBis and left side of screen (cm)
        thetaLeft = atan(Xleft/sd)*180/pi; %angular distance from left side of screen to perpBis (deg)
        
        %This "thetaLeft" correction doesn't end up changing much
        %kmap_hor = kmap_hor+180;
        
        thetaLeft = 0;
        
        kmap_hor = kmap_hor/360/getparam('s_freq') - thetaLeft;
        
        kmap_vert = kmap_vert/360/getparam('s_freq');
        
        %kmap_hor = kmap_hor-atan(getparam('dy_perpbis')/Analyzer.M.screenDist)*180/pi;
        %kmap_vert = kmap_vert-atan(getparam('dx_perpbis')/Analyzer.M.screenDist)*180/pi;
    else
        kmap_vert = kmap_vert/360/getparam('s_freq');
        kmap_hor = kmap_hor/360/getparam('s_freq');
    end
            
else
    [kmap delay] = Gprocesskori(f1m,bw,hh);
end

if ~isempty(hh)
    hh2 = zeros(size(f1m{1}));
    hh2(1:length(hh(:,1)),1:length(hh(1,:))) = hh;
end

%Create plots
if funcflag == 1
    if checkvect(1) == 1
        N = length(f1m);
        figure
        for i = 1:N
            subplot(N/2,2,i)
                
            if ~isempty(hh)
             dumIm = ifft2(fft2(f1m{i}).*abs(fft2(hh2)));
             imagesc(angle(-dumIm)*180/pi)
            else
                imagesc(angle(-f1m{i})*180/pi)
            end

            title(strcat('Condition',num2str(i-1)))
            colorbar
        end
        colormap hsv
  
    end
    if checkvect(2) == 1
        figure
        sPer = 1/getparam('s_freq');
        imagesc(kmap_hor,[-sPer/2 sPer/2])
        title('Horizontal Retinotopy')
        colorbar
        colormap jet
        axis image

        figure
        imagesc(kmap_vert,[-sPer/2 sPer/2])
        title('Vertical Retinotopy')
        colorbar
        colormap jet
        axis image
%         
%         figure
%         contour(kmap_hor,-180:5:180,'r')
%         hold on
%         contour(kmap_vert,-180:5:180,'b')
%         title('Contour')
%         axis ij     %'contour' plots inverted

    end
    if checkvect(3) == 1
        figure
        imagesc(delay_hor,[-180 180])
        title('Delay (Horizontal)')
        colorbar('SouthOutside')
        colormap hsv
        truesize

        figure
        imagesc(delay_vert,[-180 180])
        title('Delay (Vertical)')
        colorbar
        colormap hsv
        truesize
    end
    if checkvect(4) == 1
        figure
        contour(kmap_hor,-180:5:180,'r')
        hold on
        contour(kmap_vert,-180:5:180,'b')
        title('Contour')
        axis ij     %'contour' plots inverted
    end
    if checkvect(5) == 1
        figure
        imagesc(sh)
        colormap gray
        title('ROI Coverage of Stimulus Area')
    end

else
    if checkvect(1) == 1
        figure
        subplot(1,2,1)
        imagesc(angle(-f1m{1})*180/pi) 
        title(strcat('Condition',num2str(0)))
        colorbar
        subplot(1,2,2)
        imagesc(angle(-f1m{2})*180/pi)
        title(strcat('Condition',num2str(1)))
        colormap hsv
        colorbar

    end
    if checkvect(2) == 1
        figure
        imagesc((kmap+180)/2,[0 180]),colorbar
        title('Orientation Map')
        colormap hsv
        truesize
    end
    if checkvect(3) == 1
        figure
        imagesc(delay,[-180 180]),colorbar
        title('Delay')
        colormap hsv
        truesize
    end

end

function frameno_Callback(hObject, eventdata, handles)
% hObject    handle to frameno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frameno as text
%        str2double(get(hObject,'String')) returns contents of frameno as a double

tno = str2double(get(handles.trialno,'String'));    %Get trial number
fno = str2double(get(handles.frameno,'String'));    %Get frame number

Im = getTrialFrame(fno,tno-1);

axes(handles.rimage);     %Make rimage current figure
cla
imagesc(Im), colormap gray     
set(handles.rimage,'xtick',[],'ytick',[])

% --- Executes during object creation, after setting all properties.
function frameno_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frameno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function trialno_Callback(hObject, eventdata, handles)
% hObject    handle to trialno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trialno as text
%        str2double(get(hObject,'String')) returns contents of trialno as a double

tno = str2double(get(handles.trialno,'String'));    %Get trial number
fno = str2double(get(handles.frameno,'String'));    %Get frame number

Im = getTrialFrame(fno,tno-1);

axes(handles.rimage);     %Make rimage current figure
cla
imagesc(Im), colormap gray     
set(handles.rimage,'xtick',[],'ytick',[])


% --- Executes during object creation, after setting all properties.
function trialno_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trialno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in setROI.
function setROI_Callback(hObject, eventdata, handles)
global bw f1m
% hObject    handle to setROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fno = str2double(get(handles.frameno,'String'));    %Get frame number
tno = str2double(get(handles.trialno,'String'));    %Get frame number

Im = getTrialFrame(fno,tno-1);

figure,imagesc(Im), colormap gray        

bw = roipoly;
close

if ~isempty(f1m)
    set(handles.plot,'enable','on')
end

% --- Executes on selection change in LPWind.
function LPWind_Callback(hObject, eventdata, handles)
% hObject    handle to LPWind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns LPWind contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LPWind


% --- Executes during object creation, after setting all properties.
function LPWind_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LPWind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Lwidth_Callback(hObject, eventdata, handles)
% hObject    handle to Lwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Lwidth as text
%        str2double(get(hObject,'String')) returns contents of Lwidth as a double


% --- Executes during object creation, after setting all properties.
function Lwidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Lwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
global Analyzer f1m
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

UE = get(handles.loadexp,'string');
path = 'C:\neurodata\Processed Data\';
filename = strcat(path,Analyzer.M.anim,'_',UE);
uisave('f1m',filename)

% --- Executes on selection change in func.
function func_Callback(hObject, eventdata, handles)
% hObject    handle to func (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns func contents as cell array
%        contents{get(hObject,'Value')} returns selected item from func


% --- Executes during object creation, after setting all properties.
function func_CreateFcn(hObject, eventdata, handles)
% hObject    handle to func (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load.
function load_Callback(hObject, eventdata, handles)
global f1m bw
% hObject    handle to load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile('*.mat', 'Pick a .mat file','C:\neurodata\Processed Data');

if filename ~= 0
    S = load(strcat(pathname,filename));  %Returns the contents in the .mat under the structure S
    if isfield(S,'f0m')
        warndlg('This is processed data from an F0 experiment.  Try again.','!!!') 
    else
    f1m = S.f1m;    %f1m is a cell array with images from each condition

    if ~isempty(bw)
        set(handles.plot,'enable','on')
    end
        set(handles.loaded,'string',filename(1:length(filename)-4))
    end
end

% --- Executes on button press in F1im.
function F1im_Callback(hObject, eventdata, handles)
% hObject    handle to F1im (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of F1im


% --- Executes on selection change in HPWind.
function HPWind_Callback(hObject, eventdata, handles)
% hObject    handle to HPWind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns HPWind contents as cell array
%        contents{get(hObject,'Value')} returns selected item from HPWind


% --- Executes during object creation, after setting all properties.
function HPWind_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HPWind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HPwidth_Callback(hObject, eventdata, handles)
% hObject    handle to HPwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HPwidth as text
%        str2double(get(hObject,'String')) returns contents of HPwidth as a double


% --- Executes during object creation, after setting all properties.
function HPwidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HPwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in HPflag.
function HPflag_Callback(hObject, eventdata, handles)
% hObject    handle to HPflag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of HPflag


% --- Executes on button press in LPflag.
function LPflag_Callback(hObject, eventdata, handles)
% hObject    handle to LPflag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LPflag



function pixels_Callback(hObject, eventdata, handles)
% hObject    handle to pixels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pixels as text
%        str2double(get(hObject,'String')) returns contents of pixels as a double


% --- Executes during object creation, after setting all properties.
function pixels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pixels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pixsize_Callback(hObject, eventdata, handles)
% hObject    handle to pixsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pixsize as text
%        str2double(get(hObject,'String')) returns contents of pixsize as a double


% --- Executes during object creation, after setting all properties.
function pixsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pixsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pixflag.
function pixflag_Callback(hObject, eventdata, handles)
% hObject    handle to pixflag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pixflag



function edit26_Callback(hObject, eventdata, handles)
% hObject    handle to loadexp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of loadexp as text
%        str2double(get(hObject,'String')) returns contents of loadexp as a double


% --- Executes during object creation, after setting all properties.
function edit26_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loadexp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function loadana_Callback(hObject, eventdata, handles)
% hObject    handle to loadana (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of loadana as text
%        str2double(get(hObject,'String')) returns contents of loadana as a double


% --- Executes during object creation, after setting all properties.
function loadana_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loadana (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in funcAnat.
function funcAnat_Callback(hObject, eventdata, handles)
% hObject    handle to funcAnat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global imstate

OverlayGuide(handles)


% --- Executes on button press in adaptive.
function adaptive_Callback(hObject, eventdata, handles)
% hObject    handle to adaptive (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of adaptive


% --- Executes on button press in projectorAdjustment.
function projectorAdjustment_Callback(hObject, eventdata, handles)
% hObject    handle to projectorAdjustment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of projectorAdjustment


% --- Executes on button press in getAreaBoundaries.
function getAreaBoundaries_Callback(hObject, eventdata, handles)
% hObject    handle to getAreaBoundaries (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global kmap_vert kmap_hor areaBounds

pixpermm = 120;

D = 4;

kmap_horX = kmap_hor(D:D:end,D:D:end);
kmap_vertX = kmap_vert(D:D:end,D:D:end);

areaBounds = getMouseAreasX(kmap_horX,kmap_vertX,pixpermm/D);

dim = size(areaBounds);
dimi = size(kmap_hor);
[x y] = meshgrid(1:dim(2),1:dim(1));
[xi yi] = meshgrid(linspace(1,dim(2),dimi(2)),linspace(1,dim(1),dimi(1)));
areaBounds = interp2(x,y,areaBounds,xi,yi);
areaBounds(find(areaBounds<.9)) = 0;




function reps_Callback(hObject, eventdata, handles)
% hObject    handle to reps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of reps as text
%        str2double(get(hObject,'String')) returns contents of reps as a double


% --- Executes during object creation, after setting all properties.
function reps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to reps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in negSignal.
function negSignal_Callback(hObject, eventdata, handles)
% hObject    handle to negSignal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of negSignal


% --- Executes on key press with focus on datadir and none of its controls.
function datadir_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to datadir (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
