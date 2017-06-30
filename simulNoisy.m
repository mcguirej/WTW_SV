function [] = simulNoisy()
% simulate performance if choice were a softmax function of value rather
% than value-maximizing. 

% path to subfunctions
addpath('subfx');

% translate coefs from logistic regression fits into softmax noise params
coef_b0 = 3.11;
coef_b1 = 0.26;
sigma = 1/coef_b1;
bias = coef_b0/coef_b1;

% % directly set softmax noise parameters
% sigma = .1; 
% bias = .2;

% points at which a 'decision' is assumed to be made
tGrid = 1:1:40;
tGrid(end) = []; % omit the timepoint at exactly 40s

% the distributions
% col1 is time, col2 is probability
dist{1}(:,1) = (5:5:40)';
dist{1}(:,2) = (1/8)*ones(8,1); % HP
dist{2}(:,1) = [5:5:20, 90]';
dist{2}(:,2) = [(1/8)*ones(4,1); 1/2]; % LP

% loop over distributions
dLabels = {'HP', 'LP'};

% task parameters
rwdSize = 30; % in cents
iti = 2; % in seconds

% provisional: select one distribution to work with
dIdx = 2;
fprintf('%s distribution\n',dLabels{dIdx});

% come up with a value to use as the background reward rate
bestRate = policyPayoff(dist{dIdx},[],rwdSize,iti);

% set the background reward rate (may use bestRate or another value)
bkgdRate = bestRate;
% bkgdRate = 0.6;
fprintf('bkgd reward rate = %1.2f\n',bkgdRate);

% get the distribution with subjective timing uncertainty
cv = 0.16; % assumed value for coef of variability
[pdf_tgrid, subj_pdf] = gm_pdf(dist{dIdx},cv,[]);

% loop over timepoints, directly estimating the survival curve
sFx = nan(size(tGrid)); % initialize the survival function
sRate = 1; % initialize the survival rate at 1
pFx = nan(size(tGrid)); % initialize the potential function
for tIdx = 1:numel(tGrid)
    
    % current elapsed time
    tVal = tGrid(tIdx);
    
    % current potential
    %   -> WITHOUT subjective timing uncertainty
    % pvNow = potenVal_onePoint(tVal,dist{dIdx},rwdSize,bkgdRate);
    %   -> WITH subjective timing uncertainty
    pvNow = gm_potenVal_onePoint(tVal,pdf_tgrid,subj_pdf,rwdSize,bkgdRate);
    pFx(tIdx) = pvNow;
    
    % probability of quitting upon reaching this timepoint
    pQuit = 1 / (1 + exp((pvNow + bias)/sigma));
    if isnan(pvNow/sigma), pQuit = 1; end % deal with the 0/0 case
    
    % update the survival rate and store it
    sRate = sRate * (1 - pQuit);
    sFx(tIdx) = sRate;
    
end

% area under the survival curve
auc = sum(diff([0, tGrid, 40]).*[1, sFx]);

clf;

% plot the pdf
subplot(1,3,1);
plot(pdf_tgrid,subj_pdf,'r-','LineWidth',2);
set(gca,'Box','off','FontSize',16);
title('Reward PDF');

% plot the potential function
subplot(1,3,2);
plot(tGrid,pFx,'b-','LineWidth',2);
set(gca,'Box','off','FontSize',16);
title('Potential function');

% plot the survival fx
subplot(1,3,3);
plot([0, tGrid],[1, sFx],'k.-','LineWidth',2,'MarkerSize',24);
set(gca,'Box','off','FontSize',16,'YLim',[0,1]);
title(sprintf('Survival curve; AUC = %1.2fs',auc));




