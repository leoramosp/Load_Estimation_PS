% Funcao utilizada no main_program, utilizada com o metodo do pattern
% search. Monta a matriz de admitância do sistema a partir do vetor de
% admitância das cargas, realiza a redução de Kron e avalia a função
% objetivo

function [f] = opti_ybus(solution,   ... % Vetor de admitância das cargas
                         Vmed,       ... % Medicoes de tensao (tensao em todos os nos) - Complexo
                         Imed,       ... % Medicao de corrente na subestacao e derivações
                         Inodes,     ... % Vetor de correntes nodais
                         Ynet,       ... % Matriz de admitancia 41 x 41 da rede sem as cargas
                         Ysys,       ... % Matriz de admitancia 41 x 41 da rede com as cargas (para debug)
                         Yposition,  ... % Célula com as posições de cada carga dentro de Ysys
                         Yprimaria,  ... % Matrizes de admit. nodal da fonte e dos elementos com medição de I.
                         n1,         ... % Numero de medições de tensão no alimentador
                         n2,         ... % Numero de medições de tensão, exceto no alimentador
                         const,      ... % Constante para ampliar o campo de entrada
                         version,    ... % versão da função de otimização
                         dominio)        % 1 para dominio das admitâncias e 2 para impedâncias
% PS: O vetor solution contem potencias ativas na primeira coluna e
% reativas na segunda coluna, as cargas estao de acordo com a ordem
% crescente das nomenclaturas dos nos, assim como descrito na variavel
% Yload.
% -------------------------------------------------------------------------
% 0) Adaptação do vetor do domínio (impedância ou admitância)
% -------------------------------------------------------------------------
sol = solution';
dim = size(sol,1)/2;
sol = [sol(1:dim,1), sol(dim+1:end,1)];

switch dominio
    case 1
        Ysol = complex(sol(:,1),sol(:,2));
        Ysol  = (1/const)*Ysol;
    case 2
        Zsol = complex(sol(:,1),sol(:,2));
        Zsol  = (1/const)*Zsol;
        Ysol = 1./Zsol;
end

% -------------------------------------------------------------------------
% 1) Inclusão das cargas na matriz Ynet
% -------------------------------------------------------------------------
% 1.1) Matriz de cargas estimada
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
% 2) Redução de Kron
% -------------------------------------------------------------------------

% if(version==7)
%     m=n1;
% else
%     m=n1+n2;
% end
% m=n1+n2;
m=3;
A = Y(1:m,1:m);
B = Y(1:m,m+1:end);
C = Y(m+1:end,1:m);
D = Y(m+1:end,m+1:end);
Ylinha = A - B*inv(D)*C;

% -------------------------------------------------------------------------
% 3) Solução do sistema A*x = b
% -------------------------------------------------------------------------
switch version
    case {1,3,5,7,9,11,13,15}
        Icalc = Ylinha * Vmed(1:m);
    case {2,4,6,8,10,12,14,16}
        Ecalc = Ylinha\Inodes(1:m);
end

% -------------------------------------------------------------------------
% 3) Cálculo da corrente medida na saída do alimentador
% -------------------------------------------------------------------------
% if(version == 3 || version == 4)
%     Ysource = Yprimaria{1};
%     Ialim = Icalc(1:3,1) - Ysource(4:6,4:6)*Vmed(1:3,1);
% end

% -------------------------------------------------------------------------
% 4) Cálculo da corrente nos pontos de medição de corrente
% -------------------------------------------------------------------------

if(size(Yprimaria,1) > 1)
    Vcalc = Y\Inodes;
    aux=0;
    corrente=0;
    index = [];
    Imedcalc = [];
    for aux=2:size(Yprimaria,1)
        index = [Yprimaria{aux,3};Yprimaria{aux,2}];
        corrente = Yprimaria{aux,1}*Vcalc(index);
        Imedcalc = [Imedcalc; corrente(1+size(corrente,1)/2:size(corrente,1),1)];
    end
%     Imedcalc = [Ialim;Ider];
end

% -------------------------------------------------------------------------
% 5) Cálculo das diferenças entre valores medidos e calculados
% -------------------------------------------------------------------------

switch version
    case {1,3,5,7,9,11,13,15}
        delta1 = Inodes(1:m) - Icalc(1:m);
        if(size(Yprimaria,1) > 1)
            delta2 = Imed(4:end,1) - Imedcalc;
            delta = [delta1;delta2];
            reference = [Inodes(1:m);Imed(4:end,1)];
        else
            delta = delta1;
            reference = Inodes(1:m);
        end    
    case {2,4,6,8,10,12,14,16}
        delta1 = Vmed(1:m) - Ecalc(1:m);
        if(size(Yprimaria,1) > 1)
            delta2 = Imed(4:end,1) - Imedcalc;
            delta = [delta1;delta2];
            reference = [Vmed(1:m);Imed(4:end,1)];
        else
            delta = delta1;
            reference = Vmed(1:m);
        end
end
%Ps: em Imed(4:end,1) assumo que a fonte tem três fases, três medições.
% delta = [real(delta);imag(delta)];

% -------------------------------------------------------------------------
% 6) Definição da função de otimização
% -------------------------------------------------------------------------

switch version
    case {1,2}
        f = abs(delta);
    case {3,4}
        f = abs([real(delta);imag(delta)]);
    case {5,6}
        f = abs(delta)./abs(reference);
    case {7,8}
        f = abs([real(delta);imag(delta)])./abs([real(reference);imag(reference)]);
    case {9,10}
        f = abs(real(delta));
    case {11,12}
        f = abs(imag(delta));
    case {13,14}
        f = abs(real(delta))./abs(real(reference));
    case {15,16}
        f = abs(imag(delta))./abs(imag(reference));
end
f = max(f);
% f = - 1/(f^5);