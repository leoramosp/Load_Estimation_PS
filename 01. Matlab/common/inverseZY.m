% Recebe uma matriz vector [a_ij] de dimensão n_l×2 e retorna uma matriz
% [b_ij] de mesma dimensão, tal que: b_i1+i.b_i2=1/((a_i1+i.a_i2 ) )

function inv = inverseZY(vetor)
complexo = complex(vetor(:,1),vetor(:,2));
inverso = 1./complexo;
inv = [real(inverso) imag(inverso)];