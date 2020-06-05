function [Value,M] = hsscanf(String,Format,N)
% hSSCANF : Do SSCANF for a cell array of strings.

ONCE = 0;
CELLOUT = 0;

if nargin < 3, N = Inf; end;

if isa(String,'char'), String= cellstr(String); end;
NoStr = length(String(:));

%Value = cell(size(String));
Value = {};
M = [];
for StrNo = 1:NoStr,
   [A,count] = sscanf(String{StrNo},Format,N);
   if count > 0,
     Value{StrNo,1} = A;
     M(StrNo) = StrNo;
     if ONCE,
         break;
     end;
   end
end;
if ~CELLOUT,
    Value = cat(1,Value{:});
end;

return;