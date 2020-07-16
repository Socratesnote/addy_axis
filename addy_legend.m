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
if nargin < 1
  error('Not enough arguments provided.')
end

function_parser = inputParser;
function_parser.KeepUnmatched = true;
function_parser.PartialMatching = false;

% Required
% requiredArguments = {};
% for ii = 1:length(requiredArguments)
%   addRequired(function_parser, requiredArguments{ii})
% end

% Optional
defaultOptional = {gcf, [], {}};
optionalArguments = {'fig', 'lines', 'legend'};
verificationFunction = {...
  @(potential_figure) ( strcmpi(class(potential_figure), 'matlab.ui.Figure') ), ...
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
p = function_parser.Results.lines;
entries = function_parser.Results.legend;
f = fields(function_parser.Unmatched);
rest = cell(1, 2*length(f));
for ii = length(f)
rest{1, 2*ii-1} = f(ii);
rest{1, 2*ii} = {function_parser.Unmatched.(f{ii})};
end

%% AddYLegend

% Collect all line objects if none provided.
if isempty(p)
  ii = 0;
  for jj = 1:length(hfig.Children)
    if ~strcmpi(class(hfig.Children(jj)), 'matlab.graphics.axis.Axes')
      continue
    end
    for kk = 1:length(hfig.Children(jj).Children)
      ii = ii + 1;
      p(ii) = hfig.Children(jj).Children(kk);
    end
  end
  p = flip(p);
end

% Assume the last axes are the main axes that should contain the
% legend.
set(hfig, 'CurrentAxes', hfig.Children(end))
leg_handle = legend(p, entries, rest{:});

%% Outputs
varargout = {leg_handle};
end
