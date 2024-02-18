% Função que obtém a matriz de admitância das cargas do sistema de duas
% formas, compara as duas e obtém o erro de 4 formas possíveis considerando
% a potência real com a calculada segundo estimação.
% Os argumentos da função são:
% Ysis_list - Matriz de admitância do sistema com as cargas, no formato de
% célula ou lista;
% Ynet_list - Matriz de admitância do sistema sem as cargas, no formato de
% célula ou lista;
% Carga - Tabela de informações sobre as cargas, saída da função defineLoad;
% no_ordem - Lista com nomenclatura dos nós devidamente ordenada a partir
% de 'sortrows'.
% verifica - soma das admitâncias de todas as cargas fase-terra. Essa soma
% deverá ser a soma de todos os elementos da matriz de admitâncias da carga
% do sistema. Também soma cargas trifásicas em estrela.
function [Ycarga_list Erro] = defineYLoadError(Ysis_list,Ynet_list,Carga,...
                                          no_ordem,verifica)
% -------------------------------------------------------------------------
% a) Calculo da matriz de cargas - ja com os nos ordenados de forma
% crescente - de acordo com no_ordem_ascending
% -------------------------------------------------------------------------
Y1 = Ysis_list(2:end,2:end);
Y1 = cell2mat(Y1);
Y2 = Ynet_list(2:end,2:end);
Y2 = cell2mat(Y2);
Ycarga = Y1 - Y2;
Ycarga_list = num2cell(Ycarga);
Ycarga_list = ['#Y' no_ordem';no_ordem Ycarga_list];

% -------------------------------------------------------------------------
% b) Teste para ver se consegue-se construir Ycarga a partir dos dados da
% lista de cargas. Note que Ycarga é uma matriz só com as cargas do
% circuito. Esse procedimento é diferente do adotado em opti_ybus, que
% busca construir a matriz do sistema a partir da matriz de rede sem as
% cargas. Esse busca reconstruir apenas a matriz de cargas (Yl - Y2) a
% partir de uma matriz nula e da tabela de cargas.
% -------------------------------------------------------------------------
% Yposition = Carga(2:end,8);
% Yl = zeros(size(Ynet_list,1)-1,size(Ynet_list,2)-1);
Ysol = Carga(2:end,10);
Ysol = cell2mat(Ysol);
Ysol = [real(Ysol),imag(Ysol)];
Yl = defineYLoad(Ysol,Y2,Carga(2:end,8));

% -------------------------------------------------------------------------
% c) Cálculo do Erro na montagem da matriz de cargas
% -------------------------------------------------------------------------
verifica2 = sum(sum(Ycarga));
verifica3 = sum(sum(Yl));
Ydiferenca = Ycarga - Yl;
Erro1 = max(max(abs(Ydiferenca)));
Erro2 = verifica - verifica2;
Erro3 = verifica - verifica3;
Erro4 = verifica2 - verifica3;
Erro = abs(max([Erro1 Erro2 Erro3 Erro4]));