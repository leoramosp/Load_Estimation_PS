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

function [res, maxRes, res_inic, maxRes_inic, res_comp, maxRes_comp, Freq] = ...
         defineResume(resX,...     % Estrutura com resultados do teste
                      data)        % Estrutura com dados do sistema

resX.Resume = [data.Load(1:end,2)];

switch resX.id
    case 'S'
        Root = data.Sraiz;
    case 'Y'
        Root = data.Yraiz;
    case 'Z'
        Root = data.Zraiz;
end

Root_c = complex(Root(:,1),Root(:,2));
Est_c = complex(resX.Estimado(:,1),resX.Estimado(:,2));
Inic_c = complex(resX.chute_inicial(:,1),resX.chute_inicial(:,2));
Delta = Root_c - Est_c;
Delta_inic = Root_c - Inic_c;
% -------------------------------------------------------------------------
% Erro de estimativa individual
% -------------------------------------------------------------------------
Erro = [abs(Delta) abs(Root_c)-abs(Est_c) ...
         angle(Delta) angle(Root_c)-angle(Est_c) ...
         real(Delta) imag(Delta)];
ErroPercent = 100*(Erro./[abs(Root_c) abs(Root_c) ...
                   angle(Root_c) angle(Root_c) ...
                   real(Root_c) imag(Root_c)]);
% -------------------------------------------------------------------------
Erro_inic = [abs(Delta_inic) abs(Root_c)-abs(Inic_c) ...
         angle(Delta_inic) angle(Root_c)-angle(Inic_c) ...
         real(Delta_inic) imag(Delta_inic)];
ErroPercent_inic = 100*(Erro_inic./[abs(Root_c) abs(Root_c) ...
                   angle(Root_c) angle(Root_c) ...
                   real(Root_c) imag(Root_c)]);
% -------------------------------------------------------------------------
Erro_comp = abs(Erro) - abs(Erro_inic);
ErroPercent_comp = abs(ErroPercent) - abs(ErroPercent_inic);
% -------------------------------------------------------------------------
% A comparação simples entre erros percentuais não é válida, pois são
% percentuais em relação a diferentes bases.
% -------------------------------------------------------------------------
% Definição de índices de erros estatísticos
% -------------------------------------------------------------------------
% Root matrix para definir algumas figuras de erro
Root_Matrix = [abs(Root_c) abs(Root_c) ...
         angle(Root_c) angle(Root_c) ...
         real(Root_c) imag(Root_c)];
SomaRoot = sum(abs(Root_Matrix),1);
% -------------------------------------------------------------------------
% Soma dos Erros
SomaErro = sum(abs(Erro),1);
SomaErro_inic = sum(abs(Erro_inic),1);
SomaErro_comp = SomaErro - SomaErro_inic;
% -------------------------------------------------------------------------
% Erro Máximo
MaxErro = max(abs(Erro));
MaxErro_inic = max(abs(Erro_inic));
MaxErro_comp = MaxErro - MaxErro_inic;
% -------------------------------------------------------------------------
% Erro Mínimo
MinErro = min(abs(Erro));
MinErro_inic = min(abs(Erro_inic));
MinErro_comp = MinErro - MinErro_inic;
% -------------------------------------------------------------------------
% Erro Máximo Percentual
MaxErroPercent = max(abs(ErroPercent));
MaxErroPercent_inic = max(abs(ErroPercent_inic));
MaxErroPercent_comp = (MaxErro_comp)./abs(MaxErro_inic);
% -------------------------------------------------------------------------
% Erro Mínimo Percentual
MinErroPercent = min(abs(ErroPercent));
MinErroPercent_inic = min(abs(ErroPercent_inic));
MinErroPercent_comp = (MinErro_comp)./abs(MinErro_inic);
% -------------------------------------------------------------------------
% Erro Médio
MeanAvgErro = mean(abs(Erro));
MeanAvgErro_inic = mean(abs(Erro_inic));
MeanAvgErro_comp = MeanAvgErro - MeanAvgErro_inic;
MeanAvgErroPercent_comp = 100*(MeanAvgErro_comp)./MeanAvgErro_inic;
% -------------------------------------------------------------------------
% Erro Percentual Sistêmico
MeanSysErroPercent = 100*(SomaErro./SomaRoot);
MeanSysErroPercent_inic = 100*(SomaErro_inic./SomaRoot);
MeanSysErroPercent_comp = MeanSysErroPercent - MeanSysErroPercent_inic;
% -------------------------------------------------------------------------
% Desvio padrão associado ao erro médio
stdAvgErro = std(abs(Erro));
stdAvgErro_inic = std(abs(Erro_inic));
stdAvgErro_comp = stdAvgErro - stdAvgErro_inic;
stdAvgErroPercent_comp = 100*(stdAvgErro_comp)./stdAvgErro_inic;
% -------------------------------------------------------------------------
% Coeficiente de variação associado ao erro médio
cvErroPercent = 100*stdAvgErro./MeanAvgErro;
cvErroPercent_inic = 100*stdAvgErro_inic./MeanAvgErro_inic;
cvErroPercent_comp = cvErroPercent - cvErroPercent_inic;
% -------------------------------------------------------------------------
% Desvio Padrão associado ao erro percentual sistêmico
stdSysErro = sqrt(mean((abs(ErroPercent)-(ones(size(ErroPercent,1),1)*MeanSysErroPercent)).^2));
stdSysErro_inic = sqrt(mean((abs(ErroPercent_inic)-(ones(size(ErroPercent_inic,1),1)*MeanSysErroPercent_inic)).^2));
stdSysErro_comp = stdSysErro - stdSysErro_inic;
% -------------------------------------------------------------------------
% Erro Percentual Médio Absoluto (MAPE, do inglês)
mape = mean(abs(ErroPercent));
mape_inic = mean(abs(ErroPercent_inic));
mape_comp = mape - mape_inic;
% -------------------------------------------------------------------------
% Desvio Padrão associado ao MAPE
stdMape = sqrt(mean((abs(ErroPercent)-(ones(size(ErroPercent,1),1)*mape)).^2));
stdMape_inic = sqrt(mean((abs(ErroPercent)-(ones(size(ErroPercent,1),1)*mape_inic)).^2));
stdMape_comp = stdMape - stdMape_inic;

% -------------------------------------------------------------------------
% Construção da tabela de frequências
edges = [0:0.1:0.9, 1:1:9 10:10:100 Inf];
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
aux1 = {'Erro (%)',...
       'Qte Cargas - Erro Abs(Delta)','% Cargas - Erro Abs(Delta)',...
       'Qte Cargas - Erro Delta(Abs)','% Cargas - Erro Delta(Abs)',...
       'Qte Cargas - Erro Angle(Delta)','% Cargas - Erro Angle(Delta)',...
       'Qte Cargas - Erro Delta(Angle)','% Cargas - Erro Delta(Angle)',...
       'Qte Cargas - Erro Real','% Cargas - Erro Real',...
       'Qte Cargas - Erro Imag','% Cargas - Erro Imag'};
Freq = [aux1;num2cell(Freq)];
% -------------------------------------------------------------------------
% Construção da tabela de resultados individuais
res = data.Load(1,2);
for aux1=2:size(data.Load,1)
    if(strcmp(data.Load{aux1,6},'3FT Wye') || strcmp(data.Load{aux1,6},'3FN Wye') || ...
       strcmp(data.Load{aux1,6},'3F Delta'))
        res = [res; data.Load{aux1,2};data.Load{aux1,2};data.Load{aux1,2}];
    else
        res = [res; data.Load{aux1,2}];
    end
end

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
       num2cell(resX.Estimado(:,1)),num2cell(resX.Estimado(:,2)),...
       num2cell(Erro),num2cell(ErroPercent)];
res = [res,aux1];
% -------------------------------------------------------------------------
% Construção da tabela de resultados individuais da estimativa inicial
res_inic = data.Load(1,2);
for aux1=2:size(data.Load,1)
    if(strcmp(data.Load{aux1,6},'3FT Wye') || strcmp(data.Load{aux1,6},'3FN Wye') || ...
       strcmp(data.Load{aux1,6},'3F Delta'))
        res_inic = [res_inic; data.Load{aux1,2};data.Load{aux1,2};data.Load{aux1,2}];
    else
        res_inic = [res_inic; data.Load{aux1,2}];
    end
end

aux4 = sprintf('Re(%sinic)',resX.id);
aux5 = sprintf('Im(%sinic)',resX.id);
      
aux1 = {aux2, aux3, aux4, aux5,...
       'Erro - Abs(Delta)','Erro - Delta(Abs)',...
       'Erro - Arg(Delta)','Erro - Delta(Arg)',...
       'Erro - Real','Erro - Imag',...
       'Erro - Abs(Delta)(%)','Erro - Delta(Abs)(%)',...
       'Erro - Arg(Delta)(%)','Erro - Delta(Arg)(%)',...
       'Erro - Real(%)','Erro - Imag(%)'};
aux1 = [aux1; num2cell(Root(:,1)),num2cell(Root(:,2)),...
       num2cell(resX.chute_inicial(:,1)),num2cell(resX.chute_inicial(:,2)),...
       num2cell(Erro_inic),num2cell(ErroPercent_inic)];
res_inic = [res_inic,aux1];

% -------------------------------------------------------------------------
% Construção da tabela de resultados individuais comparativos
res_comp = data.Load(1,2);
for aux1=2:size(data.Load,1)
    if(strcmp(data.Load{aux1,6},'3FT Wye') || strcmp(data.Load{aux1,6},'3FN Wye') || ...
       strcmp(data.Load{aux1,6},'3F Delta'))
        res_comp = [res_comp; data.Load{aux1,2};data.Load{aux1,2};data.Load{aux1,2}];
    else
        res_comp = [res_comp; data.Load{aux1,2}];
    end
end

aux1 = {'Erro - Abs(Delta)','Erro - Delta(Abs)',...
        'Erro - Arg(Delta)','Erro - Delta(Arg)',...
        'Erro - Real','Erro - Imag',...
        'Erro - Abs(Delta)(%)','Erro - Delta(Abs)(%)',...
        'Erro - Arg(Delta)(%)','Erro - Delta(Arg)(%)',...
        'Erro - Real(%)','Erro - Imag(%)'};
aux1 = [aux1; num2cell(Erro_comp),num2cell(ErroPercent_comp)];
res_comp = [res_comp,aux1];

% -------------------------------------------------------------------------
% Construção da tabela de resultados estatísticos

maxRes = {'Erro Abs(Delta)','Erro Delta(Abs)','Erro Angle(Delta)',...
          'Erro Delta(Angle)','Erro Pt. Real', 'Erro Pt. Imag.'};
maxRes = [maxRes;num2cell(MaxErro);num2cell(MaxErroPercent);...
          num2cell(MinErro);num2cell(MinErroPercent);...
          num2cell(MeanAvgErro);num2cell(MeanSysErroPercent);...
          num2cell(stdAvgErro);num2cell(cvErroPercent);...
          num2cell(stdSysErro);num2cell(mape);num2cell(stdMape)];
aux1 = {'Indicador';...
       'MaxErro';'MaxErroPercent';'MinErro';'MinErroPercent';
       'MeanAvgError';'MeanSysErrorPercent';...
       'stdAvgError';'cvErrorPercent';'stdSysError';...
       'mape';'stdMape'};
maxRes = [aux1,maxRes];

% -------------------------------------------------------------------------
% Construção da tabela de resultados estatísticos da estimativa inicial

maxRes_inic = {'Erro Abs(Delta)','Erro Delta(Abs)','Erro Angle(Delta)',...
          'Erro Delta(Angle)','Erro Pt. Real', 'Erro Pt. Imag.'};
maxRes_inic = [maxRes_inic;num2cell(MaxErro_inic);num2cell(MaxErroPercent_inic);...
          num2cell(MinErro_inic);num2cell(MinErroPercent_inic);...
          num2cell(MeanAvgErro_inic);num2cell(MeanSysErroPercent_inic);...
          num2cell(stdAvgErro_inic);num2cell(cvErroPercent_inic);...
          num2cell(stdSysErro_inic);num2cell(mape_inic);num2cell(stdMape_inic)];
aux1 = {'Indicador';...
       'MaxErroInic';'MaxErroPercentInic';'MinErroInic';'MinErroPercentInic';
       'MeanAvgErrorInic';'MeanSysErrorPercentInic';...
       'stdAvgErrorInic';'cvErrorPercentInic';'stdSysErrorInic';...
       'mapeInic';'stdMapeInic'};
maxRes_inic = [aux1,maxRes_inic];

% -------------------------------------------------------------------------
% Construção da tabela de resultados estatísticos comparativos

maxRes_comp = {'Erro Abs(Delta)','Erro Delta(Abs)','Erro Angle(Delta)',...
          'Erro Delta(Angle)','Erro Pt. Real', 'Erro Pt. Imag.'};
maxRes_comp = [maxRes_comp;num2cell(MaxErro_comp);num2cell(MaxErroPercent_comp);...
          num2cell(MinErro_comp);num2cell(MinErroPercent_comp);...
          num2cell(MeanAvgErro_comp);num2cell(MeanAvgErroPercent_comp);...
          num2cell(MeanSysErroPercent_comp);...
          num2cell(stdAvgErro_comp);num2cell(stdAvgErroPercent_comp);...
          num2cell(cvErroPercent_comp);num2cell(stdSysErro_comp);...
          num2cell(mape_comp);num2cell(stdMape_comp)];
aux1 = {'Indicador';...
       'MaxErroComp';'MaxErroPercentComp';'MinErroComp';'MinErroPercentComp';
       'MeanAvgErrorComp';'MeanAvgErrorPercentComp';'MeanSysErrorPercentComp';...       
       'stdAvgErrorComp';'stdAvgErrorPercentComp';'cvErrorPercentComp';...
       'stdSysErrorComp';'mapeComp';'stdMapeComp'};
maxRes_comp = [aux1,maxRes_comp];
