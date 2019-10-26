 
function [percentDueToChance] = randomChance(autoArray, manArray) 
% Written by Garrett Flynn (5/14/19) 
 
% RANDOMCHANCE tells us how well the curator would do if guessing randomly. 

%% Hardcoded Variables
defaultTrialFrames = 4000;

%% Code

  % Loop and establish touches
  numTrials = length(autoArray);
  agreePct = zeros(numTrials, 1); % Total percent  of points in agreement
  agreeNum = zeros(numTrials, 1); % Number of agree upon touches
  falseTouch = zeros(numTrials, 1); % Number of false touch points according to manual curation
  falseNonTouch = zeros(numTrials, 1); % Number of false non-touch points according to manual curation
  onsetDiff = zeros(numTrials, 1); % Average difference between touch onset of agreed touches (in ms)
  offsetDiff = zeros(numTrials, 1); % Average difference between touch offset of agreed touches (in ms)
  %touchDiff = zeros(numTrials, 1); % Total number of touches in trial disagreed upon
  
  
  totalPoints = 0;
  correctPoints = 0;
  
  
  
  
  
  for i = 1:numTrials
      try
          autoPoints = autoArray{i}.contactInds{1};
          manPoints = manArray{i}.contactInds{1};
      catch
          continue
      end
      
      
    % If both empty, perfect agreement on points
    if isempty(autoPoints) && isempty(manPoints)
        if (isfield(autoArray{i},'prepross'))
      deltaP = length(autoArray{i}.prepross);
        else
           deltaP = defaultTrialFrames; 
        end
      totalPoints = totalPoints + deltaP;
      correctPoints = correctPoints + deltaP;
      continue
    end

    % Catch empty cells in array, indicating uncuratable due to lack of info
    if strcmp(autoPoints, 'Skipped')
      continue
    end
    
    
    %% Calculate Random Chance
    
    
    % Manual points are present but curator didn't curate
    if isempty(autoPoints) && ~isempty(manPoints)
       deltaP = defaultTrialFrames;
       totalPoints = totalPoints + deltaP;
       correctPoints = correctPoints + (defaultTrialFrames-length(manPoints));
       continue
    end
     
    % Curator gets half of its curated frames right by chance AND all of
    % the uncurated frames
      deltaP = length(autoArray{i}.prepross);
      totalPoints = totalPoints + deltaP;
      processedP = length(find(autoArray{i}.prepross == 2));
      uncuratedP = totalPoints - processedP;
      correctPoints = correctPoints + uncuratedP + processedP/2;
      
  end
  percentDueToChance = correctPoints/totalPoints;
end