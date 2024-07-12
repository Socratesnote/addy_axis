function axes_struct = addy_axis(varargin)
%ADDY_AXIS Adds additional y-axes adjacent to the current axis object while
%overlaying data with the current plots. Data cursors, zooming, and panning
%work. Data brushing does not. Returns a struct with visible and invisible axes
%in the figure.

% Use:
% axes_struct = addy_axis('ax', 'gca');
% axes_struct = addy_axis('side', 'left');
% axes_struct = addy_axis('ax', 'gca', 'side', 'r', 'offset', 0.05);
% axes_struct = addy_axis('axes_struct', existing_struct);

% Inspired by yyaxis,
% plotyyy (https://www.mathworks.com/matlabcentral/fileexchange/1017-plotyyy),
% and addaxis (https://www.mathworks.com/matlabcentral/fileexchange/9016-addaxis).

% https://www.mathworks.com/matlabcentral/answers/231377-problem-with-addlistener-to-xlim
% Sadly, we cannot perform a callback when the axes are automatically
% updated. Instead, updating the plot and addy-axes is handled by
% overwriting the callback for toolbar buttons.

% Limitations:
%{
- Some time between Matlab 2022a and 2024a the way that Restore View (home)
works under the hood has changed; currently restoring view does not correctly
restore axes to their original value.
%}

addpath(genpath('./')); % Add current location and subfolders to path

%% Argument parsing
function_parser = inputParser;
function_parser.KeepUnmatched = true;

% Required
requiredArguments = {'ax'};
for ii = 1:length(requiredArguments)
  addRequired(function_parser, requiredArguments{ii})
end

% Optional
% defaultOptional = {};
% optionalArguments = {};
% for ii = 1:length(optionalArguments)
%   addOptional(function_parser, optionalArguments{ii}, defaultOptional{ii})
% end

% Parameters
defaultParameter = {'', 0.04, struct};
parameterArguments = {'side', 'offset', 'ax_struct'};
for ii = 1:length(parameterArguments)
  addParameter(function_parser, parameterArguments{ii}, defaultParameter{ii})
end

% Parse
parse(function_parser, varargin{:});

% Assign results
main_axes = function_parser.Results.ax;
side = function_parser.Results.side;
axes_offset = function_parser.Results.offset;
existing_struct = function_parser.Results.ax_struct;

%% AddYAxis
% First create faux axes that will be visible, but are not used for
% plotting. Depending on how many axes already exist (or user
% arguments), plot on the right or the left.

% Count number of added axes.
hfig = main_axes.Parent;
num_addy_axes = 1; % Including the one we're about to create.
for ii = 1:(length(hfig.Children) - 1) % Assuming at least 1 axes child already exists.
    if ~strcmpi(class(hfig.Children(ii)), 'matlab.graphics.axis.Axes')
      continue
    end
    num_addy_axes = num_addy_axes + 0.5;
end

% Determine side
if isempty(side)
  side = "right";
  if mod(num_addy_axes, 2) == 0
    side = "left";
  end
end

% Create new visible axes
if any(strcmpi(side, ["right", "r"]))
  next_axes_position_shift = main_axes.Position(3) + axes_offset * ((num_addy_axes + 1)/2);
  axes_struct.axes_visible = axes('Position', main_axes.Position + ...
    [next_axes_position_shift, zeros(1,3)]);
  axes_struct.axes_visible.TickDir = 'out';
elseif any(strcmpi(side, ["left", "l"]))
  next_axes_position_shift = axes_offset * ((num_addy_axes)/2);
  axes_struct.axes_visible = axes('Position', main_axes.Position - ...
    [next_axes_position_shift, zeros(1,3)]);
  axes_struct.axes_visible.TickDir = 'in';
else
  error("Invalid argument for ''side'': use ''(r)ight'' or ''(l)eft''.");
end

axes_struct.axes_visible.Position(3) = 0; % Flatten the x-axis of the visible axes.
axes_struct.axes_visible.Toolbar.Visible = 'off'; % Hide the toolbar.

% Create a new axes object to hold the plotted data. This will not be
% visible or interactable.
axes_struct.axes_hidden = axes('Position', main_axes.Position);
axes_struct.axes_hidden.Visible = 'off';
axes_struct.axes_hidden.HitTest = 'off';
axes_struct.axes_hidden.Toolbar.Visible = 'off';

% Set callbacks for home, zoom and pan to update all axes when the
% limits of the main axes change. Click-and-drag is disabled.
this_toolbar = axtoolbar(main_axes, 'default');

% Home. The home button's ButtonDownFcn is unused as per documentation, so a
% single function handles the pre- and post-click behavior in a single action.
isRestoreButton = strcmpi({this_toolbar.Children.Icon}, 'restoreview');
restoreButtonHandle = this_toolbar.Children(isRestoreButton);
set(restoreButtonHandle, 'ButtonPushedFcn', @addy_home);

% Zoom
hzoom = zoom;
set(hzoom, 'ActionPreCallback', @addy_zoom_pre);
set(hzoom, 'ActionPostCallback', @addy_zoom_post);

% Pan
hpan = pan;
set(hpan, 'ActionPreCallback', @addy_pan_pre);
set(hpan, 'ActionPostCallback', @addy_pan_post);

% Click-and-drag is disabled, because I cannot find the right callback
% to execute on button release. It seems that Matlab cannot actually
% detect button release.
set(main_axes, 'ButtonDownFcn',@addy_click_pre);
set(gcf, 'WindowButtonUpFcn', @addy_click_post);

% Brushing. Disabled at the moment.
hbrush = brush;
set(hbrush, 'ActionPreCallback', @addy_brush_pre);
set(hbrush, 'ActionPostCallback', @addy_brush_post);

%% Cleanup
if isempty(fields(existing_struct))
  % Just return the new axes struct.
else
  % Add existing struct: newest axes are on the front, same as Figure children.
  axes_struct.axes_hidden = [axes_struct.axes_hidden existing_struct.axes_hidden];
  axes_struct.axes_visible = [axes_struct.axes_visible existing_struct.axes_visible];
end

% Restore the active axes to the main axes after plotting.
set(gcf, 'CurrentAxes', main_axes);
end
