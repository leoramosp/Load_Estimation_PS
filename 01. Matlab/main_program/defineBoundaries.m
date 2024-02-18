function [UBound LBound verify] = defineBoundaries(initial_guess,...
                                                   Root,...
                                                   domain)
% 1 - Boudaries baseados na estimativa inicial
% switch domain
%     case 1
%         UBound = [1.25*initial_guess(:,1:length(initial_guess)/2),...
%               0.1*initial_guess(:,1+length(initial_guess)/2:end)];
%         LBound = [0.1*initial_guess(:,1:length(initial_guess)/2),...
%               1.25*initial_guess(:,1+length(initial_guess)/2:end)];
%     case 2
%         UBound = 1.25*initial_guess;
%         LBound = 0.1*initial_guess;
% end
% 
% verifyRoot = [];
% verifyUB = [];
% verifyLB = [];
% verify = [];
% if(~isempty(find(Root>UBound)) || ~isempty(find(Root<LBound)))
%     verifyRoot = [LBound; initial_guess; Root; UBound];
%     verifyUB = find(Root>UBound);
%     verifyLB = find(Root<LBound);
%     verify = sprintf('Região entre LB e UB não compreende Raiz.');
% else
%      verify = sprintf('Boundaries OK.');
% end



% 2 - Boudaries baseados na raiz
switch domain
    case 1
        UBound = [1.25*Root(:,1:length(Root)/2),...
              0.1*Root(:,1+length(Root)/2:end)];
        LBound = [0.1*Root(:,1:length(Root)/2),...
              1.25*Root(:,1+length(Root)/2:end)];
    case 2
        UBound = 1.25*Root;
        LBound = 0.1*Root;
end

verifyguess = [];
verifyUB = [];
verifyLB = [];
verify = [];
if(~isempty(find(initial_guess>UBound)) || ~isempty(find(initial_guess<LBound)))
    verifyguess = [LBound; initial_guess; Root; UBound];
    verifyUB = find(initial_guess>UBound);
    verifyLB = find(initial_guess<LBound);
    verify = sprintf('Região entre LB e UB não compreende chute inicial.');
%     break;
else
     verify = sprintf('Boundaries OK.');
end