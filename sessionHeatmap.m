function sessionHeatmap(array,contactsAuto,contacts)


wholeSession = zeros(length(contacts),4000);
for ii = 1:length(contacts)
    
 params.cropind=[];   cind=[]; commonCind = []; fnegCind = [];  fposCind = []; y1=[];   x1=[];    y2=[];   x2=[];  
 
trial = zeros(1,4000);
if isfield(contacts{ii},'contactInds')
    cind=contacts{ii}.contactInds{1};
    cindAuto=contactsAuto{ii}.contactInds{1};
            cinds = {cind,cindAuto};
          for i = 1:length(cinds{1})
            if sum(cinds{2}(:) == cinds{1}(i))
                commonCind = [commonCind cinds{1}(i)];
            else
                fnegCind = [fnegCind cinds{1}(i)];
            end
          end
          for j = 1:length(cinds{2})
            if ~sum(cinds{2}(j) == cinds{1}(:))
                fposCind = [fposCind cinds{2}(j)];
            end
          end
end

wholeSession(ii,commonCind) = 2;
wholeSession(ii,fnegCind) = -1;
wholeSession(ii,fposCind) = 1;
end
fig = figure()
imagesc(wholeSession);
ylabel('Trails');
xlabel('Timepoints')
% colorbar();
map = redblue(3)
map = [map;0,1,0];
colormap(map)
name = [array.mouseName,' ',array.sessionName];
title(name)
saveas(fig,['C:\SuperUser\CNN_Projects\New_Autocurator_Test\FinalResults\BinaryAgreeDisagree',name,'.png']);
close all;

end

function c = redblue(m)
%REDBLUE    Shades of red and blue color map
%   REDBLUE(M), is an M-by-3 matrix that defines a colormap.
%   The colors begin with bright blue, range through shades of
%   blue to white, and then through shades of red to bright red.
%   REDBLUE, by itself, is the same length as the current figure's
%   colormap. If no figure exists, MATLAB creates one.
%
%   For example, to reset the colormap of the current figure:
%
%             colormap(redblue)
%
%   See also HSV, GRAY, HOT, BONE, COPPER, PINK, FLAG, 
%   COLORMAP, RGBPLOT.
%   Adam Auton, 9th October 2009
if nargin < 1, m = size(get(gcf,'colormap'),1); end
if (mod(m,2) == 0)
    % From [0 0 1] to [1 1 1], then [1 1 1] to [1 0 0];
    m1 = m*0.5;
    r = (0:m1-1)'/max(m1-1,1);
    g = r;
    r = [r; ones(m1,1)];
    g = [g; flipud(g)];
    b = flipud(r);
else
    % From [0 0 1] to [1 1 1] to [1 0 0];
    m1 = floor(m*0.5);
    r = (0:m1-1)'/max(m1,1);
    g = r;
    r = [r; ones(m1+1,1)];
    g = [g; 1; flipud(g)];
    b = flipud(r);
end
c = [r g b]; 
end