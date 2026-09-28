classdef EventDisplay < handle
    % EventDisplay lets you choose which tracks to plot.
    %   Depending on your choice of minimum transverse momentum (MinTM) and minimum
    %   impact parameter (MinIP) you can choose to either only plot tracks
    %   that satisfy these restrictions (MinPoints) or emphasise these by plotting in a
    %   different colour (MinColour).

    properties(Access=protected)
        dat % cdf data file
        event % cdf event
    end
    properties(Access=public)
        MinTM % minimum transverse momentum
        MinIP % minimum impact parameter
    end

    methods

        % constructor
        function obj = EventDisplay(d)
            obj.dat = d;
            obj.MinTM = 0;
            obj.MinIP = 0;
        end

        % return true if file is open (and valid)
        function result = isOpen(obj)
            d = obj.dat; % this and the next couple of methods are just stolen from CdfDataFile
            result = d.isOpen;
        end

        % close file
        function close(obj)
            d = obj.dat;
            d.close;
        end

        % start reading again from the beginning
        function rewind(obj)
            d = obj.dat;
            d.rewind;
        end

        % get next event
        function next(obj)
            d = obj.dat;
            obj.event = d.next;
        end

        % extracts a modified CdfTrack with transverse momentum higher than
        % or equal to MinTM
        function mtm = MinTransMom(obj)
            tr = obj.event.tracks(); % extracting the array with all the track parameters
            k = 0.002116; % unit conversion thing from cm^-1 to GeV/c
            h=[]; % initialising with an empty array
            for i = 1:numel(tr)
                h(i) = tr(i).curvature; % extracting an array with only curvature
            end
            tm = k./h; % equation for transverse momentum
            j=1;
            mtm = CdfTrack(zeros(5, 1));
            for i = 1:numel(tm)
                if tm(i) >= obj.MinTM % only values larger than MinTM allowed
                    mtm(j) = tr(i); 
                    j = j+1; % so that there isn't random space when the inequality isn't satisfied
                end
                if exist("mtm") == 0 % if no tracks satisfy the requirement...
                    mtm = []; % ...we need to make sure mtm still exists to plot
                end
            end

        end

        % extracts a modified CdfTrack with impact parameter higher than or
        % equal to MinIP
        function mip = MinImpPar(obj) % same code as before but for the impact parameter instead
            tr = obj.event.tracks();
            d0=[];
            for i = 1:numel(tr)
                d0(i) = tr(i).d0;
            end
            j=1;
            mip = CdfTrack(zeros(5, 1));
            for i = 1:numel(d0)
                if d0(i) >= obj.MinIP
                    mip(1,j) = tr(i);
                    j = j+1;
                end
            end
            if exist("mip") == 0
                mip = [];
            end
        end

        % plots tracks larger than MinTM
        function MinPointsTM(obj)
            tt = 0:pi/100:pi/4;
            tr = obj.MinTransMom();
            hold off;
            for i = 1:numel(tr)
                v = Helix(tr(i)).points(tt);
                figure(1) % figures must be numbered so the program doesnt get confused
                plot3(v(3,:), v(1,:), v(2,:), "b");
                if i == 1
                    hold on
                    axis([0 200 -100 100 -100 100]) % to make it centred about (0,0,100) in the written coords (not MATLAB coords!!)
                    xlabel('z [cm]')
                    ylabel('x [cm]')
                    zlabel('y [cm]')
                end
            end
            hold off;
            for i = 1:numel(tr)
                v = Helix(tr(i)).points(tt);
                figure(2)
                plot(v(1,:), v(2,:), "b");
                if i == 1
                    hold on
                    axis([-100 100 -100 100])
                    xlabel('x [cm]')
                    ylabel('y [cm]')
                end
            end
        end

        % plots tracks larger than MinIP
        function MinPointsIP(obj)
            tt = 0:pi/100:pi/4;
            tr = obj.MinImpPar();
            hold off;
            for i = 1:numel(tr)
                v = Helix(tr(i)).points(tt);
                figure(3) % figures are numbered from 3 instead of 1 in case you want to run MinPointsTM at the same time
                plot3(v(3,:), v(1,:), v(2,:), "b");
                if i == 1
                    hold on
                    axis([0 200 -100 100 -100 100])
                    xlabel('z [cm]')
                    ylabel('x [cm]')
                    zlabel('y [cm]')
                end
            end
            hold off;
            for i = 1:numel(tr)
                v = Helix(tr(i)).points(tt);
                figure(4)
                plot(v(1,:), v(2,:), "b");
                if i == 1
                    hold on
                    axis([-100 100 -100 100])
                    xlabel('x [cm]')
                    ylabel('y [cm]')
                end
            end
        end

        % plots tracks larger than MinTM in red
        function MinColourTM(obj)
            tt = 0:pi/100:pi/4;
            tr1 = obj.MinTransMom(); % all the tracks satisfying the requirement
            obj.rewind
            ev2 = obj.next();
            obj.rewind
            tr2 = ev2.tracks(); % all of the tracks
            hold off;
            for i = 1:numel(tr2)
                v = Helix(tr2(i)).points(tt);
                figure(1)
                plot3(v(3,:), v(1,:), v(2,:), "b");
                if i == 1
                    hold on
                    axis([0 200 -100 100 -100 100])
                    xlabel('z [cm]')
                    ylabel('x [cm]')
                    zlabel('y [cm]')
                end
            end
            for i = 1:numel(tr1)
                w = Helix(tr1(i)).points(tt);
                r(i) = plot3(w(3,:), w(1,:), w(2,:), "r"); % collecting all red tracks
            end
            uistack(r,"top") % putting the red tracks over the blue tracks
            hold off;
            for i = 1:numel(tr2)
                x = Helix(tr2(i)).points(tt);
                figure(2)
                plot(x(1,:), x(2,:), "b");
                if i == 1
                    hold on
                    axis([-100 100 -100 100])
                    xlabel('x [cm]')
                    ylabel('y [cm]')
                end
            end
            for i = 1:numel(tr1)
                y = Helix(tr1(i)).points(tt);
                r(i) = plot(y(1,:), y(2,:), "r");
            end
            uistack(r,'top')
        end

        % plots tracks larger than MinIP in red
        function MinColourIP(obj)
            tt = 0:pi/100:pi/4; 
            obj.rewind
            ev2 = obj.next();
            obj.rewind
            tr2 = ev2.tracks();
            tr1 = obj.MinImpPar();
            hold off;
            for i = 1:numel(tr1)
                v = Helix(tr1(i)).points(tt);
                figure(3)
                r(i) = plot3(v(3,:), v(1,:), v(2,:), "r");
                if i == 1
                    hold on
                    axis([0 200 -100 100 -100 100])
                    xlabel('z [cm]')
                    ylabel('x [cm]')
                    zlabel('y [cm]')
                end
            end
            for i = 1:numel(tr2)
                w = Helix(tr2(i)).points(tt);
                plot3(w(3,:), w(1,:), w(2,:), "b");
            end
            uistack(r,'top')
            hold off;
            for i = 1:numel(tr1)
                x = Helix(tr1(i)).points(tt);
                figure(4)
                r(i) = plot(x(1,:), x(2,:), "r");
                if i == 1
                    hold on
                    axis([-100 100 -100 100])
                    xlabel('x [cm]')
                    ylabel('y [cm]')
                end
            end
            for i = 1:numel(tr2)
                y = Helix(tr2(i)).points(tt);
                plot(y(1,:), y(2,:), "b");
            end
            uistack(r,'top')
        end



    end % methods
end % classdef
