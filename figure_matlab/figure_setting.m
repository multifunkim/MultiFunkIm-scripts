%% FIGURE PROPRETIES SETTING 
%==========================================================================
G = get(groot);
set(groot,'DefaultFigureInvertHardcopy','off');             % Figure saved without background
set(groot,'DefaultFigurewindowstyle','normal');             % Resizes the figures ( normal / docked / modal )
set(groot,'DefaultFigurecolor','white');                    % Figure background color none or white ?
% set(groot,'DefaultFigurePosition',[1921 -239 2560/1 1440]); % G.MonitorPositions(2,:) = 1921 -239  2560 1440 

% Figure propreties
set(groot,'DefaultFigureInvertHardcopy','off');             % [off] Figure saved without background
set(groot,'DefaultFigurewindowstyle','normal');             % [docked]  Resizes the figures % docked / normal / modal
set(groot,'DefaultFigurecolor','white');                    % [white]  Figure background color none or white 

% Axes propreties
set(groot,'DefaultAxesTitleFontWeight','bold');             % [bold] normal / bold
set(groot,'DefaultAxesTitleFontSizeMultiplier',1);          % [1]
set(groot,'DefaultAxesFontWeight','bold');                  % [bold] normal / bold
set(groot,'DefaultAxesFontAngle','normal');                 % [normal] normal / italic
set(groot,'DefaultAxesFontSize',14);                        % [14]
set(groot,'DefaultAxesLabelFontSizeMultiplier',16/14);      % [16/14]
set(groot,'DefaultAxesColor',[1 1 1]);                      % [[1 1 1]]
set(groot,'DefaultAxesTickDir','in');                       % [in] in / out /both
set(groot,'DefaultAxesTickLength',[0.01 0.01]);             % [0.02 0.02] 
set(groot,'DefaultAxesLineWidth',1);                        % [1] 

% Line propreties
set(groot,'DefaultLineLineWidth',1);                        % [1] Thickness of figure lines % in point
set(groot,'DefaultLineLineJoin','miter');                   % [miter] Style of line corners
set(groot,'DefaultLineMarkerSize',10);                      % [10] Marker size
set(groot,'DefaultLineMarkerFaceColor','auto');             % [auto] Marker size

% Bar propreties
set(groot,'DefaultBarFaceColor',[0.5,0.5,1]);               % [0.5,0.5,1]
set(groot,'DefaultBarFaceAlpha',1);                         % [1] Face transparency between 0 and 1
set(groot,'DefaultBarEdgeAlpha',1);                         % [1] Edge transparency between 0 and 1
set(groot,'DefaultBarLineStyle','-');                       % [-]
set(groot,'DefaultBarLineWidth',1);                         % [1]
set(groot,'DefaultBarBarLayout','grouped');                 % [grouped] grouped or stacked
set(groot,'DefaultBarBarWidth',1);                          % [1] between 0 and 1

% Errorbar setting
set(groot,'DefaultErrorBarLineWidth',1);                    % [1]
set(groot,'DefaultErrorBarCapSize',10);                     % [7]
set(groot,'DefaultErrorBarMarkerSize',7);                   % [7]
set(groot,'DefaultErrorBarMarkerFaceColor','auto');         % [auto]

% Legend propreties
set(groot,'DefaultLegendLocation','best');                  % [best] north/south/east/west/best/outside none
set(groot,'DefaultLegendOrientation','vertical');           % [vertical] vertical horizontal
set(groot,'DefaultLegendNumColumnsMode','auto');            % [auto]
set(groot,'DefaultLegendFontSize',16);                      % [18]
set(groot,'DefaultLegendFontWeight','bold');                % [bold]
set(groot,'DefaultLegendLineWidth',1);                      % [1]
set(groot,'DefaultLegendBox','off');                        % [off]

% Histogram propreties
set(groot,'DefaultHistogramNormalization','count');         % [count]
set(groot,'DefaultHistogramFaceAlpha',0.3);                 % [0.3]
set(groot,'DefaultHistogramLineWidth',1);                   % [1]

% Color order setting
co = [  0         0.4470    0.7410;     % Bleu
        0.8500    0.3250    0.0980;     % Orange
        0.9290    0.6940    0.1250;     % Jaune
        0.4940    0.1840    0.5560;     % Violet
        0.4660    0.6740    0.1880;     % Vert
        0.3010    0.7450    0.9330;     % Bleu clair
        0.6350    0.0780    0.1840;     % Bordeaux
        0         0         1.0000;     % Bleu vif
        0         0.5000    0;          % Vert foncé
        1.0000    0         0;          % Rouge
        0         0.7500    0.7500;     % Cyan
        0.7500    0         0.7500      % Violet clair
        0.2       0.2       0.2         % Gris foncé
 ];
set(groot,'DefaultAxesColorOrder',co); % cf  https://www.mathworks.com/help/matlab/graphics_transition/why-are-plot-lines-different-colors.html


%% EXEMPLE
%==========================================================================

ch = figure('Name','Title of the figure','Color','white'); 

% Plot --------------------------------------------------------------------
subplot(2,2,[1,2])
x = linspace(-2*pi,2*pi);
y1 = sin(x);
y2 = cos(x);
plot(x,y1,x,y2); 
% X axis ------------------------------------------------------------------
xlabel({'Xlabek','Xunit'}); 
xlim([min(x) max(x)]); 
% X axis ------------------------------------------------------------------
ylabel({'Ylabel','Yunit'}); 
ylim([-1.5 1.5]);
% Legend ------------------------------------------------------------------
title(sprintf('PART %d',1)); 
legend({'name1','name2',},'Location','northeastoutside','Orientation','vertical');
% Statistics ------------------------------------------------------------------
[H,P,CI,STATS] = ttest2(y1,y2);
if H==0
    STR = ['Not significant : p =' num2str(P)];
    annotation('textarrow',[0.4,0.4],[0.88,0.8],'String', STR,'TextColor','k','Fontsize', 16,'Color','w','LineStyle','-','FontWeight','bold');
end

