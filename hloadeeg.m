function [Data,Chan,Par] = hloadeeg(Fname,Chan,Range,NoChan,Type,ScaleFac)
%HLOADEEG [**5A2R++] Load .eeg-file (Vision Analyzer).
%
% [Data,Chan] = hloadeeg(Fname,Chan,Range,NoChan,DataType,ScaleFac)
% 
% NoChan = 64 by default.
% Chan  = [a:b] : Read channels a:b.
% Chan  = [] <=> Chan = [1:NoChan] Reads all channels.
% Range = [] <=> Range = [1,Inf] : Read all data.
% Range = [a,b] : Read data points a:b
% Range = [a,b,c,d,...] : Read data points [a,b,c,d,...]
% NoChan = Total number of (multiplexed) channels
% Type  = Data type / read precision, default = 'int16'
%         Output type is 'single' by default, unless input Type='*int16'
%
% Data = EEG data as float32 in *uV* by default!
%        NB: File data * 0.5 = EEG signal in uV (10^-6). See VHDR-file.
% Chan = Channel numbers in Data.
%
% SEE ALSO: hLoadVmrk(), hLoadVhdr()

% AUTHOR: Hendrik Mandelkow, 2003-08
% AUTH: HM, 2011-08, v.5A2R.


%% DEFAULTS:
%keyboard
OutType = 'single';
ScaleFac = 0.5;         % [uV] (default)
EXT = '.eeg';

%% CHECK INPUT:
if (nargin < 1) || isempty(Fname),
    [Fname,tmp] = uigetfile('*.eeg','hLoadEeg: Select .eeg-file');
    Fname = [tmp,Fname];
end;
[~,~,EXT] = fileparts(Fname);
if nargin<6 || isempty(ScaleFac) || isempty(Type) || isempty(NoChan) || ischar(NoChan),
    ParFile = strrep(Fname,EXT,'.vhdr');
    if nargin>3 && ischar(NoChan) && ~isempty(NoChan),
        ParFile = NoChan;
        NoChan = [];
    end
    fprintf('hLoadEeg: Read .vhdr-file: %s   ',ParFile);
    % Read entire file excluding #-comments, line brakes and blank lines.
    Par.text = textread(ParFile,'%s','delimiter','');
    fprintf('DONE.\n');

    if nargin<4 || isempty(NoChan),
        NoChan = 64;
        [tmp,idx] = hsscanr(Par.text,'NumberOfChannels\s*=\s*%d',1);
        NoChan = tmp{1};
        fprintf('\tNoChan = %u\n',NoChan);
        Par.text(1:idx) = [];
    end
    if nargin < 5 || isempty(Type),
        if strcmp(Fname(end-3:end),'.dat'),
            Type = 'float32';   % THIS IS NOT ALWAYS TRUE!
        else
            try
                [tmp,idx] = hsscanr(Par.text,'BinaryFormat\s*=\s*%s',1);
                Type = tmp{1};
                Type = lower(strrep(Type,'_',''));
            catch
                Type = 'int16';    % ***
            end
        end;
        fprintf('\tType = %s\n',Type);
        Par.text(1:idx) = [];
    end
end

if nargin < 3 || isempty(Range),
    Range = [1,Inf];
elseif length(Range)<2,
    Range = [1,Range(2)];
end;
if nargin < 2 || isempty(Chan),
    Chan = [1:NoChan];
end;

if Type(1)=='*',
    Type(1) = [];
    OutType = Type;
end
Bytes = hbytes(Type);

[Chan,idx] = sort(Chan(:)');
N0 = Chan(1)-1;
Nr = Chan(end)-N0;     % Number to read.
Ns = NoChan - Nr;   % Number to skip.
[fid,msg] = fopen(Fname,'r'); error(msg);
fseek(fid,(Range(1)-1)*NoChan*Bytes,'bof');
fseek(fid,N0*Bytes,'cof');
if Ns,
    Data = fread(fid,[Nr Range(end)-Range(1)+1],...
        [num2str(Nr),'*',Type,'=>',OutType],Ns*Bytes);
else
    Data = fread(fid,[Nr Range(end)-Range(1)+1],[Type,'=>',OutType]);
end;
fclose(fid);

if length(Range) > 2,
    Range = Range-Range(1)+1;
    Data = Data(:,Range);
end;
if any(diff(Chan,1)~=1),
    Data = Data(Chan-Chan(1)+1,:);
end;
[idx,idx] = sort(idx);
Data = Data(idx,:);
Chan = Chan(idx);
Data = Data.';
if ~isinteger(Data),
    Data = Data .* ScaleFac;
end
% END MAIN

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function Bytes = hbytes(Type)
% hBytes **1A++ : Size in bytes for a given variable type.
%
% EXAMPLE: Bytes = hbytes('uint16') = 2
%
% HM 10.2004, ver.1A

if Type(1)=='*', Type(1) = []; end
% Type = lower(Type);
try
  tmp = feval(Type,0);
  tmp = whos('tmp');
  Bytes = tmp.bytes;
catch
  Type = strrep(lower(Type),'ieee','');
  switch Type
    case {'uchar','unsigned char',...    % unsigned character,  8 bits.
        'schar','signed char',...% signed character,  8 bits.
        'int8','integer*1',...   % integer, 8 bits.
        'uint8','integer*1'},    % unsigned integer, 8 bits.
      Bytes = 1;
    case {'int16','integer*2',...        % integer, 16 bits.
        'uint16','integer*2'},   % unsigned integer, 16 bits.
      Bytes = 2;
    case {'int32','integer*4',...        % integer, 32 bits.
        'uint32','integer*4',... % unsigned integer, 32 bits.
        'single','real*4',...    % floating point, 32 bits.
        'float32','real*4'},     % floating point, 32 bits.
      Bytes = 4;
    case {'int64','integer*8',...        % integer, 64 bits.
        'uint64','integer*8',... % unsigned integer, 64 bits.
        'double','real*8',...    % floating point, 64 bits.
        'float64','real*8'},     % floating point, 64 bits.
      Bytes = 8;
    otherwise,
      error('Unknown data type: %s',Type);
  end;
end;

% END hbytes()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TEST:
function TEST
EegFile = hdir('*.eeg')
EegFile = EegFile{1}
fid = fopen(EegFile,'r');
eeg1 = fread(fid,[64 inf],'int16=>int16');
fclose(fid);
eeg1 = reshape(eeg1,64,[]).';

eeg2 = hloadeeg(EegFile);
isequal(eeg1,eeg2)

eeg1 = eeg1(1:1000,2:2:64);
eeg2 = hloadeeg(EegFile,[2:2:64],[1,1000]);
isequal(eeg1,eeg2)
