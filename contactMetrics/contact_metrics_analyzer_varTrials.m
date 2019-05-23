% CONTACT_METRICS_ANALYZER(AUTOCONTA, MANUALCONTA) is a simple function
% for comparing the autocurated version of a contact array with the manual
% version. Can be adapted for different contact array forms. Please supply
% full paths to contact arrays.
function [metrics] = contact_metrics_analyzer_varTrials(autoCon, manCon, T, i)

caught = false;

  % If sizes don't match then the arrays can't be fairly compared
  if length(autoCon) ~= length(manCon)
    error('Contact array size does not match')
  end

  % Establish touches

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
          metrics = [];
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
    end

    % Catch empty cells in array, indicating uncuratable due to lack of info
    if strcmp(autoPoints, 'Skipped')
      % No distance to pole data for trial or missing vid, uncuratable
      agreePct = nan;
      agreeNum = nan;
      falseTouch = nan;
      falseNonTouch = nan;
      onsetDiff = nan;
      offsetDiff = nan;
      %touchDiff = nan;
    end

    % Process actual points
    commonTouches = intersect(autoPoints, manPoints);
    falseTouch = numel(autoPoints) - numel(commonTouches);
    falseNonTouch = numel(manPoints) - numel(commonTouches);
    agreePct = 100*((4000 - falseTouch - falseNonTouch)/4000);

  %hold off
  metrics.percentAgreedPoints = agreePct;
    end