
% ===== Local function(s) must be BELOW the main function =====
function r = truncated_exponential_rvs(lam, a, b, sz)
    if nargin < 4, sz = [1 1]; end

    Fa = 1 - exp(-lam .* a);
    Fb = 1 - exp(-lam .* b);

    u0 = rand(sz);
    u  = Fa + (Fb - Fa) .* u0;

    r  = -log(1 - u) ./ lam;
end
