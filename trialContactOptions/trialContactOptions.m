function [] = trialContactOptions(contactsAuto,contacts,T)
% Written by Garrett Flynn (5/16/19)

repeat = true;

while repeat
    provideInput = true;
    message = {
        '\n(1) Visualize the autocurator array'
        '\n(2) Visualize the manually curated array'
        '\n(3) Visualize a comparison of the two'
        '\n\nDecision: '
        };
    
 
% Decision Input Checks
    while provideInput
        decision = input(sprintf('%s',message{:}));
        if isempty(decision) || ((decision > 4) && (decision < 0))
            warning('Invalid input. Please try again.')
        else
            provideInput = false;
        end
    end


% Reroute to the Correct trialContactBrowser. Human-curated contacts must
% be called 'contacts' and autocurated contacts must be called
% 'contactsAuto'.
switch decision
    case 0
        repeat = false;
    case 1
        trialContactBrowser(T, contactsAuto);
    case 2
        trialContactBrowser(T, contacts);
    case 3
        trialContactBrowserC2(T, contacts, contactsAuto);
end
end
end