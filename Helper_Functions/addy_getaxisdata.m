function retdata = addy_getaxisdata(hax, flag)
%ADDY_GETAXISDATA Get axis data from given flag from the axes.

% By default, get the axisdata flag.
if nargin<2, flag = 'axisdata'; end

addy_axisdata = getappdata(hax.Axes,'addy_axisdata');
if length(addy_axisdata)>=1
  switch flag
    case 'axisdata'
      retdata = addy_axisdata.axisdata;
    case 'reset_info'
      retdata = addy_axisdata.reset_info;
    case 'limits_pre'
      retdata = addy_axisdata.limits_pre;
    otherwise
      retdata = 0;
      warning('Unrecognized flag.')
  end
else
  retdata = addy_axisdata;
  addy_axisdata.reset_info = get(hax,'position');
  addy_axisdata.axisdata = [];
  setappdata(hax,'addy_axisdata', addy_axisdata);
end

