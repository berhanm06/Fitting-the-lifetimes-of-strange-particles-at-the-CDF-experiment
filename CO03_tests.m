t(1) = CdfTrack([ 0.1; 0.0053; 0.01; 0.1; 2.0 ]);
t(2) = CdfTrack([ 0.2; -0.0020; -0.04; 0.2; 2.5 ]);
h = Helix(t);
v = h(1).intersect(h(2))
h(1).p3(h(1).points(pi/2))

%tt = 0:pi/1000:pi/4; % 0 to 90 degrees
%hold off; % start a new plot
%for index = 1:numel(t(1))
%    v = Helix(t(1)).points(tt);
%    plot3(v(3,:), v(1,:), v(2,:));
%    if index == 1
%        hold on; % superimpose subsequent tracks
%        axis([-100 100 -100 100 -100 100]); % tracking volume radius ~1m
%        xlabel('z [cm]'); % beamline
%        ylabel('x [cm]');
%        zlabel('y [cm]');
%        grid on
%    end
%end
%for index = 1:numel(t(2))
%    v = Helix(t(2)).points(tt);
%    plot3(v(3,:), v(1,:), v(2,:));
%    if index == 1
%        hold on; % superimpose subsequent tracks
%        axis([-100 100 -100 100 -100 100]); % tracking volume radius ~1m
%        xlabel('z [cm]'); % beamline
%        ylabel('x [cm]');
%        zlabel('y [cm]');
%        grid on
%    end
%end
