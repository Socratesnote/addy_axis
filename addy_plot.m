function varargout = addy_plot(varargin)
%ADDY_PLOT Plots data to any of the additional axes created with
%addyaxis(). Provide an axis struct created by addyaxis(), followed
%by any command that you would normally pass to plot().

% Use:
% plot_handle = addy_plot(ax_struct, <plot arguments>);

% Inspired by yyaxis,
% plotyyy (https://www.mathworks.com/matlabcentral/fileexchange/1017-plotyyy),
% and addaxis (https://www.mathworks.com/matlabcentral/fileexchange/9016-addaxis).

%% Argument parsing

narginchk(2, inf);

function_parser = inputParser;
function_parser.KeepUnmatched = true;
function_parser.PartialMatching = false;

% Required
requiredArguments = {'ax_struct'};
verificationFunction = @(potential_axes) ...
  ( isfield(potential_axes, 'axes_visible') && isfield(potential_axes, 'axes_hidden') );
for ii = 1:length(requiredArguments)
  addRequired(function_parser, requiredArguments{ii}, verificationFunction)
end

% Optional
% optionalArguments = {};
% defaultOptional = {};
% for ii = 1:length(optionalArguments)
%   addOptional(function_parser, optionalArguments{ii}, defaultOptional{ii})
% end

% % Parameters
% parameterArguments = {};
% defaultParameter = {};
% for ii = 1:length(parameterArguments)
%   addOptional(function_parser, parameterArguments{ii}, defaultParameter{ii})
% end

% Parse
varargparsed = varargin(1:1);
parse(function_parser, varargparsed{:});

% Assign
axes_hidden = function_parser.Results.ax_struct.axes_hidden;
axes_visible = function_parser.Results.ax_struct.axes_visible;

% Restore the active axes to the main axes after plotting.
main_axes = gca;

%% AddYPlot

% Plot visible data in hidden axes.
p = plot(axes_hidden, varargin{2:end});
% Copy automatically determined limits to the visible axes.
axes_visible.YLim = axes_hidden.YLim;
% Hide what needs to be hidden.
axes_hidden.Visible = 'off';
axes_hidden.HitTest = 'off';
axes_hidden.Toolbar.Visible = 'off';
axes_visible.Toolbar.Visible = 'off';
% Set the color of the y-axis to match the plot.
axes_visible.YColor = p.Color;

%% Outputs
varargout = {p};
% Restore the active axes to the main axes after plotting.
set(gcf, 'CurrentAxes', main_axes);
end
