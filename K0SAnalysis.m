classdef K0SAnalysis < Analysis

    properties (Constant)
        mp = 0.13957
        mk = 0.497614
    end
    properties (Access=protected)
        massarray % contains all the masses
        ctarray % contains all the lifetimes
        ctsidearray % contains all the background lifetimes
        lxyarray % contains all the flight distances
        lxysidearray % contains all the background flight distances
    end
    properties (Access=public)
        mass % contains all masses in Histogram class
        ct % contains all lifetimes in Histogram class
        ctside % contains all background lifetimes in Histogram class
        lxy % contains all flight distances in Histogram class
        lxyside % contains all background flight distances in Histogram class
        minlxy % condition for flight distance
        mind0 % condition for impact parameter (of individual tracks)
    end

    methods

        % constructor
        function obj = K0SAnalysis()
            obj.massarray = []; % this will contain all the measured masses
            obj.mass = []; % this will become a Histogram object that we can plot
            obj.ctarray = []; % this will contain all the measured lifetimes
            obj.ct = []; % this will become a Histogram object that we can plot
            obj.ctsidearray = []; % this will contain all the measured background lifetimes
            obj.ctside = []; % this will become a Histogram object that we can plot
            obj.lxyarray = []; % this will contain all the measured flight distances
            obj.lxy = []; % this will become a Histogram object that we can plot
            obj.lxysidearray = []; % this will contain all the measured background flight distances
            obj.lxyside = []; % this will become a Histogram object that we can plot
            obj.mind0 = 0.3;
            obj.minlxy = 2;
        end

        % setting up the histogram
        function start(obj)
            obj.mass = Histogram(100, 0.4, 0.6); % 100 bins from 0.4 to 0.6 GeV/c^2
            obj.ct = Histogram(100, 0, 15); % 100 bins from 0 to 15 cm
            obj.ctside = Histogram(100, 0, 15);
            obj.lxy = Histogram(100, 0, 15);
            obj.lxyside = Histogram(100, 0, 15);
        end

        % filling the histogram up with the measured masses and lifetimes
        function stop(obj)
            obj.mass.fill(obj.massarray)
            obj.ct.fill(obj.ctarray)
            obj.ctside.fill(obj.ctsidearray)
            obj.lxy.fill(obj.lxyarray)
            obj.lxyside.fill(obj.lxysidearray)
        end

        % executes every event to find measured masses and lifetimes
        function event(obj, ev)
            piv = ev.vertex'; % transposing the primary interaction vertex for convenience (from 2x1 to 1x2)
            tracks = ev.tracks;
            allhelices = Helix(tracks); % all helices for an event
            helices = [];
            for k = 1:numel(allhelices)
                if all([abs(allhelices(k).pt) > 1, abs(allhelices(k).ip(piv)) > obj.mind0]) % finding helices which match our criteria
                    helices = [helices, allhelices(k)];
                end
            end
            for i = 2:numel(helices)
                h1 = helices(i);
                r1 = h1.radius;
                for j = 1:i-1 % for all possible combination of helices...
                    h2 = helices(j);
                    r2 = h2.radius;
                    v = Vertex([h1, h2]);
                    vertex_ij = v.vtx;
                    if isempty(vertex_ij) % if no intersection is found
                        continue
                    end
                    if all([sign(r1) ~= sign(r2), v.FlightDistance(piv) > obj.minlxy, abs(v.ImpactParameter(piv)) < 0.5]) % more criteria for our chosen intersection
                        obj.massarray = [obj.massarray, v.mass(obj.mp, obj.mp)]; % assuming both tracks are pions, we find the predicted mass and lifetime of the decaying particle
                        if v.mass(obj.mp, obj.mp) > 0.48 && v.mass(obj.mp, obj.mp) < 0.52
                            obj.ctarray = [obj.ctarray, v.Lifetime(obj.mk, piv)]; % vertices within the peak are added to lifetime array
                            obj.lxyarray = [obj.lxyarray, v.FlightDistance(piv)]; % vertices within the peak are added to flight distance array
                        elseif v.mass(obj.mp, obj.mp) > 0.46 && v.mass(obj.mp, obj.mp) < 0.48
                            obj.ctsidearray = [obj.ctsidearray, v.Lifetime(obj.mk, piv)]; % vertices just outside the peak are measured as background
                            obj.lxysidearray = [obj.lxysidearray, v.FlightDistance(piv)];
                        elseif v.mass(obj.mp, obj.mp) < 0.54 && v.mass(obj.mp, obj.mp) > 0.52
                            obj.ctsidearray = [obj.ctsidearray, v.Lifetime(obj.mk, piv)];
                            obj.lxysidearray = [obj.lxysidearray, v.FlightDistance(piv)];
                        end
                    end
                end % second loop of helices
            end % first loop of helices
        end % event()

    end % methods
end % classdef
