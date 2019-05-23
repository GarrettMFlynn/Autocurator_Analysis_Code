%% A SEMI-REDUNDANT FUNCTION TO CALL DETERIMINECUTOFF
function [agreements] = BestCutoffMany(structure);
% Written by Garrett Flynn (5/15/19)

% BESTCUTOFF determines the best cutoff for a given autocurated contact
% array (in relation to a supplied manually curated array and a trial
% array) by iterating through cutoff values. All results are
% averaged over the trials in a session.
for q = 1:length(structure)
    fields = fieldnames(structure{q});
    manualConTA = structure{q}.(fields{1});
    autoConTA = structure{q}.(fields{2});
    tArray = structure{q}.(fields{3});
    
% Setup
range = 0:.01:1;
trials = 1:length(autoConTA);

% Processing
for i = 1:length(range)
cutoff = range(i);
fprintf('Cutoff = %.2f\n',  cutoff);
tempConTA = rewriteContactArray(autoConTA,cutoff);
metrics = contact_metrics_analyzer_var(tempConTA, manualConTA, tArray);
agreements(q,i) = metrics.percentAgreedPoints;
fprintf('\t%.2f\n',  agreements(i));
end
end

for i = 1:length(range)
bestcutoffs(i) = nanmean(agreements(:,i))
[bestvalue, bestindex] = max(bestcutoffs);
fprintf('Best Cutoff Overall: %.2f\n', range(bestindex));
fprintf('\tAgreement: %.2f\n', bestvalue);

end

%% AVERAGE BEST CUTOFF CALCULATED FROM THE TRIAL-BY-TRIAL CALCULATION
    % Plot Cutoff Distribution
    f1 = figure;
    plot(range, bestcutoffs, 'ok'); hold on;
    axis([0 1 70 100])
    title('Agreement vs. Cutoff Value');
    xlabel('Cutoff Value');
    ylabel('Agreement (%)')
    cs = csapi(range,bestcutoffs);
    fnplt(cs,'-b');
    
end
