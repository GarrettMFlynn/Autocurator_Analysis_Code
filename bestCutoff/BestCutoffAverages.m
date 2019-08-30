%% A SEMI-REDUNDANT FUNCTION TO CALL DETERIMINECUTOFF
function [cutoffs] = BestCutoffAverages(auto,man,T);
% Written by Garrett Flynn (5/15/19)

% BESTCUTOFF determines the best cutoff for a given autocurated contact
% array (in relation to a supplied manually curated array and a trial
% array) by iterating through cutoff values. All results are
% averaged over the trials in a session.

    if exist('processedArray','var')
        [cutoffs] = determineCutoff(auto, man, T);
        
    else
        [cutoffs] = determineCutoff(auto, man, T);
    end
    
    
end


%% DETERMINE CUTOFF
function [maxAgree] = determineCutoff(autoConTA, manualConTA, tArray)
% DETERMINECUTOFF allows users to vary autocurated contacts arrays & find
% the cutoff that maximizes agreement given predictions in the array AND a
% manually curated array to match.


% Setup
range = 0:.01:1;
trials = 1:length(autoConTA);

% Processing
for i = 1:length(range)
cutoff = range(i);
fprintf('Cutoff = %.2f\n',  cutoff);
tempConTA = rewriteContactArray(tArray,autoConTA,cutoff);
metrics = contact_metrics_analyzer_var(tempConTA, manualConTA, tArray);
average(i) = metrics.percentAgreedPoints;
fprintf('\t%.2f\n',  average(i));
end


%% AVERAGE BEST CUTOFF CALCULATED FROM THE TRIAL-BY-TRIAL CALCULATION
    % Plot Cutoff Distribution
    f1 = figure;
    plot(range, average, 'ok'); hold on;
    axis([0 1 90 100])
    title('Agreement vs. Cutoff Value');
    xlabel('Cutoff Value');
    ylabel('Agreement (%)')
    cs = csapi(range,average);
    fnplt(cs,'-b');
    
    
    [top10values, top10indices] = maxk(average,10);
    top10cutoffs = range(top10indices);

   Data = [top10cutoffs' top10values'];
   VarNames = {'cutoff', 'agreement'};
   maxAgree = table(Data(:,1),Data(:,2), 'VariableNames',VarNames)

end