function [] = pmf(dist,plotColor)
% plots the probability mass function for a discrete distribution
% Input:
%   dist is a 2-col matrix. col1 = time (sec), col2 = probability mass

% set up plot
figure(gcf+1); clf; hold on;

% gridlines at reward times
ymax = 0.55;
hold on;
for i = 1:size(dist,1)
    plot(dist(i,1)*[1,1],[0,ymax],'-','LineWidth',0.5,'Color',0.8*[1,1,1]);
end

% stem plot of the distribution
h = stem(dist(:,1),dist(:,2),'.-','LineWidth',1,'MarkerSize',8);
set(h,'Color',plotColor);

% plot formatting
set(gcf,'Units','inches','Position',[7,6,2,1.5]); % 2 x 1.5"
set(gca,'Position',[0.3, 0.3, 0.6, 0.6]);
set(gca,'FontSize',7,'Box','off','Layer','top');
set(gca,'XLim',[0,95],'XTick',0:20:80,'YLim',[0, ymax],'YTick',[0,0.2,0.4]);
xlabel('Delay (sec)');
ylabel('Probability mass');




