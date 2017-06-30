function [results_pv, results_ev, results_timeCost] = potenVal(dist,plotColor,bkgdRate,rwdSize,forSlides)
% plot a trial's "potential value" 
%   i.e., argmax over policies of expected gain - cost of delay
%   as a function of elapsed time
% Input:
%   dist is a 2-col matrix. col1 = time (sec), col2 = probability mass
%   forKeynote (optional, logical) changes output formatting
%
% Note: we treat the ITI as attached to the *beginning* of a trial. This
% means the ITI is not factored into the prospective delay. ITI is not used
% anywhere in this function, *except* that the ITI influences the earlier
% calculation of the background rate.
% Implications:
%   -potential value may be >0 when the trial starts
%   -potential value should reach 30 just before the final timepoint (i.e.,
%       a 30-cent reward expected at no delay)

% check optional input
if nargin<5, forSlides = false; end
makePlot = true;
if isempty(plotColor), makePlot = false; end

% set the grid of timepoints to examine
% assume we observe each timepoint just *after* the reward would have occurred
tGridRes = 0.01;
latestTime = max(dist(:,1));
tObs = 0:tGridRes:(latestTime - tGridRes);


potentialRate = nan(size(tObs));
ev = nan(size(tObs)); % just the first term of the potential function: expected value
timeCost = nan(size(tObs)); % just the 2nd term of the potential function: time cost
for tIdx = 1:length(tObs)

    % evaluate prospects at each point
    tNow = tObs(tIdx);
    [potentialRate(tIdx), ev(tIdx), timeCost(tIdx)] = potenVal_onePoint(tNow,dist,rwdSize,bkgdRate);
    
end % loop over timepoints

% prepare output
results_pv.tObs = tObs;
results_pv.potentialRate = potentialRate;
results_pv.plotColor = plotColor;

results_ev.tObs = tObs;
results_ev.EV = ev;
results_ev.plotColor = plotColor;

results_timeCost.tObs = tObs;
results_timeCost.timeCost = timeCost;
results_timeCost.plotColor = plotColor;

if ~makePlot, return; end

% set up the plot
figure(gcf+1); clf; hold on;

% gridlines at reward times
ymax = 30;
hold on;
for i = 1:size(dist,1)
    plot(dist(i,1)*[1,1],[0,ymax],'-','LineWidth',0.5,'Color',0.8*[1,1,1]);
end

% plot potential value as time passes
h = plot(tObs,potentialRate,'k-','LineWidth',1);
set(h,'Color',plotColor);

% plot formatting
set(gcf,'Units','inches','Position',[7,6,1.5,1.5]); % 1.5 x 1.5"
set(gca,'Position',[0.3, 0.3, 0.6, 0.6]);
set(gca,'Box','off','FontSize',7,'Layer','top');
set(gca,'XLim',[0,95],'XTick',0:20:80,'YLim',[0, ymax]);
xlabel('Time elapsed (s)');
ylabel(sprintf('Potential value (%c)',162));

% alter formatting if "forSlides" is requested
% this plots only the most important part of the timecourses
if forSlides
    set(gca,'XLim',[0,30],'XTick',0:10:30);
end









