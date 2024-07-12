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
t = datetime(data.flu.Date, "InputFormat", "MM/dd/uuuu") - ...
datetime(data.flu.Date(1), "InputFormat", "MM/dd/uuuu");

%% yyaxis & addyplot^5
% Plot the data spread across left, right, and 5 additional y-axes.

% Create a figure and base axis.
f = figure;
clf(f);
f.Units = 'normalized';
f.Name = 'Addyplot';
f.Position = [0.5004    0.5146    0.4992    0.4264];
base_ax = axes(f);
hold(base_ax, 'on');
grid(base_ax, 'on');

% Plot two data sets on the left ruler of the base axis.
% yyaxis(base_ax, 'left')
p1 = plot(base_ax, t, y1, "DisplayName", "NE");
p2 = plot(base_ax, t, y2, "DisplayName", "SAtl");
base_ax = gca;
ylim(base_ax, [-15, 15]);

% Plot one data set on the right ruler of the base axis.
% yyaxis(base_ax, 'right')
% p3 = plot(base_ax, t, y3, "DisplayName", "MidAtl");

% Now, add 5 additional data sets through addy_axis and addy_plot. Use addy_axis
% to add an additional axis to a base axis: by default this alternates between
% right and left, starting on the right. Data is then plotted using addy_plot.
% Any colors assigned to the graph will be copied to the additional axes.
ax_struct = addy_axis(base_ax);
p4 = addy_plot(ax_struct, t, y4, 'm', "DisplayName", "ENCentral");
ylim(ax_struct.axes_visible(1), [-15, 15]);
ylim(ax_struct.axes_hidden(1), [-15, 15]);

ax_struct = addy_axis(base_ax, 'ax_struct', ax_struct);
p5 = addy_plot(ax_struct, t, y5, 'g', "DisplayName", "Mtn");
ylim(ax_struct.axes_visible(1), [-15, 15]);
ylim(ax_struct.axes_hidden(1), [-15, 15]);

ax_struct = addy_axis(base_ax, 'ax_struct', ax_struct);
p6 = addy_plot(ax_struct, t, y6, 'c', "DisplayName", "Pac");
ylim(ax_struct.axes_visible(1), [-15, 15]);
ylim(ax_struct.axes_hidden(1), [-15, 15]);

ax_struct = addy_axis(base_ax, 'offset', 0.03, 'ax_struct', ax_struct);
p7 = addy_plot(ax_struct, t, y7, 'r', "DisplayName", "WNCentral");
ylim(ax_struct.axes_visible(1), [-15, 15]);
ylim(ax_struct.axes_hidden(1), [-15, 15]);

% If you need an axis on a specific side, use the 'side' argument.
ax_struct = addy_axis(base_ax, 'side', 'left', 'ax_struct', ax_struct);
p8 = addy_plot(ax_struct, t, y8, 'k', "DisplayName", "ESCentral");
ylim(ax_struct.axes_visible(1), [-15, 15]);
ylim(ax_struct.axes_hidden(1), [-15, 15]);

% Add a label to a specific additional axis: these are labeled in descending
% order of creation. This one will add a label to the cyan and black axes.
l1 = addy_label(ax_struct, "Additional label 3", 3); %#ok<NASGU>
l2 = addy_label(ax_struct, "Additional label 1", 1); %#ok<NASGU>

% Add a legend to the base axes, with line handles for all 8 data sets.
addy_legend('ax', base_ax, 'lines', [p1 p2 p4 p5 p6 p7 p8], ...
  'location', 'northwest');

end
