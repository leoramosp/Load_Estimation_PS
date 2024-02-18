% Função que extrai da variável lista de cargas (Load) a admitância de cada
% uma das cargas e constrói o vetor de admitâncias que deverá minimizar a
% função objetivo. Também constrói o vetor com as posições ocupadas por
% cada uma das cargas dentro das matrizes de carga e do sistema.
% Assim, o número de elementos do vetor construído é igual ao número de 
% graus de liberdade da função de estimação de carga. Esse vetor deverá
% produzir um valor mínimo (desprezível) quando utilizando na função opti_ybus.
% Ele é necessário para avaliar a qualidade da estimação de carga feita 
% pelo Pattern Search.
% A modificação introduzida quanto à admitância da lista de cargas é que as
% cargas trifásicas, quando estiverem em estrela, devem ser modeladas
% utilizando-se a representação triângulo equivalente. Assim, neste caso,
% modifica-se as admitâncias entre fase e terra pelas admitâncias entre
% fases na configuração equivalente.
% Desse modo, a função objetivo, ao montar a matriz do sistema a partir do
% vetor de cargas estimadas, montará todas as cargas trifásicas na
% representação triângulo. A solução encontrada pelo Pattern Search deverá
% ser comparada com a representação em triângulo das cargas para produzir o
% erro.
% As cargas monofásicas, bifásicas e trifásicas em Delta são modeladas
% assim como na coluna Ycarga, da lista de cargas.
% Os argumentos de entrada são:
% * Carga - lista de cargas 'Load' armazenada em matrizes.mat
function [Y Z Yposition] = defineYRoot(Carga)
Ycomplex = [];
Yposition = [];
for aux=2:size(Carga,1)
    conection = Carga{aux,6};
    admitance = Carga{aux,10};
    position = Carga{aux,8};
    if(strcmp(conection,'3FN Wye')) % estrela isolada será modelada como triângulo
        ya = admitance(1,1);
        yb = admitance(2,1);
        yc = admitance(3,1);
        yab = (ya*yb)/(ya+yb+yc);
        ybc = (yb*yc)/(ya+yb+yc);
        yca = (yc*ya)/(ya+yb+yc);
        Ycomplex = [Ycomplex;yab;ybc;yca];
        Yposition = [Yposition; {position}];
    elseif(strcmp(conection,'3FT Wye'))
        Ycomplex = [Ycomplex;admitance];
        Yposition = [Yposition; {position(1,:)};{position(5,:)};{position(9,:)}];
    else
        Ycomplex = [Ycomplex;admitance];
        Yposition = [Yposition; {position}];
    end
end

Zcomplex = 1./Ycomplex;
Y = [real(Ycomplex) imag(Ycomplex)];
Z = [real(Zcomplex) imag(Zcomplex)];

