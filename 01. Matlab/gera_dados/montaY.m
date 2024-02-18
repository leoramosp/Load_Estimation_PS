% O propósito da função abaixo é, a partir da variável do circuito
% simulado (DSSCirc) e do vetor com a ordem dos nós, gerar a matriz de
% admitâncias do circuito, na forma de números complexos e ordenar as
% linhas e colunas da matriz a partir da função sortrows, preservando sua
% característica simétrica.
% A saida da funcao tem a forma de lista, para facilitar a identificacao
% das admitancias referentes a cada no, para o caso de debug.
%{
Argumentos de entrada:
* DSSCirc - Elemento DSSCircuit, gerado pela interface COM
* nos - vetor de strings com a nomenclatura dos nós do circuito.
* nos_ordem - vetor de strings com a nomenclatura dos nós do circuito já 
              ordenado convenientemente.
%}
function [Ylist] = montaY(DSSCirc,nos,nos_ordem)
% -------------------------------------------------------------------------
% a) Confere a igualdade entre os vetores com nomenclatura dos nós para
% efeito de debug e indicar erros no algoritmo
% -------------------------------------------------------------------------

delta = size(nos_ordem,1) - size(nos,1);
if(delta>0)
    for aux=1:size(nos_ordem,1)
        index=strfind(lower(nos),lower(nos_ordem{aux}));
        index = find(not(cellfun('isempty',index)));
        if(isempty(index))
            nos = [nos; nos_ordem{aux}];
        end
    end
end

% -------------------------------------------------------------------------
% b) Montagem de Y como lista de modo a facilitar o debug
% -------------------------------------------------------------------------

Y = DSSCirc.SystemY;
aux = sqrt(size(Y,2)/2);
Xreal = reshape(Y(1:2:end),[aux,aux]);
Ximag = reshape(Y(2:2:end),[aux,aux]);
Y = complex(Xreal',Ximag');
if(delta>0)
    Y = [Y, zeros(size(Y,1),delta); zeros(delta,size(Y,2)),...
        zeros(delta,delta)];
end
Y = num2cell(Y);
Y = ['#Y' nos';nos Y];

% -------------------------------------------------------------------------
% b) Ordenação das linhas e colunas (ordem crescente dos nós)
% -------------------------------------------------------------------------
Ylist = sortrows(Y,1);
Ylist = Ylist';
Ylist = sortrows(Ylist,1);