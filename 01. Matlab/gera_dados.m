% O programa tem como funcao oter os principais dados para utilizacao do
% programa opti_ybus.m e armazena-los no arquivo matrizes.mat. As
% informações são todas exportadas na forma de lista, para facilitar o
% acesso às informações. O conteúdo do arquivo matrizes.mat é definido no
% fim deste arquivo, só rolar para baixo.
% A nomenclatura das barras deve de ser adaptada para que seguisse um padrão.

% -------------------------------------------------------------------------
% 1) Profilaxia do ambiente Matlab (apaga o passado e demais coisas) -
% comentar esse ítem caso estiver rodando main_program.m ou loop_main.m. A
% linha clearvars só serve se estiver rodando a partir de loop_main.m. Caso
% não for o caso, comentar essa linha. No caso, a variável mainset é
% declarada em main_program, a existência dele faz com que esse ítem não
% seja executado.
% -------------------------------------------------------------------------
if(exist('mainset')) % se existir mainset, está rodando a partir de main_program
    tempo = clock;
    diftempo = etime(tempo,mainset.time); % diferença de tempo em segundos
else % se não existe mainset, está rodando standalone
    close all;
    fclose all;
    clear all;
    clc    
end

% -------------------------------------------------------------------------
% 2) Localização do arquivo a ser simulado
% -------------------------------------------------------------------------
% a) Localização do arquivo pelo usuário, independentemente do PC
% -------------------------------------------------------------------------
pasta      = cd;
if(length(pasta)-10 < 0) % pasta tem que terminar com 01. Matlab, que tem 10 caracteres;
    pasta = uigetdir(cd,'Buscar main_program em 01. Matlab');
end    
while(~strcmp(pasta(length(pasta)-10:length(pasta)),'\01. Matlab')) %força a buscar na pasta certa
    fprintf('Current Folder deve ser o local do arquivo main_program.m senão código não vai funcionar.\n');
    pasta = uigetdir(cd,'Buscar main_program em 01. Matlab');
    fprintf('Executando código.\n');
end
pasta_atual = pasta;
pasta=pasta(1:length(pasta)-11); % Um nível acima - pasta Leo_Trabalho_Mestrado
addpath([pasta_atual '\gera_dados']); % Armazena as funções da pasta gera_dados
addpath([pasta_atual '\common']); % Armazena as funções da pasta common



% -------------------------------------------------------------------------
% c) Definições particulares para cada um dos sistemas a ser simulado:
% caminho dos arquivos do OpenDSS, barras de derivação e linhas de
% derivação
% -------------------------------------------------------------------------
% PS: A medição de corrente e potência ocorrerá no terminal 2 do elemento
% de rede descrito em 'elemImed'. A potência só será medida caso esse 
% terminalestiver conectado em uma barra relacionada na lista 'barraVmed'.

switch escolha
    case 1
        caminho1 = [pasta '\02. OpenDSS\IEEE 13 Barras'];
        caminho2 = [caminho1 '\IEEE13Nodeckt.dss'];
        barraVmed = barraVmed13;
        elemImed = elemImed13;
        barras = 13;

    case 2
        caminho1 = [pasta '\02. OpenDSS\IEEE 34 Barras'];
        caminho2 = [caminho1 '\ieee34Mod1.dss'];
        barraVmed = barraVmed34;
        elemImed = elemImed34;
        barras = 34;
    case 3
        caminho1 = [pasta '\02. OpenDSS\IEEE 37 Barras'];
        caminho2 = [caminho1 '\ieee37.dss'];
        barraVmed = barraVmed37;
        elemImed = elemImed37;
        barras = 37;
    case 4
        caminho1 = [pasta '\02. OpenDSS\IEEE 123 Barras'];
        caminho2 = [caminho1 '\IEEE123Master.dss'];
        barraVmed = barraVmed123;
        elemImed = elemImed123;
        barras = 123;
end
name = ['IEEE' num2str(barras)];
clear barraVmed13 barraVmed34 barraVmed37 barraVmed123
clear elemImed13 elemImed34 elemImed37 elemImed123

% -------------------------------------------------------------------------
% 3) Inicialização do OpenDSS
% -------------------------------------------------------------------------
% a) Criando objeto servidor OpenDss - instanciando um objeto da classe
% DSS
% -------------------------------------------------------------------------
% DSS - This interface is the Top interface at the OpenDSSEngine. It is 
% the object reference delivered after connecting to the COM interface and
% it gives access to the other interfaces in OpenDSSEngine.
DSSobj = actxserver('OpenDSSEngine.DSS');

% -------------------------------------------------------------------------
% b) Iniciando servidor
% -------------------------------------------------------------------------
% DSSobj.Start - This method validates the user and start the DSS. Returns
% TRUE if successful. The argument's is a positive integer with no
% specific value.
if ~DSSobj.Start(0)
    disp('Unable to start the OpenDSS Engine')
    return
end

% -------------------------------------------------------------------------
% c) Configurando as variáveis para as principais interfaces
% -------------------------------------------------------------------------
DSSText = DSSobj.Text;
% DSSobj.Text - This property returns an interface to the Text
%(command-result) command interpreter.
DSSCircuit = DSSobj.ActiveCircuit;
% DSSobj.ActiveCircuit - This property returns an interface to Active circuit.
% AtiveCircuit - This interface can be used to gain access to the features
% and properties of the active circuit. This is one of the most important
% interfaces since it embeds other interfaces, providing access to them as
% a property declaration. The circuit interface is exposed directly by the
% OpenDSSEngine.
DSSSolution = DSSCircuit.Solution;

% -------------------------------------------------------------------------
% d) Construindo comandos para rodar arquivos no OpenDSS - "rodar",
% nesse caso, representado pelo comando "Compile" seguido do nome e caminho
% do arquivo, significa apenas ler o arquivo e armazenar os dados (ao
% contrário do que o nome "compilar" sugere). Os cálculos e a resolução do
% circuito serão possibilidados a partir do método "Solve".
% -------------------------------------------------------------------------
command_comp1 = ['Compile (' caminho2 ')'];
command_datapath1 = ['set Datapath = (' caminho1 ')'];

% -------------------------------------------------------------------------
% 4. Roda circuito com as cargas e importa a matriz Y com
% cargas, além dos vetores de correntes e tensões nodais
% -------------------------------------------------------------------------
% a) Roda o arquivo com as cargas, roda o fluxo de
% potência e define a ordem dos nós
% -------------------------------------------------------------------------
% a.1) Roda o arquivo com as cargas e instancia alguns objetos
% necessários
% -------------------------------------------------------------------------
DSSText.command = command_datapath1;
DSSText.command = command_comp1;
% Modifica o modelo das cargas como impedância constante
DSSText.command = 'batchedit Load..* model=2';
% Desabilita todos os reguladores de tensão
DSSText.command = 'batchedit RegControl..* enabled=false';
% Soluciona o circuito em regime permanente
DSSSolution.Solve;
% Calcula matriz de incidência
DSSText.Command = 'CalcIncMatrix_O';
% Instancia objetos necessários
DSSCktElement = DSSCircuit.ActiveCktElement;
DSSElement = DSSCircuit.ActiveElement;
DSSLoads = DSSCircuit.Loads;

% -------------------------------------------------------------------------
% a.2) Verifica se existe possibilidade de divisão do circuito em áreas de
% medição (pontos com medição de tensão e corrente) e pergunta ao usuário
% se deseja fazer essa divisão
% -------------------------------------------------------------------------
escolhadiv = -1;
divpoints = obtainDivPoints(DSSCircuit,DSSElement,barraVmed,elemImed);
if(~isempty(divpoints))
    texto = sprintf('\n\nÉ possível dividir o sistema em %d áreas de medição.\n\n',size(divpoints,2)+1);
    texto = [texto 'Digite 1 para sub-dividir o sistema;\n'];
    texto = [texto 'Digite qualquer outro valor para fazer a estimação sem divisão;\n'];
    texto = [texto '\n\nOpçao:'];
    escolhadiv = input(texto);
    fprintf('\n\n');
end

% -------------------------------------------------------------------------
% a.2) Obtém lista com todas as barras do circuito. Gera lista na qual as
% barras de medição estão marcadas com '**' e as barras do alimentador com
% '***'. Além disso gera lista na qual a nomenclatura das barras está
% marcada com o número da área de medição à qual pertencem.
% -------------------------------------------------------------------------
% Obtendo as barras de duas formas pois na versão do OpenDSS que peguei
% essas duas variáveis tinham diferenças.
nodesODSS1 = [DSSCircuit.YNodeOrder,DSSCircuit.AllNodeNames];
% Ps: a função organizabus modifica o vetor divpoints
[YNodeOrder, divpoints, subredes] = organizebus(barraVmed,DSSCircuit,...
                                              DSSElement,DSSSolution,...
                                              divpoints);
if(escolhadiv==1)
    node_order = sortrows(YNodeOrder(:,3));
    % Lista de barras que considera a área de medição
else
    node_order = sortrows(YNodeOrder(:,1));
    % Lista de barras que desconsidera a área de medição
end

% -------------------------------------------------------------------------
% a.3) Conta quantos nós de medição de tensão existem, contando as fases em
% cada barra.
% -------------------------------------------------------------------------
ptos_medV = size(find(not(cellfun('isempty',strfind(node_order,'*_')))),1)-3;
ptos_medSource = size(find(not(cellfun('isempty',strfind(node_order,'***_')))),1);

% -------------------------------------------------------------------------
% b) Aquisição e ordenação da matriz Y
% -------------------------------------------------------------------------
if(escolhadiv==1)
    Ysistema_list = montaY(DSSCircuit,YNodeOrder(:,3),node_order);
    % Considerando as áreas de medição, de modo a quebrar a matriz
    % posteriormente.
else
    Ysistema_list = montaY(DSSCircuit,YNodeOrder(:,1),node_order);
    % Desconsiderando as áreas de medição
end

% -------------------------------------------------------------------------
% c) Aquisição e ordenação dos vetores V e I
% -------------------------------------------------------------------------
[Vorder Iorder] = monta_V_e_I(DSSCircuit,YNodeOrder,Ysistema_list,escolhadiv);

% -------------------------------------------------------------------------
% d) Geracao de uma lista com principais dados sobre as cargas. Ps: verify
% é uma variável utilizada para verificar erros na montagem da matriz de
% admitâncias nodais. Será utilizada como entrada de outra função
% posteriormente.
% -------------------------------------------------------------------------
[Load verify] = defineLoad(DSSCircuit,DSSElement,DSSCktElement,DSSLoads,...
                           node_order,barraVmed,barras,escolhadiv);
Load = ungroupLoad(Load,Vorder);

% -------------------------------------------------------------------------
% e) Estimacao correta - Valor a ser encontrado pelo Pattern Search -
% Obtido para fins de avaliação da função otimizadora
% -------------------------------------------------------------------------
[Yraiz Zraiz Ypos] = defineYRoot(Load);
Sraiz = cell2mat(Load(2:end,11:12));

% -------------------------------------------------------------------------
% f) Geração de uma lista com os principais dados sobre o equivalente de
% Thevenin na subestação e sobre os pontos de medição de corrente
% -------------------------------------------------------------------------
[medI_list ptos_medI] = defineMedI(DSSCircuit,DSSElement,Vorder,barraVmed,...
                         elemImed,node_order,barras,escolhadiv);

% -------------------------------------------------------------------------
% g) Geração de uma lista com os principais dados sobre os transformadores,
% para construir restrição de carregamento
% -------------------------------------------------------------------------
trafoList = defineTrafos(DSSCircuit,DSSElement,node_order,barras,escolhadiv);

% -------------------------------------------------------------------------
% 5. Roda circuito  sem as cargas e importa a matriz Y sem
% cargas
% -------------------------------------------------------------------------
% a) Roda o arquivo sem as cargas, roda o fluxo de potência e define a
% ordem dos nós
% -------------------------------------------------------------------------
% a.1) Roda o arquivo  sem as cargas e instancia alguns objetos
% necessários
% -------------------------------------------------------------------------
% Remove as cargas do sistema
DSSText.command = 'batchedit Load..* enabled=no';
% Modifica o modelo das cargas como impedância constante
DSSText.command = 'batchedit Load..* model=2';
% Desabilita todos os reguladores de tensão
DSSText.command = 'batchedit RegControl..* enabled=false';
DSSSolution.Solve;

% -------------------------------------------------------------------------
% a.2) Recebe lista com ordem e nome dos nós e a modifica, para que na
% ordenação, os nós referentes às barras da subestação estejam em primeiro
% lugar, os nós referentes às derivações estejam logo depois.
% -------------------------------------------------------------------------
nodesODSS2 = [DSSCircuit.YNodeOrder,DSSCircuit.AllNodeNames];
nodes = organizebus(barraVmed,DSSCircuit,DSSElement,DSSSolution,divpoints(1,2:end));

% -------------------------------------------------------------------------
% b) Aquisição e ordenação da matriz Y
% -------------------------------------------------------------------------
if(escolhadiv==1)
    Yrede_list = montaY(DSSCircuit,nodes(1:end,3),node_order);
else
    Yrede_list = montaY(DSSCircuit,nodes(1:end,1),node_order);
end

% -------------------------------------------------------------------------
% 6. Obtém a matriz de cargas a partir das matrizes com carga e sem carga
% do sistema, monta a mesma matriz de outra forma, a partir das admitâncias
% das cargas individuais, para comparação e calcula o erro, para fins de
% debug. O erro é dado pela variável YLoadError.
% -------------------------------------------------------------------------
[Yload_list YLoadError] = defineYLoadError(Ysistema_list,Yrede_list,Load,...
                                      node_order,verify);
clear verify;

% -------------------------------------------------------------------------
% 7. Exportacao dos principais valores para arquivo matrizes.mat na
% pasta que contem o arquivo main_program, além de exclusão de variáveis
% auxiliares
% -------------------------------------------------------------------------
% clearvars verify;
cd(pasta_atual);
save matrizes.mat barras Vorder Iorder Yrede_list Ysistema_list ...
                  Yload_list medI_list node_order Load Yraiz ...
                  Zraiz Ypos ptos_medV ptos_medI ptos_medSource ...
                  barraVmed elemImed divpoints subredes YLoadError...
                  trafoList Sraiz name escolhadiv
fprintf('Dados principais gerados.\n');

% -------------------------------------------------------------------------
% 8. Limpa o workspace deixando apenas variáveis necessárias a outros
% processos
% -------------------------------------------------------------------------
if(~exist('mainset')) % se estiver rodando standalone
    clearvars -except escolhadiv;
else % mainset criada em main_program, gera_dados foi chamado por main_program
    clearvars -except mainset pasta_atual escolhadiv;
end

% -------------------------------------------------------------------------
% 9. Dadas certas condições, oferece possibilidade para subdividir o
% sistema
% -------------------------------------------------------------------------
pause(1);
if(escolhadiv==1)
    run('divideSystems.m');
    clear escolhadiv
end

fclose all;
clear ans;

%{
Ps: conteudo do arquivo matrizes.mat:

barras: contém o número de barras do circuito simulado

Vorder: tensoes nodais em todas as barras, com os nos na ordem
demonstrada no vetor node_order

Iorder: correntes injetadas em cada no, com os nos na ordem
demonstrada no vetor node_order. Na pratica, apenas as correntes na
subestacao sao nao nulas.

Yrede_list: matriz de admitancia do sistema sem as cargas, com os nos na ordem
demonstrada no vetor node_order

Y_sistema: matriz de admitancia do sistema com as cargas, com os nos na ordem
demonstrada no vetor node_order

Yload_list: diferenca entre a matriz de sistema e de rede

medI_list: lista dos elementos com medição de corrente. Para cada elemento,
armazena a matriz de admitância do elemento, as barras em que está
conectado, o subsistema a que pertence (no caso de divisão por áreas de
medição), a localização das barras em que está conectado dentro da matriz
de admitâncias nodais; corrente e potência medidos em cada terminal do
elemento.

node_order: lista dos nos do sistema ordenados de forma crescente e
conveniente. Se o circuito estiver dividido em subredes, os nós estarão
ordenados por subrede. Se contiver pontos de medição, estarão ordenados
após as barras da fonte de tensão.

Load: tabela com informacoes sobre as cargas. Para cada carga, armazena o
subsistema á que pertence, as barras em que estão conectadas, a tensão e a
potência nominal, a conexão, a posição na matriz de admitâncias nodais; a
matriz de admitância do elemento de rede carga; os elementos que definem
essa matriz de admitância (cargas equilibradas são definidas por apenas 1
elemento); potência ativa e reativa consumidas pela carga em questão.

Yraiz: vetor com admitâncias das cargas que deverá ser encontrado pela
estimação de carga em uma estimação perfeita

Zraiz: vetor com impedâncias das cargas que deverá ser encontrado pela
estimação de carga em uma estimação perfeita

Sraiz: vetor com potência das cargas que deverá ser encontrado pela
estimação de carga em uma estimação perfeita

Ypos: posição de cada uma das cargas de Yraiz dentro da matriz de
admitâncias nodais. Serve para o algoritmo montar a matriz de rede a partir
de cada estimação de carga;

ptos_medV: quantidade de pontos em que há medição de tensão;

ptos_medI: quantidade de pontos em que há medição de corrente;

ptos_medSource: quantidade de fases na fonte.

barraVmed: lista de barras com medições de tensão

elemImed: lista com elementos de rede com medição de corrente

name: string que representa o nome do circuito (IEEEx tal que x é o número
de barras)

divpoints: lista de pontos da rede em que existe medição de tensão e
corrente. Pode ser utilizado para dividir o circuito em áreas de medição,
de modo a facilitar a estimação de carga.

escolhadiv: assume o valor 1 se o usuário escolheu dividir o sistema em
áreas de medição e valor 0 caso contrário

subredes: array de listas aonde cada lista contém as barras pertencentes a
uma área de medição;

trafoList: lista com os transformadores do sistema. Para cada trafo,
armazena a potência nominal em kva, matriz de admitância dos elementos,
barras em que está conectado, subsistema que abrange cada barra, posição
dessas barras na matriz Y;

YLoadError: número que indica o erro cometido na montagem das matrizes.
Advém da comparação entre duas montagens da matriz de admitâncias da rede
de formas diferentes.
%}
