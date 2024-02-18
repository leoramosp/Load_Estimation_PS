function resV = obtainVest(data,resY)

Yrede = cell2mat(data.Yrede_list(2:end,2:end));
Yestimado = resY.Estimado;
Ypos = data.Ypos;
Iinj = cell2mat(data.Iorder(2:end,2));
Vmed = cell2mat(data.Vorder(2:end,2));
Yl=defineYLoad(Yestimado,Yrede,Ypos);
Ysistema = Yrede + Yl;
Vestimado = Ysistema\Iinj;
resV.ErroV1 = 100*(abs(Vestimado) - abs(Vmed))./abs(Vestimado);
resV.ErroV2 = 100*(angle(Vestimado) - angle(Vmed))./angle(Vestimado);
resV.ErroV3 = 100*abs(real(Vestimado) - real(Vmed))./abs(real(Vestimado));
resV.ErroV4 = 100*abs(imag(Vestimado) - imag(Vmed))./abs(imag(Vestimado));
resV.ErroV = [num2cell(resV.ErroV1) num2cell(resV.ErroV2) ...
                  num2cell(resV.ErroV3) num2cell(resV.ErroV4)];
resV.ErroV = [data.Vorder(2:end,1) resV.ErroV];
% clear Yrede Yestimado Ypos Iinj Vmed Yl Ysistema Vestimado;
% save('variables.mat','resultsV','-append');

% Esse código tenta estimar o erro nas tensões nodais a partir da carga
% estimada. O que temos é que o erro de tensão nodal para a carga estimada
% é muito pequeno.