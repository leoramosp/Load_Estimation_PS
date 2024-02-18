% Calcula a potência em cada carga a partir dos valores estimados.
function [Sl] = defineSLoad(Yest,...        % vetor ordenado com a admitância complexa das cargas estimadas
                            Ynet,...        % matriz de admitância da rede sem cargas
                            Yposition,...   % coluna da lista de cargas com as posições das cargas dentro da matriz de rede
                            Inodes)         % vetor de correntes injetadas nos nós
Ylestimado = defineYLoad(Estimado,Yrede,dados.Ypos);
Ysist_est = Ylestimado + Yrede;
Vestimado = Ysist_est*Iinj;
Vload = [];
for count = 1:size(Yposition,1)
    position = Yposition{count,1};
    sqrphases = size(position,1);
    switch sqrphases
        case 1
            Vload = [Vload; Vestimado(position(1,1),1)];
        case 4
            Vload = [Vload; ...
                     Vestimado(position(1,1),1) - Vestimado(position(4,2),1)];
    end
end
Yload = complex(Estimado(:,1),Estimado(:,2));
Iload = Vload.*Yload;
Sload = Vload*conj(Iload);
