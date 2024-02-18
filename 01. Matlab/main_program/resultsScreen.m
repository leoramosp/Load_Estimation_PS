% Função que escreve os principais resultados do teste na tela, de modo que
% o usuário possa ter uma visão rápida do resultado de testes individuais,
% os argumentos da função são os principais valores de saída do ensaio
% individual:
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
% Freq - Tabela de frequências de erros percentuais para cada uma das 4
% formas de cálculo de erro (admitância ou impedância);
% time - tempo entre o início e o fim da estimação de carga;
% Dominio = 1 - Resolve a função objetivo no domínio das admitâncias;
% Dominio = 2 - Resolve a função objetivo no domínio das impedâncias;
function [] = resultsScreen(resY,resZ,maxRes,FreqY,FreqZ,time,dominio)
fprintf('RESUME:\n\n');
    switch dominio
        case 1
            fprintf('\t%17s\t\t\t%18s\t\t%35s\t\t\t\t',...
                        'Node','Y Real','Y Estimated');
            for aux1=12:size(resY,2)
                fprintf('\t\t%20s',resY{1,aux1});
            end
            fprintf('\n');
            for aux1=2:size(resY,1)
                fprintf('\t%20s',resY{aux1,1});
                fprintf('\t\t%10g + (%11g) * i\t\t%12g + (%12g) * i',...
                        resY{aux1,2},resY{aux1,3},resY{aux1,4},resY{aux1,5});
                for aux2=12:size(resY,2)
                    fprintf('\t\t%20g',resY{aux1,aux2});
                end
                fprintf('\n');
            end
            fprintf('\n\n');
            fprintf('Tabela de frequencias de erros - Y');
            fprintf('\n\n');
            fprintf('\t%30s',FreqY{1,1});
            for aux1=2:size(FreqY,2)
                fprintf('\t\t%30s',FreqY{1,aux1});
            end
            fprintf('\n');
            for aux1=2:size(FreqY,1)
                fprintf('\t%30g',FreqY{aux1,1});
                for aux2=2:size(FreqY,2)
                    fprintf('\t\t%30g',FreqY{aux1,aux2});
                end
                fprintf('\n');
            end
            fprintf('\n\n');
            fprintf('\nMaximum error for admitance abs estimation is: %g.\n',maxRes{4,2});
            fprintf('\nMaximum admitance abs error in percent is: %g %%.\n',maxRes{5,2});
        case 2
           fprintf('\t%14s\t\t%18s\t\t%35s',...
                        'Node','Z Real','Z Estimated');
            for aux1=12:size(resZ,2)
                fprintf('\t\t%20s',resZ{1,aux1});
            end
            fprintf('\n');
            for aux1=2:size(resZ,1)
                fprintf('\t%14s',resZ{aux1,1});
                fprintf('\t\t%10g + (%11g) * i\t\t%12g + (%12g) * i',...
                        resZ{aux1,2},resZ{aux1,3},resZ{aux1,4},resZ{aux1,5});
                for aux2=12:size(resZ,2)
                    fprintf('\t\t%20g',resZ{aux1,aux2});
                end
                fprintf('\n');
            end
            fprintf('\n\n');
            fprintf('Tabela de frequencias de erros - Z');
            fprintf('\n\n');
            fprintf('\t%20s',FreqZ{1,1});
            for aux1=2:size(FreqZ,2)
                fprintf('\t\t%20g',FreqZ{1,aux1});
            end
            fprintf('\n');
            for aux1=2:size(FreqZ,1)
                fprintf('\t%20g',FreqZ{aux1,1});
                for aux2=2:size(FreqZ,2)
                    fprintf('\t\t%20g',FreqZ{aux1,aux2});
                    fprintf('\n');
                end
            end
            fprintf('\n\n');
            fprintf('\nMaximum error for impedance abs estimation is: %g.\n',maxRes{2,2});
            fprintf('\nMaximum impedance abs error in percent is: %g %%.\n',maxRes{3,2});
    end   
    fprintf('\nTime for execution is: %g seconds.\n', time);