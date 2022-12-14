function [p,ellipse]=phantom3d(varargin)

[ellipse,n] = parse_inputs(varargin{:});

p = zeros([n n n]);

rng =  ( (0:n-1)-(n-1)/2 ) / ((n-1)/2); 

[x,y,z] = meshgrid(rng,rng,rng);

coord = [flatten(x); flatten(y); flatten(z)];

p = flatten(p);

for k = 1:size(ellipse,1)    
   A = ellipse(k,1);            % Amplitude change for this ellipsoid
   asq = ellipse(k,2)^2;        % a^2
   bsq = ellipse(k,3)^2;        % b^2
   csq = ellipse(k,4)^2;        % c^2
   x0 = ellipse(k,5);           % x offset
   y0 = ellipse(k,6);           % y offset
   z0 = ellipse(k,7);           % z offset
   phi = ellipse(k,8)*pi/180;   % first Euler angle in radians
   theta = ellipse(k,9)*pi/180; % second Euler angle in radians
   psi = ellipse(k,10)*pi/180;  % third Euler angle in radians
   
   cphi = cos(phi);
   sphi = sin(phi);
   ctheta = cos(theta);
   stheta = sin(theta);
   cpsi = cos(psi);
   spsi = sin(psi);
   
   % Euler rotation matrix
   alpha = [cpsi*cphi-ctheta*sphi*spsi   cpsi*sphi+ctheta*cphi*spsi  spsi*stheta;
            -spsi*cphi-ctheta*sphi*cpsi  -spsi*sphi+ctheta*cphi*cpsi cpsi*stheta;
            stheta*sphi                  -stheta*cphi                ctheta];        
   
   % rotated ellipsoid coordinates
   coordp = alpha*coord;
   
   idx = find((coordp(1,:)-x0).^2./asq + (coordp(2,:)-y0).^2./bsq + (coordp(3,:)-z0).^2./csq <= 1);
   p(idx) = p(idx) + A;
end

p = reshape(p,[n n n]);

return;


function out = flatten(in)

out = reshape(in,[1 prod(size(in))]);

return;
   
   
function [e,n] = parse_inputs(varargin)
%  e is the m-by-10 array which defines ellipsoids
%  n is the size of the phantom brain image

n = 128;     % The default size
e = [];
defaults = {'shepp-logan', 'modified shepp-logan', 'yu-ye-wang'};

for i=1:nargin
   if ischar(varargin{i})         % Look for a default phantom
      def = lower(varargin{i});
      idx = strmatch(def, defaults);
      if isempty(idx)
         eid = sprintf('Images:%s:unknownPhantom',mfilename);
         msg = 'Unknown default phantom selected.';
         error(eid,'%s',msg);
      end
      switch defaults{idx}
      case 'shepp-logan'
         e = shepp_logan;
      case 'modified shepp-logan'
         e = modified_shepp_logan;
      case 'yu-ye-wang'
         e = yu_ye_wang;
      end
   elseif numel(varargin{i})==1 
      n = varargin{i};            % a scalar is the image size
   elseif ndims(varargin{i})==2 && size(varargin{i},2)==10 
      e = varargin{i};            % user specified phantom
   else
      eid = sprintf('Images:%s:invalidInputArgs',mfilename);
      msg = 'Invalid input arguments.';
      error(eid,'%s',msg);
   end
end

% ellipse is not yet defined
if isempty(e)                    
   e = modified_shepp_logan;
end

return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Default head phantoms:   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function e = shepp_logan

e = modified_shepp_logan;
e(:,1) = [1 -.98 -.02 -.02 .01 .01 .01 .01 .01 .01];

return;

      
function e = modified_shepp_logan
%
%   This head phantom is the same as the Shepp-Logan except 
%   the intensities are changed to yield higher contrast in
%   the image.  Taken from Toft, 199-200.
%      
%         A      a     b     c     x0      y0      z0    phi  theta    psi
%        -----------------------------------------------------------------
e =    [  1  .6900  .920  .810      0       0       0      0      0      0
        -.8  .6624  .874  .780      0  -.0184       0      0      0      0
        -.2  .1100  .310  .220    .22       0       0    -18      0     10
        -.2  .1600  .410  .280   -.22       0       0     18      0     10
         .1  .2100  .250  .410      0     .35    -.15      0      0      0
         .1  .0460  .046  .050      0      .1     .25      0      0      0
         .1  .0460  .046  .050      0     -.1     .25      0      0      0
         .1  .0460  .023  .050   -.08   -.605       0      0      0      0
         .1  .0230  .023  .020      0   -.606       0      0      0      0
         .1  .0230  .046  .020    .06   -.605       0      0      0      0 ];
       
return;
          

function e = yu_ye_wang
%
%   Yu H, Ye Y, Wang G, Katsevich-Type Algorithms for Variable Radius Spiral Cone-Beam CT
%      
%         A      a     b     c     x0      y0      z0    phi  theta    psi
%        -----------------------------------------------------------------
e =    [  1  .6900  .920  .900      0       0       0      0      0      0
        -.8  .6624  .874  .880      0       0       0      0      0      0
        -.2  .4100  .160  .210   -.22       0    -.25    108      0      0
        -.2  .3100  .110  .220    .22       0    -.25     72      0      0
         .2  .2100  .250  .500      0     .35    -.25      0      0      0
         .2  .0460  .046  .046      0      .1    -.25      0      0      0
         .1  .0460  .023  .020   -.08    -.65    -.25      0      0      0
         .1  .0460  .023  .020    .06    -.65    -.25     90      0      0
         .2  .0560  .040  .100    .06   -.105    .625     90      0      0
        -.2  .0560  .056  .100      0    .100    .625      0      0      0 ];
       
return;
        
             
