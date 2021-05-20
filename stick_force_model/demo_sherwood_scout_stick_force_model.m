function[F_stick]=demo_sherwood_scout_stick_force_model()
%% description
% this function is a demonstration version of the mechanical linakge stick
% force model used in the full system SIMULINK model. the full system
% SIMULINK model contains the most up to date versions of the stick force
% model. this function is only for demonstration purposes.

% total aircraft lift coefficient (dim)
CLtot=n*m*g/(0.5*rho*(V^2)*s_w);

% fuselage datum angle of attack (rad)
alpha_f=(CLtot/dCLtot_dalpha)+alpha0tot;

% wing angle of attack (rad)
alpha_w=alpha_f+alpha_ws-alpha0;

% tailplane angle of attack (rad)
alpha_tp=alpha_f+alpha_ts;

% main wing lift coefficient (dim)
CL_w=alpha_w*dCL_w_dalpha;

% downwash at tailplane due to main wing (rad)
epsilon=1.75*(CL_w/(((pi*AR_w*(tr*r)^0.25))*...
        (1.0+modM)));

% tail effective angle of attack (rad)
alpha_tp_eff=alpha_tp-epsilon;

% hinge moment coefficient (dim)
Ch=alpha_tp_eff*b1+eta*b2+beta*b3;

% hinge moment (Nm)
Mh=Ch*0.5*rho*V^2*s_e*c_e;

% assuming hinge moment is equal to moment at base of stick
Mbs=Mh;

% stick force (N)
F_stick=Mbs/l_stick;