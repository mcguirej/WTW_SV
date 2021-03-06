function [bestRate] = gm_policyPayoff(tGrid,subj_pdf,subj_cdf,plotColor,rwdSize,iti)
% plots the rate of return expected from stopping at each point
% Input:
%   tGrid is a vector of time values determined previously
%   subj_pdf is the subjective density fx corresponding to tGrid
%   plotColor is optional (if empty, nothing is plotted)
%   rwdSize and iti are scalars
%
% Each point in tGrid is a candidate "stopping time" policy.


makePlot = true;
if isempty(plotColor), makePlot = false; end

% store all rates of return
allRates = nan(length(tGrid),1);

% set up the plot, to be built incrementally
if makePlot
    figure(gcf+1);
    hold on;
    ymax = 1.5;
    % gridlines at reward times
%     hold on;
%     for i = 1:size(dist,1)
%         plot(dist(i,1)*[1,1],[0,ymax],'-','LineWidth',0.5,'Color',0.8*[1,1,1]);
%     end
end

% loop over timepoints
for i = 1:length(tGrid)
    
    timeNow = tGrid(i); % the timepoint now in focus
    
    % rate of return for the policy of waiting until (just after) timeNow
    pRwd = subj_cdf(i);
    expRwd = rwdSize*pRwd;
    waitTime = min(timeNow,tGrid); % actual wait time for each scheduled delay
    expTime = iti + sum(waitTime.*subj_pdf)./sum(subj_pdf);
    rate = expRwd./expTime;
    allRates(i) = rate;

end

% plot
if makePlot
    plot(tGrid,allRates,'-','Color',plotColor,'LineWidth',1);
end

% general plot formatting
if makePlot
    set(gcf,'Units','inches','Position',[7,6,1.5,1.5]); % 1.5 x 1.5"
    set(gca,'Position',[0.3, 0.3, 0.6, 0.6]);
    set(gca,'Box','off','FontSize',7,'Layer','top');
    set(gca,'XLim',[0,150],'XTick',0:20:80,'YLim',[0, ymax]);
    xlabel('Waiting policy (sec)');
    ylabel(sprintf('Return (%c/sec)',162));
end

% identify the best available rate of return
[bestRate, bestIdx] = max(allRates);

% print results for the best rate
fprintf('    best overall rate of return = %1.4f %c/s\n',bestRate,162);
fprintf('    occurring at t = %1.2fs\n',tGrid(bestIdx));



