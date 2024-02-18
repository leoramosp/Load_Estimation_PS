% Dado um vetor "Yest" com as admitâncias estimadas, utiliza as informações
% de conexão e posição das cargas da tabela de cargas "Carga" para montar a
% matriz de admitância nodal das cargas e acrescentá-la à matriz "Ynet" de
% admitância da rede sem as cargas. Depois, utiliza o vetor de correntes
% injetadas/medidas no alimentador para obter uma estimativa das tensões
% nodais e assim calcular as tensões nodais "Vest" em todas as barras. Com
% esse resultado, estimar a potência dissipada nas cargas "Sest" a partir
% da fórmula Sest = 0.001*abs(Vest)^2*Yest. Essa função trabalha com a hipótese
% de cargas monofásicas ou bifásicas. S dado em kVA.
% 1 - Montar a matriz do sistema a partir das admitâncias estimadas
% 2 - Calcular as tensões nodais estimadas
% 3 - Uilizar essas tensões para calcular a potência juntamente com a
% admitância estimada.
function [Sest] = defineS(Carga,... % Lista de cargas
                             Iordem,...% Vetor de correntes injetadas
                             Yest,...  % Vetor com admitâncias estimadas
                             Ynet)     % Matriz de admitância nodal da rede sem cargas
Sest = [];
Ypos = Carga(2:end,8);
Yl = defineYLoad(Yest,Ynet,Ypos);
Ysist = Ynet + Yl;
Vest = Ysist\Iordem;
for aux1 = 1:size(Ypos,1)
    conection = Carga{aux1+1,6};
    if(strcmp(conection,'Fase-Terra'))
        position1 = Ypos{aux1,1}(1,1);
        admitance = complex(Yest(aux1,1),Yest(aux1,2));
        ddp = Vest(position1,1);
        Sest = [Sest; conj((abs(ddp)^2)*admitance)];
    else
        position1 = Ypos{aux1,1}(1,1);
        position2 = Ypos{aux1,1}(3,1);
        admitance = complex(Yest(aux1,1),Yest(aux1,2));
        ddp = Vest(position1,1) - Vest(position2,1);
        Sest = [Sest; conj((abs(ddp)^2)*admitance)];
    end
end
Sest = 0.001*[real(Sest) imag(Sest)];