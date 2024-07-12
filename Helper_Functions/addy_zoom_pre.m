function addy_zoom_pre(hfig, hax)
%ADDY_ZOOM_PRE Capture limits to update any axes created by addyaxis()
%post zooming.

% Store the X and Y limits prior to this zoom action so that we can scale all
% addy-axes by the same amount.
limits_pre.X = hax.Axes.XLim;
limits_pre.Y = hax.Axes.YLim;

addy_setaxisdata(hax.Axes, limits_pre, 'limits_pre');
end
