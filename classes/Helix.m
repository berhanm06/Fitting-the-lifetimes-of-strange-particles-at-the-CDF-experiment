classdef Helix
    % Helix contains data about path of helix traced by particles:
    %   'radius' is the radius of curvature of the helix path
    %   'centre' is the centre of curvature of the helix path

    properties(Access=?Vertex)
        trk;
    end
    properties(Constant)
        kpc = 0.002116;
    end

    methods

        % constructor
        function obj = Helix(t)
            if nargin > 0
                obj(numel(t)) = Helix; % create an array of the right size
                for i = 1:numel(t)
                    obj(i).trk = t(i);
                end
            end
        end

        % finds radius of curvature
        function radius = radius(t)
            radius = 1/(2*t.trk.curvature);
        end
    
        % finds centre of curvature in x-y plane
        function centre = centre(t)
            r = radius(t);
            d0 = t.trk.d0;
            phi = t.trk.phi0;
            wc = (r+d0)*exp(1i*(phi+pi/2)); % centre encoded as complex exponential
            centre(1) = real(wc); % real part is the x coord
            centre(2) = imag(wc); % imag part is the y coord
        end

        % finds points on the particles track over time
        function p = points(tr,t) % tr is track, t is time
            r = radius(tr);
            d0 = tr.trk.d0;
            phi0 = tr.trk.phi0;
            z0 = tr.trk.z0;
            cotTheta = tr.trk.cotTheta;
            q = sign(radius(tr)); % particle's charge depends on the 'sign' of its radius
            wc = (r+d0)*exp(1i*(phi0+pi/2));
            w = wc - 1i*r*exp(1i*(phi0+q*t)); % position in x-y plane (complex)
            p(1,:) = real(w);
            p(2,:) = imag(w);
            p(3,:) = z0 + abs(r)*t*cotTheta; % z position
        end
        
        % finds intersection of two helices
        function w = intersect(tr,h)
            if ~isa(h, 'Helix')
                disp('Argument of intersect() is not a Helix');
                w = []; % no intersection
                return;
            end
            c1 = tr.centre();
            c2 = h.centre();
            d = c2 - c1;
            d2 = d(1)*d(1) + d(2)*d(2); % square of distance between centers
            r1 = tr.radius();
            r2 = h.radius();
            if (d2 > (abs(r1)+abs(r2))^2)
                w = []; % no intersection
                return;
            end
            alpha = acos((norm(c2-c1)^2 + r1^2 - r2^2) / (2 * norm(c2-c1) * abs(r1))); % equations given in lab script
            delta = atan2(c2(2) - c1(2), c2(1) - c1(1));
            w = zeros([4,2]); % initialising
            w(1,1) = c1(1) + abs(r1) * cos(delta + alpha);
            w(1,2) = c1(1) + abs(r1) * cos(delta - alpha);
            w(2,1) = c1(2) + abs(r1) * sin(delta + alpha);
            w(2,2) = c1(2) + abs(r1) * sin(delta - alpha);
            q1 = sign(r1);
            q2 = sign(r2);
            t1p = (asin( (w(1,1) - c1(1)) / r1 ) - tr.trk.phi0) / q1; % solved eqs for points()
            t2p = (asin( (w(1,1) - c2(1)) / r2 ) - h.trk.phi0) / q2;
            t1m = (asin( (w(1,2) - c1(1)) / r1 ) - tr.trk.phi0) / q1;
            t2m = (asin( (w(1,2) - c2(1)) / r2 ) - h.trk.phi0) / q2;
            v1p = tr.points(t1p); % contains z position at point of intersection in (x, y)
            v2p = h.points(t2p);
            v1m = tr.points(t1m);
            v2m = h.points(t2m);
            w(3,1) = (v1p(3) + v2p(3))/2; % average z position
            w(3,2) = (v1m(3) + v2m(3))/2;
            w(4,1) = v1p(3) - v2p(3); % difference in z positions
            w(4,2) = v1m(3) - v2m(3);
        end

        % finds transverse (x-y plane) momentum of particle
        function x = pt(obj)
            x = obj.kpc / obj.trk.curvature;
        end

        % finds momentum of particle in x,y and z direction
        function x = p3(obj, v)
            h = obj.trk.curvature;
            d0 = obj.trk.d0;
            phi0 = obj.trk.phi0;
            x(1) = abs(obj.pt) * ((1 + 2 * h * d0) * cos(phi0) - 2 * h * v(2));
            x(2) = abs(obj.pt) * ((1 + 2 * h * d0) * sin(phi0) + 2 * h * v(1));
            x(3) = abs(obj.pt) * obj.trk.cotTheta;
        end

        % finds impact parameter of particle
        function dPV = ip(obj, wPV) % wPV is primary interaction vertex (proton-antiproton collision location)
            wc = obj.centre;
            dPV = abs(wc(1) + wc(2)*1i - wPV(1) - wPV(2)*1i) - abs(obj.radius);
        end


    end % methods
end % classdef
