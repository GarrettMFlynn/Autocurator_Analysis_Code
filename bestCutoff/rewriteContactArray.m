 
function [contactsAuto] = rewriteContactArray(contactArray, cutoff) 
% Written by Garrett Flynn (5/14/19) 
 
% REWRITECONTACTARRAY converts an existing autocurated contact array into a 
% new contact array based on its prediction values and a desired cutoff for 
% touch/nontouch distinction. 
 
cArray = contactArray; 
numTrials = length(contactArray); 
for i = 1:numTrials % We want to iterate by trial 
    contactCell = []; 
    if ~isempty(contactArray{i}) 
    if num2str(contactArray{i}.contactInds{1}) == "Skipped" || isempty(contactArray{i}.contactInds{1}) 
        continue 
        % A negative one indicates that the trial array had no data 
        % and we should skip this trial 
    elseif isfield(contactArray{i},'touchConfidence') 
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
end 
 
% Save the contact array 
contactsAuto = cArray; 
%params = cArray.params; 
end