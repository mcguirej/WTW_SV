function [pvNow, evNow, timeCostNow] = potenVal_onePoint(tNow,dist,rwdSize,bkgdRate)
% calculates a trial's potential value at a specific elapsed time (tNow)
%   (note: tNow must be a scalar)
% this depends on:
%   a discrete timing distribution (dist; col1=time, col2=prmass)
%   the reward size (rwdSize)
%   the background reward rate (bkgdRate)

assert(numel(tNow)==1,'tNow must be a scalar'); % check input
tr_dist = dist; % time-remaining distribution
passedTmpts = tr_dist(:,1)<=tNow; % which timepoints are already in the past
tr_dist(passedTmpts,:) = []; % remove these
tr_dist(:,1) = tr_dist(:,1) - tNow; % advance the remaining timepoints
tr_dist(:,2) = tr_dist(:,2)./sum(tr_dist(:,2)); % normalize probabilities

% the "candidate policies" are to wait till each point in the
% discrete distribution.
% find the expected gain under each candidate policy
cumProb = cumsum(tr_dist(:,2));
expGain = cumProb*rwdSize;

% expected cost under each candidate policy
cumCost = cumsum(tr_dist(:,1).*tr_dist(:,2)) + tr_dist(:,1).*(1 - cumProb);

% store the best potential rate (across policies)
[pvNow, maxIdx] = max(expGain - bkgdRate*cumCost);
evNow = expGain(maxIdx); % return the 1st term at the maximizal value
timeCostNow = -bkgdRate*cumCost(maxIdx); % return the 2nd term at the maximal value

% if the potential rate is lower than zero it gets set to zero (because
% the best available course of action is to quit and obtain the
% background rate)
% pvNow = max(pvNow,0);
if pvNow<0
    pvNow = 0;
    evNow = 0;
    timeCostNow = 0;
end



