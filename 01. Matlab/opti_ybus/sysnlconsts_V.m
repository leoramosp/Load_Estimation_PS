% Função de restrição com relação as tensões medidas. O conjunto com todas
% as funções de restrição possíveis encontra-se em sysnlconsts_reference.m

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
% 2) Construção da matriz de admitância para próximas restrições
% -------------------------------------------------------------------------
% 2.a) Adaptação do vetor do domínio (impedância ou admitância) e
% inicialização de algumas variáveis
% -------------------------------------------------------------------------
switch dominio
    case 1
        Ysol = complex(sol(:,1),sol(:,2));
    case 2
        Zsol = complex(sol(:,1),sol(:,2));
        Ysol = 1./Zsol;
end

% -------------------------------------------------------------------------
% 2.b) Inclusão das cargas na matriz Ynet
% -------------------------------------------------------------------------
Yl = zeros(size(Ynet,1),size(Ynet,2));
count2=1;
for count = 1:size(Yposition,1)
    position = Yposition{count,1};
    sqrphases = size(position,1);
    switch sqrphases
        case 1
            lin = position(1);
            col = lin;
            Yl(lin,col) = Yl(lin,col)+Ysol(count2,1);
            count2 = count2+1;
        case 4
            for count3 = 1:sqrphases
                lin = position(count3,1);
                col = position(count3,2);
                if(lin==col)
                    Yl(lin,col) = Yl(lin,col)+Ysol(count2,1);
                else
                    Yl(lin,col) = Yl(lin,col) - Ysol(count2,1);
                end
            end
            count2 = count2+1;
        case 9
            yab = Ysol(count2,1);
            ybc = Ysol(count2+1,1);
            yca = Ysol(count2+2,1);
            lin = position(1,1);
            col = position(end,2);
            Yl(lin:col,lin:col) = Yl(lin:col,lin:col) + ...
                                      [ yab+yca, -yab, -yca;...
                                      -yab ,yab+ybc, -ybc;...
                                      -yca , -ybc, yca+ybc];
            count2 = count2+3;
    end
end

Y = Ynet + Yl;

% -------------------------------------------------------------------------
% 3) Cálculo das tensões nodais
% -------------------------------------------------------------------------
Ecalc = Y\Inodes;
if(n2>0)
    % ---------------------------------------------------------------------
    % 4) Restrição para medição de tensão
    % ---------------------------------------------------------------------
    ceq = [ceq; abs(Ecalc(4:m)-Vmed(4:m))];
end
