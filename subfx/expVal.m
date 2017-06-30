function [results] = expVal(dist,plotColor,rwdSize,forSlides)
% plot a trial's _expected_ value as a function of elapsed time
%   (assuming a roughly optimal giving-up policy)
% EV is a reduced version of SV, omitting the cost of time; we're 
%   examining it at a reviewer's request. Merely attending to EV would not 
%   support optimal behavior (but it's still conceptually possible that 
%   VMPFC cares only about EV). 
% Input:
%   dist is a 2-col matrix. col1 = time (sec), col2 = probability mass
%   forSlides (optional, logical) changes output formatting


% check optional input
if nargin<4, forSlides = false; end
makePlot = true;
if isempty(plotColor), makePlot = false; end

% set the grid of timepoints to examine
% assume we observe each timepoint just *after* the reward would have occurred
tGridRes = 0.01;
latestTime = max(dist(:,1));
tObs = 0:tGridRes:(latestTime - tGridRes);

EV = nan(size(tObs));
for tIdx = 1:length(tObs)

    % evaluate prospects at each point
    tNow = tObs(tIdx);
    EV(tIdx) = expVal_onePoint(tNow,dist,rwdSize);
    
end % loop over timepoints

% prepare output
results.tObs = tObs;
results.EV = EV;
results.plotColor = plotColor;

if ~makePlot, return; end

% set up the plot
figure(gcf+1); clf; hold on;

% gridlines at reward times
ymax = 30;
hold on;
for i = 1:size(dist,1)
    plot(dist(i,1)*[1,1],[0,ymax],'-','LineWidth',0.5,'Color',0.8*[1,1,1]);
end

% plot EV as time passes
h = plot(tObs,EV,'k-','LineWidth',1);
set(h,'Color',plotColor);

% plot formatting
set(gcf,'Units','inches','Position',[7,6,1.5,1.5]); % 1.5 x 1.5"
set(gca,'Position',[0.3, 0.3, 0.6, 0.6]);
set(gca,'Box','off','FontSize',7,'Layer','top');
set(gca,'XLim',[0,95],'XTick',0:20:80,'YLim',[0, ymax]);
xlabel('Time elapsed (s)');
ylabel(sprintf('Expected value (%c)',162));

% alter formatting if "forSlides" is requested
% this plots only the most important part of the timecourses
if forSlides
    set(gca,'XLim',[0,30],'XTick',0:10:30);
end









