% Geração de uma lista com os principais dados sobre o equivalente de
% Thevenin na subestação e sobre os elementos de medição de corrente.
% Além disso, geração de vetor com a potência trifásica na saída do
% alimentador. Os argumentos de entrada são:
function [List ptmedI] = defineMedI(DSSCirc,...     % Elemento DSSCircuit da interface COM do OpenDSS
                                    DSSElem,...     % Elemento DSSElement da interface COM do OpenDSS
                                    Vordem,...      % Lista referente às tensões nodais gerada em 'monta_V_e_I.m'
                                    barraV_med,...  % Lista com o nome dos elementos em que há medição de tensão
                                    elem_Imed,...   % Lista com o nome dos elementos em que há medição de corrente
                                    no_ordem,...    % vetor com o nome das barras previamente ordenado
                                    buses,...       % vetor com o número total de barras do circuito.
                                    choice)         % divisão do circuito em áreas de medição
% -------------------------------------------------------------------------
% a) Obtenção de dados sobre o equivalente de Thevenin
% -------------------------------------------------------------------------
ptmedI = 0;
DSSCirc.SetActiveElement(['VSOURCE.SOURCE']);
Yfonte = DSSCirc.ActiveElement.Yprim;
aux1 = sqrt(size(Yfonte,2)/2);
cell_aux = reshape(Yfonte,[2*aux1,aux1]);
cell_aux = cell_aux';
Xreal = reshape(Yfonte(1:2:end),[aux1,aux1]);
Ximag = reshape(Yfonte(2:2:end),[aux1,aux1]);
Yfonte = complex(Xreal',Ximag');

% -------------------------------------------------------------------------
% b) Obtenção da corrente medida no alimentador
% -------------------------------------------------------------------------
Ifonte = DSSCirc.ActiveElement.Currents;
Xreal = Ifonte(1:2:end);
Ximag = Ifonte(2:2:end);
Ifonte = complex(Xreal',Ximag');
Imed = Ifonte(4:6);

Sfonte = DSSCirc.ActiveElement.Powers;
Xreal = Sfonte(1:2:end);
Ximag = Sfonte(2:2:end);
Sfonte = complex(Xreal',Ximag');
Smed = Sfonte(1:3);

% -------------------------------------------------------------------------
% c) Obtenção das correntes nos pontos de medição e da matriz de admitâncias 
% primárias dos elementos
% -------------------------------------------------------------------------
List = {'Elemento','Yprim','Node1','Subsystem1','Indice Node 1','V1','I1','S1',...
        'Node 2','Subsystem2','Indice Node 2','V2','I2','S2 (meter)','Imed'};
List = [List;{'SOURCEBUS', Yfonte,DSSElem.BusNames{1},'01',[1;2;3],...
        cell2mat(Vordem(2:4,2)),Ifonte(4:6),-Sfonte(1:3),...
        DSSElem.BusNames{2},'01','X'},zeros(3,1),Ifonte(1:3),Sfonte(4:6),...
        Imed];
for aux2=1:size(elem_Imed,2)
    eval(['DSSCirc.SetActiveElement([' '''' 'Line.' elem_Imed{aux2} '''' ']);']);
    cell_aux = DSSElem.Currents;
    Xreal = cell_aux(1:2:end);
    Ximag = cell_aux(2:2:end);
    cell_aux = complex(Xreal',Ximag');
    aux1 = size(cell_aux,1)/2;
    I_T1 = cell_aux(1:aux1,1);
    I_T2 = -cell_aux(aux1+1:end,1);
    Imed = I_T2;
    cell_aux = DSSElem.Yprim;
    Xreal = cell_aux(1:2:end);
    Ximag = cell_aux(2:2:end);
    aux1 = sqrt(length(Xreal));
    Xreal = reshape(Xreal,[aux1,aux1]);
    Ximag = reshape(Ximag,[aux1,aux1]);
    Yprim = complex(Xreal',Ximag');
    cell_aux = DSSElem.Powers;
    Xreal = cell_aux(1:2:end);
    Ximag = cell_aux(2:2:end);
    cell_aux = complex(Xreal',Ximag');
    aux1 = size(cell_aux,1)/2;
    S{1} = cell_aux(1:aux1,1);
    S{2} = -cell_aux(aux1+1:end,1);
    position = [];
    v = [];
    for aux1=1:2
        position_aux = [];
        no = organizeNames(DSSElem.BusNames{aux1});
        cell_aux = splitPhases(no{1,1});
        for aux3=1:size(cell_aux,1)
            index = strfind(lower(no_ordem),lower(cell_aux{aux3,1}));
            index = find(not(cellfun('isempty',index)));
            position_aux = [position_aux; index];
        end
        position = [position, position_aux];
        index = position_aux + ones(size(position_aux,1),1);
        v(1:size(index,1),aux1) = cell2mat(Vordem(index,2));
        if(choice==1)
            subsystem{aux1} = no_ordem{index(1)}(1:2);
        else
            subsystem{aux1} = '01';
        end
        if(aux1==2)
            no = strsplit(no{1,1},'.');
            no = no{1};
            index = strfind(organizeNames(lower(barraV_med)),lower(no));
            index = ~cellfun(@isempty,index);
            if(sum(index)==0)
                S{aux1}= 'No meter';
            end
        end
    end 
    List = [List; {['Line.' elem_Imed{aux2}],Yprim,DSSElem.BusNames{1},...
            subsystem{1},position(1:end,1),v(1:end,1),I_T1,S{1},DSSElem.BusNames{2},...
            subsystem{2},position(1:end,2),v(1:end,2),I_T2,S{2},Imed}];
    ptmedI = ptmedI + size(position(1:end,2),1);
end
List = [List(1,:);sortrows(List(2:end,:),[4 10])];
% -------------------------------------------------------------------------
% Campos presentes na lista gerada:
% * Elemento - nome do elemento do alimentador ou de derivação;
% * Yprim - matriz de admitância primária do elemento do alimentador ou de
% derivação. Sendo T1 o terminal aonde a corrente entra e T2 o terminal por
% onde sai em uma rede radial, Yprim é definido como:
% [I_T2 ; I_T1] = [Yprim] * [V_T2 ; V_T1];
% * Node1 - Barra terminal de conexão do elemento do alimentador ou de
% derivação;
% Subsystem 1 - Área de medição que contém Node 1.
% * Indice Node1 - Posição de Node 1 na matriz de admitâncias nodais;
% * V1 - tensão nodal em Node 1 de acordo com a simulação do sistema com
% carga;
% * I1 - corrente em Node 1 de acordo com a simulação do sistema com
% carga (na fonte essa corrente está saindo do nó enquanto nos outros
% elementos de rede essa corrente está entrando no nó);
% * S1 - potência em Node 1 de acordo com a simulação do sistema com
% carga (na fonte esse fluxo está saindo enquanto nos outros elementos
% de rede esse fluxo está entrando);
% * Node2 - Barra terminal de conexão do elemento do alimentador ou de
% derivação;
% Subsystem 2 - Área de medição que contém Node 2.
% * Indice Node2 - Posição de Node 2 na matriz de admitâncias nodais;
% * V2 - tensão nodal em Node 2 de acordo com a simulação do sistema com
% carga;
% * I2 - corrente em Node 2 de acordo com a simulação do sistema com
% carga (na fonte essa corrente está saindo enquanto nos outros elementos
% de rede essa corrente está entrando);
% * S2 - potência em Node 2 de acordo com a simulação do sistema com
% carga (na fonte esse fluxo está saindo enquanto nos outros elementos
% de rede esse fluxo está entrando);
% * Imed - Corrente medida na derivação de acordo com simulação do sistema
% com carga;
% -------------------------------------------------------------------------