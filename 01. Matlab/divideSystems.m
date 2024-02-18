% Função que divide o sistema em subredes, caso o usuário escolher esse
% procedimento em gera_dados
% A função recebe como entrada o arquivo matrizes.mat e o subdivide em
% diversos arquivos matrizes<n>.mat, no qual n é o número da área de
% medição.
% A divisão só pode ser feita de modo que um ponto possa dividir toda a
% rede.
% -------------------------------------------------------------------------
% 1. Verifica se o algoritmo está rodando standalone (caso em que manda 
% apagar tudo) ou foi chamado por outra rotina como gera dados
% Obs: o algoritmo está rodando standalone quando não existe a variável
% escolhadiv (assim foi considerado).
% -------------------------------------------------------------------------
if(~exist('escolhadiv'))
    close all;
    fclose all;
    clear all;
    clc
    pasta      = cd;
    addpath([pasta '\gera_dados']);
end
% -------------------------------------------------------------------------
% 2. Carrega as informações da rede maior - depende da existência do
% arquivo matrizes.mat
% -------------------------------------------------------------------------
widenet = load('matrizes.mat'); % dados principais
numsystems = size(widenet.divpoints,2); % número de áreas de medição
campos = fieldnames(widenet);
emptynet = struct();
for aux1 = 1:length(campos)
    emptynet.(campos{aux1}) = [];
end
subrede = repmat(emptynet,1,numsystems);

% -------------------------------------------------------------------------
% a.1. Para cada área de medição (AM), determina as informações principais
% -------------------------------------------------------------------------
for aux1=1:numsystems
    % 1. escolhadiv
    subrede(aux1).escolhadiv = 0;
    % 2. name: <barras da rede principal_número da AM>_<ID da área de medição>
    subrede(aux1).name = [num2str(widenet.name) '_' num2str(aux1)];
    % 3. subredes: subredes menores ainda associadas
    subrede(aux1).subredes = [];
    % 4. barras: número de barras
    subrede(aux1).barras = size(widenet.subredes{1,aux1},1);
    % 5. divpoints: possibilidade de sub-áreas de medição a ser explorada posteriormente
    subrede(aux1).divpoints = [];
    % 6. barrraVmed
    subrede(aux1).barraVmed = [];
    for aux2 = 1:size(widenet.barraVmed,2)
        index = strfind(widenet.node_order,widenet.barraVmed{1,aux2});
        index = find(~cellfun(@isempty,index));
        if(~isempty(index) && ~isequal(index(1),1))
            subrede(aux1).barraVmed = [subrede(aux1).barraVmed, ...
                                       widenet.barraVmed(1,aux2)];
        end
    end
    % 7. medI_list
    fwd_connect = [];
    bck_connect = [];
    if(aux1==1)
        for aux2=1:numsystems
            subrede(aux2).medI_list = widenet.medI_list(1,:);
        end
    end
    marcador1 = ['0' num2str(aux1)];
    index1 = strfind(widenet.medI_list(:,4),marcador1);
    index2 = strfind(widenet.medI_list(:,10),marcador1);
    index1 = ~cellfun(@isempty,index1);
    index2 = ~cellfun(@isempty,index2);
    index = find(index1 & index2==true);
    if(~isempty(index))
        subrede(aux1).medI_list = [subrede(aux1).medI_list; widenet.medI_list(index,:)];
    end
    index = find(index1 & ~index2==true);
    if(~isempty(index))
        subrede(aux1).medI_list = [subrede(aux1).medI_list; widenet.medI_list(index,:)];
        for aux2=1:size(index,1)
            aux3 = str2num(widenet.medI_list{index(aux2),10});
            subrede(aux3).medI_list = [subrede(aux3).medI_list; widenet.medI_list(index,:)];
            aux4 = widenet.medI_list{index(aux2),3};
            aux4 = strsplit(aux4,'.');
            aux4 = aux4{1};
            aux5 = widenet.medI_list{index(aux2),9};
            aux5 = strsplit(aux5,'.');
            aux5 = aux5{1};
            fwd_connect = [fwd_connect; {aux3,aux4,aux5,index(aux2)}];
        end 
    end
    index = find(~index1 & index2==true);
    if(~isempty(index))
        for aux2=1:size(index,1)
            aux3 = str2num(widenet.medI_list{index(aux2),4});
            aux4 = widenet.medI_list{index(aux2),3};
            aux4 = strsplit(aux4,'.');
            aux4 = aux4{1};
            aux5 = widenet.medI_list{index(aux2),9};
            aux5 = strsplit(aux5,'.');
            aux5 = aux5{1};
            bck_connect = [bck_connect; {aux3,aux4,aux5,index(aux2)}];
        end 
    end
    % 8. node_order
    marcador1 = ['0' num2str(aux1) '_'];
    index = strncmp(widenet.node_order, marcador1, length(marcador1));
    subrede(aux1).node_order = [subrede(aux1).node_order; widenet.node_order(index)];
    for aux2=1:size(fwd_connect,1)
        marcador1 = ['0' num2str(fwd_connect{aux2,1}) '_'];
        index = strncmp(widenet.node_order, marcador1, length(marcador1));
        marcador1 = num2str(fwd_connect{aux2,3});
        index1 = strfind(widenet.node_order, marcador1);
        index1 = ~cellfun(@isempty,index1);
        list=widenet.node_order(index & index1);
        subrede(aux1).node_order = [subrede(aux1).node_order; list];        
    end
    %9. trafoList
    marcador1 = ['0' num2str(aux1)];
    if(aux1==1)
        for aux2=1:numsystems
            subrede(aux2).trafoList = widenet.trafoList(1,:);
        end
    end
    index = strfind(widenet.trafoList(:,6),marcador1);
    index = find(~cellfun(@isempty,index));
    if(~isempty(index))
        subrede(aux1).trafoList = [subrede(aux1).trafoList; ...
                                   widenet.trafoList(index,:)];
    end
    % 10. elemImed
    for aux2 = 1:size(widenet.elemImed,2)
        index = strfind(subrede(aux1).medI_list(2:end,1),widenet.elemImed{1,aux2});
        index = find(~cellfun(@isempty,index));
        if(~isempty(index))
            subrede(aux1).elemImed = [subrede(aux1).elemImed widenet.elemImed(1,aux2)];
        end
    end
    % 11. ptos_medI
    subrede(aux1).ptos_medI = 0;
    if(size(subrede(aux1).medI_list,1)>2)
        for aux2 = 3:size(subrede(aux1).medI_list,1)
            subrede(aux1).ptos_medI = subrede(aux1).ptos_medI + ...
                                      size(subrede(aux1).medI_list{aux2,5},1);
        end
    end
    % 12. ptos_medSource
    if(aux1==1)
        index = strfind(subrede(aux1).node_order,'_***_');
        index = find(~cellfun(@isempty,index));
        if(~isempty(index))
            subrede(aux1).ptos_medSource = size(index,1);
        end
    else
        index = strfind(subrede(aux1).node_order,'.**_');
        index = find(~cellfun(@isempty,index));
        if(~isempty(index))
            subrede(aux1).ptos_medSource = size(index,1);
        end
    end
    % 13. ptos_medV
    subrede(aux1).ptos_medV = 0;
    if(aux1==1)
        index = strfind(subrede(aux1).node_order,'_**_');
        index = find(~cellfun(@isempty,index));
        if(~isempty(index))
            subrede(aux1).ptos_medV = size(index,1);
        end
        index = strfind(subrede(aux1).node_order,'_*_');
        index = find(~cellfun(@isempty,index));
        if(~isempty(index))
            subrede(aux1).ptos_medV = subrede(aux1).ptos_medV + size(index,1);
        end
    else
        index = strfind(subrede(aux1).node_order,'.*_');
        index = find(~cellfun(@isempty,index));
        if(~isempty(index))
             subrede(aux1).ptos_medV = size(index,1);
        end
    end
    % 14. Iorder
    % Primeira composição de Iorder
    index = find(ismember(widenet.Iorder(:,1),subrede(aux1).node_order));
    subrede(aux1).Iorder = [widenet.Iorder(1,:); widenet.Iorder(index,:)];
    % Organização de fwd_connect e bck_connect
    sub_connect = {};
    % sub_connect = [fwd_connect bck_connect];
    for aux2=1:size(fwd_connect,1)
        marcador1 = fwd_connect{aux2,3};
        index=[];
        if(aux2>1)
            index = strfind(sub_connect(:,3),marcador1);
            index = find(~cellfun(@isempty,index));
        end
        if(isempty(index))
            index = strfind(fwd_connect(:,3),marcador1);
            index = find(~cellfun(@isempty,index));
            list = fwd_connect(index,:);
            sub_connect = [sub_connect; {list(:,1)}, {list(:,2)},...
                                         marcador1, {list(:,4)}];
        end
    end
    fwd_connect = sub_connect;
    sub_connect = {};
    for aux2=1:size(bck_connect,1)
        marcador1 = bck_connect{aux2,3};
        index=[];
        if(aux2>1)
            index = strfind(sub_connect(:,3),marcador1);
            index = find(~cellfun(@isempty,index));
        end
        if(isempty(index))
            index = strfind(bck_connect(:,3),marcador1);
            index = find(~cellfun(@isempty,index));
            list = bck_connect(index,:);
            sub_connect = [sub_connect; {list(:,1)}, {list(:,2)},...
                                         marcador1, {list(:,4)}];
        end
    end
    bck_connect = sub_connect;
    % Agrupamento das correntes no vetor sub_connect
    Imed=zeros(3,1);
    Iorder=zeros(3,1);
    sub_connect = {};
    for aux2=1:size(fwd_connect,1)
        index = fwd_connect{aux2,4};
        for aux3=1:size(index,1)
            list = widenet.medI_list{index{aux3,1},15};
            index2 = strsplit(widenet.medI_list{index{aux3,1},9},'.');
            index2 = str2double(index2(2:end));
            Imed(index2) = list;
            Iorder = Iorder - Imed;
        end
        sub_connect = [sub_connect; {fwd_connect{aux2,3}, Iorder}];
    end
    Imed=zeros(3,1);
    for aux2=1:size(bck_connect,1)
        marcador1 = bck_connect{aux2,3};
        index=[];
        if(aux2>1)
            index = strfind(sub_connect(:,1),marcador1);
            index = find(~cellfun(@isempty,index));
        end
        if(isempty(index))
            Iorder=zeros(3,1);
        else
            Iorder = sub_connect{index,2};
        end
        index1 = bck_connect{aux2,4};
        for aux3=1:size(index1,1)
            list = widenet.medI_list{index1{aux3,1},15};
            index2 = strsplit(widenet.medI_list{index1{aux3,1},9},'.');
            index2 = str2double(index2(2:end));
            Imed(index2) = list;
            Iorder = Iorder + Imed;
        end
        if(isempty(index))
            sub_connect = [sub_connect; {marcador1, Iorder}];
        else
            sub_connect{index,2} = Iorder;
        end
    end
    % correção de Iorder
    for aux2=1:size(sub_connect,1)
        list = sub_connect{aux2,2};
        for aux3=1:3
            marcador1=sub_connect{aux2,1};
            marcador2 =['.' num2str(aux3)];
            index1 = strfind(subrede(aux1).Iorder(:,1),marcador1);
            index1 = ~cellfun(@isempty,index1);
            index2 = strfind(subrede(aux1).Iorder(:,1),marcador2);
            index2 = ~cellfun(@isempty,index2);
            index = find(index1 & index2 == true);
            subrede(aux1).Iorder{index,2}=list(aux3);
        end
    end
    % 15. Vorder
    index = find(ismember(widenet.Vorder(:,1),subrede(aux1).node_order));
    subrede(aux1).Vorder = [widenet.Vorder(1,:); widenet.Vorder(index,:)];
    % 16 e 17. Ysistema_list e Yrede_list
    Ysistema = cell2mat(widenet.Ysistema_list(2:end,2:end));
    Yrede = cell2mat(widenet.Yrede_list(2:end,2:end));
    for aux2=1:size(fwd_connect,1)
        marcador1 = fwd_connect{aux2,3};
        index1 = strfind(widenet.node_order,marcador1);
        index1 = find(~cellfun(@isempty,index1));
        Ysistema(index1,index1)=zeros(size(index1,1));
        Yrede(index1,index1)=zeros(size(index1,1));
        index = fwd_connect{aux2,2};
        for aux3=1:size(index,1)
            index2 = strfind(widenet.node_order,index{aux3});
            index2 = find(~cellfun(@isempty,index2));
            list1 = {index1, index2};
            [aux4,aux5] = min([size(list1{1},1),size(list1{2},1)]);
            if(aux4<3)
                list2 = widenet.node_order(list1{aux5});
                for aux6 = 1:size(list2,1)
                    index3 = strfind(list2{aux6},'.');
                    index3 = str2num(list2{aux6}(index3+1:end));
                    list3(aux6)=index3;
                end
                switch aux5
                    case 1
                        index2=index2(index3);
                    case 2
                        index1=index1(index3);
                end
            end
            Ysistema(index1,index1) = Ysistema(index1,index1) + Ysistema(index1,index2);
            Yrede(index1,index1) = Yrede(index1,index1) + Yrede(index1,index2);
        end
    end
    for aux2=1:size(bck_connect,1)
        %marcador1 = cell2mat(bck_connect{aux2,1});
        marcador2 = bck_connect{aux2,3};
        index1 = strfind(widenet.node_order,marcador2);
        index1 = find(~cellfun(@isempty,index1));
        Ysistema(index1,index1) = zeros(size(index1,1));
        Yrede(index1,index1) = zeros(size(index1,1));
        list = widenet.subredes{2,aux1};
        index = strfind(list(:,1),marcador2);
        index = find(~cellfun(@isempty,index));
        for aux3=1:size(index,1)
            marcador1 = list{index,2};
            index2 = strfind(widenet.node_order,marcador1);
            index2 = find(~cellfun(@isempty,index2));
            list1 = {index1, index2};
            [aux4,aux5] = min([size(list1{1},1),size(list1{2},1)]);
            if(aux4<3)
                list2 = widenet.node_order(list1{aux5});
                for aux6 = 1:size(list2,1)
                    index3 = strfind(list2{aux6},'.');
                    index3 = str2num(list2{aux6}(index3+1:end));
                    list3(aux6)=index3;
                end
                switch aux5
                    case 1
                        index2=index2(index3);
                    case 2
                        index1=index1(index3);
                end
            end
            Ysistema(index1,index1) = Ysistema(index1,index1) - Ysistema(index1,index2);
            Yrede(index1,index1) = Yrede(index1,index1) - Yrede(index1,index2);
        end
    end
    index1 = find(ismember(widenet.node_order,subrede(aux1).node_order));
    subrede(aux1).Ysistema_list = ['#Y' subrede(aux1).node_order';
                                   subrede(aux1).node_order,...
                                   num2cell(Ysistema(index1,index1))];
    subrede(aux1).Yrede_list = ['#Y' subrede(aux1).node_order';
                                   subrede(aux1).node_order,...
                                   num2cell(Yrede(index1,index1))];
    Ysistema = Ysistema(index1,index1);
    Yrede = Yrede(index1,index1);
    % 18. Load
    marcador1 = ['0' num2str(aux1)];
    index = strfind(widenet.Load(:,1),marcador1);
    index = find(~cellfun(@isempty,index));
    if(~isempty(index))
        subrede(aux1).Load = [widenet.Load(1,:); widenet.Load(index,:)];
    else
        subrede(aux1).Load = widenet.Load(1,:);
    end
   
    % ---------------------------------------------------------------------
    % a.2. Ajuste de Ysistema_list, Yrede_list e Iorder. Em Ysistema_list e
    % Yrede_list devem-se descontar as admitâncias das linhas do sistema a
    % montante/jusante que incidem sobre os nós de fronteira. Em Iorder,
    % deve-se ajustar os pontos de fronteira como correntes de carga e
    % reconstruir as colunas de verificação de erro dos vetores Vorder e
    % Iorder.
    % ---------------------------------------------------------------------
    % Verificação de Iorder e Vorder - reconstrução das colunas 3 a 5
    Imed = cell2mat(subrede(aux1).Iorder(2:end,2));
    Vmed = cell2mat(subrede(aux1).Vorder(2:end,2));
    subrede(aux1).Iorder(2:end,3) = num2cell(Ysistema*Vmed);
    subrede(aux1).Iorder(2:end,4) = num2cell(Imed - Ysistema*Vmed);
    subrede(aux1).Vorder(2:end,4) = num2cell(Ysistema\Imed);
    subrede(aux1).Vorder(2:end,5) = num2cell(Vmed - Ysistema\Imed);
    
       
    %----------------------------------------------------------------------
    % a.3.
    % Redefinição de node_order em todas as listas - geralmente os últimos
    % nós da lista tem a marcação do sistema a jusante. Essa marcação é
    % substituída em todas as variáveis pela marcação do sistema atual.
    %----------------------------------------------------------------------
    for aux2=1:numsystems
        marcador1 = ['0' num2str(aux2) '_\*'];
        marcador2 = ['0' num2str(aux1) '_\*'];
        subrede(aux1).node_order = regexprep(subrede(aux1).node_order,marcador1,marcador2);
        subrede(aux1).Iorder(2:end,1) = subrede(aux1).node_order;
        subrede(aux1).Vorder(2:end,1) = subrede(aux1).node_order;
        subrede(aux1).Ysistema_list(1,2:end) = subrede(aux1).node_order';
        subrede(aux1).Ysistema_list(2:end,1) = subrede(aux1).node_order;
        subrede(aux1).Yrede_list(1,2:end) = subrede(aux1).node_order';
        subrede(aux1).Yrede_list(2:end,1) = subrede(aux1).node_order;
    end
    
    %----------------------------------------------------------------------
    % a.4.
    % Reorganização de node_order em todas as listas - colocação dos nós de
    % medição nas primeiras posições da matriz a partir da função
    % "sortrows"
    %----------------------------------------------------------------------
    subrede(aux1).node_order = sortrows(subrede(aux1).node_order);
    subrede(aux1).Iorder = [subrede(aux1).Iorder(1,:); sortrows(subrede(aux1).Iorder(2:end,:),1)];
    subrede(aux1).Vorder = [subrede(aux1).Vorder(1,:); sortrows(subrede(aux1).Vorder(2:end,:),1)];
    subrede(aux1).Ysistema_list = sortrows(subrede(aux1).Ysistema_list,1);
    subrede(aux1).Ysistema_list = subrede(aux1).Ysistema_list';
    subrede(aux1).Ysistema_list = sortrows(subrede(aux1).Ysistema_list,1);
    subrede(aux1).Yrede_list = sortrows(subrede(aux1).Yrede_list,1);
    subrede(aux1).Yrede_list = subrede(aux1).Yrede_list';
    subrede(aux1).Yrede_list = sortrows(subrede(aux1).Yrede_list,1);
    
    %----------------------------------------------------------------------
    % a.5.
    % Redefinição das posições em medI_list - As colunas 5 e 12 de
    % medI_list guardam a posição das barras (nas quais os elementos com
    % medição de corrente estão conectados) dentro do vetor node_order. Com
    % o comando sortrows dado acima, o vetor node_order foi alterado, de
    % modo que essas posições dentro do vetor medI_list também precisam ser
    % alteradas.
    %----------------------------------------------------------------------
    aux3=3;
    for aux2=aux3:size(subrede(aux1).medI_list,1)
        cell_aux1 = strsplit(subrede(aux1).medI_list{aux2,3},'.');
        cell_aux1 = cell_aux1{1};
        index = strfind(subrede(aux1).node_order, cell_aux1);
        index = find(~cellfun(@isempty,index));
        if(~isempty(index))
            subrede(aux1).medI_list{aux2,5} = index;
        end
        cell_aux1 = strsplit(subrede(aux1).medI_list{aux2,9},'.');
        cell_aux1 = cell_aux1{1};
        index = strfind(subrede(aux1).node_order, cell_aux1);
        index = find(~cellfun(@isempty,index));
        if(~isempty(index))
            subrede(aux1).medI_list{aux2,11} = index;
        end
    end
    
    %----------------------------------------------------------------------
    % a.6.
    % Redefinição das posições em Load - A colunas 8 de Load guarda a
    % posição da admitância da carga dentro da matriz de admitância nodal.
    % Com o comando sortrows dado acima, o vetor node_order foi alterado, de
    % modo que essas posições dentro do vetor medI_list também precisam ser
    % alteradas.
    %----------------------------------------------------------------------
    verifica(aux1) = 0;
    for aux2 = 2:size(subrede(aux1).Load,1)
        position = [];
        cell_aux1 = subrede(aux1).Load{aux2,7};
        if(size(cell_aux1,1)==1)
            index = strfind(subrede(aux1).node_order, cell_aux1{1});
            index = find(~cellfun(@isempty,index));
            position = [index index];
            subrede(aux1).Load{aux2,8} = position;
            verifica(aux1) = verifica(aux1) + subrede(aux1).Load{aux2,10};
        else
            for aux3 = 1: size(cell_aux1,1)
                index = strfind(subrede(aux1).node_order, cell_aux1{aux3});
                index = find(~cellfun(@isempty,index));
                position = [position, index];
            end
            position = [ position(1), position(1);...
                         position(1), position(2);...
                         position(2), position(1);...
                         position(2), position(2)];
            subrede(aux1).Load{aux2,8} = position;
        end
    end
    
    %----------------------------------------------------------------------
    % a.7. Redefinição dos vetores Yraiz Zraiz Ypos Sraiz (19 a 22)
    %----------------------------------------------------------------------
    [subrede(aux1).Yraiz subrede(aux1).Zraiz subrede(aux1).Ypos] = defineYRoot(subrede(aux1).Load);
    subrede(aux1).Sraiz = cell2mat(subrede(aux1).Load(2:end,11:12));

    %----------------------------------------------------------------------
    % a.8. Verificação do Erro na construção da matriz de cargas para cada
    % subsistema (23. Yload_list e 24. YLoadError)
    %----------------------------------------------------------------------
    [subrede(aux1).Yload_list subrede(aux1).YLoadError] = ...
                              defineYLoadError(subrede(aux1).Ysistema_list,...
                                               subrede(aux1).Yrede_list,...
                                               subrede(aux1).Load,...
                                               subrede(aux1).node_order,...
                                               verifica(aux1));
    
    %----------------------------------------------------------------------
    % a.10. Construção de variável estruturada a exemplo de widenet para
    % cada subsistema e armazenamento desses valores em arquivo .mat
    %----------------------------------------------------------------------   
    nameFile = ['matrizes' num2str(aux1) '.mat'];
    list=fieldnames(subrede(aux1));
    for aux2=1:size(list,1)
        eval([list{aux2}, '=subrede(aux1).', list{aux2}, ';']);
    end
    save(nameFile,list{:});
    clearvars -except aux1 campos emptynet numsystems pasta ...
                      subrede widenet escolhadiv mainset pasta_atual
end
clearvars -except escolhadiv mainset pasta_atual widenet subrede