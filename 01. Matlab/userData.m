% DEFINIÇÃO DE CONFIGURAÇÕES PRINCIPAIS DE SIMULAÇÃO

% 1. CONFIGURAÇÕES DA VARIÁVEL MAINSET:
% As versions representam formas de calcular o valor da função de otimização:
% 1 - Função objetivo f = max(abs(delta)), sendo delta = I - h(y);
% 2 - Função objetivo f = max(abs(delta)), sendo delta = V - h(y);
% 3 - Função objetivo f = max([abs(Re(delta));abs(Imag(delta))]),sendo delta = I - h(y);
% 4 - Função objetivo f = max([abs(Re(delta));abs(Imag(delta))]), sendo delta = V - h(y);
% 5 - Função objetivo f = max(abs(delta)), sendo delta = (I - h(y))/I;
% 6 - Função objetivo f = max(abs(delta)), sendo delta = (V - h(y))/V;
% 7 - Função objetivo f = max([abs(Re(delta))./abs(Re(I));abs(Imag(delta))./abs(Imag(I))]), sendo delta = I - h(y);
% 8 - Função objetivo f = max([abs(Re(delta))./abs(Re(V));abs(Imag(delta))./abs(Imag(V))]), sendo delta = V - h(y);
% 9 - Função objetivo f = max(abs(real(delta))), sendo delta = I - h(y);
% 10 - Função objetivo f = max(abs(real(delta))), sendo delta = V - h(y);
% 11 - Função objetivo f = max(abs(imag(delta))), sendo delta = I - h(y);
% 12 - Função objetivo f = max(abs(imag(delta))), sendo delta = V - h(y);
% 13 - Função objetivo f = max(abs(real(delta))), sendo delta = (I - h(y))/I;
% 14 - Função objetivo f = max(abs(real(delta))), sendo delta = (V - h(y))/V;
% 15 - Função objetivo f = max(abs(imag(delta))), sendo delta = (I - h(y))/I;
% 16 - Função objetivo f = max(abs(imag(delta))), sendo delta = (V - h(y))/V;
mainset.version = 1;
% * mainset.restriction - 0 para não utilizar restrições não lineares, 1 caso contrário;
mainset.restriction = 0; 
% 1 para restrição por fator de potência;
% 2 para restrição por nível de tensão nas barras;
% 3 para restrição de carregamento dos transformadores;
% 4 para restrição por medição de tensão;
% 5 para restrição por medição de corrente;

% 2. DEFINIÇÃO DAS BARRAS COM MEDIÇÃO DE TENSÃO E CORRENTE

% IEEE13 BARRAS
%         barraVmed13 = {'670' '671' '632'}; % Barras do Tronco Principal
        barraVmed13 = {'670'}; % Divisão em areas de mediçao
%         barraVmed13 = {'634' '675'}; % Barras com piores estimações
%         elemImed13 = {'632670' '670671' '650632'}; % Linhas do tronco principal com melhores resultados na tensão
        elemImed13 = {'632670'}; % Divisão em áreas de mediçao
%         elemImed13 = {'632633' '692675'}; % Elementos com piores medições.
% PS: a barra 634 fica conectada a um transformador, por isso não
% tem como medir corrente, dado que o processo só trabalha com
% medição em linhas. Por isso, foi escolhida a linha 632633 que faz
% parte do ramo que contém a carga 634.

% IEEE34 BARRAS
%         barraVmed34 = {'808' '816' '824' '854' '832' '858' '834' '836'};
%         elemImed34 = {'L1' 'L24' 'L9' 'L15' 'L25' 'L16' 'L29' 'L30'};

% IEEE37 BARRAS
%         barraVmed37 = {'701' '718'}; % Barras piores estimativas
%         barraVmed37 = {'702' '703' '709' '708' '734' '711'}; % Barras com derivações
        barraVmed37 = {'709'}; % Divisão em areas de mediçao
%         barraVmed37 = {'701' '702' '703' '730' '709' '708' '733' '734' '737' '738' '711' '741'}; % tronco principal
%         elemImed37 = {'L35' 'L23'}; % Linhas chegam nas barras com piores medições
%         elemImed37 = {'L1' 'L4' 'L27' 'L17' 'L28' 'L32'}; % Linhas chegam nas barras com derivações
        elemImed37 = {'L27'}; % Divisão em areas de medição
%         elemImed37 = {'L35' 'L1' 'L4' 'L6' 'L27' 'L17' 'L14' 'L28' ...
%                     'L31' 'L29' 'L32' 'L20'}; % Linhas chegam nas barras do tronco principal
% IEEE123 BARRAS
%         barraVmed123 = {'1' '13' '15' ...
%                         '18' '35' '36' '40' '42' '44' '47' ...
%                         '21' '23' '25' '26' '27' ...
%                         '54' '57' '60' '67' '110' '108' '105' '101' ...
%                         '97' '72' '76' '78' '81' '87' '89' '91' '93' ...
%                         '95'}; % barras de derivação
%         barraVmed123 = {'13' ...
%                         '18' '35' ...
%                         '54' '97' '72'}; % principais derivações
        barraVmed123 = {'72'}; % divisão em 2 áreas de mediçao
%         elemImed123 =  {'L10' ...
%                         'L13' 'L114' 'L35' 'L36' 'L41' 'L43' 'L45'...
%                         'L19' 'L22' 'L24' 'L25' 'L27' ...
%                         'L53' 'L55' 'L58' 'L117' 'L109' 'L105' 'L101' 'L118' ...
%                         'L68' 'L67' 'L73' 'L78' 'L81' 'L86' 'L88' 'L90' 'L92' ...
%                         'L94'}; % linhas até as barras de derivação
%         elemImed123 =  {'L115' 'L10' 'L34' ...
%                         'L13' 'L114' ...
%                         'L53' 'L68' 'L67'}; % linhas até as principais derivações.
        elemImed123 =  {'L67'}; % divisão em 2 áreas de medição