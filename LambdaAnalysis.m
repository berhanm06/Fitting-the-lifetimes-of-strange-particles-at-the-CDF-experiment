classdef LambdaAnalysis < Analysis

    properties (Constant)
        mpion = 0.13957
        mproton = 0.938272
        ml = 1.115683
    end
    properties (Access=protected)
        massarray % contains all the masses
        ctarray % contains all the lifetimes
        ctsidearray % contains all the background lifetimes
    end
    properties (Access=public)
        mass % contains all masses in Histogram class
        ct % contains all lifetimes in Histogram class
        ctside % contains all background lifetimes in Histogram class
        minlxy % condition for flight distance
        mind0 % condition for impact parameter (of individual tracks)
    end

    methods

        % constructor
        function obj = LambdaAnalysis()
            obj.massarray = []; % this will contain all the measured masses
            obj.mass = []; % this will become a Histogram object that we can plot
            obj.ctarray = []; % this will contain all the measured lifetimes
            obj.ct = []; % this will become a Histogram object that we can plot
            obj.ctsidearray = []; % this will contain all the measured background lifetimes
            obj.ctside = []; % this will become a Histogram object that we can plot
            obj.mind0 = 0.2;
            obj.minlxy = 2;
        end

        % setting up the histogram
        function start(obj)
            obj.mass = Histogram(100, 1.0, 1.2); % 100 bins from 1.0 to 1.2 GeV/c^2
            obj.ct = Histogram(100, 0, 30); % 100 bins from 0 to 30 cm
            obj.ctside = Histogram(100, 0, 30);
        end

        % filling the histogram up with the measured masses and lifetimes
        function stop(obj)
            obj.mass.fill(obj.massarray)
            obj.ct.fill(obj.ctarray)
            obj.ctside.fill(obj.ctsidearray)
        end
        
        % executes every event to find measured masses and lifetimes
        function event(obj, ev)
            piv = ev.vertex'; % transposing the primary interaction vertex for convenience (from 2x1 to 1x2)
            tracks = ev.tracks;
            allhelices = Helix(tracks); % all helices for an event
            helices = [];
            for k = 1:numel(allhelices)
                if abs(allhelices(k).ip(piv)) > obj.mind0 % finding helices which match our criteria
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
                    if (sign(r1) ~= sign(r2)) && (v.FlightDistance(piv) > obj.minlxy) % more criteria for our chosen intersection
                        if (h1.pt > h2.pt) && (abs(h1.pt) > 2) % finding whichever track has a higher pt and assigning it the mass of a proton (also must match criteria)
                            obj.massarray = [obj.massarray, v.mass(obj.mproton, obj.mpion)];
                            if v.mass(obj.mproton, obj.mpion) > 1.10 && v.mass(obj.mproton, obj.mpion) < 1.14
                                obj.ctarray = [obj.ctarray, v.Lifetime(obj.ml, piv)]; % vertices within the peak are added to lifetime array
                            elseif v.mass(obj.mproton, obj.mpion) > 1.08 && v.mass(obj.mproton, obj.mpion) < 1.10
                                obj.ctsidearray = [obj.ctsidearray, v.Lifetime(obj.ml, piv)]; % vertices just outside the peak are measured as background
                            elseif v.mass(obj.mproton, obj.mpion) > 1.14 && v.mass(obj.mproton, obj.mpion) < 1.16
                                obj.ctsidearray = [obj.ctsidearray, v.Lifetime(obj.ml, piv)];
                            end
                        elseif (h1.pt < h2.pt) && (abs(h2.pt) > 2)
                            obj.massarray = [obj.massarray, v.mass(obj.mpion, obj.mproton)];
                            if v.mass(obj.mpion, obj.mproton) > 1.10 && v.mass(obj.mpion, obj.mproton) < 1.14
                                obj.ctarray = [obj.ctarray, v.Lifetime(obj.ml, piv)]; % vertices within the peak are added to lifetime array
                            elseif v.mass(obj.mpion, obj.mproton) > 1.08 && v.mass(obj.mpion, obj.mproton) < 1.10
                                obj.ctsidearray = [obj.ctsidearray, v.Lifetime(obj.ml, piv)]; % vertices just outside the peak are measured as background
                            elseif v.mass(obj.mpion, obj.mproton) > 1.14 && v.mass(obj.mpion, obj.mproton) < 1.16
                                obj.ctsidearray = [obj.ctsidearray, v.Lifetime(obj.ml, piv)];
                            end
                        end
                    end
                end % second loop of helices
            end % first loop of helices
        end % event()

    end
end
