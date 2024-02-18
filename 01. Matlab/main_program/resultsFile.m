% Função que escreve os principais resultados do teste no arquivo de log, de modo que
% o usuário tenha um log de cada ensaio realizado, caso precise acessar
% resultados anteriores. Os argumentos de entrada são:
% * resY - armazena, para cada carga (linhas) os valores (colunas):
% admitância real, admitância estimada, Diferença entre os módulos da
% admitância real e estimada, diferença entre as fases, diferença entre as
% partes real e entre as partes imaginárias. Essas diferenças são expressas
% em termos de valor absoluto e valor percentual, o que totaliza 8 formas
% de cálculo de erro para a admitância de cada carga.
% * resZ - Idem a resY, utilizando a impedância.
% * maxRes - Armazena os valores máximos para cada uma das fórmulas de erro,
% nas formas absoluta e percentual, considerando impedância e admitância.
% Temos assim, 16 valores a serem armazenados nesse vetor a cada estimação.
% FreqZ - Tabela de frequências de erros percentuais para cada uma das 4
% formas de cálculo de erro (impedância);
% FreqY - Tabela de frequências de erros percentuais para cada uma das 4
% formas de cálculo de erro (admitância);
% time - tempo entre o início e o fim da estimação de carga;
% arq - id do arquivo aonde serão escritos os resultados.
% Dominio = 1 - Resolve a função objetivo no domínio das admitâncias;
% Dominio = 2 - Resolve a função objetivo no domínio das impedâncias;
function [] = resultsFile(resY,...
                          resZ,...
                          resS,...
                          time,...
                          arq)
res = [resY resZ resS];
id_res = {'Y','Z','S'};
for aux1 = 1:3
    fprintf(arq,'RESUME %s:\n\n',id_res{aux1});
    straux1 = [id_res{aux1} ' Real'];
    straux2 = [id_res{aux1} ' Estimated'];
    fprintf(arq,'\t%17s\t\t\t%18s\t\t%35s\t\t\t\t',...
                'Node',straux1,straux2);
    for aux2=12:size(res(aux1).resume,2)
        fprintf(arq,'\t\t%20s',res(aux1).resume{1,aux2});
    end
    fprintf(arq,'\n');
    for aux2=2:size(res(aux1).resume,1)
        fprintf(arq,'\t%20s',res(aux1).resume{aux2,1});
        fprintf(arq,'\t\t%10g + (%11g) * i\t\t%12g + (%12g) * i',...
                res(aux1).resume{aux2,2},res(aux1).resume{aux2,3},res(aux1).resume{aux2,4},res(aux1).resume{aux2,5});
        for aux3=12:size(res(aux1).resume,2)
            fprintf(arq,'\t\t%20g',res(aux1).resume{aux2,aux3});
        end
        fprintf(arq,'\n');
    end
    fprintf(arq,'\n\n');
    fprintf(arq,'Tabela de frequencias de erros - %s',id_res{aux1});
    fprintf(arq,'\n\n');
    fprintf(arq,'\t%30s',res(aux1).tabFreq{1,1});
    for aux2=2:size(res(aux1).tabFreq,2)
        fprintf(arq,'\t\t%30s',res(aux1).tabFreq{1,aux2});
    end
    fprintf(arq,'\n');
    for aux2=2:size(res(aux1).tabFreq,1)
        fprintf(arq,'\t%30g',res(aux1).tabFreq{aux2,1});
        for aux3=2:size(res(aux1).tabFreq,2)
            fprintf(arq,'\t\t%30g',res(aux1).tabFreq{aux2,aux3});
        end
        fprintf(arq,'\n');
    end
    fprintf(arq,'\n\n');
    fprintf(arq,'\nMaximum error for %s abs estimation is: %g.\n',id_res{aux1},res(aux1).maxResume{4,2});
    fprintf(arq,'Maximum %s abs error in percent is: %g %%.\n\n',id_res{aux1},res(aux1).maxResume{5,2});
end
fprintf(arq,'\nTime for execution is: %g seconds.\n', time);
    