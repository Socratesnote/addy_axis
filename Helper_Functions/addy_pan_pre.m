function addy_pan_pre(hfig, hax)
%ADDY_PAN_PRE Capture limits to update any axes created by addyaxis()
%post panning.

limits_pre = [hax.Axes.XLim hax.Axes.YLim];

addy_setaxisdata(hax.Axes, limits_pre, 'limits_pre');
end

