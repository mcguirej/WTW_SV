function [] = pvRegs()
% save potential value timecourses for use as analysis regressors
% (some code here borrowed from distribPlots.m and potenVal_dualPlot.m)
%
% timecourse regressors are saved as comma-delimited text files
% optional code at the end of this fx tests the analysis on mock data


% path to subfunctions
addpath('subFx');
addpath(genpath('~/spm8')); % use hrf from spm

% the distributions
% col1 is time, col2 is probability
dist{1}(:,1) = (5:5:40)';
dist{1}(:,2) = (1/8)*ones(8,1); % uniform
dist{2}(:,1) = [5:5:20, 90]';
dist{2}(:,2) = [(1/8)*ones(4,1); 1/2]; % long-tailed

% labels for the 2 distributions above (for saved figure files)
distLabels = {'hpd','lpd'}; % high- and low-persistence distribution

% output time grid (s)
tGrid = (2.5:2.5:37.5)';

% task parameters (used for "policyPayoff" and "potenVal")
rwdSize = 30; % in cents
iti = 2; % in seconds

% for each distribution
for d = 1:2

    label = distLabels{d};
    
    % waiting policy rates of return
    bestRate = policyPayoff(dist{d},[],rwdSize,iti);
    
    % potential value function (stored in a struct array)
    pv(d) = potenVal(dist{d},[],bestRate,rwdSize);
    
    % convolve pv function with hrf
    % (note: sampled at high temporal resolution)
    tDiffs = pv(d).tObs(2:end) - pv(d).tObs(1:(end-1));
    tDiffs = round(1000000.*tDiffs)./1000000; % deal w/ rounding error
    tr = unique(tDiffs);
    h = spm_hrf(tr);
    c = conv(pv(d).potentialRate,h);
    
    % extract points that match the values in tGrid
    % (assumes all the values in tGrid occur in pv(d).tObs)
    tIdx = ismember(pv(d).tObs,tGrid);
    pvGrid.(label) = c(tIdx)';
    assert(numel(tGrid)==numel(pvGrid.(label)),'time grid mismatch');

end

regSum = pvGrid.hpd + pvGrid.lpd;
regDiff_HPvsLP = pvGrid.hpd - pvGrid.lpd;

% write files w/ 2 cols of data (col1 = time, col2 = regressor value)
% sum regressor
fname = fullfile('pvRegFiles','regSum.txt');
dlmwrite(fname,[tGrid,regSum]);
% difference regressor
fname = fullfile('pvRegFiles','regDiff_HPvsLP.txt');
dlmwrite(fname,[tGrid,regDiff_HPvsLP]);

return; % to skip tests

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% optional -- test these regressors. 
% make datasets containing various patterns
testData(1).label = 'expected';
testData(1).hpd = pvGrid.hpd;
testData(1).lpd = pvGrid.lpd;
testData(2).label = 'reversed';
testData(2).hpd = pvGrid.lpd;
testData(2).lpd = pvGrid.hpd;
testData(3).label = 'both hpd';
testData(3).hpd = pvGrid.hpd;
testData(3).lpd = pvGrid.hpd;
testData(4).label = 'both lpd';
testData(4).hpd = pvGrid.lpd;
testData(4).lpd = pvGrid.lpd;
testData(5).label = 'randomized';
testData(5).hpd = pvGrid.hpd(randperm(length(tGrid)));
testData(5).lpd = pvGrid.lpd(randperm(length(tGrid)));

% loop over test datasets
nTest = length(testData);
for testIdx = 1:nTest
    d = testData(testIdx);
    fprintf('\n=== test data: %s ===\n',d.label);
    
    % loop over the number of timepoints analyzed
    % (always using the same number in both conditions)
    for n = 8:length(tGrid)
        fprintf('  %d timepoints (%1.1f to %1.1f s)\n',n,tGrid(1),tGrid(n));
        
        % set up the regression
        y = [d.hpd(1:n); d.lpd(1:n)];
        int1 = [ones(n,1); zeros(n,1)];
        int2 = [zeros(n,1); ones(n,1)];
        xSum = [regSum(1:n); regSum(1:n)];
        xDiff = [regDiff_HPvsLP(1:n); -regDiff_HPvsLP(1:n)];
        b = regress(y,[int1,int2,xSum,xDiff]);
        r = corr(xSum,xDiff);
        fprintf('    correl of sum and diff regs: r = %1.2f\n',r);
        fprintf('    sum coef: b = %1.2f\n',b(3));
        fprintf('    diff coef: b = %1.2f\n',b(4));
        
    end % loop over number of timepoints
end % loop over test datasets



