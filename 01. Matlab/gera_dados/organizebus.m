% A função organizebus tem o propósito de modificar a nomenclatura das barras
% nativa do OpenDSS de modo a:
% 1 - permitir identificação de modo simples do alimentador, dos pontos de 
% medição de corrente, de tensão e do subsistema ao qual a barra faz parte 
% (no caso de áreas de medição)
% 2 - permitir que as barras possam ser ordenadas, a partir do comando 
% sortrows, de modo que as barras do gerador fiquem nas primeiras posições 
% e as barras de medição de tensão fiquem logo em seguida
% 3 - quando houver mais de uma área de medição, as barras devem ser 
% ordenadas, a partir do comando sortrows, de modo que as barras da área 
% de medição 1 fiquem nos primeiros lugares, seguidas pelas barras da área 
% de medição 2 e assim por diante
% 4 - dentro de cada área de medição, as barras devem ser ordenadas de acordo
% com o ítem 2, sendo o gerador substituído pela medição principal, que dá
% origem a área de medição em questão
% Para isso, a estrutura geral de nomenclatura das listas será adotada
% da seguinte forma: (SS)_(MA/MT)_(Barra).(Fase) ou (SS)_(Barra).(Fase), 
% aonde:
% SS = Subsistema, indica a área de medição na qual se encontra a barra.
% Caso o sistema não for dividido em áreas de medição, SS será igual a 01
% para todas as barras. A correspondência entre cada barra e sua área de
% medição é feita a partir da matriz de incidência da rede e do fato dela
% ser radial.
% MA/MT = Marcação de alimentador/Marcação de medição de tensão, indica se
% a barra pertence ao alimentador do sistema/área de medição ou se a barra
% possui medição de tensão. 
% 1 - Se for barra de alimentador/gerador MA/MT = '***'.
% 2 - Se for barra com medição de tensão apenas, MA/MT = '*_(tag_ordem)'
% Ps: (tag_ordem) é um número de dois dígitos para ordenar as
% barras conforme ordenação da lista medVODSS.
% 3 - Se for barra com medição de tensão e houver elemento com medição de
% corrente tal que a corrente incide naquela barra, este poderá ser um
% ponto de divisão do circuito em áreas de medição. Nesse caso.
% MA/MT = '**_(tag_ordem)'.
% Ps: (tag_ordem) é um número de dois dígitos para ordenar as
% barras conforme ordenação na lista medVODSS.
% 4- Caso a barra não for nem de alimentação e nem contiver medição de 
% tensão esse marcador será ausente na nomenclatura,  MA/MT = '', a
% nomenclatura da barra será do tipo SS)_(Barra).(Fase).
% (Barra) - identificador da barra, como fornecido pelo OpenDSS, corrigido
% por um sistema de nomenclatura descrito em organizeNames.m
% (Fase) - 1 e/ou 2 e/ou 3, dependendo da fase do barramento que será
% utilizada. Quando mais de uma fase é utilizada, as fases são separadas
% por pontos (ex: 00670.1.2 refere-se as fases 1 e 2 da barra 00670).
function [f root_nodes subrede_parents] =  organizebus(barraV,...% Barras com medição de tensão
                                                       DSSCirc,... % Elemento DSSCircuit gerado pela interface COM
                                                       DSSElem,... % Elemento DSSCircuit gerado pela interface COM
                                                       DSSSol,...  % Elemento DSSCircuit gerado pela interface COM
                                                       divpoint)   % Pontos de divisão do sistema em áreas de medição
% -------------------------------------------------------------------------
% a) Obtém lista com todas as barras do circuito e organiza a nomenclatura
% -------------------------------------------------------------------------
nodesODSS = [DSSCirc.YNodeOrder,DSSCirc.AllNodeNames];
% função para padronizar a nomenclatura dos nós para qqr circuito
nodes = organizeNames(nodesODSS); 
% -------------------------------------------------------------------------
% b.1) Recebe lista com nós da matriz de incidência, já aplicando a
% nomenclatura padronizada
% -------------------------------------------------------------------------
incColODSS = DSSSol.IncMatrixCols; % recebe lista de nós da M.Inc.
incCol = organizeNames(incColODSS); % aplica nomenclatura padronizada
% -------------------------------------------------------------------------
% b.2) Recebe lista com nós de outra variável do OpenDSS e aplica a
% nomenclatura padronizada. Isso foi necessário porque a ordem das barras
% entre essas variáveis se alterava na versão do OpenDSS utilizada.
% Essa lista de barras será utilizada nas funções extras (tópico h)
% -------------------------------------------------------------------------
BusNamesODSS = DSSCirc.AllBusNames; % recebe lista de barras de terceira fonte
BusNames = organizeNames(BusNamesODSS); % aplica nomenclatura padronizada
% -------------------------------------------------------------------------
% c) Obtém os nós referentes à fonte de tensão e aplica a nomenclatura
% padrão
% -------------------------------------------------------------------------
DSSCirc.SetActiveElement(['VSOURCE.SOURCE']);
fontenos = organizeNames(DSSElem.BusNames(1)); % aplica nomenclatura correta
% -------------------------------------------------------------------------
% d) Renomeia os nós da fonte e dos pontos de medição
% -------------------------------------------------------------------------
% d.1) Renomeia os nós da fonte acrescentando a string ***_ antes do nome
% -------------------------------------------------------------------------
nodes = regexprep(nodes,fontenos{1},['***_' fontenos{1}]);
% -------------------------------------------------------------------------
% d.2) Renomeia os nós de medição de tensão acrescentando a string **_
% antes do nome caso for um ponto de divisão do circuito (for um ponto ao
% qual a medição de corrente também se aplica) ou acrescentando a string *_
% caso não for um ponto de divisão do circuito.
% Ps: a função lower coloca os caracteres do alfabeto em letra minúscula
% para facilitar a comparação no-case-sensitive entre strings.
% -------------------------------------------------------------------------
medV = organizeNames(barraV);
aux2 = 0;
aux3 = 0;
for aux=1:size(medV,2)
    % procura os pontos da lista de medição na lista de pontos de divisão 
    % do circuito
    index = strfind(lower(divpoint),lower(medV{aux}));
    index = find(~cellfun(@isempty,index));
    if(~isempty(index)) % caso encontrar, insere a marcação MT/MA correspondente (**)
        aux2 = aux2 + 1;
        if(aux2<10)
            nodes = regexprep(nodes,medV{aux},['**_0' num2str(aux2) '_' medV{aux}]);
        else
            nodes = regexprep(nodes,medV{aux},['**_' num2str(aux2) '_' medV{aux}]);
        end
    else % caso não encontrar, insere a marcação MT/MA correspondente (*)
        aux3 = aux3 + 1;
        if(aux<10)
            nodes = regexprep(nodes,medV{aux},['*_0' num2str(aux3) '_' medV{aux}]);
        else
            nodes = regexprep(nodes,medV{aux},['*_' num2str(aux3) '_' medV{aux}]);
        end
    end
end

% -------------------------------------------------------------------------
% d) Constrói a matriz de incidência IncList em forma de lista para
% determinar as barras de cada área de medição;
% Ps: A matriz de incidência vem do OpenDSS na forma de vetor-linha, cada três
% colunas representam um único elemento diferente de zero dessa matriz. A
% notação para cada elemento é: [linha coluna incidência], onde "linha" e
% "coluna" são os números da linha e da coluna na matriz e incidência é
% a condição de incidência entre o elemento correspondente à linha e a
% barra correspondente à coluna (-1 ou 1). Depois de todos os elementos não
% nulos, a matriz vem com um zero adicional que representa o fim da cadeia
% de caracteres numéricos.
% -------------------------------------------------------------------------
IncTab = DSSSol.IncMatrix; % obtém a matriz de incidência do OpenDSS
IncTab = IncTab(1:(length(IncTab)-1)); % despreza o zero adicional
IncTab = reshape(IncTab,3,[])'; % reorganiza a matriz em 3 colunas
incLine = DSSSol.IncMatrixRows; % obtém os elementos representados pelas linhas de IncList
lines = size(incLine,1);
colum = size(incCol,1);
IncMatrix = zeros(lines,colum); % esqueleto da matriz de incidência
for aux2=1:size(IncTab,1)
    IncMatrix(IncTab(aux2,1)+1,IncTab(aux2,2)+1)=IncTab(aux2,3); % preenche as posições da matriz
end
IncList = [ '#' incCol'; incLine num2cell(IncMatrix)]; % armazena a matriz e os nomes como uma lista

% -------------------------------------------------------------------------
% e) Determina a barra do alimentador (raiz) em IncList
% -------------------------------------------------------------------------
for aux=2:size(IncList,2)
    index=find(IncMatrix(:,aux-1)==-1); % procura por -1 em cada coluna
    if(isempty(index))  % barra do alimentador é a única barra cuja coluna não contem -1
        root_node = IncList(1,aux);
    end
end

% -------------------------------------------------------------------------
% f) A partir dos pontos de divisão do circuito, dado pela lista divpoint,
% divide a lista de barras incCol em listas de barras por área de medição
% e armazena essas listas no list array subrede_parents
% -------------------------------------------------------------------------
root_nodes = [root_node divpoint]; % lista com as barras raiz em cada subrede
list_connections = {};
for aux=1:size(root_nodes,2) % Percorre todas as barras em root nodes
    list_parents = root_nodes(aux); % list_parents armazena cada subrede temporariamente, a primeira barra é a que está em root_nodes
    for aux2=1:size(IncMatrix,2) % aux2 percorre, no máximo, as barras nas colunas de IncMatrix (na horizontal)
        if(aux2<=size(list_parents,1)) % porém, aux2 não pode passar o tamanho da subrede
            father = list_parents{aux2}; % toma uma barra como barra-pai
            index = strfind(lower(root_nodes),lower(father)); % verifica se a barra-pai está em root_nodes
            index = find(~cellfun(@isempty,index)); % e descobre nesta linha, caso estiver nada é feito e a próxima barra em list_parents é selecionada
            if(isempty(index) || aux2 == 1) % caso não for raiz ou caso seja raiz, mas seja a barra do alimentador principal (aux2=1)
                index = strfind(lower(IncList(1,:)),lower(father)); % procura a coluna da barra pai em incList
                index = find(~cellfun(@isempty,index)); % descobre a coluna da barra pai em IncList
                sun_lines = find(IncMatrix(:,index-1)==1); % sun_lines são as linhas dos elementos que saem da barra pai
                if(~isempty(sun_lines)) % caso houverem linhas que saem da barra-pai
                    for aux3 = 1:size(sun_lines,1) % aux3 percorre todos os elementos em cada sun_line
                        sun_colum = find(IncMatrix(sun_lines(aux3),:)==-1); % procura a barra aonde esses elementos chegam (-1)
                        for aux4=1:size(sun_colum)
                            sun = IncList{1,sun_colum(aux4)+1};   % a coluna aonde os elementos incidem revela as barras filho
                            index = strfind(lower(list_parents),lower(sun)); % verifica se a barra filho já consta na lista da subrede
                            index = find(~cellfun(@isempty,index)); % caso constar, descobre a posição em que consta
                            if(isempty(index)) % caso não constar, a barra será adicionada a subrede
                                list_parents = [list_parents; sun];
                                list_connections = [list_connections; {father, sun}];
                            end
                        end
                    end
                end
            end
        end
    end % O loop só é abandonado se chegar em uma barra raiz de outra subrede
    subrede_parents{1,aux}=list_parents; % subrede_parents é lista com todas as subredes e conexões.
    subrede_parents{2,aux}=list_connections;
    list_parents={}; % esvazia list_parents para guardar a próxima subrede
end
% Obs: note que as barras de divisão em áreas de medição fazem parte de
% duas subredes, estarão em duas listas
% -------------------------------------------------------------------------
% g) Cria uma lista de barras e fases, nos moldes de nodes, porém dividindo
% a lista por áreas de medição
% -------------------------------------------------------------------------
% g.1) Utiliza a variável list_parents para criar uma lista de barras com
% separação por área de medição
% -------------------------------------------------------------------------
for aux = 1:size(subrede_parents,2)
    list_parents = [list_parents; subrede_parents{1,aux}];
end
% -------------------------------------------------------------------------
% g.2) Constrói uma terceira coluna na variável nodes similar a primeira,
% porém marcando as barras com as respectivas áreas de medição. Utiliza-se,
% para isso, da variável subrede_parents
% As barras de divisão estarão em duas subredes, porém o algoritmo vai
% colocá-las nas subredes com índice maior
% -------------------------------------------------------------------------
nodes(1:end,3)=cell(size(nodes,1),1);
for aux = 1:size(subrede_parents,2) % percorre todas as listas de barras de subrede
    for aux2 = 1:size(subrede_parents{1,aux},1) % em cada subrede, percorre todas as barras
        index=strfind(lower(nodes(:,1)),lower(subrede_parents{1,aux}{aux2,1})); % procura cada nó em cada subrede na lista de nós do circuito geral
        index = find(~cellfun(@isempty,index)); % encontra as posições dessas barras na lista de nós do circuito geral
        for aux3=1:size(index,1) % percorre todas as posições em que a barra da subrede foi encontrada
            nodes{index(aux3,1),3} = ['0' num2str(aux) '_' nodes{index(aux3,1),1}]; % coloca o prefixo da subrede no nome e guarda na coluna 3 de nodes
        end
    end
end
% -------------------------------------------------------------------------
% g.2) Constrói uma quarta coluna na variável nodes similar a segunda, porém
% marcando as barras com as respectivas áreas de medição
% -------------------------------------------------------------------------  
nodes(1:end,4)=cell(size(nodes,1),1);
for aux = 1:size(subrede_parents,2)
    for aux2 = 1:size(subrede_parents{1,aux},1)
        index=strfind(lower(nodes(:,2)),lower(subrede_parents{1,aux}{aux2,1}));
        index = find(~cellfun(@isempty,index));
%         if(isempty(index))
%             index=strfind(nodes(:,2),upper(subrede_parents{1,aux}{aux2,1}));
%             index = find(~cellfun(@isempty,index));
%         end
        for aux3=1:size(index,1)
            nodes{index(aux3,1),4} = ['0' num2str(aux) '_' nodes{index(aux3,1),2}];
        end
    end
end

% -------------------------------------------------------------------------
% h) Extra: Nível das barras e distância do alimentador
% -------------------------------------------------------------------------  
% h.1) Relaciona cada barra à sua distância do alimentador
% -------------------------------------------------------------------------  
BLevels = DSSSol.BusLevels;
% creates a table with the data
myBLTable = [];
for i = 1:size(BusNames),
    myBLTable = [myBLTable; [BusNames(i,1),num2str(BLevels(1,i))]];
end;
myBLTable = sortrows(myBLTable,2);

% -------------------------------------------------------------------------
% h.2) Acrescenta a informação de distância de cada barra da primeira
% coluna ao alimentador em nodes, construindo uma quinta coluna
% -------------------------------------------------------------------------  
nodes(1:end,5)=cell(size(nodes,1),1);
for aux = 1:size(BusNames,1)
    index=strfind(lower(nodes(:,1)),lower(BusNames{aux,1}));
    index = find(~cellfun(@isempty,index));
%     if(isempty(index))
%         index=strfind(nodes(:,1),upper(BusNames{aux,1}));
%         index = find(~cellfun(@isempty,index)); 
%     end
    for aux2=1:size(index,1)
        nodes(index(aux2,1),5) = myBLTable(aux,2);
    end
end
% -------------------------------------------------------------------------
% h.3) Acrescenta a informação de distância de cada barra da segunda
% coluna ao alimentador em nodes, construindo uma sexta coluna
% ------------------------------------------------------------------------- 
nodes(1:end,6)=cell(size(nodes,1),1);
for aux = 1:size(BusNames,1)
    index=strfind(lower(nodes(:,2)),lower(BusNames{aux,1}));
    index = find(~cellfun(@isempty,index));
%     if(isempty(index))
%         index=strfind(nodes(:,2),upper(BusNames{aux,1}));
%         index = find(~cellfun(@isempty,index)); 
%     end
    for aux2=1:size(index,1)
        nodes(index(aux2,1),6) = myBLTable(aux,2);
    end
end

f = nodes;
% As saídas da função são:
% f - lista de barras como indicado no cabeçalho. Possui 6 colunas, as
% colunas 1, 3 e 5 se baseiam no vetor DSSCircuit.YNodeOrder enquando a 2,
% 4 e 6 se baseiam no vetor DSSCircuit.AllNodeNames. A quinta e sexta
% coluna são uma função experimental do OpenDSS, que calculam a distância
% entre a barra e o alimentador.
% root_nodes - lista com barras raiz de cada uma das subredes. Se o
% circuito não estiver dividido em áreas de medição, essa lista vai conter
% apenas a barra do alimentador principal
% subredes - lista com barras em cada uma das subredes definidas pelos
% pontos de medição de tensão e corrente. Se não houver divisão do circuito
% em áreas de medição, essa lista visa conter apenas a rede principal.