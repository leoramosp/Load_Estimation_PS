% recebe uma matriz vector [a_ij] de dimensão  2n_l×1 e retorna uma 
% matriz [b_ij] de dimensão n_l×2, tal que:
% [b_i1]=[a_i1]
% [b_i2]=[a_(i+n_l)1], sendo i?n_l
function [v] = unModifyVector(vector)
    n = size(vector,2)/2;
    v = [vector(1,1:n);vector(1,n+1:end)]';