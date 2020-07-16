function addy_demo(~)
% ADDY_DEMO Demonstration function of addyaxis use.

% Use:
% addy_demo;

% Inspired by yyaxis,
% plotyyy (https://www.mathworks.com/matlabcentral/fileexchange/1017-plotyyy),
% and addaxis (https://www.mathworks.com/matlabcentral/fileexchange/9016-addaxis).

addpath(genpath('./')); % Add current location and subfolders to path

%% Data
% Generate some pseudo-randomly scaled data to populate the axes.

data = load('flu.mat');
y1 = data.flu.NE;
y2 = 10*data.flu.SAtl - mean(10*data.flu.SAtl);
y3 = 10*data.flu.MidAtl - mean(5*data.flu.MidAtl);
y4 = 6*data.flu.ENCentral - mean(10*data.flu.ENCentral);
y5 = 3*data.flu.Mtn - mean(7*data.flu.Mtn);
y6 = 15*data.flu.Pac - mean(1*data.flu.Pac);
y7 = 4*data.flu.WNCentral - mean(2*data.flu.WNCentral);
y8 = 1*data.flu.ESCentral - mean(8*data.flu.ESCentral);
t = datenum(data.flu.Date) - datenum(data.flu.Date(1));

%% yyaxis & addyplot^5
% Plot the data spread across left, right, and 5 additional y-axes.

f = figure;
f.Units = 'normalized';
f.Name = 'Addyplot';
f.Position = [0.5004    0.5146    0.4992    0.4264];
hold on; grid on;

yyaxis('left')
p1 = plot(t, y1);
p2 = plot(t, y2);
ax = gca;

yyaxis('right')
p3 = plot(t, y3);

ax_struct = addy_axis(ax);
p4 = addy_plot(ax_struct, t, y4, 'm');

ax_struct = addy_axis(ax);
p5 = addy_plot(ax_struct, t, y5, 'g');

ax_struct = addy_axis(ax);
p6 = addy_plot(ax_struct, t, y6, 'c');

ax_struct = addy_axis(ax);
p7 = addy_plot(ax_struct, t, y7, 'y');

ax_struct = addy_axis(ax, 'side', 'left');
p8 = addy_plot(ax_struct, t, y8, 'k');

addy_legend('lines', [p1 p2 p3 p4 p5 p6 p7 p8], ...
  'legend', {'NE', 'SAtl', 'MidAtl', 'ENCentral', 'Mtn', 'Pac', 'WNCentral', 'ESCentral'}, ...
  'location', 'northwest');

end
