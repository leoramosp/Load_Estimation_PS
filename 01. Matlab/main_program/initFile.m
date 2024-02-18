% Popula arquivo de log com dados iniciais sobre a estimação: a versão da
% função objetivo, a constante de expansão do domínio, o número de fases de
% medição no alimentador e nas barras do circuito, o nome das barras com
% medição de tensão e elementos com medição de corrente, o registro das
% opções referentes ao Pattern Search, os limites inferiores e superiores
% para a estimação de carga.
function [] = initFile(arqlg,...        % caminho para arquivo .txt de log do algoritmo;
                       ver,...          % versao da função objetivo que será avaliada;
                       con,...          % constante de expansão do domínio da função objetivo;
                       ptosS,...        % número de pontos de medição no alimentador, contando as fases;
                       ptosV,...        % elementos de rede que contém mediçãod e corrente, fora o alimentador;
                       nos,...          % lista com barras ordenada de acordo com organize_bus
                       barraV,...       % lista com barras nas quais há medição de tensão
                       elemI,...        % lista com elementos nos quais há medição de corrente
                       opt,...          % estrutura com as opções de configuração do Pattern Search
                       lb,...           % limite inferior para o algoritmo de estimação;
                       ub,...           % limite superior para o algoritmo de estimação;
                       init_guess,...   % chute inicial para o algoritmo de estimação;
                       bus,...          % número de barras trifásicas do circuito;
                       verificaB,...    % string que diz se o valor correto se encontra entre as raízes
                       method)          % 0 para PS e 1 para GA
% -------------------------------------------------------------------------
% a) População do arquivo com dados iniciais
% -------------------------------------------------------------------------
switch method
    case 0
        fprintf(arqlg,'SIMULAÇÃO PATTERN SEARCH MATLAB\n\n');
    case 1
        fprintf(arqlg,'SIMULAÇÃO GENETIC ALGORITHM MATLAB\n\n');
end
fprintf(arqlg,'Versão de opti_bus = %d \n',ver);
% fprintf(arqlog,'Modo de execução = %d \n\n',modo);
fprintf(arqlg,'Constante de expansao = %d \n',con);
if(size(barraV,1)>0)
    fprintf(arqlg,'Barras com Medição de tensão: ');
    for aux=1:size(barraV,2)-1
        fprintf(arqlg,'%s, ',barraV{aux});
    end
    fprintf(arqlg,'%s.\n',barraV{end});
end
fprintf(arqlg,'Medicoes de tensão utilizadas (Fases do Alimentador + Fases nas Barras) = (%d + %d) / %d \n',ptosS,ptosV,size(nos,1));
if(size(elemI,1)>0)
    fprintf(arqlg,'Elementos com medição de corrente: ');
    for aux=1:size(elemI,1)-1
        fprintf(arqlg,'%s, ',elemI{aux});
    end
    fprintf(arqlg,'%s.\n',elemI{end});
end
fprintf(arqlg,'\n');

% -------------------------------------------------------------------------
% a.1) Registro das opcoes utilizadas
% -------------------------------------------------------------------------
fprintf(arqlg,'OPTIONS \n');
switch method
    case 0
        fprintf(arqlg,'TolMesh = %d\n', opt.TolMesh);
        fprintf(arqlg,'TolCon = %d\n', opt.TolCon);
        fprintf(arqlg,'TolX = %d\n', opt.TolX);
        fprintf(arqlg,'TolFun = %d\n', opt.TolFun);
        fprintf(arqlg,'TolBind = %d\n', opt.TolBind);
        fprintf(arqlg,'MaxIter = %d\n', opt.MaxIter);
        fprintf(arqlg,'MaxFunEvals = %d\n', opt.MaxFunEvals);
        fprintf(arqlg,'TimeLimit = %d\n', opt.TimeLimit);
        fprintf(arqlg,'MeshContraction = %d\n', opt.MeshContraction);
        fprintf(arqlg,'MeshExpansion = %d\n', opt.MeshExpansion);
        fprintf(arqlg,'MeshAccelerator = %s\n', opt.MeshAccelerator);
        fprintf(arqlg,'MeshRotate = %d\n', opt.MeshRotate);
        fprintf(arqlg,'InitialMeshSize = %d\n', opt.InitialMeshSize);
        fprintf(arqlg,'ScaleMesh = %s\n', opt.ScaleMesh);
        fprintf(arqlg,'MaxMeshSize = %d\n', opt.MaxMeshSize);
        fprintf(arqlg,'InitialPenalty = %d\n', opt.InitialPenalty);
        fprintf(arqlg,'PenaltyFactor = %d\n', opt.PenaltyFactor);
        fprintf(arqlg,'PollMethod = %s\n', opt.PollMethod);
        fprintf(arqlg,'CompletePoll = %s\n', opt.CompletePoll);
        fprintf(arqlg,'PollingOrder = %s\n', opt.PollingOrder);
        fprintf(arqlg,'SearchMethod = %s\n', opt.SearchMethod);
        fprintf(arqlg,'CompleteSearch = %s\n', opt.CompleteSearch);
        fprintf(arqlg,'Display = %s\n', opt.Display);
        fprintf(arqlg,'OutputFcns = %s\n', opt.OutputFcns);
        fprintf(arqlg,'PlotInterval = %d\n', opt.PlotInterval);
        fprintf(arqlg,'Cache = %s\n', opt.Cache);
        fprintf(arqlg,'CacheSize = %d\n', opt.CacheSize);
        fprintf(arqlg,'CacheTol = %d\n', opt.CacheTol);
        fprintf(arqlg,'Vectorized = %s\n', opt.Vectorized);
        fprintf(arqlg,'UseParallel = %d\n\n', opt.UseParallel);
    case 1
        fprintf(arqlg,'PopulationType = %d\n', opt.PopulationType);
        fprintf(arqlg,'PopInitRange = %d\n', opt.PopInitRange);
        fprintf(arqlg,'PopulationSize = %d\n', opt.PopulationSize);
        fprintf(arqlg,'EliteCount = %d\n', opt.EliteCount);
        fprintf(arqlg,'CrossoverFraction = %d\n', opt.CrossoverFraction);
        fprintf(arqlg,'ParetoFraction = %d\n', opt.ParetoFraction);
        fprintf(arqlg,'MigrationDirection = %d\n', opt.MigrationDirection);
        fprintf(arqlg,'MigrationInterval = %d\n', opt.MigrationInterval);
        fprintf(arqlg,'MigrationFraction = %d\n', opt.MigrationFraction);
        fprintf(arqlg,'Generations = %d\n', opt.Generations);
        fprintf(arqlg,'TimeLimit = %d\n', opt.TimeLimit);
        fprintf(arqlg,'FitnessLimit = %d\n', opt.FitnessLimit);
        fprintf(arqlg,'StallGenLimit = %d\n', opt.StallGenLimit);
        fprintf(arqlg,'StallTest = %d\n', opt.StallTest);
        fprintf(arqlg,'StallTimeLimit = %d\n', opt.StallTimeLimit);
        fprintf(arqlg,'TolFun = %d\n', opt.TolFun);
        fprintf(arqlg,'TolCon = %d\n', opt.TolCon);
        fprintf(arqlg,'InitialPopulation = %d\n', opt.InitialPopulation);
        fprintf(arqlg,'InitialScores = %d\n', opt.InitialScores);
        fprintf(arqlg,'NonlinConAlgorithm = %d\n', opt.NonlinConAlgorithm);
        fprintf(arqlg,'InitialPenalty = %d\n', opt.InitialPenalty);
        fprintf(arqlg,'PenaltyFactor = %d\n', opt.PenaltyFactor);
        fprintf(arqlg,'CreationFcn = %d\n', opt.CreationFcn);
        fprintf(arqlg,'FitnessScalingFcn = %d\n', opt.FitnessScalingFcn);
        fprintf(arqlg,'SelectionFcn = %d\n', opt.SelectionFcn);
        fprintf(arqlg,'CrossoverFcn = %d\n', opt.CrossoverFcn);
        fprintf(arqlg,'MutationFcn = %d\n', opt.MutationFcn);
        fprintf(arqlg,'DistanceMeasureFcn = %d\n', opt.DistanceMeasureFcn);
        fprintf(arqlg,'HybridFcn = %d\n', opt.HybridFcn);
        fprintf(arqlg,'Display = %d\n', opt.Display);
        fprintf(arqlg,'OutputFcns = %d\n', opt.OutputFcns);
%         fprintf(arqlg,'PlotFcns = %s\n', opt.PlotFcns);
        fprintf(arqlg,'PlotInterval = %d\n', opt.PlotInterval);
        fprintf(arqlg,'Vectorized = %d\n', opt.Vectorized);
        fprintf(arqlg,'UseParallel = %d\n', opt.UseParallel);
end

% -------------------------------------------------------------------------
% a.2) Registro dos boundaries e valores a serem alcançados - para fins de
% debug
% -------------------------------------------------------------------------

lb1 = unModifyVector(lb);
ub1 = unModifyVector(ub);
chute = unModifyVector(init_guess);
fprintf(arqlg,'IEEE %d BARRAS MODIFICADO\n\n',bus);
fprintf(arqlg,'Initial Guess, Lower Bounds and Upper Bounds:\n\n');
fprintf(arqlg,'\t%22s\t\t%14s\t\t%22s\n','Init. Guess','LB','UB');
for aux=1:size(ub1,1)
    fprintf(arqlg,'\t%10g\t%10g\t\t%10g\t%10g\t\t%10g\t%10g\t\n',...
                  chute(aux,1)/con,chute(aux,2)/con,...
                  lb1(aux,1)/con,lb1(aux,2)/con,...
                  ub1(aux,1)/con,ub1(aux,2)/con);
end
fprintf(arqlg,'\n');
fprintf(arqlg,'%s\n',verificaB);