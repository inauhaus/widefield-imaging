function f = adaptiveSmoother(gcomp,h)

% Estimate the local mean of f.
g = real(gcomp);
localMean = filter2(h, g);

% Estimate of the local variance of f.
localVar = filter2(h, g.^2) - localMean.^2; %var = E(x^2) - (E(x))^2

% Estimate the noise power if necessary.
%if (isempty(noise))
noise = mean2(localVar);
%end

% Compute result

f = g - localMean;
g = localVar - noise; 
g = max(g, 0); %fudge factor
localVar = max(localVar, noise); %fudge factor
f = f ./ localVar;
f = f .* g;
f = f + localMean;
fr = f;
%%%%

g = imag(gcomp);

% Estimate the local mean of f.
localMean = filter2(h, g);

% Estimate of the local variance of f.
localVar = filter2(h, g.^2) - localMean.^2; %var = E(x^2) - (E(x))^2

% Estimate the noise power if necessary.
%if (isempty(noise))
noise = mean2(localVar);
%end

% Compute result

f = g - localMean;
g = localVar - noise; 
g = max(g, 0); %fudge factor
localVar = max(localVar, noise); %fudge factor
f = f ./ localVar;
f = f .* g;
f = f + localMean;
fi = f;
%%%%%

f = fr + 1i*fi;