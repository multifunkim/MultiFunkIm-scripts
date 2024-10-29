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
% Custom ------------------------------------------------------------------
yaxisbnd = ylim;
patch([0 2 2 0], [yaxisbnd(1) yaxisbnd(1) yaxisbnd(2) yaxisbnd(2)],'k', 'FaceColor',[0.8500    0.3250    0.0980],'FaceAlpha',0.1,'LineStyle','none')
% Legend ------------------------------------------------------------------
title(sprintf('PART %d',1)); 
legend({'name1','name2',},'Location','northeastoutside','Orientation','vertical');
% Statistics ------------------------------------------------------------------
[H,P,CI,STATS] = ttest2(y1,y2);
if H==0
    STR = ['Not significant : p =' num2str(P)];
    annotation('textarrow',[0.4,0.4],[0.88,0.8],'String', STR,'TextColor','k','Fontsize', 16,'Color','w','LineStyle','-','FontWeight','bold');
end