% Função que, a partir da lista de cargas gerada em 'gera_dados' e das
% tensões nodais do circuito simulado, define um valor inicial para a
% estimação da impedância das cargas, dado por Vnom^2/Sinicio, aonde Vnom é
% a tensão nominal de cada carga e Sinicio = Sfonte*Snom/sum(Snom), ou
% seja, Sinicio é a porcentagem da potência medida na subestação
% correspondente à potência nominal da carga em relação à potência total
% instalada. Os argumentos de entrada são:
% * Carga - Lista de cargas 'Load' salva no arquivo matrizes.mat
% * Sfonte - Potência medida na saída da subestação
% Dominio = 1 - Resolve a função objetivo no domínio das admitâncias;
% Dominio = 2 - Resolve a função objetivo no domínio das impedâncias;
function [chute] = defineChuteInicial(Carga,Sfonte,dominio)

escolha = -1;
texto = '\n\nDigite 1 para re-utilizar resultados como chute inicial.\n';
texto = [texto 'Digite qualquer outra tecla caso contrário.'];
texto = [texto '\n\nOpçao:'];
escolha = input(texto);
fprintf('\n\n');
if(escolha==1)
    [file path] = uigetfile('*.mat','Localizar arquivo .mat com variável vetorps');
    command = ['load(' '''' path file '''' ',' '''' 'search' '''' ');' ];
    eval(command);
    chute = search.vetorps;
else
    Pnom = Carga(2:end,4);
    Qnom = Carga(2:end,5);
    Vnom = Carga(2:end,3);
    Pnom = cell2mat(Pnom);
    Qnom = cell2mat(Qnom);
    Snom = complex(Pnom,Qnom);
    Vnom = cell2mat(Vnom);

    % Chute inicial 1 - divisão proporcional, mesmo fator de potência (fator da
    % soma das potências na saída da subestação);
    Spercent = abs(Snom)/sum(abs(Snom));
    Sinicio = (sum(1000*Sfonte))*Spercent;

    % Chute inicial 2 - divisão proporcional, fator de potência correto;
    % Spercent = abs(Snom)/sum(abs(Snom));
    % Sinicio = abs(sum(-1000*Sfonte))*Spercent;
    % Sinicio = Sinicio.*exp(i*angle(Snom));

    % Chute inicial 3 - divisão proporcional, mesmo fator de potência
    % (0.75);
    % Spercent = abs(Snom)/sum(abs(Snom));
    % Sinicio = abs(sum(-1000*Sfonte))*Spercent;
    % Sinicio = Sinicio.*exp(i*acos(0.75));

    % Chute Inicial 4 - divisão proporcional, considerando as potências
    % complexas, fator de potência diferente para cada, dependendo do fator
    % real da carga e das potências medidas na fonte.
    % Spercent = Snom/sum(Snom);
    % Sinicio = sum(-1000*Sfonte)*Spercent;
    
    Yaux = [];

    for aux = 2:size(Carga,1)
        if(strcmp(Carga{aux,6},'Fase-Terra') || strcmp(Carga{aux,6},'Fase-Fase'))
            y = conj(Sinicio(aux-1,1))/Vnom(aux-1,1)^2;
            Yaux = [Yaux;y];
        else
            y = conj(Sinicio(aux-1,1))/(3*Vnom(aux-1,1)^2);
            Yaux = [Yaux;y;y;y];
        end
    end

    Zaux = 1./Yaux;
    switch dominio
        case 1
            chute = [real(Yaux); imag(Yaux)]';
        case 2
            chute = [real(Zaux); imag(Zaux)]';
    end
end