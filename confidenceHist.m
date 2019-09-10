function [out] = confidenceHist(contacts, mode, varargin)
switch mode
    case 'plot-session'
        totalContacts = [];
        for i = 1:length(contacts)
            if isfield(contacts{i}, 'touchConfidence') == 1
                conf = contacts{i}.touchConfidence;
                conf(conf==0) = [];
                totalContacts = [totalContacts conf];
            end
        end
        histogram(totalContacts)
        out = 0;
    case 'plot-trial'
        num = varargin{1};
        if isfield(contacts{num}, 'touchConfidence') == 1
                conf = contacts{num}.touchConfidence;
                conf(conf==0) = [];
                histogram(conf)
        end
        out = 0;
    case 'session-cutoff'
        % Not implemented
    case 'trial-cutoff'
        numCons = length(contacts);
        outMat = zeros(1, numCons);  
        for i = 3:numCons
            if isfield(contacts{i}, 'touchConfidence') == 1
                conf = contacts{i}.touchConfidence;
                conf(conf==0) = [];
                [N, edges] = histcounts(conf, 16);
                N(N<10) = 0;
                [peaks, locs] = findpeaks([0 N 0]);
                % Establish largest two peaks 
                indices = edges(locs);
                if numel(peaks) < 2
                    outMat(i) = 0.5;
                elseif numel(peaks) == 2
                    outMat(i) = (indices(1) + indices(2))/2;
                else
                    [maxPeak, maxIdx] = max(peaks);
                    peaks(maxIdx) = 0;
                    [SecPeak, secIdx] = max(peaks);
                    outMat(i) = (indices(maxIdx) + indices(secIdx))/2;
                end
            else
                outMat(i) = 0.5;
            end
        end
        out = outMat;
end


