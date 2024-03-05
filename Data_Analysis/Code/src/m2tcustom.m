function [value] = m2tcustom(handle, varargin)
    % M2TCUSTOM creates user-defined options for matlab2tikz output
    %
    % M2TCUSTOM can be used to create, get and set a properly formatted data 
    % structure to customize the conversion of MATLAB figures to TikZ using 
    % matlab2tikz. In particular, it allows to:
    %
    %   * add blocks of LaTeX/TikZ code around any HG object,
    %   * add blocks of comments around any HG object,
    %   * add TikZ options to any HG object,
    %   * add LaTeX/TikZ code inside some HG objects (e.g. axes),
    %   * provide a custom handler to convert a particular HG object.
    %
    % Note that this provides advanced functionality. Only very basic 
    % sanity checks are performed such that injudicious use may produce
    % broken TikZ figures!
    %
    % It is HIGHLY recommended that you are comfortable with:
    %
    %   * writing pgfplots, TikZ and LaTeX code, 
    %   * using the Handle Graphics (HG) framework in MATLAB/Octave, and
    %   * the inner working of matlab2tikz (for custom handlers)
    %
    % when you use this function. I.e. you should know what you are doing.
    %
    %
    % Usage as a GETTER:
    % ------------------
    %
    %     value = M2TCUSTOM(handle)
    %  retrieves the current custom data structure from the HG object "handle"
    %
    %
    % Usage as a SETTER:
    % ------------------
    %
    %             M2TCUSTOM(handle, ...) 
    %     value = M2TCUSTOM(handle, ...)
    % will construct the proper data structure and try to set it to the object
    % |handle| if possible. The arguments (see below) are specified in 
    % key-value pairs akin to a normal |struct|, but here we do a few checks
    % and data normalization.
    %
    % If we denote BLOCK to mean either a |char| or a |cellstr|, the following
    % options can be passed. Different entries in a cellstr are assumed
    % separated by a newline. The default values are empty.
    %     
    %     M2TCUSTOM(handle, 'commentBefore', BLOCK, ...)
    %     M2TCUSTOM(handle, 'commentAfter' , BLOCK, ...)
    % to add comments before/after the object. Our code translates newlines
    % and adds the percentage signs for you.
    %
    %     M2TCUSTOM(handle, 'codeBefore', BLOCK, ...)
    %     M2TCUSTOM(handle, 'codeAfter', BLOCK, ...)
    %     M2TCUSTOM(handle, 'codeInsideFirst', BLOCK, ...)
    %     M2TCUSTOM(handle, 'codeInsideLast', BLOCK, ...)
    % to add raw LaTeX/TikZ code respectively before, after, as first thing
    % inside or as last thing inside the pgfplots representation of the object.
    % Note that for some HG objects, (e.g. line objects), |codeInsideFirst|
    % and |codeInsideLast| do not make any sense and are hence ignored.
    %
    %     M2TCUSTOM(handle, 'extraOptions', OPTIONS, ...)
    % adds extra pgfplots/TikZ options to the end of the option list. Here,
    % OPTIONS is properly formatted TikZ code in 
    %     - a |char|    (e.g.  'color=red, line width=1pt'  )
    %     - a |cellstr| (e.g. {'color=red','line width=1pt'})
    %
    %     M2TCUSTOM(handle, 'customHandler', FUNCTION_HANDLE, ...)
    % allows you to replace the default matlab2tikz handler for this object.
    % This is not for the faint of heart and requires intimate knowledge of 
    % the matlab2tikz code base! We expect a function (either as |char| or
    % function handle) that will be called as
    %
    %     [m2t, str] = feval(handler, m2t, handle, custom)
    %
    % such that the expected function signature is:
    %
    %     function [m2t, str] = handler(m2t, handle, custom)
    %  
    % where |m2t| is an undocumented/unstable data structure,
    %       |str| is a char containing TikZ code representing the 
    %             HG object |handle| as generated by your handler,
    %       |custom| is a structure as returned by |m2tcustom|
    %             from which you only need to handle |extraOptions|,
    %             |codeInsideFirst| and |codeInsideLast| when applicable.
    % A particularly useful value for |customHandler| is 'drawNothing',
    % which remove the object from the output.
    %
    %       
    % Example: 
    % --------
    %
    % Executing the following MATLAB code fragment:
    %
    %    figure;
    %    plot(1:10);
    %    EOL = sprintf('\n');
    %    m2tCustom(gca, 'codeBefore'      , ['<codeBefore>' EOL]     , ...
    %                   'codeAfter'       , ['<codeAfter>'  EOL]     , ...
    %                   'commentsBefore'  ,  '<commentsBefore>'      , ...
    %                   'commentsAfter'   ,  '<commentsAfter>'       , ...
    %                   'codeInsideFirst' , ['<codeInsideFirst>' EOL], ...
    %                   'codeInsideLast'  , ['<codeInsideLast>'  EOL], ...
    %                   'extraOptions'    ,  '<extraOptions>');
    %
    %    matlab2tikz('test.tikz')
    % 
    % Should result in a |test.tikz| file with contents that look somewhat
    % like this:
    %
    %       \begin{tikzpicture}
    %           %<commentsBefore>
    %           <codeBefore>
    %           \begin{axis}[..., <extraOptions>]
    %               <codeInsideFirst>
    %               \addplot{...};
    %               <codeInsideLast>
    %           \end{axis}
    %           %<commentsAfter>
    %           <codeAfter>
    %       \end{tikzpicture}
    %
    % See also: matlab2tikz, setappdata, getappdata
    
    %% arguments specific to this constructor function
    ipp = m2tInputParser();
    ipp = ipp.addRequired(ipp, 'handle', @isHgObject);
    
    %% Declaration of the custom data structure
    ipp = ipp.addParamValue(ipp, 'codeBefore',      '', @isCellstrOrCharOrString);
    ipp = ipp.addParamValue(ipp, 'codeAfter',       '', @isCellstrOrCharOrString);
    
    ipp = ipp.addParamValue(ipp, 'commentsBefore',  '', @isCellstrOrCharOrString);
    ipp = ipp.addParamValue(ipp, 'commentsAfter',   '', @isCellstrOrCharOrString);
    
    ipp = ipp.addParamValue(ipp, 'codeInsideFirst', '', @isCellstrOrCharOrString);
    ipp = ipp.addParamValue(ipp, 'codeInsideLast',  '', @isCellstrOrCharOrString);
    
    ipp = ipp.addParamValue(ipp, 'extraOptions',    '', @isCellstrOrCharOrString);
    ipp = ipp.addParamValue(ipp, 'customHandler',   '', @isHandler);
    

     %% Converts Matlab Strings to chars to make it compatible with Strings
    varargin = convertArguments2Char(varargin{:});
    %% Parse the arguments
    ipp = ipp.parse(ipp, handle, varargin{:});
    
    %% Construct custom data structure
    % We leverage the results from the input parser. It provides us
    % with validation already. We just need to remove bookkeeping fields
    value = ipp.Results;
    value = rmfield(value, {'handle'});
    
    %% Normalize the actual values
    value.codeBefore      = cellstr2char(value.codeBefore);
    value.codeAfter       = cellstr2char(value.codeAfter);
    value.codeInsideFirst = cellstr2char(value.codeInsideFirst);
    value.codeInsideLast  = cellstr2char(value.codeInsideLast);
    value.commentsBefore  = cellstr2char(value.commentsBefore);
    value.commentsAfter   = cellstr2char(value.commentsAfter);
    if isempty(value.customHandler)
        value = rmfield(value, 'customHandler');
    end
    % extraOptions gets normalized by |opts_append_userdefined|
    
    %% Different Usage modes
    MATLAB2TIKZ = 'matlab2tikz'; % key used for application data storage
    if numel(varargin) == 0
        %% GETTER MODE
        % syntax: value = m2tcustom(h);
        if ~isempty(handle)
            object = getappdata(handle, MATLAB2TIKZ);
        else
            object = [];
        end
        if ~isempty(object)
            value = object;
        else
            % |value| contains all default (empty) values
        end
    else 
        %% SETTER MODE
        % syntax:         m2tcustom(h , key1, val1, ...)
        % syntax: value = m2tcustom([], key1, val1, ...)
        if ~isempty(handle)
            setappdata(handle, MATLAB2TIKZ, value);
        end
    end 
end
% == INPUT VALIDATORS ==========================================================
function bool = isHgObject(value)
    % true for HG object or empty (or numeric for backwards compatibility)
    bool = isempty(value) || ishghandle(value) || isnumeric(value);
end
function bool = isCellstrOrChar(value)
    % true for cellstr or char
    bool = ischar(value) || iscellstr(value);
end
function bool = isCellstrOrCharOrString(x)
%checks if input is either a cellstr or a char. And if we are working in a
%Matlab environment also if it is a string.
bool = iscellstr(x) || ischar(x);

if strcmp(getEnvironment(),'MATLAB')
    bool = bool || isstring(x);
end

end
function bool = isHandler(value)
    % true for char or function handle of the form [m2t, str] = f(m2t, h, opts)
    bool = isempty(value) || ischar(value) || ...
               (isa(value, 'function_handle') && ...
                atLeastOrUnknown(nargin(value), 3) && ...
                atLeastOrUnknown(nargout(value), 2));
end
function bool = atLeastOrUnknown(nargs, limit)
    % checks for |nargin| and |nargout| >= |limit| (or equal to -1)
    UNKNOWN = -1;
    bool = (nargs == UNKNOWN) || nargs >= limit;
end 
% == FIELD NORMALIZATION =======================================================
function value = cellstr2char(value)
    % convert cellstr to char (and keep char unaffected)
    if iscellstr(value)
        EOL = sprintf('\n');
        value = m2tstrjoin(value, EOL);
    end
end
% ==Make programm compatible with Matlab Strings=================================
function varargin = convertArguments2Char(varargin)
% This function converts the Arguments to char if any strings were
% handed over to be able to handle Matlab strings while staying
% compatible to GNU Octave

if strcmp(getEnvironment(),'MATLAB')

    for k = 1: length(varargin)

        if iscell(varargin{k})
            %converts cells of strings,'UniformOutput'==false to return
            %the results ass cellarray
            varargin{k} = cellfun(@convertStringsToChars,varargin{k},'UniformOutput',false);
        else
            %converts Strings, arrays of strings...
            varargin{k} = convertStringsToChars(varargin{k});
        end

    end
end
end
