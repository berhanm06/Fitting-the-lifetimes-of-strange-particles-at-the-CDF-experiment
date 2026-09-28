la = LambdaAnalysis;
loop = Loop('cdf.dat');
loop.run(la)
la.mass.plot();
xlabel('mass [GeV/c^2]');
ylabel('entries/(2 MeV/c^2)');
