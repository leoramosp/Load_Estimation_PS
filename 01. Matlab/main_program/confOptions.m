% Rotina que recebe o método de busca e a variável estruturada 'search' e
% devolve a variável estruturada options, com as opções de busca
% necessárias para executar a função patternsearch.

% PS: todos os métodos de busca foram testados e o que produz melhor
% resultados no contexto atual são as opções padrão. Muitos dos resultados
% em variar apenas uma opção estão descritos abaixo.

function opt = confOptions(metodo,...    % 0 para PS e 1 para GA
                           busca)    % estrutura com configurações de busca
if(metodo == 0)
    opt = psoptimset;
    % O comando acima cria todas os atributos de options que serão
    % inicializados pelo matlab ao aplicar o PS. Ele também pode ser
    % utilizado para definir o valor de certos atributos, tal como no
    % exemplo:
    % opt  = psoptimset('TolFun',1E-12,'TimeLimit',Inf,'InitialMeshSize',4.0,...
    %                   'PollMethod','GPSPositiveBasis2N','CompletePoll','on',...
    %                   'Vectorized','off','MaxIter',1000000,'PlotFcns',...
    %                   search.PlotFunctions);
    % Campos de options cuja modificação afeta o algoritmo
    % busca.PlotFunctions = {@psplotbestf,@psplotfuncount,@psplotmeshsize};
    % opt.PlotFcns = busca.PlotFunctions;
    opt.MaxFunEvals = Inf;
    opt.MaxIter = Inf;
    opt.UseParallel = 1;
    opt.PollingOrder = 'Success';
    % opt.InitialMeshSize = 8; * Não afeta desempenho do algoritmo padrão;
    % opt.CompletePoll = 'on'; * Piora desempenho;
    % opt.PollMethod = 'MADSPositiveBasis2N'; * Piora desempenho;
    % opt.PollingOrder = 'Success'; * Piora desempenho;
    % search.PlotFunctions = {};
    % opt.MeshAccelerator = 'on';
    % opt.PollingOrder = 'Random';  * Piora desempenho;
    % opt.ScaleMesh = 'off'; * Não modifica desempenho;
    % opt.TolMesh = 1e-12;
    % opt.TolX = 1e-12;
    % opt.MeshExpansion = 1;
    % opt.MeshContration = 2;
    % opt.Display = 'diagnose';

else
    busca.PlotFunctions = {@gaplotbestf @gaplotbestindiv @gaplotdistance};
    opt = gaoptimset;
    opt = gaoptimset(opt,'PlotFcns',busca.PlotFunctions);
%     opt = gaoptimset(opt,'PopulationSize', PopulationSize_Data);
%     opt = gaoptimset(opt,'Display', 'off');
end
