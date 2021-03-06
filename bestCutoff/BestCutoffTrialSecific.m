%% A SEMI-REDUNDANT FUNCTION TO CALL DETERIMINECUTOFF
function [accuracy] = BestCutoffTrialSecific(auto,man,T);
% Written by Garrett Flynn (5/15/19)

% BESTCUTOFFTRIALSPECIFIC determines the best cutoff for all trials of a given autocurated contact
% array (in relation to a supplied manually curated array and a trial
% array) by iterating through cutoff values & outputting the resulting
% accuracy

        [allCutoffs,accuracy] = determineCutoff_TS(auto, man, T);

    
end


%% DETERMINE CUTOFF
function [allCutoffs, performance] = determineCutoff_TS(autoConTA, manualConTA, tArray)
% DETERMINECUTOFF allows users to vary autocurated contacts arrays & find
% the cutoff that maximizes agreement given predictions in the array AND a
% manually curated array to match.


% Setup
range = 0:.01:1;
[tempConTA,allCutoffs] = rewriteContactArray_TS(tArray,autoConTA,range);
metrics = contact_metrics_analyzer_var(tempConTA, manualConTA, tArray)
performance = metrics.percentAgreedPoints;
fprintf('\t%.2f\n', performance);
end


 
function [contactsAuto] = rewriteContactArray_TS(T,contactArray, range) 
% Written by Garrett Flynn (5/14/19) 
 
% REWRITECONTACTARRAY converts an existing autocurated contact array into a 
% new contact array based on its prediction values and a desired cutoff for 
% touch/nontouch distinction. 
 
cArray = contactArray; 
numTrials = length(contactArray); 

best_cutoff = nan(1,numTrials);
max_acc = nan(1,numTrials);
for i = 1:numTrials % We want to iterate by trial 
    performance = zeros(range);
for cutoff = range
    if ~isempty(contactArray{i}) 
    if num2str(contactArray{i}.contactInds{1}) == "Skipped" || isempty(contactArray{i}.contactInds{1}) 
        continue 
        % A negative one indicates that the trial array had no data 
        % and we should skip this trial 
    elseif isfield(contactArray{i},'touchConfidence') 
        contactCell = zeros(1, numel(contactArray{i}.touchConfidence)); 
        cArray{i}.contactInds{1} = {}; 
        for j = 1:numel(contactArray{i}.touchConfidence) %Iterate through each point 
            con = contactArray{i}.touchConfidence; 
            if con(j) < cutoff 
                % Non-Touch point 
                contactCell(j) = 0; 
            elseif con(j)  > cutoff 
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
    
    metrics = contact_metrics_analyzer_var(tempConTA, manualConTA, tArray)
    performance(cutoff) = metrics.percentAgreedPoints;
end

[max_acc(i), ind] = max(performance);
best_cutoff(i) = range(ind);
end 
 
% Save the contact array 
contactsAuto = cArray; 
%params = cArray.params; 
end