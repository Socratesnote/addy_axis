function addy_home(hbutton, hevent)
%ADDY_HOME Sync limits post homing to axes created by addyaxis().

hax.Axes = hbutton.Parent.Parent;

% No pre-home callback needed.

% Call Matlab's resetHelper ('resetview'/'home') with default
% settings. I'm unsure what the boolean flag does, but its value
% doesn't seem to matter here.
matlab.graphics.controls.internal.resetHelper(hax.Axes, false)

% Post-home callback.
addy_home_post(hbutton, hevent);
end
