function addy_pan_post(hfig, hax)
%ADDY_PAN_POST Update any axes created by addyaxis() post panning.

% Get limits prior to pan.
limits_pre = addy_getaxisdata(hax, 'limits_pre');
% Get current limits.
limits_post.X = hax.Axes.XLim;
limits_post.Y = hax.Axes.YLim;
origin_shift.X = limits_post.X - limits_pre.X;
origin_shift.Y = limits_post.Y - limits_pre.Y;

% Apply to all axes children of the figure.
for ii = 1:length(hfig.Children)
  if ~strcmpi(class(hfig.Children(ii)), 'matlab.graphics.axis.Axes')
    continue
  end
  % Assumption: last axes are the original axes that were panned, so
  % those don't need to be shifted.
  if ii == length(hfig.Children)
    continue
  end
  % Shift axes.
  % Try-catch X-shifts because not all axes may be compatible with the original
  % pan shift.
  try %#ok<TRYNC>
    hfig.Children(ii).XLim = hfig.Children(ii).XLim + ...
      origin_shift.X;
  end

  hfig.Children(ii).YLim = hfig.Children(ii).YLim + ...
    origin_shift.Y;
end
end
