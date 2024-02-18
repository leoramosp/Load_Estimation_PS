% A função abaixo produz uma tabela com informações de todas as cargas do
% sistema. Além disso, a função produz um número verificador da validade da matriz
% do sistema (verifica). Esse número é a soma de todos os elementos da
% matriz de cargas, ou seja, a soma de todas as admitâncias monofásicas e
% trifásicas em estrela.

function [Carga verifica] = defineLoad(DSSCirc,...      % Elemento DSSCircuit da interface COM do OpenDSS
                                       DSSElem,...      % Elemento DSSElement da interface COM do OpenDSS
                                       DSSCktElem,...   % DSSCktElem - Elemento DSSCktElement da interface COM do OpenDSS
                                       DSSCarga,...     % Elemento DSSLoad da interface COM do OpenDSS
                                       nos_ordem,...    % vetor com o nome das barras previamente ordenado
                                       busmedV,...      % lista com barras nas quais há medição de tensão.
                                       buses,...        % vetor com o número total de barras do circuito.
                                       choice)          % divisão do circuito em áreas de medição
% -------------------------------------------------------------------------
% a) Definição da classe carga como ativa
% -------------------------------------------------------------------------
DSSCirc.SetActiveClass('Load');

% -------------------------------------------------------------------------
% b) Método que define a primeira carga da lista como Elemento Ativo
% -------------------------------------------------------------------------
aux1 = DSSCarga.First;
aux2 = DSSCirc.FirstElement;

% -------------------------------------------------------------------------
% c) Informações disponíveis na lista de cargas
% -------------------------------------------------------------------------
Carga = {'Subsystem' 'Name','Tensao(V)','W','VAr','Conn','Bus','Ypos','Yprim','Ycarga','P1(kW)','Q1(kVAr)','P2(kW)','Q2(kVAr)','P3(kW)','Q3(kVAr)','PN(kW)','QN(kVAr)'};

% -------------------------------------------------------------------------
% d) Variáveis a serem preenchidas
% -------------------------------------------------------------------------
Conn = ''; % Conexão de cada carga
Ycarga = 0; % Admitância própria de cada carga (no caso de carga 3F utilizo  admitância entre fases);
Yprim = []; % Matriz de admitância primitiva de cada carga;
position = []; % posição de cada carga na matriz de admitância da rede
potencia = []; % vetor com o fluxo de potência em cada carga
verifica = 0; % armazena a soma das admitâncias das cargas fase terra, de
              % modo a verificar se a matriz de carga é diagonal

% -------------------------------------------------------------------------
% e) Loop que percorre todas as cargas, verifica a conexão delas com o
% sistema, obtém a matriz de admitância primitiva e escolhe um valor para
% representar essa matriz, verificando também em qual posiçao da matriz de
% rede essa carga está conectada, entre outros dados
% -------------------------------------------------------------------------
while(aux1 > 0) % aux1 sempre aponta para uma das cargas e chega em 0 no fim da lista
    
    % Obtém a matriz de admitância primária
    Yprim = DSSElem.Yprim;
    aux1 = sqrt(size(Yprim,2)/2);
    Xreal = reshape(Yprim(1:2:end),[aux1,aux1]);
    Ximag = reshape(Yprim(2:2:end),[aux1,aux1]);
    Yprim = complex(Xreal',Ximag');
    no = organizeNames(DSSElem.BusNames);
    cell_aux = splitPhases(no{1,1});
    for aux3=1:size(cell_aux,1)
        index = strfind(lower(nos_ordem),lower(cell_aux{aux3,1}));
        index = find(not(cellfun('isempty',index)));
        position = [position; index];
    end
    no = nos_ordem(position);
    % Define a conexão para cada carga e a admitância própria
    switch DSSCktElem.NumPhases % Confere o número de fases
        case 3 % Trifásico
            if(DSSCarga.IsDelta == 1) % Carga em trifásico-Delta
                Conn = '3F Delta';
                position = [position(1,1)*ones(3,1),position;...
                            position(2,1)*ones(3,1),position;...
                            position(3,1)*ones(3,1),position];
                Ycarga = [-Yprim(1,2);-Yprim(2,3);-Yprim(1,3)];
            else % Conexão Estrela
                if(size(cell_aux,1)==4) % Conexão Estrela com neutro não aterrado.
                    Conn = '3FN Wye';
                    position = [position(1,1)*ones(4,1),position;...
                                position(2,1)*ones(4,1),position;...
                                position(3,1)*ones(4,1),position;...
                                position(4,1)*ones(4,1),position];
                    Ycarga = [Yprim(1,1);Yprim(2,2);Yprim(3,3);Yprim(4,4)];
                    verifica = verifica + Yprim(4,4)-Yprim(3,3)-Yprim(2,2)-Yprim(1,1);
                else % Conexão Estrela com neutro aterrado
                    Conn = '3FT Wye';
                    position = [position(1,1)*ones(3,1),position;...
                                position(2,1)*ones(3,1),position;...
                                position(3,1)*ones(3,1),position];
                    Ycarga = [Yprim(1,1);Yprim(2,2);Yprim(3,3)];
                    verifica = verifica + sum(Ycarga);
                end
            end
        case 1
            switch size(cell_aux,1)
                case 2
                    Conn = 'Fase-Fase';
                    position = [position(1,1)*ones(2,1),position;...
                                position(2,1)*ones(2,1),position];
                case 1
                    Conn = 'Fase-Terra';
                    verifica = verifica + Yprim(1,1);
                    position = [position, position];
            end
            Ycarga = Yprim(1,1);
    end

    % Obtém a área de medição
    if(choice==1)
        BusNames = organizeNames(DSSElem.BusNames);
        BusNames = strsplit(BusNames{1},'.');
        index = strfind(lower(nos_ordem),lower(BusNames{1,1}));
        index = find(not(cellfun('isempty',index)));
        subsystem = nos_ordem{index(1)}(1:2);
    else
        subsystem = '01';
    end
     
    % Obtém o fluxo de potência para cada carga
    potencia = zeros(1,8);
    potencia(1:size(DSSElem.Powers,2))=DSSElem.Powers;
    
    % Preenche a lista de cargas com os dados necessários
    Carga = [Carga; subsystem, [DSSElem.BusNames{1} ' - ' DSSCarga.Name], DSSCarga.kV*1000, DSSCarga.kW*1000,DSSCarga.kvar*1000,Conn,{no}, position,Yprim,Ycarga,num2cell(potencia)];
    
    % Aponta para próxima carga da lista, se não tiver nenhuma aux1 fica
    % igual a zero.
    aux1 = DSSCarga.Next;
    aux2 = DSSCirc.NextElement;
    position = [];
end;

% -------------------------------------------------------------------------
% f) Ordenação das cargas de acordo com nos_ordem
% -------------------------------------------------------------------------
if(choice==1)
    Carga = [Carga(1,:);sortrows(Carga(2:end,:),[1 2])];
else
    Carga = [Carga(1,:);sortrows(Carga(2:end,:),2)];
end
%{
Formato da lista de cargas:
* Name: nome de cada uma das cargas, como configurado no OpenDSS;
* Name: nome de cada uma das cargas, como configurado no OpenDSS;
* Tensão(V): Tensão nominal, em Volts.
* W: Potência ativa nominal, em Watts.
* Conn: conexão da carga, pode ser Fase-Fase, Fase-Terra, 3F Wye ou 3F Delta
* Bus: barramento ao qual a carga está conectada.
* Ypos: posição [linha coluna] em que a admitância da carga entra na matriz
de admitâncias do sistema;
* Yprim: matriz primária de admitância da carga;
* Ycarga: elementos necessários para definir a matriz de admitância
primária. O número desses elementos define o grau de liberdade na
determinação da carga. Para cargas monofásicas e bifásicas, Ycarga é a
própria admitância entre fases (ou entre fase e terra). Para cargas
trifásicas em triângulo, o elemento são as 3 admitâncias entre as fases (Yab,
Ybc, Yca). Para cargas trifásicas em estrela, Ycarga são as admitâncias
entre cada fase e o neutro.
* Pn, Qn: potências ativa e reativa na fase n de acordo com simulação do
OpenDSS;
%}