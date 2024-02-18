% Gera lista com dados dos trafos para restrição de potência
function trafo_list = defineTrafos(DSSCirc,... % Elemento DSSCircuit da interface COM do OpenDSS
                                   DSSElem,... % Elemento DSSElement da interface COM do OpenDSS
                                   no_ordem,...% vetor com o nome das barras previamente ordenado
                                   buses,...   % número de barras do circuito
                                   choice)     % variável que sinaliza divisão em subsistemas
                                    
DSSXfmr = DSSCirc.Transformers;
aux1 = DSSXfmr.First;
% Enumerates transformers by name
trafo_list = [{'Nome','kva','Yprim','Bus1','Indice Bus1','Subsystem',...
                                    'Bus2','Indice Bus2','Subsystem'}];
while  aux1 > 0,
    eval(['DSSCirc.SetActiveElement([' '''' 'Transformer.' DSSXfmr.Name '''' ']);']);
    cell_aux = DSSElem.Yprim;
    Xreal = cell_aux(1:2:end);
    Ximag = cell_aux(2:2:end);
    aux2 = sqrt(length(Xreal));
    Xreal = reshape(Xreal,[aux2,aux2]);
    Ximag = reshape(Ximag,[aux2,aux2]);
    Yprim = complex(Xreal',Ximag');
    position = [];
    for aux2=1:2
        position_aux = [];
        no = organizeNames(DSSElem.BusNames{aux2});
        cell_aux = splitPhases(no{1,1});
        for aux3=1:size(cell_aux,1)
            index = strfind(lower(no_ordem),lower(cell_aux{aux3,1}));
            index = find(not(cellfun('isempty',index)));
            position_aux = [position_aux; index];
        end
        position = [position, position_aux];
        if(choice==1)
            subsystem{aux2} = no_ordem{index(1)}(1:2);
        else
            subsystem{aux2} = '01';
        end
    end
    switch size(position,1)
        case 4
            if(size(Yprim,1)==8)
                Yprim = Yprim([1:3,5:7],[1:3,5:7]);
            end
        case 3
            if(size(Yprim,1)==8)
                Yprim = Yprim([1:3,5:7],[1:3,5:7]);
            end
        case 2
        case 1
            if(size(Yprim,1)>2)
                Yprim = Yprim([1,3],[1,3]);
            end;
    end

    trafo_list = [trafo_list; {DSSXfmr.Name, DSSXfmr.kva, Yprim, ...
                  DSSElem.BusNames{1}, position(1:end,1), subsystem{1},...
                  DSSElem.BusNames{2},position(1:end,2), subsystem{2}}];
    aux1 = DSSXfmr.Next;
end;
