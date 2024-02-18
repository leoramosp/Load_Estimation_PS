% Gera um gráfico de frequências para cada teste individual, considerando a
% porcentagem de cargas e o erro percentual acumulado.
% Parâmetros da função:
function CreateGraphinic(resX,... % estrutura com resultados dos testes para grandeza X
                     arqX)    % arquivos para guardar os resultados dos testes para grandeza X
yvector = cell2mat([resX.tabFreqinicinic(2:end,3)';resX.tabFreqinic(2:end,9)';...
                    resX.tabFreqinic(2:end,11)';resX.tabFreqinic(2:end,13)']');
resX.hist.fig = figure('Position', get(0, 'Screensize')); %('visible','off');
% Create axes
axes1 = axes('Parent',resX.hist.fig,...
    'XTickLabel',{'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1','2','3','4','5','6','7','8','9','10','20','30','40','50','60','70','80','90','100','Inf'},...
    'XTick',[0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30],...
    'FontSize',24,...
    'Position',[0.0625 0.112227805695142 0.920312499999999 0.820658100345126]);
xlim(axes1,[0 30]);
box(axes1,'on');
hold(axes1,'on');

graph = bar([0:29],yvector,'Parent',axes1);
grid on;
grid minor;
switch size(yvector,2)
    case 4
        set(graph(4),'DisplayName','Erro Imag');
        set(graph(3),'DisplayName','Erro Real');
        set(graph(2),'DisplayName','Erro Angle');
        set(graph(1),'DisplayName','Erro Abs');
    case 6
        set(graph(6),'DisplayName','Erro Imag');
        set(graph(5),'DisplayName','Erro Real');
        set(graph(4),'DisplayName','Erro Delta(Angle)');
        set(graph(3),'DisplayName','Erro Angle(Delta)');
        set(graph(2),'DisplayName','Erro Delta(Abs)');
        set(graph(1),'DisplayName','Erro Abs(Delta)');
end

% Create legend and position
legend1 = legend(axes1,'show');
set(legend1,'Location','northwest');

% Axes Labels
xlabel({'Erro Z ou Y (%)'},'FontSize',26.4);
ylabel({'% Carga'},'FontSize',26.4);

% Title
title({resX.hist.title},'FontSize',26.4);


% Saving in formats fig and png
savepath = [arqX.nomearqfig(1:length(arqX.nomearqfig)-4) 'inic.png'];
saveas(gcf,[arqX.nomearqfig(1:length(arqX.nomearqfig)-4) 'inic.fig']);
screen_size = get(0, 'ScreenSize');
set(gcf, 'Position', [0 0 screen_size(3) screen_size(4) ] ); %set to scren size
set(gcf,'PaperPositionMode','auto') %set paper pos for printing
saveas(gcf,savepath);