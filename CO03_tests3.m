kb = K0SAnalysis();
kb.minlxy = -999;
kb.mind0 = 0;
loop = Loop('cdf.dat');
loop.run(kb);
x = kb.ct.bins();
sig = kb.ct.data - kb.ctside.data;
err = sqrt(kb.ct.data + kb.ctside.data);
[A, ctau] = meshgrid(11:60,2.1:0.1:7);
chisquared = zeros(50);
for i = 2:numel(x)
    chisquared = chisquared + ((sig(i) - (A ./ ctau) .* exp(-x(i) ./ ctau)) ./ err(i)) .^ 2;
end
surf(A,ctau,chisquared)
xlabel('A')
ylabel('c * mean lifetime [cm]')
zlabel('chi squared value')
