function addy_pan_post(hfig, hax)
%ADDY_PAN_POST Update any axes created by addyaxis() post panning.

limits_pre = addy_getaxisdata(hax, 'limits_pre');
limits_post = [hax.Axes.XLim, hax.Axes.YLim];
origin_shift = limits_post - limits_pre;

% Apply to all axes children of the figure
for ii = 1:length(hfig.Children)
  if ~strcmpi(class(hfig.Children(ii)), 'matlab.graphics.axis.Axes')
    continue
  end
  % Assumption: last axes are the original axes that were panned, so
  % those don't need to be shifted.
  if ii == length(hfig.Children)
    continue
  end
  % Shift axes
  hfig.Children(ii).XLim = hfig.Children(ii).XLim + ...
    origin_shift(1:2);
  hfig.Children(ii).YLim = hfig.Children(ii).YLim + ...
    origin_shift(3:4);
end
end
