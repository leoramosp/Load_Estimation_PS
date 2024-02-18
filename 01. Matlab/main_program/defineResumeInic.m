% Função que, a partir de uma grandeza estimada e uma grandeza de
% referência, constrói uma lista comparativa com vários tipo de erro.
% As listas geradas são:
% res - armazena, para cada carga (linhas) os valores (colunas):
% 1. ID da carga (1 coluna);
% 2. Valor real da grandeza (2 colunas, parte real e imaginária);
% 3. Valor estimado da grandeza (2 colunas, parte real e imaginária);
% 4. Módulo da diferença entre real e estimada (1 coluna)
% 5. Diferença do módulo entre real e estimada (1 coluna)
% 6. Fase da diferença entre real e estimada (1 coluna)
% 7. Diferença das fases entre real e estimada (1 coluna)
% 8. Diferença entre a parte real entre real e estimada (1 coluna)
% 9. Diferença entre a parte imaginária entre real e estimada (1 coluna)
% 10. Campo 4 dividido pelo módulo da grandeza real, percentual (1 coluna)
% 11. Campo 5 dividido pelo módulo da grandeza real, percentual (1 coluna)
% 12. Campo 6 dividido pelo módulo da fase da grandeza real, percentual (1 coluna)
% 13. Campo 7 dividido pelo módulo da fase da grandeza real, percentual (1 coluna)
% 14. Campo 8 dividido pelo módulo da parte real da grandeza real, percentual (1 coluna)
% 15. Campo 9 dividido pelo módulo da parte imaginária da grandeza real, percentual (1 coluna)
% maxRes - Armazena os valores máximos, mínimos, médios e os desvios
% padrão, além do coeficiente de variação das grandezas da tabela res.
% Freq - Tabela de frequências para cada um dos 6 erros percentuais da
% tabela res. Cada frequência é expressa em valor absoluto (qtde de cargas)
% e percentual (% de cargas), totalizando 12 colunas + 1 coluna para o
% identificador para cada carga.

function [res maxRes Freq] = defineResumeInic(resX,...      % Estrutura com resultados do teste
                                          data,...          % Estrutura com dados do sistema
                                          Root)             % Valor de referência - raiz

edges = [0:0.1:0.9, 1:1:9 10:10:100 Inf];
Root_c = complex(Root(:,1),Root(:,2));
Est_c = complex(resX.chute_inicial(:,1),resX.chute_inicial(:,2));
Delta = Root_c - Est_c;
% as formas utilizadas para cálculo do erro são: módulo da diferença e
% diferença dos módulos, argumento da diferença e diferença dos argumentos,
% além das diferenças nas partes real e imaginária, totalizando 56 figuras
% de erro possíveis.
Erro = [abs(Delta) abs(Root_c)-abs(Est_c) ...
         angle(Delta) angle(Root_c)-angle(Est_c) ...
         real(Delta) imag(Delta)];
ErroPercent = 100*(Erro./[abs(Root_c) abs(Root_c) ...
                   angle(Root_c) angle(Root_c) ...
                   real(Root_c) imag(Root_c)]);

MaxErro = max(abs(Erro));
MinErro = min(abs(Erro));
MaxErroPercent = max(abs(ErroPercent));
MinErroPercent = min(abs(ErroPercent));
MeanErro = mean(abs(Erro));
MeanErroPercent = mean(abs(ErroPercent));
stdErro = std(abs(Erro));
stdErroPercent = std(abs(ErroPercent));
cvErro = stdErro./MeanErro;
cvErroPercent = stdErroPercent./MeanErroPercent;

Freq =  [edges',...
        [0;cumsum(histcounts(abs(ErroPercent(:,1)),edges))'],...
        [0;cumsum(histcounts(abs(ErroPercent(:,2)),edges))'],...
        [0;cumsum(histcounts(abs(ErroPercent(:,3)),edges))'],...
        [0;cumsum(histcounts(abs(ErroPercent(:,4)),edges))'],...
        [0;cumsum(histcounts(abs(ErroPercent(:,5)),edges))'],...
        [0;cumsum(histcounts(abs(ErroPercent(:,6)),edges))']];
aux1 = [edges', (100/Freq(end,2))*Freq(:,2:end)];
Freq = [Freq(:,1),Freq(:,2),aux1(:,2),Freq(:,3),aux1(:,3),...
        Freq(:,4),aux1(:,4),Freq(:,5),aux1(:,5),Freq(:,6),aux1(:,6),...
        Freq(:,7),aux1(:,7)];
res = data.Load(1,2);
for aux1=2:size(data.Load,1)
    if(strcmp(data.Load{aux1,6},'3FT Wye') || strcmp(data.Load{aux1,6},'3FN Wye') || ...
       strcmp(data.Load{aux1,6},'3F Delta'))
        res = [res; data.Load{aux1,2};data.Load{aux1,2};data.Load{aux1,2}];
    else
        res = [res; data.Load{aux1,2}];
    end
end
maxRes = {'Erro Abs(Delta)','Erro Delta(Abs)','Erro Angle(Delta)',...
          'Erro Delta(Angle)','Erro Pt. Real', 'Erro Pt. Imag.'};

aux2 = sprintf('Re(%sraiz)',resX.id);
aux3 = sprintf('Im(%sraiz)',resX.id);
aux4 = sprintf('Re(%sest)',resX.id);
aux5 = sprintf('Im(%sest)',resX.id);
      
aux1 = {aux2, aux3, aux4, aux5,...
       'Erro - Abs(Delta)','Erro - Delta(Abs)',...
       'Erro - Arg(Delta)','Erro - Delta(Arg)',...
       'Erro - Real','Erro - Imag',...
       'Erro - Abs(Delta)(%)','Erro - Delta(Abs)(%)',...
       'Erro - Arg(Delta)(%)','Erro - Delta(Arg)(%)',...
       'Erro - Real(%)','Erro - Imag(%)'};
aux1 = [aux1; num2cell(Root(:,1)),num2cell(Root(:,2)),...
       num2cell(resX.chute_inicial(:,1)),num2cell(resX.chute_inicial(:,2)),...
       num2cell(Erro),num2cell(ErroPercent)];
res = [res,aux1];

maxRes = [maxRes;num2cell(MaxErro);num2cell(MaxErroPercent);...
          num2cell(MeanErro);num2cell(MeanErroPercent);...
          num2cell(stdErro);num2cell(stdErroPercent);...
          num2cell(cvErro);num2cell(cvErroPercent)];
aux1 = {'Indicador';...
       'MaxErro';'MaxErroPercent';'MeanError';'MeanErrorPercent';...
       'StdError';'StdErrorPercent';'cvError';'cvErrorPercent'};
maxRes = [aux1,maxRes];

aux1 = {'Erro (%)',...
       'Qte Cargas - Erro Abs(Delta)','% Cargas - Erro Abs(Delta)',...
       'Qte Cargas - Erro Delta(Abs)','% Cargas - Erro Delta(Abs)',...
       'Qte Cargas - Erro Angle(Delta)','% Cargas - Erro Angle(Delta)',...
       'Qte Cargas - Erro Delta(Angle)','% Cargas - Erro Delta(Angle)',...
       'Qte Cargas - Erro Real','% Cargas - Erro Real',...
       'Qte Cargas - Erro Imag','% Cargas - Erro Imag'};
Freq = [aux1;num2cell(Freq)];