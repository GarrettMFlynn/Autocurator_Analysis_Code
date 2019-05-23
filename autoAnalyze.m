function [output] = autoAnalyze(T, contactsAuto, contacts);
% Written by Garrett Flynn (5/16/19)

% AUTOANALYZE gives users a selection of ways to analyze autocurated data,
% particularly when paired with human-validation arrays. Human-curated contacts must
% be called 'contacts' and autocurated contacts must be called
% 'contactsAuto' if you wish to use trialContactBrowser.

%% Options
if nargin == 3
    repeat = true;
    
    while repeat
        
        provideInput = true;
        message = {
            '\n(1) Visualize using trialContactBrowser & derivatives'
            '\n(2) Display contact_metrics_analyzer results'
            '\n(3) Determine best cutoff values'
            '\n(4) Rewrite contact array given a specific cutoff'
            '\n\nDecision: '
            };
        
        % Decision Input Check
        while provideInput
            decision = input(sprintf('%s',message{:}));
            
            if isempty(decision) || ((decision > 3) && (decision < 0))
                warning('Invalid input. Please try again.')
            else
                provideInput = false;
            end
        end
        
        % Redirect to Correct Auxillary Function
        switch decision
            case 0
                repeat = false;
            case 1
                trialContactOptions(contactsAuto,contacts,T);
                output = [];
                fprintf('No output from tCB\n');
            case 2
                metrics = contact_metrics_analyzer_var(contactsAuto, contacts, T);
                output = metrics;
                display(metrics);
                fprintf('Output now contains metrics\n');
            case 3
                cutoffs = BestCutoffAverages(contactsAuto,contacts,T);
                output = cutoffs;
                display(cutoffs);
                fprintf(['Output is now the cutoff value(s) displayed above\n']);
            case 4
                cutoff = input('What cutoff value would you like to use?\nCutoff:');
                contactsAuto = rewriteContactArray(contactsAuto,cutoff);
                output = contactsAuto
                savedir = input('What directory would you like to save this array?','s');
                saveFile = [savedir '\rewritten_array_at_cutoff.mat']
                save(saveFile, 'output');
                fprintf(['Contact array has been saved at ' saveFile]);
                fprintf(['Output is now a rewritten contact array at Cutoff = ' num2str(cutoff) '\n']);
            otherwise
                fprintf('Error: Not a valid input. If you wish to escape this function, press 0');
        end
    end
    
    
else
    error('Please supply (1) a trial array, (2) an autocurated contact array, and (3) a human-curated contact array.');
end
