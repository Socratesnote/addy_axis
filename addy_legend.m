function varargout = addy_legend(varargin)
%ADDY_LEGEND Create a legend of all plots in this figure, including
%those added to additional axes created with addyaxis().

% Use:
% legend_handle = addy_legend('legend entry');
% legend_handle = addy_legend('legend', {'legend entry'});
% legend_handle = addy_legend('lines', [line1 line2], 'legend', {'legend entry1', 'legend entry2'});
% legend_handle = addy_legend('fig', gcf, 'lines', [line1 line2], 'legend', {'legend entry1', 'legend entry2'});

% Inspired by yyaxis,
% plotyyy (https://www.mathworks.com/matlabcentral/fileexchange/1017-plotyyy),
% and addaxis (https://www.mathworks.com/matlabcentral/fileexchange/9016-addaxis).

%% Argument parsing
narginchk(1, inf);

function_parser = inputParser;
function_parser.KeepUnmatched = true;
function_parser.PartialMatching = false;

% Required
% requiredArguments = {};
% for ii = 1:length(requiredArguments)
%   addRequired(function_parser, requiredArguments{ii})
% end

% Optional
defaultOptional = {gcf, [], [], {}};
optionalArguments = {'fig', 'ax', 'lines', 'legend'};
verificationFunction = {...
  @(potential_figure) ( strcmpi(class(potential_figure), 'matlab.ui.Figure') ), ...
  @(potential_axes) ( strcmpi(class(potential_axes), 'matlab.graphics.axis.Axes') ), ...
  @(lines) strcmpi(class(lines(1)), 'matlab.graphics.chart.primitive.Line') ...
  @(entries) ischar(entries{1})};
for ii = 1:length(optionalArguments)
  addOptional(function_parser, optionalArguments{ii}, defaultOptional{ii}, verificationFunction{ii})
end

% Parameters
% defaultParameter = {};
% parameterArguments = {};
% for ii = 1:length(parameterArguments)
%   addParameter(function_parser, parameterArguments{ii}, defaultParameter{ii})
% end

% Parse
varargparsed = varargin;
parse(function_parser, varargparsed{:});

% Assign
hfig = function_parser.Results.fig;
hax = function_parser.Results.ax;
if isempty(hax)
  % Assume the axes created last are the (invisible) added axes that
  % should contain the legend.
  hax = hfig.Children(1);
end
p = function_parser.Results.lines;
entries = function_parser.Results.legend;
f = fields(function_parser.Unmatched);
rest = cell(1, 2*length(f));
for ii = length(f)
  rest{1, 2*ii-1} = f(ii);
  rest{1, 2*ii} = {function_parser.Unmatched.(f{ii})};
end

%% AddYLegend

% Collect all line objects if none provided. When iterating through
% the children and the grandchildren from 1 to end, the lines are
% collected in reverse chronological order (newest - oldest)
if isempty(p)
  ii = 0;
  p = gobjects(0);
  for jj = 1:length(hfig.Children)
    if ~strcmpi(class(hfig.Children(jj)), 'matlab.graphics.axis.Axes')
      continue
    end
    % If the axes are left/right paired, go through them in reverse
    % order.
    for ll = flip(1:length(hfig.Children(jj).YAxis))
      if ll == 2
        yyaxis('right');
      elseif ll == 1
        yyaxis('left');
      end
      for kk = 1:length(hfig.Children(jj).Children)
        ii = ii + 1;
        p(ii) = hfig.Children(jj).Children(kk);
      end
    end
  end
  % Re-arrange to chronological order
  p = flip(p);
end

leg_handle = legend(hax, p, entries, rest{:});

%% Outputs
varargout = {leg_handle};
end
