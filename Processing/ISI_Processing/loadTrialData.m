function Tens = loadTrialData(varargin)

%if varargin has 2 elements, it assumes you have entered
%(condition,repeat).  If there is 1 element, it assumes you have entered
%the (timetag).

global datadir

if length(varargin) ==  2
    ttag = gettimetag(varargin{1},varargin{2});
elseif length(varargin) == 1
	ttag = varargin{1};
end

ue = datadir(end-8:end-1);

fname = [datadir ue  '_' sprintf('%03d',ttag)];

load(fname)  
%

%Use this if each frame is saved as a variable within the .mat file
fileinfo = whos('-file',fname);
Nframes = length(fileinfo);

dim = size(f1);
Tens = zeros(dim(1),dim(2),Nframes,'uint16');  %Preallocate!!

for i = 1:Nframes
    var = ['f' num2str(i)];
    eval(['Tens(:,:,i) = ' var ';']);
    eval(['clear ' var]) 
end

