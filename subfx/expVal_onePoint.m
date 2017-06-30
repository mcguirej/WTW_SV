function [evNow] = expVal_onePoint(tNow,dist,rwdSize)
% calculates a trial's _expected_ value at a specific elapsed time (tNow)
%   (note: tNow must be a scalar)
% this depends on:
%   a discrete timing distribution (dist; col1=time, col2=prmass)
%   the reward size (rwdSize)
%
% expected value is just based on the probability of receiving the reward
% on this trial, assuming you're willing to wait 40s but not 90s. 
%   this is a reduced version of SV, which we're testing at a reviewer's 
%       request.
%   we _don't_ assume people base their policy on maximizing EV (this would
%       just mean always waiting).
%   the possibility we're investigating here is that people use something
%       like the full SV to determine the roughly optimal policy, but that
%       VMPFC is not involved in this and just dynamically tracks the 
%       resulting EV. 

% rough approximation of giving-up time. all that matters is that rewards
% up to 40s are always received, and 90s rewards are never received.
% time costs based on exact delay amounts are ignored in this EV model.
gut = 50; 

assert(numel(tNow)==1,'tNow must be a scalar'); % check input
passedTmpts = dist(:,1)<=tNow; % which timepoints are already in the past
dist(passedTmpts,:) = []; % remove these
dist(:,2) = dist(:,2)./sum(dist(:,2)); % normalize probabilities
pre_GUT_tmpts = dist(:,1)<gut; % index timepoints where the reward will be obtained
pRwd = sum(dist(pre_GUT_tmpts,2)); % total probability of the reward arriving at a pre-GUT timepoint
evNow = pRwd*rwdSize;



