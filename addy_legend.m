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
defaultOptional = {[], [], [], {}};
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
if isempty(hax) && isempty(hfig)
  error('Either figure or axes must be specified.')
end
if isempty(hax)
  % Assume the axes created last are the (invisible) added axes that
  % should contain the legend.
  hax = hfig.Children(1);
end
if isempty(hfig)
  if strcmpi(class(hax.Parent), 'matlab.graphics.layout.TiledChartLayout')
    hfig = hax.Parent.Parent;
  else
    hfig = hax.Parent;
  end
end
hlines = function_parser.Results.lines;
entries = function_parser.Results.legend;
legend_parameters = fields(function_parser.Unmatched);
rest = cell(1, 2*length(legend_parameters));
for ii = length(legend_parameters)
  rest{1, 2*ii-1} = legend_parameters(ii);
  rest{1, 2*ii} = {function_parser.Unmatched.(legend_parameters{ii})};
end

%% AddYLegend

% Collect all line objects if none provided. When iterating through
% the children and the grandchildren from 1 to end, the lines are
% collected in reverse chronological order (newest - oldest)
if isempty(hlines)
  
  % First, collect the scope of the axes whose children will be
  % named by the legend.
  % Find the class of all figure children
  for ii = 1:length(hfig.Children)
    class_array{ii} = class(hfig.Children(ii)); %#ok<AGROW>
  end
  % Determine the presence of tiles
  is_tile = strcmpi(class_array,'matlab.graphics.layout.TiledChartLayout');
  if any(is_tile)
    % If the figure has tiles, consider only the current tile
    current_tile = getappdata(hfig.Children(is_tile), 'CurrentTile');
    axes_scope = gobjects(0);
    htile = hfig.Children(is_tile);
    % Iterate over all children; action depends on the class
    for ii = 1:length(hfig.Children)
      if strcmpi(class_array{ii}, 'matlab.graphics.axis.Axes')
        % Child is axes. Determine associated tile
        if getappdata(hfig.Children(ii), 'CurrentTile') == current_tile
          axes_scope = [axes_scope; hfig.Children(ii)]; %#ok<AGROW>
        else
          % Not part of current tile
          continue
        end
      elseif is_tile(ii)
        % Child is tile. Get the axis handle from nexttile().
        tile_axis = nexttile(htile, current_tile);
        % Tiles are created first, so they are appended
        axes_scope = [axes_scope; tile_axis]; %#ok<AGROW>
      else
        % Child is other, e.g. legend
        continue
      end
    end
    
  else % No tiles
  axes_scope = hfig.Children;
  end
  
  % Now that the scope is clear, collect lines
  ii = 0; % Count lines
  hlines = gobjects(0); % Initialize line handles

  % Iterate over all axes in scope
  for jj = 1:length(axes_scope)
    
    if ~strcmpi(class(axes_scope(jj)), 'matlab.graphics.axis.Axes')
      % If the figure is a simple figure, this scope might contain
      % legends or other non-axes objects
      continue 
    end
    
    % If the axes are left/right paired, assume the right was added
    % last (so process it first)
    for ll = flip(1:length(axes_scope(jj).YAxis))
      if ll == 2
        yyaxis('right');
      elseif ll == 1
        yyaxis('left');
      end
      
      % Collect all children (lines) of the current axes
      for kk = 1:length(axes_scope(jj).Children)
        ii = ii + 1;
        hlines(ii) = axes_scope(jj).Children(kk);
      end
    end
  end
  
  % Re-arrange to chronological order; last created line at the end of
  % the array
  hlines = flip(hlines);
end

hlegend = legend(hax, hlines, entries, rest{:});

%% Outputs
varargout = {hlegend};
end
