function [bestRate] = policyPayoff(dist,plotColor,rwdSize,iti)
% plots the rate of return expected from stopping at each point
% Input:
%   dist is a 2-col matrix. col1 = time (sec), col2 = probability mass
%   plotColor is optional (if empty, nothing is plotted)
%
% Which stopping points should be treated as "candidate" policies?
%   If the distribution is truly understood as discrete, it only makes
%   sense to stop right *after* a reward time has passed. Waiting longer
%   but not all the way to the next reward time is counterproductive.
%   Still, might want to illustrate this. 
%
% Let's plot points at the candidate times, and discontinuous dashed lines
% to show the effects of waiting past each point.
%
% Note that this is meant to demonstrate objective properties of the
% distribution. It's NOT meant to represent participants' subjective
% calculations, which probably do not treat the distribution as perfectly
% discrete. 

makePlot = true;
if isempty(plotColor), makePlot = false; end

% add a zero point to the distribution
dist = [[0, 0]; dist];

% set the increments for the time grid to test
tGridRes = 0.01;

% store all rates of return
allRates = nan(size(dist,1),1);

% set up the plot, to be built incrementally
if makePlot
    figure(gcf+1);
    hold on;
    % gridlines at reward times
    ymax = 1.25;
    hold on;
    for i = 1:size(dist,1)
        plot(dist(i,1)*[1,1],[0,ymax],'-','LineWidth',0.5,'Color',0.8*[1,1,1]);
    end
end

% loop over timepoints
for i = 1:size(dist,1)
    
    timeNow = dist(i,1); % the timepoint now in focus
    
    % rate of return for the policy of waiting until (just after) timeNow
    pRwd = sum(dist(1:i,2));
    expRwd = rwdSize*pRwd;
    waitTime = min(timeNow,dist(:,1)); % actual wait time for each scheduled delay
    expTime = iti + sum(waitTime.*dist(:,2));
    rate = expRwd./expTime;
    % plot it
    if makePlot
        plot(timeNow,rate,'.','MarkerSize',8,'Color',plotColor);
    end
    % store the rate for future evaluation
    allRates(i) = rate;
    
    % now, rates of return for the policies of waiting from the current
    % timepoint up until (just before) the next one
    if i==size(dist,1), continue; end % do nothing if this is the last point
    % expRwd remains the same as above
    nextTime = dist(i+1,1);
    tGrid = timeNow:tGridRes:(nextTime - tGridRes);
    rateGrid = nan(size(tGrid));
    for tIdx = 1:length(tGrid)
        tVal = tGrid(tIdx);
        waitTime = min(tVal,dist(:,1)); % actual wait time for each scheduled delay
        expTime = iti + sum(waitTime.*dist(:,2));
        rateGrid(tIdx) = expRwd./expTime;
    end
    % plot these
    if makePlot
        plot(tGrid,rateGrid,'-','Color',plotColor,'LineWidth',1);
    end
    
end

% general plot formatting
if makePlot
    set(gcf,'Units','inches','Position',[7,6,2,1.5]); % 2 x 1.5"
    set(gca,'Position',[0.3, 0.3, 0.6, 0.6]);
    set(gca,'Box','off','FontSize',7,'Layer','top');
    set(gca,'XLim',[0,95],'XTick',0:20:80,'YLim',[0, ymax]);
    xlabel('Waiting policy (sec)');
    ylabel(sprintf('Return (%c/sec)',162));
end

% identify the best available rate of return
bestRate = max(allRates);




