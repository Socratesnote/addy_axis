function addy_home_post(hbutton, hevent)
%ADDY_HOME_POST Update any axes created by addy_axis() post homing.

hax.Axes = hbutton.Parent.Parent;
hfig = hax.Axes.Parent;

% Apply to all axes children of the figure.
for ii = 1:length(hfig.Children)
  if ~strcmpi(class(hfig.Children(ii)), 'matlab.graphics.axis.Axes')
    continue
  end
  % Assumption: last axes are the original axes that were homed.
  if ii == length(hfig.Children)
    % If the main axes have a left/right pair, home both.
    if length(hfig.Children(ii).YAxis) == 2
      for loc = ["right", "left"]
        yyaxis(loc);
        matlab.graphics.controls.internal.resetHelper(hfig.Children(ii), true);
      end
    end
    continue
  end

  % Let Matlab's resethelper handle the correct scaling of all
  % addy-axes. Not sure what the boolean flag does, but it needs to be
  % true.
  if length(hfig.Children(ii).YAxis) == 2
    for loc = ["right", "left"]
      yyaxis(loc);
      matlab.graphics.controls.internal.resetHelper(hfig.Children(ii), true);
    end
  end
  % However, this resets the faux axes to their default state with [0, 1]
  % limits; copy the limits from the axes on the previous index (which are the
  % invisible, data-containing counterpart).
  if strcmpi(hfig.Children(ii).Visible, 'on')
    hfig.Children(ii).YLim = hfig.Children(ii - 1).YLim;
  end
end
end
