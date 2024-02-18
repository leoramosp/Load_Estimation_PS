% -------------------------------------------------------------------------
% <main_program.m>
% Rotina principal. Desempenha as seguintes tarefas em sequência.
% 1.	Escolha, pelo usuário, do circuito a ser simulado;
% 2.	Definição de opções de simulação pelo usuário: a partir da rotina 
%     "userData.m";
% 3.	Executa a rotina “gera_dados.m” para obter dados do sistema escolhido e
%     carrega esses dados a partir do arquivo “matrizes.mat”;
% 4.	Processa os dados do sistema para obter os dados de entrada para a
%     função “opti_ybus.m”;
% 5.	Processa os dados do sistema para obter os dados de entrada para a 
%     função “patternsearch”;
% 6.	Cria listas para avaliar a estimação, define nomenclatura e local para
%     salvar arquivos de log e arquivos de registros de resultados e realiza
%     o preenchimento inicial dessas listas e arquivos;
% 7.	Executa a rotina Pattern Search de modo a otimizar a função “opti_ybus.m”;
% 8.	Processa os resultados e os salva para processamento e registro;
% 9.	Finalização;

% -------------------------------------------------------------------------
% 0) APAGAMENTO DE VARIÁVEIS RESIDUAIS E CONEXÕES COM ARQUIVOS
% -------------------------------------------------------------------------
close all;
clear all;
fclose all;
clc;
warning('off');

% -------------------------------------------------------------------------
% 1) Definição da versão do circuito IEEE a ser executada pelo usuário
% -------------------------------------------------------------------------
escolha = 0; % define as opções de escolha e o que representam
texto = '\n\nEscolha a opção de circuito a ser simulado:\n\n';
texto = [texto 'Digite 1 para Circuito IEEE 13 barras;\n'];
texto = [texto 'Digite 2 para Circuito IEEE 34 barras;\n'];
texto = [texto 'Digite 3 para Circuito IEEE 37 barras;\n'];
texto = [texto 'Digite 4 para Circuito IEEE 123 barras;\n'];
texto = [texto '\n\nOpçao:'];
% coloca o texto na tela para o usuário
while(escolha~=1 && escolha~=2 && escolha~=3 && escolha~=4)
    escolha = input(texto);
end
fprintf('\n\n');

% -------------------------------------------------------------------------
% 2) DEFINIÇÃO DE CONFIGURAÇÕES PRINCIPAIS DE SIMULAÇÃO PELO USUÁRIO
% Definição de dados fornecidos pelo usuário, modificados frequentemente, 
% que definem parâmetros de simulação. Essas configurações são armazenadas
% na estrutura mainset. Ficam nesse tópico para serem facilmente modificadas.
% -------------------------------------------------------------------------
run('userData.m');
mainset.const = 1;
mainset.dom = 1;
mainset.method = 0;
mainset.time = clock;
% Descrição variáveis:
% * mainset.const: opção de ampliar ou diminuir o espaço vetorial de 
% admitância de cargas por um fator constante, variável utilizada de forma
% experimental.
% * mainset.dom: Escolhe o domínio da função objetivo. Pode assumir:
% 1 - Resolve a função objetivo no domínio das admitâncias;
% 2 - Resolve a função objetivo no domínio das impedâncias;
% * mainset.method - 0 para Pattern Search e 1 para GA;
% * mainset.time - artifício utilizado para simular os outros arquivos em
%   modo standalone (execução não é chamada a partir de main_program.m)

% Verifica se o valor mainset.version foi escolhido corretamente
switch mainset.version
    case 1
    case 2
    case 3
    case 4
    case 5
    case 6
    case 7
    case 8
    case 9
    case 10
    case 11
    case 12
    case 13
    case 14
    case 15
    case 16
    otherwise
        printf('\nDefinir valor correto para version.\n');
        break
end



% -------------------------------------------------------------------------
% 3) OBTENÇÃO DE DADOS
% -------------------------------------------------------------------------
% a) Executa a rotina gera_dados, para obter dados do sistema escolhido, os
% dados são armazenado no arquivo "matrizes.mat" e suas variações.
% b) Carrega o arquivo "matrizes.mat" através das variáveis "widenet" e
% "dados".
% OBS: Em caso de sub-redes, os dados são armazenados no arquivo
% 'matrizesx.mat', onde x é o número da sub-rede/área de medição.
% OBS2: Em caso de divisão em áreas de medição, também a rotina ajuda e
% escolher qual área de medição será utilizada para estimação de carga pelo
% PS.
% -------------------------------------------------------------------------
run('gera_dados.m'); % gera todos os dados do circuito escolhido.
pause(1);
widenet=load('matrizes.mat');
if(widenet.escolhadiv == 1)
    numsubredes = size(widenet.subredes,2);
    alternativas = 0:numsubredes;
    teste=[];
    while(isempty(teste))
        text = sprintf(...
        '\n\nEscolha a sub-rede a ser utilizada na estimação (1 - %d)',...
        numsubredes);
        text = [text ' ou 0 para utilizar a rede principal.'];
        text = [text sprintf(':\n\n')];
        text = [text sprintf('\n\nOpçao:')];
        choice = input(text);
        teste = find(alternativas==choice);
    end
    if(choice~=0)
        dados = subrede(choice);
    else
        dados = widenet;
    end
else
    dados=widenet;
end
clear numsubredes alternativas teste text choice widenet

% -------------------------------------------------------------------------
% c) Adiciona sub-pastas ao path para executar funções auxiliares
% -------------------------------------------------------------------------
addpath([pasta_atual '\main_program']);
addpath([pasta_atual '\opti_ybus']);

% -------------------------------------------------------------------------
% 4) PROCESSAMENTO DE DADOS 
% -------------------------------------------------------------------------
% a) Organiza dados referentes á tensão, corrente e potência,
% armazenando-os na variável estruturada 'circuit', que concentra os dados
% relevantes para o PS
% -------------------------------------------------------------------------
circuit.Vmed = dados.Vorder(2:end,2); % Vetor de tensões nodais
circuit.Vmed = cell2mat(circuit.Vmed);
circuit.Vpu = dados.Vorder(2:end,3); % Vetor de tensões nodais em pu
circuit.Vpu = cell2mat(circuit.Vpu);
circuit.Iinj = dados.Iorder(2:end,2); % Injeções nodais de corrente
circuit.Iinj = cell2mat(circuit.Iinj);
circuit.Imedido = cell2mat(dados.medI_list(2:end,15)); % elementos com medição de corrente
circuit.Ssource = cell2mat(dados.medI_list(2,8)); % potência medida na fonte

% -------------------------------------------------------------------------
% b) Organiza matrizes de impedância, admitância e matriz de cargas,
% armazenando-os na variável 'circuit'
% -------------------------------------------------------------------------
circuit.Yrede = cell2mat(dados.Yrede_list(2:end,2:end));
circuit.Ysistema = cell2mat(dados.Ysistema_list(2:end,2:end));
circuit.Yload = cell2mat(dados.Yload_list(2:end,2:end));

% -------------------------------------------------------------------------
% c) Obtém matrizes primárias de admitância da fonte e elementos de 
% posição dos nós referentes a esses elementos dentro de circuit.Vmed
% -------------------------------------------------------------------------
circuit.Y_prim = [dados.medI_list(2:end,2),dados.medI_list(2:end,5),...
          dados.medI_list(2:end,11)];

% -------------------------------------------------------------------------
% d) Obtém outros dados necessários à simulação
% -------------------------------------------------------------------------   
circuit.Ypos = dados.Ypos;
circuit.ptos_medSource = dados.ptos_medSource;
circuit.ptos_medV = dados.ptos_medV;
circuit.ptos_medI = dados.ptos_medI;
circuit.medI_list = dados.medI_list;
circuit.trafoList = dados.trafoList;
circuit.barraVmed = dados.barraVmed;
circuit.elemImed = dados.elemImed;

% -------------------------------------------------------------------------
% 5) Faz as preparacoes para a utilizacao do Pattern Search
% -------------------------------------------------------------------------
% a) Obtém o valor verdadeiro das admitâncias/potências a serem estimadas,
% armazenando-os na variável estruturada 'search', que concentra os
% parâmetros de busca.
% -------------------------------------------------------------------------
search.Yraiz = modifyVector(dados.Yraiz);
search.Zraiz = modifyVector(dados.Zraiz);
search.Sraiz = modifyVector(dados.Sraiz);
switch mainset.dom % Domínio das admitâncias ou impedâncias define a raiz - valor a ser estimado
    case 1
        search.Raiz = search.Yraiz;
        mainset.string_dom = 'Y';
    case 2
        search.Raiz = search.Zraiz;
        mainset.string_dom = 'Z';
end

% -------------------------------------------------------------------------
% b) Otimização (definição de options)
% -------------------------------------------------------------------------
options = confOptions(mainset.method,search);

% -------------------------------------------------------------------------
% c) Chute inicial - A função abaixo oferece diversas alternativas para o
% chute inicial, consultar o código da função. O chute inicial usual é
% dividir a potência medida no alimentador proporcionalmente ao peso
% percentual da potência nominal de cada carga em relação ao sistema. A
% função abaixo permite também a reutilização de resultados anteriores como
% chute inicial.
% -------------------------------------------------------------------------
search.chute_inicial = defineChuteInicial(dados.Load,circuit.Ssource,mainset.dom);
% search.chute_inicial = 0.97*search.Raiz;

% -------------------------------------------------------------------------
% d) Inicialização dos boundaries e verificação se contém a raiz
% -------------------------------------------------------------------------

[search.UB search.LB search.verifyBounds] = ...
    defineBoundaries(search.chute_inicial,search.Raiz,mainset.dom);

% -------------------------------------------------------------------------
% e) Teste de uma constante de amplicação do campo de busca do PS para a
% função opti_ybus
% -------------------------------------------------------------------------
search.chute_inicial = search.chute_inicial * mainset.const;
search.Raiz = search.Raiz * mainset.const;
search.UB = search.UB * mainset.const;
search.LB = search.LB * mainset.const;

% -------------------------------------------------------------------------
% f) Inicialização de restrições não lineares (restrições podem ser
% manipuladas no arquivo sysnlconsts.m, dentro da pasta opti_ybus
% -------------------------------------------------------------------------

switch(mainset.restriction)
    case 1
        search.nonlcon = @(x)sysnlconsts_fp(x,circuit.Vmed,dados.medI_list,...
                                       circuit.Vpu,circuit.Iinj,circuit.Yrede,...
                                       dados.Ypos,circuit.Y_prim,dados.barraVmed,...
                                       dados.ptos_medI,dados.ptos_medV,...
                                       dados.trafoList,mainset.dom);
    case 2
        search.nonlcon = @(x)sysnlconsts_magV(x,circuit.Vmed,dados.medI_list,...
                                       circuit.Vpu,circuit.Iinj,circuit.Yrede,...
                                       dados.Ypos,circuit.Y_prim,dados.barraVmed,...
                                       dados.ptos_medI,dados.ptos_medV,...
                                       dados.trafoList,mainset.dom);
    case 3
        search.nonlcon = @(x)sysnlconsts_trafo(x,circuit.Vmed,dados.medI_list,...
                                       circuit.Vpu,circuit.Iinj,circuit.Yrede,...
                                       dados.Ypos,circuit.Y_prim,dados.barraVmed,...
                                       dados.ptos_medI,dados.ptos_medV,...
                                       dados.trafoList,mainset.dom);
    case 4
        search.nonlcon = @(x)sysnlconsts_V(x,circuit.Vmed,dados.medI_list,...
                                       circuit.Vpu,circuit.Iinj,circuit.Yrede,...
                                       circuit.Ypos,circuit.Y_prim,dados.barraVmed,...
                                       dados.ptos_medI,dados.ptos_medV,...
                                       dados.trafoList,mainset.dom);
     case 5
        search.nonlcon = @(x)sysnlconsts_current(x,circuit.Vmed,dados.medI_list,...
                                       circuit.Vpu,circuit.Iinj,circuit.Yrede,...
                                       circuit.Ypos,circuit.Y_prim,dados.barraVmed,...
                                       dados.ptos_medI,dados.ptos_medV,...
                                       dados.trafoList,mainset.dom);
    otherwise
        search.nonlcon = [];
end

% -------------------------------------------------------------------------
% 6) Definição do arquivo de log e das variáveis de log, e população do
% arquivo com dados iniciais. Dado que os resultados são apresentados com
% base em impedância, admitância e potência, a nomenclatura dos arquivos
% universais é armazenada na estrutura 'files'. A nomenclatura dos arquivos
% referentes ao log dos resultados em impedância é armazenada na variável
% 'filesZ', sendo 'filesY' e 'filesS' análogos.
% -------------------------------------------------------------------------
% a) Definição do nome e estrutura dos arquivos de saída
% -------------------------------------------------------------------------
[files filesY filesZ filesS] = defineFiles(mainset,dados,search);

% -------------------------------------------------------------------------
% b) População do arquivo de log universal com dados iniciais
% -------------------------------------------------------------------------
fprintf('\n\nPrenchendo arquivos de log...\n\n');
files.arqlog     = fopen(files.nomearqlog,'wt');
initFile(files.arqlog,mainset.version,mainset.const,dados.ptos_medSource,dados.ptos_medV,...
         dados.node_order,dados.barraVmed,dados.elemImed,options,search.LB,search.UB,...
         search.chute_inicial,dados.barras,search.verifyBounds,mainset.method);

% -------------------------------------------------------------------------
% 7) Aplicacao do metodo de busca direta
% -------------------------------------------------------------------------

fprintf('\n\nIniciando loop para processo de busca...\n\n');

% -------------------------------------------------------------------------
% a) Aplicacao da funcao opti_ybus considerando o chute inicial e o valor
% correto a ser encontrado; escrita no arquivo de log
% Obs: serve principalmente para fins de debug
% -------------------------------------------------------------------------
search.finic  = opti_ybus(search.chute_inicial,circuit.Vmed,circuit.Imedido,...
                    circuit.Iinj,circuit.Yrede,circuit.Ysistema,...
                    circuit.Ypos,circuit.Y_prim,dados.ptos_medSource,...
                    dados.ptos_medV,mainset.const,mainset.version,...
                    mainset.dom);
search.fmin  = opti_ybus(search.Raiz,circuit.Vmed,circuit.Imedido,...
                         circuit.Iinj,circuit.Yrede,circuit.Ysistema,...
                         circuit.Ypos,circuit.Y_prim,dados.ptos_medSource,...
                         dados.ptos_medV,mainset.const,mainset.version,...
                         mainset.dom);
             
fprintf(files.arqlog,'\n');
fprintf(files.arqlog,'Initial value of function is: %g\n', search.finic);
fprintf(files.arqlog,'Best value to be reached is: %g\n', search.fmin);

% -------------------------------------------------------------------------
% b) Aplicação do PS em função da versão escolhida
% -------------------------------------------------------------------------
if(mainset.method==0)
    search.inicio = clock;
    [search.vetorps,search.fvalps,search.exitflag,search.output] = patternsearch(...
                                              @(solution)opti_ybus(solution,...
                                              circuit.Vmed,circuit.Imedido,circuit.Iinj,circuit.Yrede,...
                                              circuit.Ysistema,dados.Ypos,circuit.Y_prim,...
                                              dados.ptos_medSource,...
                                              dados.ptos_medV,...
                                              mainset.const,mainset.version,mainset.dom),...
                                              search.chute_inicial,[],[],[],[],search.LB,...
                                              search.UB,search.nonlcon,options);
    search.fim = clock;
else
    options.InitialPopulation = [search.chute_inicial;search.LB;search.UB];
    search.inicio = clock;
    [search.vetorps,search.fvalps,search.exitflag,search.output] = ga(...
                                          @(solution)opti_ybus(solution,...
                                          circuit.Vmed,circuit.Imedido,circuit.Iinj,circuit.Yrede,...
                                          circuit.Ysistema,dados.Ypos,circuit.Y_prim,...
                                          dados.ptos_medSource,...
                                          dados.ptos_medV,...
                                          mainset.const,mainset.version,mainset.dom),...
                                          size(search.chute_inicial,2),[],[],[],[],search.LB,...
                                          search.UB,search.nonlcon,options);
    search.fim = clock;
end
% -------------------------------------------------------------------------
% c) Determinação do tempo para convergência do PS
% -------------------------------------------------------------------------
if(find([6,9,11]==search.inicio(2)))
    search.tempo = ((search.fim - search.inicio))*[0;30*86400;86400;3600;60;1];
else
    search.tempo = ((search.fim - search.inicio))*[0;31*86400;86400;3600;60;1];
end

% -------------------------------------------------------------------------
% d) Modificação do vetor de resultados do PS para forma complexa e geração
% de vetores de resultados na forma de impedância e potência.
% -------------------------------------------------------------------------
resultsY.id = 'Y';
resultsZ.id = 'Z';
resultsS.id = 'S';
resultsY.chute_inicial = unModifyVector(search.chute_inicial);
resultsZ.chute_inicial = inverseZY(resultsY.chute_inicial);
resultsS.chute_inicial = defineS(dados.Load,circuit.Iinj,...
                                 resultsY.chute_inicial,circuit.Yrede);
resultsY.Estimado = unModifyVector(search.vetorps/mainset.const);
% resultsY.Estimado = dados.Yraiz;
% resultsY.Estimado = resultsY.chute_inicial;
resultsZ.Estimado = inverseZY(resultsY.Estimado);
resultsS.Estimado = defineS(dados.Load,circuit.Iinj,resultsY.Estimado,...
                            circuit.Yrede);

% -------------------------------------------------------------------------
% e) Verificação de violação das restrições pelo resultado
% -------------------------------------------------------------------------
% e1) Obtenção da tensão estimada nas barras;
% -------------------------------------------------------------------------
resultsV = obtainVest(dados,resultsY);

% -------------------------------------------------------------------------
% e2) Verifica se o vetor de carga estimado obedece as restrições
% não lineares estabelecidas no arquivo sysnlconsts.m na pasta opti_ybus
% -------------------------------------------------------------------------
if(isempty(search.nonlcon))
    search.test_c=[];
    search.test_ceq=[];
    search.verify_constraints = sprintf('Constraints OK.');
else
    [search.test_c,search.test_ceq] = search.nonlcon(search.vetorps);
    search.verify_c = find(search.test_c > 0);
    search.verify_ceq = find(search.test_ceq ~= 0);
    if(~isempty(search.verify_c) || ~isempty(search.verify_ceq))
        search.verify_constraints = sprintf('Constraints not OK.');
    else
        search.verify_constraints = sprintf('Constraints OK.');
    end
end
    
                        
% -------------------------------------------------------------------------
% 8) ARMAZENAMENTO DOS RESULTADOS EM LISTAS, ESCRITA EM TELA, EM ARQUIVOS E
% VARIÁVEIS SALVAS EM ARQUIVOS .MAT
% -----------------------------------------------------------------------                        
% a) Geração de listas com resultados dos testes.
% As listas geradas são:
% * resume(Y/Z/S) - tabela com a Y/Z/S real, a estimada e os erros
% absolutos e percentuais em módulo, fase, parte real e parte imaginária, 
% totalizando 8 medidas de erro, armazenada na estrutura results(Y/Z/S);
% * resume(Y/Z/S).maxResume - tabela baseada na anterior, agora com medidas
% estatísticas de qualidade de estimação;
% * resume(Y/Z/S).resumeinic e maxResumeinic - idem às tabelas anteriores,
% agora com os mesmos dados referentes à estimativa inicial;
% * tabFreq(Y/Z/S) - tabela com distribuição acumulada de frequências de erros de
% Y/Z/S - os campos para eixo y são os erros em módulo, fase, parte 
% real e imaginária. Para cada tipo de erro temos a quantidade de cargas 
% percentual ou menos e a percentagem de cargas com determinado erro
% com determinado erro percentual ou menos, armazenada na estrutura results(Y/Z/S);
% * Comparação entre estimação e chute inicial
% - compare1 - compara as tabelas de erros, tomando as diferenças entre os
% percentuais de erro do chute inicial (divisão proporcional) e da
% estimação do PS
% - compare2 - toma as diferenças entre as principais medidas de erro (erro
% médio, erro máximo e desvio padrão) cometidos pela estimação com PS e
% com o chute inciial
% ---------------------------------------------------------------------
% resultsY.resume = [dados.Load(1:end,2)];
% resultsZ.resume = resultsY.resume;
% resultsS.resume = resultsY.resume;

[resultsY.resume, resultsY.maxResume, ...
 resultsY.resumeinic, resultsY.maxResumeinic,...
 resultsY.compare1, resultsY.compare2, resultsY.tabFreq] = ...
                                  defineResume(resultsY,dados);
[resultsZ.resume, resultsZ.maxResume, ...
 resultsZ.resumeinic, resultsZ.maxResumeinic,...
 resultsZ.compare1, resultsZ.compare2, resultsZ.tabFreq] = ...
                                  defineResume(resultsZ,dados);
[resultsS.resume, resultsS.maxResume, ...
 resultsS.resumeinic, resultsS.maxResumeinic,...
 resultsS.compare1, resultsS.compare2, resultsS.tabFreq] = ...
                                  defineResume(resultsS,dados);

                              
% -------------------------------------------------------------------------
% b) Escrita das listas em arquivo;
% -------------------------------------------------------------------------
csvGenerator(resultsY,filesY);
csvGenerator(resultsZ,filesZ);
csvGenerator(resultsS,filesS);


% -------------------------------------------------------------------------
% c) Síntese dos testes e registro em arquivo
% -------------------------------------------------------------------------
fprintf('\n\nEscrevendo síntese dos resultados obtidos...\n\n');
% -------------------------------------------------------------------------
% c1) População do arquivo de log para cada teste individual
% -------------------------------------------------------------------------
% c1.1) Alguns dados sobre a simulação
% -------------------------------------------------------------------------
fprintf(files.arqlog,'Inicio da simulação = %.2d/%.2d/%d - %.2d:%.2d:%g\n',...
        search.inicio(3),search.inicio(2),search.inicio(1),search.inicio(4),...
        search.inicio(5),search.inicio(6));
fprintf(files.arqlog,'Fim da simulação = %.2d/%.2d/%d - %.2d:%.2d:%g\n',...
        search.fim(3),search.fim(2),search.fim(1),search.fim(4),search.fim(5),...
        search.fim(6));
if(mainset.method~=1)
    fprintf(files.arqlog,'The number of iterations is: %d\n',...
            search.output.iterations);
end
fprintf(files.arqlog,'The number of function evaluations is: %d\n',...
        search.output.funccount);
fprintf(files.arqlog,'The best function value found is: %g\n\n', search.fvalps);
% -------------------------------------------------------------------------
% c1.2) A função abaixo escreve os dados principais
% -------------------------------------------------------------------------
resultsFile(resultsY,resultsZ,resultsS,search.tempo,files.arqlog);
% -------------------------------------------------------------------------
% c1.2) Dados sobre particularidades da simulação
% -------------------------------------------------------------------------
fprintf(files.arqlog,...
'\nSimulação realizada para %d pontos com medição de tensão, %d pontos de medição de corrente, version = %d\n',...
dados.ptos_medV,dados.ptos_medI,mainset.version);
% -------------------------------------------------------------------------
% d) Escrita de resultados na tela
% -------------------------------------------------------------------------
if(mainset.method~=1)
    fprintf('The number of iterations is: %d\n', search.output.iterations);
end
fprintf('The number of function evaluations is: %d\n', search.output.funccount);
fprintf('The best function value found is: %g\n', search.fvalps);
% resultsScreen(resultsY.resume,resultsZ.resumeZ,resultsY.maxResume,resultsY.tabFreq,...
%               resultsZ.tabFreq,search.tempo,mainset.dom);
fprintf(...
'\nSimulação realizada para %d pontos com medição de tensão, %d pontos de medição de corrente, version = %d\n',...
dados.ptos_medV,dados.ptos_medI,mainset.version);

% -------------------------------------------------------------------------
% e) Geração de histograma com resultado, armazenado na variável
% 'resultsX', sendo X a grandeza na qual o histograma é gerado
% -------------------------------------------------------------------------
resultsY.hist.fig = 0;
resultsZ.hist.fig = 0;
resultsS.hist.fig = 0;
resultsY.hist.graph = 0;
resultsZ.hist.graph = 0;
resultsS.hist.graph = 0;
resultsY.hist.title = 'Distribuição acumulada dos erros de Y';
resultsZ.hist.title = 'Distribuição acumulada dos erros de Z';
resultsS.hist.title = 'Distribuição acumulada dos erros de S';
CreateGraph(resultsY,filesY);
CreateGraph(resultsZ,filesZ);
CreateGraph(resultsS,filesS);
% CreateGraphinic(resultsY,filesY);
% CreateGraphinic(resultsZ,filesZ);
% CreateGraphinic(resultsS,filesS);

% -------------------------------------------------------------------------
% g) Registro das variáveis principais em arquivo .mat, para posterior
% processamento, se necessário. Todos os principais dados do resultado são
% armazenados na pasta 'log' com a data da simulação
% -------------------------------------------------------------------------
save(files.nomearqmat,'mainset','dados','search','resultsY','resultsZ',...
                      'resultsS','resultsV','options','files','filesY',...
                      'filesZ','filesS');

% -------------------------------------------------------------------------
% 9) Finalização
% -------------------------------------------------------------------------
fclose all;
cd(pasta_atual);

fprintf('\n\nSimulação finalizada com sucesso...\n\n');

