function Hdr = hloadvhdr(Fname)
% hLoadVHDR [**1AR+] IBT Read EEG header file (.vhdr).
%
% Hdr = hloadvhdr(Filename)
%
% SEE ALSO: HLOADEEG, HLOADVHDR, HLOADVMRK

% AUTHOR: Hendrik Mandelkow, 2004-05-12
% AUTH: HM 12.05.2004, ver.1A.
% FIXIT: Make pattern reading more robust. See data sb_*.vhdr

if nargin < 1,
  Fname = uigetfile('*.vhdr');
end;
if strcmpi(Fname(end-3:end),'.eeg'),
  warning('Replace wrong extension (.eeg).');
  Fname(end-3:end+1) = '.vhdr';
end
%fprintf('hLoadVmrk: Read .vmrk-file: %s\n',Fname);
% Read entire file excluding #-comments, line brakes and blank lines.
%Text = textread(Fname,'%s','delimiter','','commentstyle','shell');
Text = textread(Fname,'%s','delimiter','');

%%% Find and delete comment lines:
idx = strmatch(';',Text);   % Find comment lines.
Text(idx) = [];

%%%-----------------------------------------------------
%%% Find / separate sections:
% idx = strmatch('[',Text);   % Find Headings.
% if idx(1) > 1,
%     Text = [{'[Header]'}; Text];
%     idx = [1;idx+1];
% end;
% idx(end+1) = length(Text)+1;
% for n=1:length(idx)-1,
%     Section(n).name = Text{idx(n)};
%     Section(n).text = Text(idx(n)+1:idx(n+1)-1);
% end;

%%%-----------------------------------------------------
% for n = 1:diff(idx(Nidx:Nidx+1))-1,
%     [ChNo,ChName,ChRef,ChRes] =...
%         strread(Text{idx(Nidx)+n},'Ch%*u=%s%u%f','delimiter',',');
%%%-----------------------------------------------------
%%% The [Channel Infos] are not necissarily correct:
LineNo = strmatch('#     Name      Phys. Chn.',Text);
if isempty(LineNo),
  LineNo = strmatch('Name      Phys. Chn.',Text);
end;
if LineNo,
  try,
    while 1,
      LineNo = LineNo + 1;
      % FIXIT: Not robust against some file variations:
      %             [ChNo,ChName,ChPhys,ChRes,ChLow,ChHigh,ChNotch] =...
      %                 strread(Text{LineNo},'%u%s%u%f%f%f%s');
      [ChNo,ChName,ChPhys,ChRes] =...
        strread(Text{LineNo},'%u%s%u%f',1);   % HOTFIX!
      % ChNo = Number of RECORDING channel.
      Hdr.ChName(ChNo,1) = ChName;    % Standart? Channel Names
      Hdr.ChPhys(ChNo,1) = ChPhys;    % Standart? Physiology? channel number.
      Hdr.ChRes(ChNo,1) = ChRes;      % Channel resolution in uV
      %             Hdr.ChLow(ChNo,1) = ChLow;      % High-pass filter cutoff in sec!
      %             Hdr.ChHigh(ChNo,1) = ChHigh;    % Low-pass filter cutoff in Hz!
      %             Hdr.ChNotch(ChNo,1) = ChNotch;  % Notch filter On/Off
    end;
  catch,
  end;
else,
  warning('Standart pattern not found. Trying alternate.');
  LineNo = strmatch('[Channel Infos]',Text);
  try,
    while 1,
      LineNo = LineNo + 1;
      [ChNo,ChName,ChRef,ChRes] =...
        strread(Text{LineNo},'Ch%u=%s%u%f','delimiter',',');
      Hdr.ChName(ChNo,1) = ChName;
      Hdr.ChRef(ChNo,1) = uint8(ChRef);
      Hdr.ChRes(ChNo,1) = ChRes;
    end;
  catch,
  end;
end;
