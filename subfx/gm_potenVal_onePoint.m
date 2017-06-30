function [pvNow] = gm_potenVal_onePoint(tNow,tGrid,subj_pdf,rwdSize,bkgdRate)
% calculates a trial's potential value at a specific elapsed time (tNow)
%   (note: tNow must be a scalar)
% this depends on:
%   a timing distribution (tGrid and subj_pdf)
%   the reward size (rwdSize)
%   the background reward rate (bkgdRate)

assert(numel(tNow)==1,'tNow must be a scalar'); % check input
passedTmpts = tGrid<=tNow; % which timepoints are already in the past
tr_t = tGrid(~passedTmpts) - tNow; % advance the remaining timepoints
tr_p = subj_pdf(~passedTmpts)./sum(subj_pdf(~passedTmpts)); % normalize probabilities (no longer a density fx)

% the "candidate policies" are to wait till each point in tr_t
% find the expected gain under each candidate policy
cumProb = cumsum(tr_p);
expGain = cumProb*rwdSize;

% expected cost under each candidate policy
cumCost = cumsum(tr_t.*tr_p) + tr_t.*(1 - cumProb);

% store the best potential rate (across policies)
pvNow = max(expGain - bkgdRate*cumCost);

% if the potential rate is lower than zero it gets set to zero (because
% the best available course of action is to quit and obtain the
% background rate)
pvNow = max(pvNow,0);


