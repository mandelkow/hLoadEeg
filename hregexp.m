function [Token,Match,Start] = hregexp(str,expr,varargin)
% hREGEXP : Run REGEXP but return Matches and Tokens instead of indices in vars finish and token.
%
% SYNTAX: [Token,Match,Start] = hregexp(str,expr,varargin)   % see REGEXP(str,expr,...)
%
% str = cell-array of strings, char-arrays will be converted to cellstring.
% expr = regular expression, see REGEXP().
%
% Varargin can contain any or all of the following strings:
% 'once' : find first match only
% 'nocase' : ignore case
% 'cell' : Cell array output even if 1x1.
%
% Token{StrNo}{MatchNo,TokNo} == Tokens extracted from the matched strings.
% Match{StrNo}{MatchNo} == String that matched the regexp.
% Start{StrNo}(1,MatchNo) == Starting index of matches found.
%
% AUTH: HM, 27.03.03, ver. 1a

%%% TODO:
% - Output all indices for matches and tokens found.

%%% PARAM:
DEREF = 1;    % dereference 1x1-cells
ONCE = 0;       % use REGEXP(...,'once')
NOCASE = 0;     % use REGEXRI() (ignore case)
% if isa(str,'char'),
%     DEREF = 1;
% end;

for n = 1:length(varargin(:)),
    switch lower(varargin{n}),
        case 'once',
            ONCE = 1;
        case 'cell';
            DEREF = 0;
        case 'nocase';
            NOCASE = 1;
        otherwise,
            error(['Invalid input no. ',num2str(2+n),'.']);
    end;
end;

str = cellstr(str);     % Ensure str is a cellstring.

% +++ DO REGEXP():
if ONCE,
    if NOCASE,
        [Start,finish,token] = regexpi(str, expr, 'once');
    else,
        [Start,finish,token] = regexp(str, expr, 'once');
    end;
else,
    if NOCASE,
        [Start,finish,token] = regexpi(str, expr);
    else,
        [Start,finish,token] = regexp(str, expr);
    end;
end;

if isa(Start,'numeric'),    % Make sure output from regexp is a cell-array.
    Start = {Start};
    finish = {finish};
    token = {token};
end;
NoStr = length(Start);  % Nof lines in str.
Match = cell(NoStr,1);  % Match{StrNo,1}{MatchNo} = matches found.
Token = cell(NoStr,1);  % Token{StrNo,1}{MatchNo,TokNo} = tokens for each match.
for StrNo = 1:NoStr,
    NoMatch = length(Start{StrNo});
    for MatchNo = 1:NoMatch,
        Match{StrNo,1}{MatchNo} = ...
            str{StrNo}(Start{StrNo}(MatchNo):finish{StrNo}(MatchNo)); % +++
    end;
end;

for StrNo = 1:NoStr,    % +++ FOR each string...
    if isa(token{StrNo},'numeric'), token{StrNo} = {token{StrNo}}; end;
    NoMatch = length(token{StrNo});
    for MatchNo = 1:NoMatch,    % FOR each match...
        NoTok = size(token{StrNo}{MatchNo},1);
        if NoTok > 0,
            for TokNo = 1:NoTok,
                Token{StrNo,1}{MatchNo,TokNo} = ...
                    str{StrNo}(token{StrNo}{MatchNo}(TokNo,1):token{StrNo}{MatchNo}(TokNo,2)); % +++
            end;
        else,
            % If no tokens, return the whole match as token?
            % OBSOLETE - IS DONE BELOW!
            % Token{StrNo,1}{MatchNo,1} = Match{StrNo,1}{MatchNo};    % +++
        end;
    end;
    if DEREF && length(Token{StrNo,1}) == 1,
        Token{StrNo,1} = Token{StrNo,1}{1};
    end;
end;

if DEREF && length(Start) < 2,
    Start = Start{1};
    Match = Match{1};
    Token = Token{1};
end;

if isempty(Token),
    Token = Match;
end;

return;

%%% TEST:
[a,b,c] = hregexp({'qwer0987.rec234.rec','234ijhub23.rec'},'(\d+)\.(rec)')
[a,b,c] = hregexp('234ijhub23.rec1234.rec','(\d+)\.rec')
