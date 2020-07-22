function varargout = addy_axis(varargin)
%ADDY_AXIS Adds additional y-axes adjacent to the current axis object
%while overlaying data with the current plots. Retains full data
%cursor functionality and scaling.

% Use:
% axes_struct = addy_axis;
% axes_struct = addy_axis('ax', 'gca');
% axes_struct = addy_axis('side', 'left');
% axes_struct = addy_axis('ax', 'gca', 'side', 'right');
% axes_struct = addy_axis(____, 'offset', 0.03);
% axes_struct = addy_axis(____, 'hold', 'on')
% Inspired by yyaxis,
% plotyyy (https://www.mathworks.com/matlabcentral/fileexchange/1017-plotyyy),
% and addaxis (https://www.mathworks.com/matlabcentral/fileexchange/9016-addaxis).

% https://www.mathworks.com/matlabcentral/answers/231377-problem-with-addlistener-to-xlim
% Sadly, we cannot perform a callback when the axes are automatically
% updated. Instead, updating the plot and addy-axes is handled by
% overwriting the callback for toolbar buttons.

addpath(genpath('./')); % Add current location and subfolders to path

%% Argument parsing
function_parser = inputParser;
function_parser.KeepUnmatched = true;

% Required
% requiredArguments = {};
% for ii = 1:length(requiredArguments)
%   addRequired(function_parser, requiredArguments{ii})
% end

% Optional
defaultOptional = {gca, 'right'};
optionalArguments = {'ax', 'side'};
for ii = 1:length(optionalArguments)
  addOptional(function_parser, optionalArguments{ii}, defaultOptional{ii})
end

% Parameters
defaultParameter = {0.04, 'off'};
parameterArguments = {'offset', 'hold'};
for ii = 1:length(parameterArguments)
  addParameter(function_parser, parameterArguments{ii}, defaultParameter{ii})
end

% Parse
parse(function_parser, varargin{:});

% Assign results
axes_offset = function_parser.Results.offset;
main_axes = function_parser.Results.ax;
side = function_parser.Results.side;
do_hold = function_parser.Results.hold;

%% AddYAxis
% First create faux axes that will be visible, but are not used for
% plotting. Depending on how many axes already exist (or user
% arguments), plot on the right or the left.

hparent = main_axes.Parent;

% Count number of added axes, but only to the 'tile' were working on.
% This needs some extension of Matlab's lackluster implementation.
% addy_axis does not work well with subplot(X), but can synergize with
% tiledlayoutplus.
if strcmpi(class(hparent), 'matlab.graphics.layout.TiledChartLayout')
  htile = hparent;
  current_tile = getappdata(htile, 'CurrentTile');
  hax = nexttile(htile, current_tile);
elseif strcmpi(class(hparent), 'matlab.ui.Figure') % Simple figure, no tiles
  hax = main_axes;
  current_tile = 0;
  %   for ii = 1:(length(hfig.Children) - 1) % Assuming at least 1 axes child already exists
  %     if ~strcmpi(class(hfig.Children(ii)), 'matlab.graphics.axis.Axes')
  %       continue
  %     end
  %     num_addy_axes = num_addy_axes + 0.5;
  %   end
end
num_addy_axes = getappdata(hax, 'AddedYAxes');

if isempty(num_addy_axes)
  num_addy_axes = 0;
end

% Determine side
if mod(num_addy_axes, 2) == 0
  side = 'right';
end

% Create new visible axes
if strcmpi(side, 'right')
  next_axes_position_shift = main_axes.Position(3) + axes_offset * ((num_addy_axes + 1)/2);
  axes_pair.axes_visible = axes('Position', main_axes.Position + ...
    [next_axes_position_shift, zeros(1,3)]);
  axes_pair.axes_visible.TickDir = 'out';
else
  next_axes_position_shift = axes_offset * ((num_addy_axes)/2);
  axes_pair.axes_visible = axes('Position', main_axes.Position - ...
    [next_axes_position_shift, zeros(1,3)]);
  axes_pair.axes_visible.TickDir = 'in';
end
axes_pair.axes_visible.Position(3) = 0; % Flatten the x-axis of the visible axes
axes_pair.axes_visible.Toolbar.Visible = 'off'; % Hide the toolbar
setappdata(axes_pair.axes_visible, 'CurrentTile', current_tile);

% Create a new axes object to hold the plotted data. This will not be
% visible or interactable.
axes_pair.axes_hidden = axes('Position', main_axes.Position);
axes_pair.axes_hidden.Visible = 'off';
axes_pair.axes_hidden.HitTest = 'off';
axes_pair.axes_hidden.Toolbar.Visible = 'off';
if strcmpi(do_hold, 'on')
  axes_pair.axes_hidden.NextPlot = 'add';
end
setappdata(axes_pair.axes_hidden, 'CurrentTile', current_tile);

% Set callbacks for home, zoom and pan to update all axes when the
% limits of the main axes change. Click-and-drag is disabled.
% Home
hhome = findall(main_axes.Toolbar,'Tooltip','Restore View');
% The home button's ButtonDownFcn is unused as per documentation, so a
% single function handles the pre- and post-click behavior in a single
% action.
set(hhome,'ButtonPushedFcn',@addy_home);
% Zoom
hzoom = zoom;
set(hzoom,'ActionPreCallback',@addy_zoom_pre);
set(hzoom,'ActionPostCallback',@addy_zoom_post);
% Pan
hpan = pan;
set(hpan,'ActionPreCallback', @addy_pan_pre);
set(hpan,'ActionPostCallback', @addy_pan_post);
% Click-and-drag is disabled, because I cannot find the right callback
% to execute on button release. It seems that Matlab cannot actually
% detect button release.
set(main_axes, 'ButtonDownFcn',@addy_click_pre);
set(gcf,'WindowButtonUpFcn',@addy_click_post);

% Increment number of added axes
num_addy_axes = num_addy_axes + 1;
setappdata(hax, 'AddedYAxes', num_addy_axes);

%% Outputs
varargout = {axes_pair};
% Restore the active axes to the main axes after plotting.
set(gcf, 'CurrentAxes', main_axes);
end
