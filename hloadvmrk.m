function Mrk = hloadvmrk(Fname)
% hLoadVMRK:3BC1: IBT Read EEG marker file (.vmrk).
%
% Mrk = hloadvmrk(Fname)
%
% SEE ALSO: HLOADEEG, HLOADVHDR, HLOADVMRK

% AUTHOR: Hendrik Mandelkow, 2003-10-23
% AUTH: HM 23.10.2003, ver.1A.
% AUTH: HM 13.06.2005, ver.2B.
% AUTH: HM 2007, ver.3BC.
% AUTH: HM 2011, ver.3BC1.

Mrk = {};
if nargin < 1,
    Fname = uigetfile('*.vmrk');
end;
%fprintf('hLoadVmrk: Read .vmrk-file: %s\n',Fname);
[fid,msg] = fopen(Fname); error(msg);
while ~feof(fid),
    tmp = textscan(fid,'Mk%u=%s%s%n%n%n%s','Delimiter',',','CommentStyle',';');
    if isempty(tmp{1}),
        tmp = textscan(fid,'%s',1,'Delimiter','\n','CommentStyle',';');
        continue
    end
    Mrk = [Mrk;tmp];
end
fclose(fid);

Mrk = cell2struct(Mrk,{'num','type','info','pos','size','chan','etc'},2);

%% OLD: See hloadvmrk2b.m
%     % This will cope with some irregular vmrk-files:
%     if size(tmp,2) > 6,
%         if (size(tmp,2)== 7) & isempty(tmp{1,3}),
%             warning('hLoadVMRK:MarkLen','Marker has too many fields - FIX!\n\t%s\n',[tmp{:}]);
%             tmp(1,3) = tmp(1,end);
%             tmp(:,end) = [];
%         else,
%             warning('hLoadVMRK:MarkLen','Too many fields for mark - IGNORE!\n\t%s\n',[tmp{:}]);
%             continue
%         end;
%     end;
    
%% OLD:
% Mrk(:,1) = strrep(Mrk(:,1),'Mk','');
% Mrk(:,[1,4:6]) = num2cell(str2double(Mrk(:,[1,4:6])));
% Mrk = cell2struct(Mrk,{'num','type','info','pos','size','chan'},2);
