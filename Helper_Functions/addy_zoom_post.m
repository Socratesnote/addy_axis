function addy_zoom_post(hfig,hax)
%ADDY_ZOOM_POST Update any axes created by addyaxis() post zooming.

% The change in range and origin of the visible main axes are
% captured in a normalized shift and scaling factor. These are then
% applied to the addy-axis, scaled by its own range. Since we're only
% scaling and shifting the y-axis, we only care about shift/scaling in
% that dimension.

% Get limits prior to zoom.
limits_pre = addy_getaxisdata(hax, 'limits_pre');
% Get current limits.
limits_post.X = hax.Axes.XLim;
limits_post.Y = hax.Axes.YLim;

% Original and new axes range of the main axes.
range_pre = limits_pre.Y(2) - limits_pre.Y(1);
range_post = limits_post.Y(2) - limits_post.Y(1);

% Axes shift of the origin and range scaling, normalized to
% main axes range.
origin_shift = (limits_post.Y(1) - limits_pre.Y(1)) / ...
  range_pre;
range_scaling = (range_post / range_pre);

% Apply to all axes children of the figure.
for ii = 1:length(hfig.Children)
  if ~strcmpi(class(hfig.Children(ii)), 'matlab.graphics.axis.Axes')
    continue
  end
  % Assumption: last axes are the original axes that were zoomed, so
  % those don't need to be shifted unless there is a left/right pair.
  if ii == length(hfig.Children)
    if length(hfig.Children(ii).YAxis) == 2
      current_loc = hfig.Children(ii).YAxisLocation;
      % Select the axis that wasn't active
      if strcmpi(current_loc, 'Right')
        yyaxis('left')
      else
        yyaxis('right')
      end
      % Adjust axes.
      addy_limits_pre = hfig.Children(ii).YLim;
      addy_range_pre = addy_limits_pre(2) - addy_limits_pre(1);
      
      hfig.Children(ii).XLim = limits_post.X;
      hfig.Children(ii).YLim(1) = addy_limits_pre(1) + addy_range_pre*origin_shift;
      hfig.Children(ii).YLim(2) = hfig.Children(ii).YLim(1) + addy_range_pre*range_scaling;
    end
    continue
  end
  % Adjust axes.
  addy_limits_pre = hfig.Children(ii).YLim;
  addy_range_pre = addy_limits_pre(2) - addy_limits_pre(1);
  
  hfig.Children(ii).YLim(1) = addy_limits_pre(1) + addy_range_pre*origin_shift;
  hfig.Children(ii).YLim(2) = hfig.Children(ii).YLim(1) + addy_range_pre*range_scaling;
end

end
