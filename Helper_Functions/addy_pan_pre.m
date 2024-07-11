function addy_pan_pre(hfig, hax)
%ADDY_PAN_PRE Capture limits to update any axes created by addyaxis()
%pre panning.

% Store the X and Y limits prior to this pan action so that we can scale all
% addy-axes by the same amount.
limits_pre.X = hax.Axes.XLim;
limits_pre.Y = hax.Axes.YLim;

addy_setaxisdata(hax.Axes, limits_pre, 'limits_pre');
end

