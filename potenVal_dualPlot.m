function [] = potenVal_dualPlot(pv,xmax,hrf)
% take previously computed potential functions and plot two conditions on
% the same axes.
%
% Inputs:
%   pv: struct with one entry per condition and the following fields:
%       .tObs: plotted x values (delays)
%       .potentialRate OR .EV OR .timeCost: plotted y values
%       .plotColor: self-explanatory
%   xmax (optional, or may be empty); max value on x axis
%   hrf (optional); logical, whether to convolve with hrf

% optional inputs
if nargin<3, hrf = false; end
if nargin<2, xmax = []; end

% set up the plot
figure(gcf+1); clf;

% if hrf convolution is requested, need spm
if hrf
    addpath(genpath('~/spm8')); % use hrf from spm
end

% plot potential value as time passes
for i = 1:length(pv)
    
    if isfield(pv,'potentialRate')
        yData = pv(i).potentialRate;
        yLab = sprintf('Subjective value (%c)',162);
        yRange = [0, 32];
    elseif isfield(pv,'EV')
        yData = pv(i).EV;
        yLab = sprintf('Expected reward (%c)',162);
        yRange = [0, 32]; 
        if hrf, yRange = [0, 35]; end % the EV HRF initally overshoots
    elseif isfield(pv,'timeCost')
        yData = pv(i).timeCost;
        yLab = sprintf('Time cost (%c)',162);
        yRange = [-32, 0];
    end
    
    if hrf
        % determine the spacing of the time grid
        tDiffs = pv(i).tObs(2:end) - pv(i).tObs(1:(end-1));
        tDiffs = round(1000000.*tDiffs)./1000000; % deal w/ rounding error
        tr = unique(tDiffs);
        h = spm_hrf(tr);
        c = conv(yData,h);
        toPlot = c(1:length(yData));
    else
        toPlot = yData;
    end
    
    h = plot(pv(i).tObs,toPlot,'k-','LineWidth',1);
    set(h,'Color',pv(i).plotColor);
    hold on;
end

% plot formatting
set(gcf,'Units','inches','Position',[7,6,2,1.5]); % 2 x 1.5"
set(gca,'Position',[0.3, 0.3, 0.6, 0.6]);
set(gca,'Box','off','FontSize',7,'Layer','top');
set(gca,'XLim',[0,95],'XTick',0:20:80,'YLim',yRange);
xlabel('Elapsed time (s)');
ylabel(yLab);

% alter formatting if x limits are specified
if ~isempty(xmax) && xmax<50
    set(gca,'XLim',[0,xmax],'XTick',0:10:xmax);
end




