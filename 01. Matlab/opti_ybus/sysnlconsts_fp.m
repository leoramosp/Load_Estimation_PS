% Função de restrição com relação as tensões medidas. Esse arquivo contém
% todas as funções de restrição não lineares possíveis, enquanto o arquivo
% sysnlconsts.m contém apenas as que serão utilizadas pelo algoritmo.

function [c,ceq] =    sysnlconsts(x,         ... % Vetor de admitância das cargas
                                 Vmed,       ... % Medicoes de tensao (tensao em todos os nos) - Complexo
                                 Imedlist,   ... % Medicao de corrente na subestacao e derivações
                                 Vp,         ... % Medicoes de tensao (tensao em todos os nos) - Módulo em pu
                                 Inodes,     ... % Vetor de correntes nodais
                                 Ynet,       ... % Matriz de admitancia 41 x 41 da rede sem as cargas
                                 Yposition,  ... % Célula com as posições de cada carga dentro de Ysys
                                 Yprimaria,  ... % Matrizes de admit. nodal da fonte e dos elementos com medição de I.
                                 nomeVmed,   ... % Lista com Barras de medição de tensão.
                                 n1,         ... % Numero de medições de corrente
                                 n2,         ... % Numero de medições de tensão, exceto no alimentador
                                 trafList,   ... % Lista com dados de transformadores
                                 dominio)        % 1 para dominio das admitâncias e 2 para impedâncias
% PS: O vetor solution contem potencias ativas na primeira coluna e
% reativas na segunda coluna, as cargas estao de acordo com a ordem
% crescente das nomenclaturas dos nos, assim como descrito na variavel
% Yload.
% -------------------------------------------------------------------------
% 0) Inicialização das variáveis de restrição
% -------------------------------------------------------------------------
c = [];
ceq = [];
FPmin = 0.5;
Vpumax = 1.05;
Vpumin = 0.93;
m = 3+n2;
sol = x';
dim = size(sol,1)/2;
sol = [sol(1:dim,1), sol(dim+1:end,1)];

% -------------------------------------------------------------------------
% 1) Restrição para fator de potência mínimo
% -------------------------------------------------------------------------
fp = -sol(:,1) + FPmin*sqrt(sol(:,1).^2 + sol(:,1).^2);
c = [c; fp];
    
