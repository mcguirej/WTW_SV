function [] = distribPlots()
% create several forms of plots for a given set of discrete distributions

% path to subfunctions
addpath('subFx');

% the distributions
% col1 is time, col2 is probability
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

% dual plot of the discrete-distribution hazard functions
haz_dualPlot(dist,plotColor);
set(gcf, 'PaperPositionMode', 'auto');
fname = 'fig_hazDual.eps';
print(gcf,fname,'-depsc');


% for each distribution
% (save out the eps at each step)
for d = 1:2

    %%% step 1: plot the distribution itself
    pmf(dist{d},plotColor{d});
    
    % save figure
    set(gcf, 'PaperPositionMode', 'auto');
    fname = ['fig_',distLabels{d},'_pmf.eps'];
    print(gcf,fname,'-depsc');
    
    
    %%% step 2: plot expected total delay
    expDelay(dist{d},plotColor{d});
    
    % save figure
    set(gcf, 'PaperPositionMode', 'auto');
    fname = ['fig_',distLabels{d},'_etd.eps'];
    print(gcf,fname,'-depsc');
    
    
    %%% step 3: plot waiting policy rates of return
    bestRate = policyPayoff(dist{d},plotColor{d},rwdSize,iti);
    
    % print results for the best rate
    fprintf('%s: best overall rate of return = %1.4f %c/sec\n',...
        distLabels{d},bestRate,162);
    
    % save figure
    set(gcf, 'PaperPositionMode', 'auto');
    fname = ['fig_',distLabels{d},'_rr.eps'];
    print(gcf,fname,'-depsc');
    
    
    %%% step 4: plot the potential function
    bkgdRate = bestRate; % (from earlier output)
    [pv(d), ev(d), timeCost(d)] = potenVal(dist{d},plotColor{d},bkgdRate,rwdSize);
    
    % save figure
    set(gcf, 'PaperPositionMode', 'auto');
    fname = ['fig_',distLabels{d},'_pv.eps'];
    print(gcf,fname,'-depsc');
    
    
    %%% step 4-B: plot the potential function over only part of its range
    % (for clarity in slide presentations)
    forSlides = true;
    potenVal(dist{d},plotColor{d},bkgdRate,rwdSize,forSlides);
    
    set(gcf, 'PaperPositionMode', 'auto');
    fname = ['fig_',distLabels{d},'_pvForSlides.eps'];
    print(gcf,fname,'-depsc');
    
    
    %%% NB: the step below was later incorporated into the potenVal
    %%% subfunction, called above.
    
%     %%% step 5: compute EV (a reduced/suboptimal version of potential)
%     % suppress plots here by leaving plotColor arg empty.
%     % dual plots are created below.
%     ev(d) = expVal(dist{d},[],rwdSize);
%     ev(d).plotColor = plotColor{d};
    
end


% plot potential functions for 2 conditions on the same axes.
xmax = 90.2; % might also want 30.2
hrf = false;
potenVal_dualPlot(pv,xmax,hrf);
set(gcf, 'PaperPositionMode', 'auto');
fname = 'fig_pvDual.eps';
print(gcf,fname,'-depsc');

% same but with shorter x axis
xmax = 40;
hrf = false;
potenVal_dualPlot(pv,xmax,hrf);
set(gcf, 'PaperPositionMode', 'auto');
fname = 'fig_pvDual_40s.eps';
print(gcf,fname,'-depsc');

% also include HRF convolution
xmax = 30.2;
hrf = true;
potenVal_dualPlot(pv,xmax,hrf);
set(gcf, 'PaperPositionMode', 'auto');
fname = 'fig_pvDual_hrf.eps';
print(gcf,fname,'-depsc');
    

%%% equivalent plots for expected value (reduced version of potential
%%% functions, presupposing optimal behavior but ignoring the time cost)

% plot EV for 2 conditions on the same axes.
xmax = 40;
hrf = false;
potenVal_dualPlot(ev,xmax,hrf);
set(gcf, 'PaperPositionMode', 'auto');
fname = 'fig_evDual.eps';
print(gcf,fname,'-depsc');

% also include HRF convolution
xmax = 30.2;
hrf = true;
potenVal_dualPlot(ev,xmax,hrf);
set(gcf, 'PaperPositionMode', 'auto');
fname = 'fig_evDual_hrf.eps';
print(gcf,fname,'-depsc');

%%% and likewise plot the time cost

% plot time cost for 2 conditions on the same axes.
xmax = 40;
hrf = false;
potenVal_dualPlot(timeCost,xmax,hrf);
set(gcf, 'PaperPositionMode', 'auto');
fname = 'fig_timeCostDual.eps';
print(gcf,fname,'-depsc');

% also include HRF convolution
xmax = 30.2;
hrf = true;
potenVal_dualPlot(timeCost,xmax,hrf);
set(gcf, 'PaperPositionMode', 'auto');
fname = 'fig_timeCostDual_hrf.eps';
print(gcf,fname,'-depsc');


    



