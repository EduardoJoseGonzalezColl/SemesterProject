% Created by Maxime Volery & Eduardo José González Coll 
% Date: 06.06.2022
% This is a 1D analytical calculation of the input impedance with and
% without absorbers. Of course, in Comsol, it is needed9 two simulations (or even
% better a sweep) to simulate the response with or without the absorbers.
% Because this is a 1D simulation (only plane waves), results might differ
% from c0/(2*sqrt(S_duct) = 1.7[kHz]

rho0 = 1.2; % [kg/m^3]
c0 = 343; % [m/s]

f_ = logspace(1, 4, 2001)';
s_ = 2i*pi*f_; % Laplace variable
k_ = 2*pi*f_/c0; % wave number

% duct dimensions
S_duct = 0.1^2; % duct section [m^2]
L_duct = 1; % duct length [m]

% first higher order mode cutoff frequency:
fprintf('First mode cutoff frequency: %.3f[kHz]\n', 0.5e-3*c0/sqrt(S_duct));

% speaker parameters
Sd = 32e-4; % piston area [m^2]
w0 = 2*pi*100; % resonance frequency [rad/s]
Qms = 3.45; % quality factor
r = 2.1e-3*w0/(Qms*Sd*rho0*c0); % normalized resistance
% Bl = 3.05; % [N/A]

% absorber impedance
rt = [0.1*r, Inf]; % normalized target resistance (inf for hard wall)
wt = 2*pi*330;
Qt = 5*Qms;
za_ = rt.*(s_.^2 + s_*wt/Qt + wt^2)./(s_*wt/Qt);

% radiation impedance (https://mathworld.wolfram.com/StruveFunction.html)
ka_ = 2*pi*f_/c0*sqrt(S_duct/pi);
zout_ = 1 -  besselj(1, 2*ka_)./ka_ + 1i*StruveH1(2*ka_)./ka_;

% total load impedance (this parallel sum is weighted by the areas because
% of the conservation of flow and not velocity.
zload_ = S_duct./(4*Sd./za_ + S_duct./zout_); % there are 4 absorbers

% input impedance
zin_ = (zload_ + 1i*tan(k_*L_duct)) ./ (1 + 1i*zload_.*tan(k_*L_duct));

figure();
plot_bode(f_, zout_, 'DisplayName', 'Output impedance');
plot_bode(f_, za_(:, 1), 'DisplayName', 'Absorber impedance');
plot_bode(f_, zload_(:, 1), 'DisplayName', 'Load impedance');
plot_bode(f_, zin_(:, 1), 'DisplayName', 'Input impedance (with load)');
plot_bode(f_, zin_(:, 2), 'DisplayName', 'Input impedance (hard wall)');


% Struve functions (radiation impedance) are not implemented in Matlab. You
% can find some implementation here:
% https://ch.mathworks.com/matlabcentral/fileexchange/37302-struve-functions
function fun = StruveH1(z)
    % StruveH1 calculates the function StruveH1 for complex argument z
    % 
    % Author : T.P. Theodoulidis
    % Date   : 11 June 2012
    % Revised: 28 June 2012
    %
    % Arguments
    % z : can be scalar, vector, matrix
    %
    % External routines called         : cheval, StruveH1Y1
    % Matlab intrinsic routines called : bessely, besselh
    
    bn=[1.174772580755468e-001 -2.063239340271849e-001  1.751320915325495e-001...
        -1.476097803805857e-001  1.182404335502399e-001 -9.137328954211181e-002...
        6.802445516286525e-002 -4.319280526221906e-002  2.138865768076921e-002...
        -8.127801352215093e-003  2.408890594971285e-003 -5.700262395462067e-004...
        1.101362259325982e-004 -1.771568288128481e-005  2.411640097064378e-006...
        -2.817186005983407e-007  2.857457024734533e-008 -2.542050586813256e-009...
        2.000851282790685e-010 -1.404022573627935e-011  8.842338744683481e-013...
        -5.027697609094073e-014  2.594649322424009e-015 -1.221125551378858e-016...
        5.263554297072107e-018 -2.086067833557006e-019  7.628743889512747e-021...
        -2.582665191720707e-022  8.118488058768003e-024 -2.376158518887718e-025...
        6.492040011606459e-027 -1.659684657836811e-028  3.978970933012760e-030...
        -8.964275720784261e-032  1.901515474817625e-033];
    
    x=z(:);
    
    % |x|<=16
    i1=abs(x)<=16;
    x1=x(i1);
    if isempty(x1)==0
        z1=x1.^2/400;
        fun1=cheval('shifted',bn,z1).*x1.^2*2/3/pi;
    else
        fun1=[];
    end
    
    % |x|>16
    i2=abs(x)>16;
    x2=x(i2);
    if isempty(x2)==0
        fun2=StruveH1Y1(x2)+bessely(1,x2);
    else
        fun2=[];
    end
    
    fun=x*0;
    fun(i1)=fun1;
    fun(i2)=fun2;
    
    fun=reshape(fun,size(z));
end
function fun = StruveH1Y1(z)
    % StruveH1Y1 calculates the function StruveH1-BesselY1 for complex argument z
    %
    % Author : T.P. Theodoulidis
    % Date   : 11 June 2012
    %
    % Arguments
    % z : can be scalar, vector, matrix
    %
    % External routines called         : cheval, StruveH1
    % Matlab intrinsic routines called : bessely, besselh
    
    nom=[4,0,9648             ,0,8187030           ,...
        0,3120922350       ,0,568839210030      ,...
        0,49108208584050   ,0,1884052853216100  ,...
        0,28131914180758500,0,126232526316723750,...
        0,97007862050064000,0,2246438344775625];
    
    den=[4,0,9660              ,0,8215830           ,...
        0,3145141440        ,0,577919739600      ,...
        0,50712457149900    ,0,2014411492343250  ,...
        0,32559467386446000 ,0,177511711616489250,...
        0,230107774317671250,0,31378332861500625];
    
    x=z(:);
    
    % |x|<=16
    i1=abs(x)<=16;
    x1=x(i1);
    if isempty(x1)==0
        fun1=StruveH1(x1)-bessely(1,x1);
    else
        fun1=[];
    end
    
    % |x|>16 and real(x)<0 and imag(x)<0
    i2=(abs(x)>16 & real(x)<0 & imag(x)<0);
    x2=x(i2);
    if isempty(x2)==0
        x2=-x2;
        fun2=2/pi+2/pi./x2.^2.*polyval(nom,x2)./polyval(den,x2)-2i*besselh(1,1,x2);
    else
        fun2=[];
    end
    % |x|>16 and real(x)<0 and imag(x)>=0
    i3=(abs(x)>16 & real(x)<0 & imag(x)>=0);
    x3=x(i3);
    if isempty(x3)==0
        x3=-x3;
        fun3=2/pi+2/pi./x3.^2.*polyval(nom,x3)./polyval(den,x3)+2i*besselh(1,2,x3);
    else
        fun3=[];
    end
    % |x|>16 and real(x)>=0
    i4=(abs(x)>16 & real(x)>=0);
    x4=x(i4);
    if isempty(x4)==0
        fun4=2/pi+2/pi./x4.^2.*polyval(nom,x4)./polyval(den,x4);
    else
        fun4=[];
    end
    fun=x*0;
    fun(i1)=fun1;
    fun(i2)=fun2;
    fun(i3)=fun3;
    fun(i4)=fun4;
    
    fun=reshape(fun,size(z));
end
function eval = cheval(Ctype,An,xv)
    % cheval evaluates any one of the four types of Chebyshev series.
    % It is a Matlab translation of the Fortran function EVAL
    % found in page 20 of:
    % Y.L. Luke, Algorithms for the computation of mathematical functions
    % Academic Press, 1977, p.20
    %
    % Author : T.P. Theodoulidis
    % Date   : 11 June 2012
    %
    % Ctype (string): type of Chebyshev polynomial
    %                 'regular' T_n(x)
    %                 'shifted' T*_n(x)
    %                 'even'    T_2n(x)
    %                 'odd'     T_2n+1(x)
    % An            : vector of Chebyshev coefficients
    % z             : argument, can be scalar, vector, matrix
    
    switch Ctype
        case {'regular'}
            log1=1; log2=1;
        case {'shifted'}
            log1=1; log2=0;
        case {'even'}
            log1=0; log2=1;
        case {'odd'}
            log1=0; log2=0;
        otherwise
            return;
    end
    
    x=xv(:);
    
    xfac=2*(2*x-1);
    if log1 && log2, xfac=2*x; end
    if ~log1, xfac=2*(2*x.*x-1); end
    n=length(An);
    n1=n+1;
    Bn=zeros(length(x),n1+1);
    
    for j=1:n
        Bn(:,n1-j)=xfac.*Bn(:,n1+1-j)-Bn(:,n1+2-j)+An(n1-j);
    end
    eval=Bn(:,1)-xfac.*Bn(:,2)/2;
    if ~log1 && ~log2, eval=x.*(Bn(:,1)-Bn(:,2)); end
    eval=reshape(eval,size(xv));
end
