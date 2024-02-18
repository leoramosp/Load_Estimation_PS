% Organiza nomenclaturas para serem melhor interpretadas pelo algoritmo. É
% desejável que essa função seja aplicável a qualquer string ou arrays de
% strings.
% No geral, essa função:
% 1 - remove caracteres não numéricos da nomenclatura das barras, mantendo
% apenas os pontos que separam o nome das barras do número das fases;
% Obs: se caracteres não numéricos foram utilizados na nomenclatura nativa do
% modelo no OpenDSS para distinguir entre duas barras (ex: barra 799 e
% barra 799r), então esse caractere não numérico será mantido;
% 2 - depois da ação 1, a função faz com que a nomenclatura de todas as
% barras, excluindo-se os pontos e números das fases, tenham um comprimento
% fixo de 5 caracteres, completando com zeros a nomenclatura das barras 
% abaixo desse comprimento (ex: barra 799.1.2 será 00799.1.2 e barra
% 799r.1.2 será 0799r.1.2).
function f = organizeNames(name)
% -------------------------------------------------------------------------
% 1) Organiza a variável de entrada em células
% -------------------------------------------------------------------------
if(~iscell(name))
    f = {name};
else
    f = name;
end
% -------------------------------------------------------------------------
% 2) Retira partes não-numéricas da nomenclatura. Esse código deve ser
% sempre revisto quando um circuito novo do OpenDSS for incluído. A única
% parte não numérica que permanece na nomenclatura após esse código é uma
% letra ao final de alguns barramentos, de modo a diferenciar barras
% repetidas (ex: 799r e 799 no mesmo circuito). Desse modo, strings antes
% da numeração são substituídas por 0 enquanto strings ao final da
% numeração são reduzidas a um único caractere, pois nesse caso geralmente
% servem para diferenciar duas barras.
% Idéias para melhorar a função:
% 1 - a expressão newf = regexprep(f(i,j), '[a-zA-Z]', ''); remove todas as
% letras da string (i,j) do array f e armazena o resultado no array newf.
% 2 - a expressão newf = regexprep(f(i,j), '^[0-9]', ''); remove todos os
% dígitos que não forem numéricos (caractere "^" quer dizer "não")
% da string (i,j) do array f e armazena o resultado no array newf.
% -------------------------------------------------------------------------
f = regexprep(f,'"','');
f = regexprep(f,'SOURCEBUS','0');
f = regexprep(f,'sourcebus','0');
f = regexprep(f,'RG','0');
f = regexprep(f,'rg','0');
f = regexprep(f,'_OPEN','A');
f = regexprep(f,'_open','A');
% -------------------------------------------------------------------------
% 3) Deixa as strings com comprimento fixo, sem contar as marcações das
% fases. As fases (utilizadas principalmente em barras com ligações
% monofásicas) são marcadas por um ponto "." seguido da numeração da
% fase considerada (ex: 609.1 significa fase 1 do barramento 609). Nesse
% caso considerando um comprimento fixo de 5 caracteres, a barra 609 será
% nomeada como 00609 e a fase 1 desse barramento será 00609.1
% -------------------------------------------------------------------------
for aux1=1:size(f,1)
    for aux2=1:size(f,2)
        cell_aux = strsplit(f{aux1,aux2},'.');
        sizeName = length(cell_aux{1,1});
        for aux3=1:5-sizeName
            f{aux1,aux2} = ['0' f{aux1,aux2}];
        end
    end
end