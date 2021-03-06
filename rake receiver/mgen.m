%m sequence generation/mgen.m
function[out] = mgen(g,state,N)
%test g = 11;state = 3;N = 15;

gen = dec2bin(g)-48;
M = length(gen);
curState = dec2bin(state,M-1) - 48;

for  k = 1:N
    out(k) = curState(M-1);
    a = rem(sum(gen(2:end).*curState),2);
    curState = [a curState(1:M-2)];
end