contactPoints = [];

for i = 1:length(T.trials)
q = 0;
    if ~isempty(contactsAuto{i}) 
    if num2str(contactsAuto{i}.contactInds{1}) == "Skipped" || isempty(contactsAuto{i}.contactInds{1}) 
        continue 
        % A negative one indicates that the trial array had no data 
        % and we should skip this trial 
    elseif isfield(contactsAuto{i},'touchConfidence') 
for j = 1:numel(contactsAuto{i}.touchConfidence)
if ~ismember(j/1000, T.trials{i}.whiskerTrial.time{1})
   if q == 0
contactPoints = [contactPoints i];
q = 1;
   else 
      continue
   end
end
end
end
end
end