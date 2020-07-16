function addy_setaxisdata(axishandle, data, flag)

if nargin<3, flag = 'axisdata'; end

addy_axisdata = getappdata(axishandle,'addy_axisdata');
switch flag
  case 'axisdata'
    addy_axisdata.axisdata = data;
  case 'reset_info'
    addy_axisdata.reset_info = data;
  case 'limits_pre'
    addy_axisdata.limits_pre = data;
  otherwise
    error('Unrecognized flag.')
end

setappdata(axishandle, 'addy_axisdata', addy_axisdata);

