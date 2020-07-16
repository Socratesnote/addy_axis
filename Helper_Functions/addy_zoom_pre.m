function addy_zoom_pre(hfig, hax)
%ADDY_ZOOM_PRE Capture limits to update any axes created by addyaxis()
%post zooming.

limits_pre = [hax.Axes.XLim hax.Axes.YLim];

addy_setaxisdata(hax.Axes, limits_pre, 'limits_pre');
end
