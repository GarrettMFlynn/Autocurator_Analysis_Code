function [metrics] = contact_metrics_analyzer_varTrials2(autoCon, manCon, T,i)

caught = false;


  % If sizes don't match then the arrays can't be fairly compared
  if length(autoCon) ~= length(manCon)
    error('Contact array size does not match')
  end

      try
          autoPoints = autoCon{i}.contactInds{1};
          manPoints = manCon{i}.contactInds{1};
      catch
          % At least one contact idx failed to load
          agreePct = nan;
          agreeNum = nan;
          falseTouch = nan;
          falseNonTouch = nan;
          onsetDiff = nan;
          offsetDiff = nan;
          %touchDiff = nan;
          caught = true;

      end
      
    if ~caught
    % If both empty, perfect agreement on points
    if isempty(autoPoints) && isempty(manPoints)
      agreePct = 100;
      agreeNum = 0;
      falseTouch = 0;
      falseNonTouch = 0;
      onsetDiff = 0;
      offsetDiff = 0;
      %touchDiff = 0;

    % Catch empty cells in array, indicating uncuratable due to lack of info
    elseif strcmp(autoPoints, 'Skipped')
      % No distance to pole data for trial or missing vid, uncuratable
      agreePct = nan;
      agreeNum = nan;
      falseTouch = nan;
      falseNonTouch = nan;
      onsetDiff = nan;
      offsetDiff = nan;
      %touchDiff = nan;
    else

    % Process actual points
    commonTouches = intersect(autoPoints, manPoints);
    falseTouch = numel(autoPoints) - numel(commonTouches);
    falseNonTouch = numel(manPoints) - numel(commonTouches);
    agreePct = 100*((4000 - falseTouch - falseNonTouch)/4000);
    vel = nanmean(abs(diff((T.trials{i}.whiskerTrial.distanceToPoleCenter{1}))));

    % Find onsets
    if ~isempty(autoPoints)
        autoOnset = find(diff(autoPoints) > 1);
        autoOffset = autoOnset;
        autoOnset = autoOnset + 1;
        autoOnset = [1 autoOnset];
        autoOnsetPts = autoPoints(autoOnset);
        autoOffsetPts = [autoPoints(autoOffset) autoPoints(end)];
    else
        autoOnsetPts = [];
    end
        
    if ~isempty(manPoints)
    manOnset = find(diff(manPoints) > 1);
    manOffset = manOnset;
    manOnset = manOnset + 1;
    manOnset = [1 manOnset];
    manOnsetPts = manPoints(manOnset);
    manOffsetPts = [manPoints(manOffset) manPoints(end)];
    else
        manOnsetPts = [];
    end
    if isempty(commonTouches) 
        agreeNum = 0;
    elseif ~isempty(autoPoints) && ~isempty(manPoints)
        commonOnset = find(diff(commonTouches) > 1);
        commonOffset = commonOnset;
        commonOnset = commonOnset + 1;
        commonOnset = [1 commonOnset];
        commonOnsetPts = commonTouches(commonOnset);
        commonOffsetPts = [commonTouches(commonOffset) commonTouches(end)];
        numCommonTouch = numel(commonOnset);
        agreeNum = numCommonTouch;
        onsetDelta = zeros(1, numCommonTouch);
        offsetDelta = zeros(1, numCommonTouch);
        % Loop through touches
        for j = 1:numCommonTouch
            % Find difference between onset points
            onsetPt = commonOnsetPts(j);
            [~,autoDiff] = min(abs(autoOnsetPts - onsetPt));
            [~,manDiff] = min(abs(manOnsetPts - onsetPt));
            onsetDelta(j) = abs(autoDiff - manDiff);
            % Find difference between offset points
            offsetPt = commonOffsetPts(j);
            [~,autoDiff] = min(abs(autoOffsetPts - offsetPt));
            [~,manDiff] = min(abs(manOffsetPts - offsetPt));
            offsetDelta(j) = abs(autoDiff - manDiff);
        end
        onsetDiff = mean(onsetDelta);
        offsetDiff = mean(offsetDelta);
        extraTouches = length(autoOnset) - length(manOnset);
        disagreedWholeTouches = abs(extraTouches);
        humanTouches = length(manOnset);
    else
        agreeNum = 0;
    end
    end
    end
 

  %hold off
  metrics.percentAgreedPoints = agreePct;