function [T,I,R] = hsscanr(S,F,ONCE)
%HSSCANR [**1b1] SSCANF() using regexps as format string.
%
% SYNTAX: [T,I,R] = hsscanr(S,F)
%
% S = array of stings or cellstrings
% F = Regexp pattern with SSCANF codes (%d %g ...)
% T{MatchNo,TokNo} = scanned values
% I = line numbers of positive hits
% R = Regexp used for REGEXP()
%
% SSCANF codes (like %2.2d %3f %6.0g) found in F are replaced by regular
% expressions which are used to search the string S before evaluating the
% retrieved tokens using SSCANF.

% AUTHOR: Hendrik Mandelkow, 2003-04, v1bc
% AUTH: HM, 23.09.2003, ver. 1B1. BUGFIX T{NoMatch,TokNo} = ...

if nargin < 3, ONCE = 0; end;

I = [];
T = {};             % *** return empty if nothing
S = cellstr(S);     % *** HOWTO ensure you've got a cellstring.
NoStr = size(S,1);
f = hregexp(F,'%[hl\d\.]*[defgiouxcs]');    % +++ find conversinon codes in F
if isempty(f),
    warning('HSSCANR:NoConv','No conversion chars in format string:\n%s',F);
    return;
end;
% Replace conversion codes in F by appropriate regexps:
% numerical conversions:
%R = regexprep(F,'%[hl\d\.]*[defgiou]','([eE-,\.\d]+)');
R = regexprep(F,'%[hl\d\.]*[defgiou]',' *([eE-,\.\d]+)');   % allow for extra spaces
% hexadecimal conversion:
%R = regexprep(R,'%[hl\d\.]*[x]','([-,ABCDEFabcdef\.\d]+)');
R = regexprep(R,'%[hl\d\.]*[x]',' *([-,ABCDEFabcdef\.\d]+)');   % allow extra spaces
% chars and strings:
R = regexprep(R,'%[hl\d\.]*[cs]','(.*)');

NoMatch = 0;
for StrNo = 1:NoStr,
    Tok = hregexp( S{StrNo}, R);    % +++ search every line for regexp
    if isempty(Tok), continue; end; % nix gefunden
    % if isempty(Tok), Tok = ''; end;
    NoMatch = NoMatch + 1;
    I(NoMatch) = StrNo;
    Tok = cellstr(Tok);
    for TokNo = 1:length(Tok),
        % +++ Convert each token found:
        % HM! 23.09.2003 T{StrNo,TokNo} = hsscanf( Tok{TokNo}, f{TokNo});
        T{NoMatch,TokNo} = hsscanf( Tok{TokNo}, f{TokNo});
    end;
    if ONCE, break; end;
end;
return;

%%% TEST:
S = 'asd 23.4 73.6 -234 65 87 23e7'
F = 'asd %1c %d %d %u %f %g'
hsscanr(S,F)

