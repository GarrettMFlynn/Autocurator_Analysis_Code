function [trialSpecificCutoffs, maxAcc] = TrialSpecificCutoffs(T,autoConTA, manualConTA) 
% Written by Garrett Flynn (5/14/19) 
 
% TS_cutoffs finds the best cutoffs on a trial-by-trial basis

range = 0:0.01:1;
cArray = autoConTA; 
numTrials = length(autoConTA); 

trialSpecificCutoffs = nan(1,numTrials);
maxAcc = nan(1,numTrials);
for i = 1:numTrials % We want to iterate by trial 
    performance = zeros(1,length(range));
for c = 1:length(range)
    if ~isempty(autoConTA{i}) 
    if num2str(autoConTA{i}.contactInds{1}) == "Skipped" || isempty(autoConTA{i}.contactInds{1}) 
        continue 
        % A negative one indicates that the trial array had no data 
        % and we should skip this trial 
    elseif isfield(autoConTA{i},'touchConfidence') 
        contactCell = zeros(1, numel(autoConTA{i}.touchConfidence)); 
        cArray{i}.contactInds{1} = {}; 
        for j = 1:numel(autoConTA{i}.touchConfidence) %Iterate through each point 
            con = autoConTA{i}.touchConfidence; 
            if con(j) < range(c)
                % Non-Touch point 
                contactCell(j) = 0; 
            elseif con(j)  > range(c) 
                % Touch point 
                contactCell(j) = 1; 
            else 
                % This means the CNN determined the probability of touch vs non-touch 
                % was exactly equal. Empirically we know the CNN is biased towards 
                % touches so we will mark as a non-touch. Note that getting this 
                % conditional should be HIGHLY unlikely 
                contactCell(j) = 1; 
            end 
            
        % Section to remove contacts at invalid time points: 
%          if ~ismember(j/1000, T.trials{i}.whiskerTrial.time{1}) 
%              contactCell(j) = 0; 
%          end 
        end
        
    end 
 
    % Remove lone touches 
    loneTouch = strfind(contactCell, [0, 1, 0]); 
    loneTouch = loneTouch + 1; 
    contactCell(loneTouch) = 0; 
     
    conIdx = {find(contactCell == 1)}; % Extract out indices of touches because 
    %that's what the contact array uses 
    % DISREGARD: trialNum = trialNum - 155; 
    cArray{i}.contactInds = conIdx; 
    end 
    
    metrics = contact_metrics_analyzer_var(cArray, manualConTA, T);
    performance(c) = metrics.percentAgreedPoints;
end

[maxAcc(i), ind] = max(performance);
trialSpecificCutoffs(i) = range(ind);
end 
end