function [] = distribPlots_gm()
% create several forms of plots for a given set of timing distributions
% *** gaussian mixture model version ***
%   this version converts the discrete distributions to gaussian mixtures,
%   incorporating scalar variability. 

% path to subfunctions
addpath('subFx');

cv = 0.16; % assumed value for coef of variability
    % in units of s_sd/s_mean (so that sigma = cv*mu)
    % value of 0.16 drawn from Rakitin et al, 1998; see notes for details
fprintf('subjective cv = %1.2f\n',cv);

% the original discrete distributions
% col1 is time, col2 is probability
%
% for gaussian mixture distributions, each row is 1 component
% col1 is mu; col2 is the mixing proportion; sigma = mu*cv
dist{1}(:,1) = (5:5:40)';
dist{1}(:,2) = (1/8)*ones(8,1); % uniform
dist{2}(:,1) = [5:5:20, 90]';
dist{2}(:,2) = [(1/8)*ones(4,1); 1/2]; % long-tailed

% labels for the 2 distributions above (for saved figure files)
distLabels = {'hpd','lpd'}; % high- and low-persistence distribution

% task parameters (used for "policyPayoff" and "potenVal")
rwdSize = 30; % in cents
iti = 2; % in seconds

% plot formatting details
plotColor{1} = (50+[0, 100, 0])./255; % uniform = green token color
plotColor{2} = (50+[80, 0, 100])./255; % long-tailed = purple token color
% based on the colors from the experiment:
% tokColors.green = 50+[0, 100, 0];
% tokColors.purple = 50+[80, 0, 100];

% for each distribution
% (save out the eps at each step)
for d = 1:2

    %%% step 1: plot the distribution itself
    [tGrid{d}, pdfs{d}, cdfs{d}, haz{d}] = gm_pdf(dist{d},cv,plotColor{d});
    
%     % save figure
%     set(gcf, 'PaperPositionMode', 'auto');
%     fname = ['fig_',distLabels{d},'_gm_pdf.eps'];
%     print(gcf,fname,'-depsc');

%     %%% step 2: plot expected total delay
%     gm_expDelay(tGrid{d},pdfs{d},plotColor{d});
    
%     % save figure
%     set(gcf, 'PaperPositionMode', 'auto');
%     fname = ['fig_',distLabels{d},'_etd.eps'];
%     print(gcf,fname,'-depsc');
    
    
    %%% step 3: plot waiting policy rates of return
    fprintf('  %s:\n',distLabels{d});
    bestRate = gm_policyPayoff(tGrid{d},pdfs{d},cdfs{d},plotColor{d},rwdSize,iti);
    
    
    
%     % save figure
%     set(gcf, 'PaperPositionMode', 'auto');
%     fname = ['fig_',distLabels{d},'_rr.eps'];
%     print(gcf,fname,'-depsc');
    
    continue;
    
    %%% step 4: plot the potential function
    bkgdRate = bestRate; % (from earlier output)
    pv(d) = gm_potenVal(tGrid{d},pdfs{d},plotColor{d},bkgdRate,rwdSize);
    
    
%     % save figure
%     set(gcf, 'PaperPositionMode', 'auto');
%     fname = ['fig_',distLabels{d},'_pv.eps'];
%     print(gcf,fname,'-depsc');
    
end

% % plot the two hazard rates on the same axes.
% lineStyle = {'-','--'};
% xmax = 40;
% hazContin_dualPlot(tGrid,haz,plotColor,lineStyle,xmax);
% set(gcf, 'PaperPositionMode', 'auto');
% fname = 'fig_haz-subjective.eps';
% print(gcf,fname,'-depsc');

% plot discrete AND continuous hazard functions, for both distributions,
% all on a single set of axes.
% dual plot of the discrete-distribution hazard functions
haz_dualPlot(dist,plotColor,tGrid,haz);
set(gcf, 'PaperPositionMode', 'auto');
fname = 'fig_hazDual+subjective.eps';
print(gcf,fname,'-depsc');


% % plot potential functions for 2 conditions on the same axes.
% xmax = 30;
% hrf = false;
% potenVal_dualPlot(pv,xmax,hrf);
% % set(gcf, 'PaperPositionMode', 'auto');
% % fname = 'fig_pvDual.eps';
% % print(gcf,fname,'-depsc');
% 
% % also include HRF convolution
% xmax = 30;
% hrf = true;
% potenVal_dualPlot(pv,xmax,hrf);
% % set(gcf, 'PaperPositionMode', 'auto');
% % fname = 'fig_pvDual_hrf.eps';
% % print(gcf,fname,'-depsc');
    

    



