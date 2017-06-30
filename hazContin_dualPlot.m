function [] = hazContin_dualPlot(tGrid,haz,plotColor,lineStyle,xmax)
% take previously computed hazard functions and plot two conditions on
% the same axes.
% This version is for *continuous* (subjectively smeared) hazard fxs.
%
% Inputs:
%   tGrid, haz, plotColor, and lineStyle are each a cell array with a 
%   element for each condition. 
%   xmax (optional) is a scalar.


% optional inputs
if nargin<4, xmax = []; end

% set up the plot
figure(gcf+1); clf;

% plot hazard as a fx of time
h = nan(size(tGrid));
for i = 1:length(tGrid)
    h(i) = plot(tGrid{i},haz{i},lineStyle{i},'LineWidth',1);
    set(h(i),'Color',plotColor{i});
    hold on;
end

% plot formatting
set(gcf,'Units','inches','Position',[7,6,1.5,1.5]); % 1.5 x 1.5"
set(gca,'Position',[0.3, 0.3, 0.6, 0.6]);
set(gca,'Box','off','FontSize',7,'Layer','top');
set(gca,'XLim',[0,95],'XTick',0:20:80,'YLim',[0, 0.1],'YTick',0:0.05:0.1);
xlabel('Time (sec)');
ylabel(sprintf('Hazard rate (%c)',162));
legend(h,'HP','LP','Location','NorthWest');

% alter formatting if x limits are specified
if ~isempty(xmax)
    set(gca,'XLim',[0,xmax],'XTick',0:10:xmax);
end




