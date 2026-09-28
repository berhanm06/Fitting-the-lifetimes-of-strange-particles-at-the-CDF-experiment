[A, ctau] = meshgrid(101:150,5.1:0.1:10);
chisquared = zeros(50);
for i = 2:numel(x)
    chisquared = chisquared + ((sig(i) - (A ./ ctau) .* exp(-x(i) ./ ctau)) ./ err(i)) .^ 2;
end
surf(A,ctau,chisquared)
xlabel('A')
ylabel('c * mean lifetime [cm]')
zlabel('chi squared value')
