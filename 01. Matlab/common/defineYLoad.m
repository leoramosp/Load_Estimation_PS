% Função que soma as admitâncias de carga presentes na matriz Yest à matriz
% de admitâncias de rede Ynet, retornando o resultado da soma. 
% A matriz real Yest tem dimensão n_l×2, aonde nl é o número de cargas. 
% As duas colunas são referentes às partes real e imaginária das admitâncias. 
% Cada linha da matriz contém a parte real e imaginária de uma das 
% admitâncias de carga. Passando-se as admitâncias para a forma complexa, 
% cada admitância é somada ao elemento cuja posição dentro da matriz Ynet
% é definida pelo vetor Yposition.
function [Yl] = defineYLoad(Yest,...        % vetor ordenado com a admitância em duas colunas [Re Im] das cargas estimadas
                            Ynet,...        % matriz de admitância da rede sem cargas
                            Yposition)      % coluna da lista de cargas com as posições
                                            % cargas dentro da matriz de
                                            % rede
% -------------------------------------------------------------------------
% b) Teste para ver se consegue-se chegar em Ycarga a partir dos dados de
% Carga
% -------------------------------------------------------------------------
Ysol = complex(Yest(:,1),Yest(:,2));
Yl = zeros(size(Ynet,1),size(Ynet,2));
count2 = 1;
for count1 = 1:size(Yposition,1)
    position = Yposition{count1,1};
    sqrphases = size(position,1);
    switch sqrphases
        case 1 % Carga monofásica
            lin1 = position(1,1);
            col1 = position(1,2);
            Yl(lin1,col1) = Yl(lin1,col1)+Ysol(count2,1);
            count2 = count2+1;
        case 4 % Carga bifásica
            for count3 = 1:sqrphases
                lin1 = position(count3,1);
                col1 = position(count3,2);
                if(lin1==col1)
                    Yl(lin1,col1) = Yl(lin1,col1)+Ysol(count2,1);
                else
                    Yl(lin1,col1) = Yl(lin1,col1)- Ysol(count2,1);
                end
            end
            count2 = count2+1;
        case 9
            if(strcmp(Carga{count+1,5},'3F Delta'))
                yab = Ysol(count2,1);
                ybc = Ysol(count2+1,1);
                yca = Ysol(count2+2,1);
                Ydelta = [ yab+yca, -yab,  -yca;...
                           -yab,  yab+ybc, -ybc;...
                           -yca,  -ybc, ybc + yca];
                for count3 = 1:sqrphases
                    lin1 = position(count3,1);
                    col1 = position(count3,2);
                    lin2 = ceil(count3/3);
                    if(mod(count3,3)==0)
                        col2=3;
                    else
                        col2 = mod(count3,3);
                    end
                    Yl(lin1,col1) = Yl(lin1,col1)+Ydelta(lin2,col2);
                end
            else
                ya = Ysol(count2,1);
                yb = Ysol(count2+1,1);
                yc = Ysol(count2+2,1);
                Ywye = [ya , 0 , 0;...
                        0  , yb, 0;...
                        0  , 0 , yc];
                for count3 = 1:sqrphases
                    lin1 = position(count3,1);
                    col1 = position(count3,2);
                    lin2 = ceil(count3/3);
                    if(mod(count3,3)==0)
                        col2=3;
                    else
                        col2 = mod(count3,3);
                    end
                    Yl(lin1,col1) = Yl(lin1,col1) + Ywye(lin2,col2);
                end
            end
            count2 = count2+3;
        case 16
            ya = Ysol(count2,1);
            yb = Ysol(count2+1,1);
            yc = Ysol(count2+2,1);
            yn = Ysol(count2+3,1);
            Ywye = [ya , 0 , 0, -ya;...
                    0  , yb, 0, -yb;...
                    0  , 0 , yc,-yc;...
                    -ya,-yb,-yc, yn];
            for count3 = 1:sqrphases
                lin1 = position(count3,1);
                col1 = position(count3,2);
                lin2 = ceil(count3/4);
                if(mod(count3,4)==0)
                    col2=4;
                else
                    col2 = mod(count3,4);
                end
                 Yl(lin1,col1) = Yl(lin1,col1) + Ywye(lin2,col2);
            end
            count2 = count2+4;
    end
end