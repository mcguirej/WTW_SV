function [tGrid, pdfTot, cdfTot, haz] = gm_pdf(dist,cv,plotColor)
% plots the probability density function for a gaussian mixture distribution
% Input:
%   dist is a 2-col matrix. col1 = mu (sec), col2 = mixing proportion
%   cv (scalar) controls variance: sigma = mu*cv

% set up plots
firstFig = gcf+1;


% resolution of the time grid
tGridRes = 0.01;

% set the latest time to be plotted
latest_mu = max(dist(:,1));
tMax = latest_mu + 3*cv*latest_mu; % 3 SDs past the latest mean
tGrid = 0:tGridRes:tMax;

% get each component's contribution to the pdf
nComps = size(dist,1);
pdfs = nan(nComps,length(tGrid)); % initialize
cdfs = nan(nComps,length(tGrid)); % initialize
for c = 1:nComps
    pdfs(c,:) = dist(c,2)*normpdf(tGrid,dist(c,1),dist(c,1)*cv);
    cdfs(c,:) = dist(c,2)*normcdf(tGrid,dist(c,1),dist(c,1)*cv);
end
pdfTot = sum(pdfs);
cdfTot = sum(cdfs);
haz = pdfTot./(1-cdfTot);

if isempty(plotColor), return; end

figData = {pdfTot, cdfTot, haz};
figLabels = {'Probability density', 'Cumulative probability', 'Hazard rate'};
for f = 1:1

    figure(firstFig+f-1); clf; hold on;
    ymax = ceil(10*max(figData{f}))./10;

    % gridlines at reward times (component centers)
    hold on;
    for i = 1:size(dist,1)
        plot(dist(i,1)*[1,1],[0,ymax],'-','LineWidth',0.5,'Color',0.8*[1,1,1]);
    end

    % plot of the data
    h = plot(tGrid,figData{f},'-','LineWidth',1);
    set(h,'Color',plotColor);

    % plot formatting
    set(gcf,'Units','inches','Position',[7,6,1.5,1.5]); % 1.5 x 1.5"
    set(gca,'Position',[0.3, 0.3, 0.6, 0.6]);
    set(gca,'FontSize',7,'Box','off','Layer','top');
    set(gca,'XLim',[0,95],'XTick',0:20:80,'YLim',[0, ymax]);
    xlabel('Delay (sec)');
    ylabel(figLabels{f});
    
end % loop over figs




