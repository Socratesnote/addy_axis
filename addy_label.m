function label_handle = addy_label(varargin)
%ADDY_LABEL Create a y-label for a figure that has additional axes made with
%addy_axis().

% Use:
% label_handle = addy_label(axes_struct, "New label");
% label_handle = addy_label(axes_struct, "Label for axes 4", 4);

% Inspired by yyaxis,
% plotyyy (https://www.mathworks.com/matlabcentral/fileexchange/1017-plotyyy),
% and addaxis (https://www.mathworks.com/matlabcentral/fileexchange/9016-addaxis).

%% Argument parsing
narginchk(1, inf);

function_parser = inputParser;
function_parser.KeepUnmatched = true;
function_parser.PartialMatching = false;

% Required
requiredArguments = {'ax_struct', 'label'};
for ii = 1:length(requiredArguments)
  addRequired(function_parser, requiredArguments{ii})
end

% Optional
defaultOptional = {1};
optionalArguments = {'index'};
for ii = 1:length(optionalArguments)
  addOptional(function_parser, optionalArguments{ii}, defaultOptional{ii})
end

% Parameters
% defaultParameter = {};
% parameterArguments = {};
% for ii = 1:length(parameterArguments)
%   addParameter(function_parser, parameterArguments{ii}, defaultParameter{ii})
% end

% Parse.
varargparsed = varargin;
parse(function_parser, varargparsed{:});

% Assign.
axes_struct = function_parser.Results.ax_struct;
this_label = function_parser.Results.label;
this_index = function_parser.Results.index;

%% Add label

this_axes = axes_struct.axes_visible(this_index);
label_handle = ylabel(this_axes, this_label);

end
