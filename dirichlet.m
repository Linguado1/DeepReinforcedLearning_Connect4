
function nu = dirichlet(Alpha, n)
    y=gamrnd(Alpha,1,1,n);
    nu = y./sum(y);
end

