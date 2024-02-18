% O propósito da função é desagregar cargas trifásicas transformando-as em
% sequências de cargas monofásicas e bifásicas. Após isso o algoritmo
% identifica cargas em paralelo, substituindo-as por uma carga equivalente.
% Em alguns circuitos, existem diversas situações de carga
% distribuida, ou seja, cargas que estão sob a mesma barra, com a mesma
% conexão. A função abaixo tem o propósito de agregar essas cargas em uma
% única conexão equivalente, produzindo uma tabela de cargas resumida.
% A única variável de entrada é a própria lista de cargas gerada por
% defineLoad.m
function Agregate2 = ungroupLoad(Carga,Vbus)

Agregate1 = Carga(1,1:12);
aux2 = 2;

% -------------------------------------------------------------------------
% a) Modifica a representação das cargas trifásicas para 3 cargas
% monofásicas ou bifásicas, de acordo com a conexão trifásica escolhida. A
% tabela com as cargas desagregadas, apenas em versões monofásicas ou
% bifásicas, é armazenada na variável Agregate1
% -------------------------------------------------------------------------

for aux1=2:size(Carga,1)
    if(strcmp(Carga{aux1,6},'3F Delta'))
        node = Carga{aux1,7};
        Ycarga = Carga{aux1,10}(1);
        Ymatriz = [Ycarga, -Ycarga; -Ycarga, Ycarga];
        Agregate1(aux2,1:10) = {Carga{aux1,1},[Carga{aux1,2} '.1.2'], Carga{aux1,3}, ...
                             Carga{aux1,4}/3, Carga{aux1,5}/3, 'Fase-Fase',...
                             node([1 2],1),Carga{aux1,8}([1 2 4 5],:),...
                             Ymatriz, Ycarga};
        S = 0.001*Ycarga*abs(Vbus{Agregate1{aux2,8}(2,1)+1,2} - Vbus{Agregate1{aux2,8}(2,2)+1,2})^2;
        Agregate1(aux2,11) = {real(S)};
        Agregate1(aux2,12) = {-imag(S)};
        Ycarga = Carga{aux1,10}(2);
        Ymatriz = [Ycarga, -Ycarga; -Ycarga, Ycarga];
        Agregate1(aux2+1,1:10) = {Carga{aux1,1}, [Carga{aux1,2} '.2.3'], Carga{aux1,3}, ...
                             Carga{aux1,4}/3, Carga{aux1,5}/3, 'Fase-Fase',...
                             node([2 3],1),Carga{aux1,8}([5 6 8 9],:),...
                             Ymatriz, Ycarga};
        S = 0.001*Ycarga*abs(Vbus{Agregate1{aux2+1,8}(2,1)+1,2} - Vbus{Agregate1{aux2+1,8}(2,2)+1,2})^2;
        Agregate1(aux2+1,11) = {real(S)};
        Agregate1(aux2+1,12) = {-imag(S)};
        Ycarga = Carga{aux1,10}(3);
        Ymatriz = [Ycarga, -Ycarga; -Ycarga, Ycarga];
        Agregate1(aux2+2,1:10) = {Carga{aux1,1}, [Carga{aux1,2} '.3.1'], Carga{aux1,3}, ...
                             Carga{aux1,4}/3, Carga{aux1,5}/3, 'Fase-Fase',...
                             node([1 3],1),Carga{aux1,8}([1 3 7 9],:),...
                             Ymatriz, Ycarga};
        S = 0.001*Ycarga*abs(Vbus{Agregate1{aux2+2,8}(2,1)+1,2} - Vbus{Agregate1{aux2+2,8}(2,2)+1,2})^2;
        Agregate1(aux2+2,11) = {real(S)};
        Agregate1(aux2+2,12) = {-imag(S)};
        aux2 = aux2 + 3;
    elseif(strcmp(Carga{aux1,6},'3FT Wye')) % Estrela aterrada
        node = Carga{aux1,7};
        Ycarga = Carga{aux1,10}(1);
        Ymatriz = [Ycarga, -Ycarga; -Ycarga, Ycarga];
        Agregate1(aux2,1:10) = {Carga{aux1,1}, [Carga{aux1,2} '.1'], Carga{aux1,3}, ...
                             Carga{aux1,4}/3, Carga{aux1,5}/3, 'Fase-Terra',...
                             node(1,1),Carga{aux1,8}(1,:),...
                             Ymatriz, Ycarga};
        Agregate1(aux2,11) = Carga(aux1,11);
        Agregate1(aux2,12) = Carga(aux1,12);
        Ycarga = Carga{aux1,10}(2);
        Ymatriz = [Ycarga, -Ycarga; -Ycarga, Ycarga];
        Agregate1(aux2+1,1:10) = {Carga{aux1,1}, [Carga{aux1,2} '.2'], Carga{aux1,3}, ...
                             Carga{aux1,4}/3, Carga{aux1,5}/3, 'Fase-Terra',...
                             node(2,1),Carga{aux1,8}(5,:),...
                             Ymatriz, Ycarga};
        Agregate1(aux2+1,11) = Carga(aux1,13);
        Agregate1(aux2+1,12) = Carga(aux1,14);
        Ycarga = Carga{aux1,10}(3);
        Ymatriz = [Ycarga, -Ycarga; -Ycarga, Ycarga];
        Agregate1(aux2+2,1:10) = {Carga{aux1,1}, [Carga{aux1,2} '.3'], Carga{aux1,3}, ...
                             Carga{aux1,4}/3, Carga{aux1,5}/3, 'Fase-Terra',...
                             node(3,1),Carga{aux1,8}(9,:),...
                             Ymatriz, Ycarga};
        Agregate1(aux2+2,11) = Carga(aux1,15);
        Agregate1(aux2+2,12) = Carga(aux1,16);
        aux2 = aux2 + 3;
    % Verificar campos com potência em cargas aterradas por impedância
    elseif(strcmp(Carga{aux1,6},'3FN Wye')) % Estrela isolada
        node = Carga{aux1,7};
        Ycarga = Carga{aux1,10}(1);
        Ymatriz = [Ycarga, -Ycarga; -Ycarga, Ycarga];
        Agregate1(aux2,1:10) = {Carga{aux1,1}, [Carga{aux1,2} '.1.4'], Carga{aux1,3}, ...
                             Carga{aux1,4}/3, Carga{aux1,5}/3, 'Fase-Fase',...
                             node([1 3],1),Carga{aux1,8}([1 4 13 16],:),...
                             Ymatriz, Ycarga};
        Agregate1(aux2,11) = Carga(aux1,11);
        Agregate1(aux2,12) = Carga(aux1,12);
        Ycarga = Carga{aux1,10}(2);
        Ymatriz = [Ycarga, -Ycarga; -Ycarga, Ycarga];
        Agregate1(aux2+1,1:10) = {Carga{aux1,1}, [Carga{aux1,2} '.2.4'], Carga{aux1,3}, ...
                             Carga{aux1,4}/3, Carga{aux1,5}/3, 'Fase-Fase',...
                             node([1 3],1),Carga{aux1,8}([6 8 14 16],:),...
                             Ymatriz, Ycarga};
        Agregate1(aux2,11) = Carga(aux1,13);
        Agregate1(aux2,12) = Carga(aux1,14);
        Ycarga = Carga{aux1,10}(3);
        Ymatriz = [Ycarga, -Ycarga; -Ycarga, Ycarga];
        Agregate1(aux2+2,1:10) = {Carga{aux1,1}, [Carga{aux1,2} '.3'], Carga{aux1,3}, ...
                             Carga{aux1,4}/3, Carga{aux1,5}/3, 'Fase-Fase',...
                             node([1 3],1),Carga{aux1,8}([11 12 15  16],:),...
                             Ymatriz, Ycarga};
        Agregate1(aux2,11) = Carga(aux1,15);
        Agregate1(aux2,12) = Carga(aux1,16);
        aux2 = aux2 + 3;
    elseif(strcmp(Carga{aux1,6},'Fase-Fase'))
        Agregate1(aux2,1:10) = Carga(aux1,1:10);
        Agregate1(aux2,11) = {sum(cell2mat(Carga(aux1,[11 13])))};
        Agregate1(aux2,12) = {sum(cell2mat(Carga(aux1,[12 14])))};
        aux2 = aux2 + 1;
    else
        Agregate1(aux2,1:12) = Carga(aux1,1:12);
        aux2 = aux2 + 1;
    end
end

% -------------------------------------------------------------------------
% b) Representa cargas em paralelo por meio de uma carga equivalente,
% gerando uma nova lista de cargas armazenada em Agregate2.
% -------------------------------------------------------------------------

Agregate2 = Carga(1,1:12);
aux2 = 2;

for aux1=2:size(Agregate1,1)
    index = cellfun(@(x)isequal(x,Agregate1{aux1,8}),Agregate1(2:aux1-1,8));
    index = find(index==1);
    if(isempty(index))
        index = cellfun(@(x)isequal(x,Agregate1{aux1,8}),Agregate1(2:end,8));
        index = find(index==1);
        index = index + ones(size(index,1),1);
        Agregate2(aux2,:)={strjoin(Agregate1(index,1)), ...
                           strjoin(Agregate1(index,2)), ...
                           min(cell2mat(Agregate1(index,3))),...
                           sum(cell2mat(Agregate1(index,4))),...
                           sum(cell2mat(Agregate1(index,5))),...
                           Agregate1{aux1,6}, Agregate1{aux1,7},...
                           Agregate1{aux1,8},...
                           sum(cat(3,Agregate1{index,9}),3),...
                           sum(cell2mat(Agregate1(index,10))),...
                           sum(cell2mat(Agregate1(index,11))),...
                           sum(cell2mat(Agregate1(index,12)))};
        aux2 = aux2+1;
    end
end
