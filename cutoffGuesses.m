
f1 = figure;
hold on;
confidenceHist(contactsAuto, 'plot-session');

%% Heuristics
% Cutoffs from Session Confidences Added (then cutoff derived)
sessionCutoff = confidenceHist(contactsAuto, 'session-cutoff-averaged');

% Cutoffs from Trial-Derived Cutoffs Averaged
trialCutoffs = confidenceHist(contactsAuto, 'trial-cutoff');

cutoffAveraged = nanmean(trialCutoffs);


heuristicArray = rewriteTrialsIndependently(contactsAuto,trialCutoffs);
heuristicMetrics = contact_metrics_analyzer_var(heuristicArray, contacts, T);
hAcc = heuristicMetrics.percentAgreedPoints;

%% Ground Truth
% Cutoffs from Specific Trials
cutoffsTrialSpecific = TrialSpecificCutoffs(T,contactsAuto, contacts);
cutoffSpecificAveraged = nanmean(trialCutoffs);

specificArray = rewriteTrialsIndependently(contactsAuto,cutoffsTrialSpecific);
specificMetrics = contact_metrics_analyzer_var(specificArray, contacts, T)
sAcc = specificMetrics.percentAgreedPoints;

% Cutoffs Averaged Across Trials
[topCutoffs, allCutoffs] = BestCutoffAverages(contactsAuto,contacts,T);

%% Determine Random Chance
percentDueToRandom = randomChance(contactsAuto,contacts);


%% Data Extraction from Tables
topCut = topCutoffs.(1);
topAccuracy = topCutoffs.(2);
allCuts = allCutoffs.(1);
allAccuracy = allCutoffs.(2);

%% Matcg Heuristic Cutoffs to Nearest Ground Truth Test
[cutSessions,idx1] = closest(allCuts,sessionCutoff);
[cutTrials,idx2] = closest(allCuts,cutoffAveraged);
accSessions = allAccuracy(idx1);
accTrials = allAccuracy(idx2);

%% Remap Accuracies to Figure Window
figure(f1)

yl = ylim;
xl = xlim;
ymax = yl(2);
xmin = xl(1);
xmax = xl(2);

accArray = [topAccuracy(1),accSessions,accTrials,hAcc,sAcc];
accArray = round(accArray*100)/100;

minAcc = percentDueToRandom;

maxAcc = 100;

diffAcc = maxAcc - minAcc;

normAccArray = (accArray - minAcc)/diffAcc;

minPlotted = ymax/10;

maxPlotted = ymax - minPlotted;

diffPlotted = maxPlotted - minPlotted;

accPlotPositions = (normAccArray*diffPlotted) + minPlotted;

%% Plotting
figure(f1)

markerSize = 25;

% Plot Random Chance
line([xmin,xmax], [0,0],'color','r');
text(xmax,0,['\leftarrow' 'Chance: ' num2str(percentDueToRandom) '%'],'FontSize', 10);
text(xmax,ymax,['\leftarrow' ' Max: 100.00%'],'FontSize', 10);

% Plot Averaged Results (cutoff AND accuracies)
scatter(sessionCutoff,accPlotPositions(2),markerSize,'MarkerFaceColor','r','MarkerEdgeColor','none');
scatter(cutoffAveraged,accPlotPositions(3),markerSize,'MarkerFaceColor',[0,191/255,255/255],'MarkerEdgeColor','none');
scatter(topCut(1), accPlotPositions(1),markerSize,'MarkerFaceColor','g','MarkerEdgeColor','none');
text(topCut(1),accPlotPositions(1),['\leftarrow' ' Ground: S_a | ' num2str(accArray(1)) '%'],'FontSize', 10);
text(sessionCutoff,accPlotPositions(2),['\leftarrow' ' Heuristic: S_a | ' num2str(accArray(2)) '%'],'FontSize', 10);
text(cutoffAveraged,accPlotPositions(3),['\leftarrow' ' Heuristic: T_a | ' num2str(accArray(3)) '%'],'FontSize', 10);

% Plot Accuracies for Trial-Specific Results (accuracies only)
line([0,xmax],[accPlotPositions(4),accPlotPositions(4)],'color','b','LineWidth',1);
line([0,xmax],[accPlotPositions(5),accPlotPositions(5)],'color',[60/255,179/255,113/255],'LineWidth',1);
text(xmax,accPlotPositions(4),['\leftarrow' ' Heuristic: T_s ' num2str(accArray(4)) '%'],'FontSize', 10);
text(xmax,accPlotPositions(5),['\leftarrow' ' Model Max: ' num2str(accArray(5)) '%'],'FontSize', 10);

title('2070');
ax = gca;
ax.TitleFontSizeMultiplier = 3;

function [minVal,idx] = closest(base, search)
[val,idx]=min(abs(base-search));
minVal=base(idx);
end

