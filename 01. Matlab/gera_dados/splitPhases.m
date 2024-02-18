% É costume, na nomenclatura do OpenDSS, nomear terminais que são
% conectados a mais de uma fase com o nome das duas fases, como 609.1.2,
% por exemplo. Isso significa que o terminal está conectado as fases 1 e 2
% do barramento 609. Essa função devolve um array com o nome das barras e
% fases em que o terminal está conectado. Para o caso 609.1.2 a função deve
% devolver o vetor [609.1; 609.2]. O argumento de entrada deverá ser uma
% string. Já o valor de saída f será sempre um array de células.
function f = splitPhases(Bus)
cell_aux = strsplit(Bus,'.');
f = [];
if(size(cell_aux,2)<=1)
    f = {Bus};
else
    for aux=2:size(cell_aux,2)
        f = [f; {[cell_aux{1} '.' cell_aux{aux}]}];
    end
end