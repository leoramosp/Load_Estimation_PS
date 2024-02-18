% Verifica se existem pontos do circuito nos quais se medem tensão e
% corrente, analisando os vetores barraV e elemI.
% Determina os pontos a partir dos quais o sistema radial pode ser dividido
% em áreas de medição, de modo a particionar a solução do sistema.
% 
% É convencionado que a medição de corrente em um elemento acontece sempre
% no terminal 2.
function divpontos = obtainDivPoints(DSSElem,... % Objeto DSSElement, da interface COM
                                     barraV,...  % Lista com barras de medição de tensão
                                     elemI)      % Lista com elementos com medição de corrente
divpontos = {};
for aux2=1:size(elemI,2) % percorre a lista de elementos com medição de corrente
    % seleciona o elemento de medição de corrente dentro da estrutura
    % DSSCirc
    eval(['DSSCirc.SetActiveElement([' '''' 'Line.' elemI{aux2} '''' ']);']);
    % Obtém as barras as quais o elemento está conectado
    cell_aux = strsplit(DSSElem.BusNames{2},'.');
    BusName = organizeNames(cell_aux{1});
    % Procura essas barras na lista de pontos de medição de tensão
    index = strfind(organizeNames(barraV),BusName{1});
    index = find(~cellfun(@isempty,index));
    % Caso achar, acrescenta o ponto à lista de pontos que podem dividir o
    % sistema.
    if(~isempty(index))
        divpontos = [divpontos organizeNames(barraV(index))];
    end
end