function [] = expDelay(dist,plotColor)
% plot expected total delay as time elapses
% also plot the current time, for reference
% Input:
%   dist is a 2-col matrix. col1 = time (sec), col2 = probability mass
%
% expDelay is a step function, changing only at timepoints where p>0

delayX = [0; dist(:,1)];
delayF = nan(size(delayX));

% compute expected delay at each timepoint
% (assuming only *later* points are still possible)
for i = 1:(length(delayX) - 1)
    
    remaining_tmpts = dist(i:end,1);
    remaining_pmass = dist(i:end,2);
    delayF(i) = sum(remaining_tmpts.*remaining_pmass)/sum(remaining_pmass);
    
end % loop over timepoints

% fill in the final delay point
delayF(end) = delayF(end-1);

% set up plot
figure(gcf+1);

% gridlines at reward times
ymax = 95;
hold on;
for i = 1:size(dist,1)
    plot(dist(i,1)*[1,1],[0,ymax],'-','LineWidth',0.5,'Color',0.8*[1,1,1]);
end

% plot data
h1 = stairs(delayX,delayF,'k-','LineWidth',1);
set(h1,'Color',plotColor);

% also draw elapsed time
hold on;
h2 = plot(delayX([1,end]),delayX([1,end]),'k--','LineWidth',1);
hold off;

% plot formatting
set(gcf,'Units','inches','Position',[7,6,1.5,1.5]); % 1.5 x 1.5"
set(gca,'Position',[0.3, 0.3, 0.6, 0.6]);
set(gca,'Box','off','FontSize',7,'Layer','top');
set(gca,'XLim',[0,95],'XTick',0:20:80,'YLim',[0,ymax],'YTick',0:20:80);
xlabel('Time elapsed (sec)');
ylabel('Expected delay (sec)');

% legend
% legend([h1,h2],'Expected reward time','Current time','Location','SouthEast');


