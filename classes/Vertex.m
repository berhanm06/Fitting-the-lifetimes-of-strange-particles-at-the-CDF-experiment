classdef Vertex
    % Vertex contains data about a particle which has decayed into two new
    % particles
    %   'h1' is one of the resulting paths
    %   'h2' is the other resulting path
    %   'vtx' is the coordinate of decay

    properties(Access=protected)
        h1
        h2 % initial helices
    end
    properties(Access={?K0SAnalysis, ?LambdaAnalysis})
        vtx % vertex of intersection (point of decay)
    end

    methods

        % constructor
        function obj = Vertex(h) % Input must be a 1x2 array of helices that form vertex
            obj.h1 = h(1);
            obj.h2 = h(2);
            obj.vtx = zeros(1,2);
            v = h(1).intersect(h(2));
            if isempty(v)
                obj.vtx = v;
            elseif norm(v(4,1)) > norm(v(4,2)) % checking which intersection seems more accurate by finding the smaller difference in z values
                obj.vtx(1) = v(1,2);
                obj.vtx(2) = v(2,2);
            else
                obj.vtx(1) = v(1,1);
                obj.vtx(2) = v(2,1);
            end
        end
        
        function pT = pT(obj)
            p1 = obj.h1.p3(obj.vtx);
            p2 = obj.h2.p3(obj.vtx); % initial transverse momenta
            pT = p1(1:2) + p2(1:2); % conservation of momentum
        end
        
        % function uses SR to find mass of decaying particle (c = 1 of course)
        function x = mass(obj, mass1, mass2)
            p1 = obj.h1.p3(obj.vtx); % momenta of resulting particles
            p2 = obj.h2.p3(obj.vtx);
            E = sqrt(mass1^2 + norm(p1)^2) + sqrt(mass2^2 + norm(p2)^2); % finding the energy of the decaying particle INCLUDING NON TRANSVERSE MOMENTUM
            x = sqrt(E^2 - norm(p1 + p2)^2); % using the energy momentum relation to find the mass of the decaying particle
        end

        % finds flight distance IN THE TRANSVERSE DIRECTION
        function L_xy = FlightDistance(obj, piv)
            pThat = obj.pT / norm(obj.pT);
            L_xy = dot(obj.vtx - piv, pThat); % equation for L_xy
        end

        % finds impact parameter of initial particle
        function d_0 = ImpactParameter(obj, piv)
            v = [obj.vtx, 0]; % every array must be 1x3 so we can do a cross product
            wPV = [piv, 0];
            pThat = [obj.pT,0] / norm([obj.pT,0]);
            d_0v = cross((v - wPV), pThat);
            d_0 = d_0v(3);
        end

        function ct = Lifetime(obj, m, piv)
            ct = abs(obj.FlightDistance(piv) * (m / norm(obj.pT)));
        end

    end % methods
end % classdef
