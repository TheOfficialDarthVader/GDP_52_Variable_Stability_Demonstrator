%% cessna 172 data

%% description
% this script contains all the information required to form the aerodynamic
% model of the cessna 172. this script MUST be ran atleast once before
% using "aircraft_flight_dynamic_model.mat". if any changes are made to
% this script, the script must be ran again so the .mat file is updated.

%% flight conditions
rho=1.056;                    % free stream density        (kg/m^3)
nu=1.900e-5;                  % kinematic viscosity        (m^2/s)
mu=2.000e-5;                  % dynamic viscosity          (Pa/s)
gamma0=0.0*pi/180;            % flight path angle          (rad)
g=9.81;                       % gravitational acceleration (m/s^2)

%% aircraft specs
m=1200;                       % aircraft mass              (kg)
Iyy=1824.93;                  % second moment of inertia   (kgm^2)
kappa=0.63e-5;                % surface grain diameter     (m)
engtyp=-1;                    % engtyp=-1 for piston
                              % engtyp=0 for jet engine

%% defined main wing data
% aerofoil=NACA 4409
a0=1.8*pi;                    % aerofoil lift curve slope  (rad)
alpha0=-2.5*pi/180;          % aerofoil zero lift angle   (rad)
alpha_ws=1.5*pi/180;          % wing setting angle... 
                              % (w.r.t fuselage datum)     (rad)

c_w_root=1.68;                % wing root chord            (m)
c_w_tip=1.15;                 % wing tip chord             (m)

b_w=11.00;                    % wing span                  (m)

e_w=0.75;                     % main wing oswald efficiency factor [-]
delta_w=0.05;                 % main wing induced drag factor [-]...
                              % (found using a vortex lattice method)
            
tr=0.7;                       % taper ratio                        [-]

tc_w_root=0.12;               % wing root thickness/chord ratio [-]
tc_w_tip=0.12;                % wing tip thickness/chord ratio  [-]

wing_sweep=0.0*pi/180;        % wing sweep angle at quarter chord  (rad)
gamma_mid_chord_w=0;          % wing sweep at midchord line        (rad)                              
                            
%% defined horizontal tail plane data
% aerofoil=flat plate
alpha_ts=0;                   % tail setting angle                    (rad)

b_tp=3.357;                   % horizontal tail plane span            (m)
c_tp_root=1.37;               % horizontal tail root chord            (m)
c_tp_tip=0.73;                % horizontal tail tip chord             (m)

stab_e_ratio=0.4;             % elevator/stabiliser ratio  [-]
c_tt=0.128;                   % trim tab reference chord   (m)

s_tt=0.102;                   % trim tab reference area    (m^2)

e_tp=0.75;                    % tail plane oswald efficiency factor [-]
delta_tp=0.1;                 % tail induced drag factor [-]...
                              % (found using a vortex lattice method)

tc_tp_root=0.09;              % horizontal tail root thickness/chord ratio [-]
tc_tp_tip=0.09;               % horizontal tail tip thickness/chord ratio  [-]

gamma_mid_chord_tp=0;         % horizontal tail sweep at midchord line (rad)

a1=2.600;                     % tail lift curve slope,
                              % w.r.t change in  tail effective angle of 
                              % attack                     (rad^-1)
                            
a2=1.900;                     % tail lift curve slope,
                              % w.r.t change in elevator deflection
                              %                            (rad^-1)

a3=0.333;                     % tail lift curve slope
                              % w.r.t change in trimtab deflection 
                              %                            (rad^-1)

b1=-0.075;                    % hinge moment curve slope,
                              % w.r.t change in tail effective angle of 
                              % attack                     (rad^-1)

b2=-0.168;                    % hinge moment curve slope,
                              % w.r.t change in elevator deflection
                              %                            (rad^-1)

b3=-0.215;                    % hinge moment curve slope,
                              % w.r.t change in trim tab deflection angle
                              %                            (rad^-1)

l_m=0.06;                   % elevator moment arm length (m)

G=1;                        % elevator linkage system gearing factor

%% defined fuselage data
c_f=7.00;                     % fuselage length     (m)
b_f_h=1.5;                    % fuselage max height s(m)
b_f_w=1;                      % fuselage max width  (m)
s_f_wet=20.0;                 % approx fuselage wetted area     (m^2)

%% defined vertical tail data
c_tp_v_root=1.40;             % vertical tail root chord [m]
c_tp_v_tip=0.70;              % vertical tail tip chord [m]

b_tp_v=2.6;                   % vertical tail span           (m)

tc_tp_v_root=0.09;            % vertical tail root thickness/chord ratio[-]
tc_tp_v_tip=0.09;             % vertical tail tip thickness/chord ratio [-]

gamma_mid_chord_tp_v=0.0;     % vertical tail sweep at midchord line (rad)

%% defined wing strut data
L_strut=2.3;       % wing strut length [m]
c_strut=0.1;       % wing strut chord [m]
tc_strut=0.2;      % wing strut thickness/chord ratio [-]
num_wing_struts=2;

%% defined jury strut data
L_jury_strut=0.0;         % wing strut length [m]
c_jury_strut=0.0;         % wing strut chord [m]
tc_jury_strut=0.0;        % wing strut thickness/chord ratio [-]
num_jury_struts=0.0;      % number of jury struts

%% defined tail strut data
L_tail_strut=1;         % tail strut length [m]
c_tail_strut=0.1;       % tail strut chord [m]
tc_tail_strut=0.2;      % tail strut thickness/chord ratio [-]
num_tail_struts=0.0;    % number of tail struts

%% defined tail bracing cable data
L_tail_cable=0.86;      % bracing cable length (m)
d_tail_cable=0.01;      % bracing cable diameter (m)
Cds_cable=1;            % bracing cable section drag coefficient (-)
num_tail_bracing_cables=0.0; % number of tail bracing cables

%% defined gear data
d_gear_front=0.43;
w_gear_front=0.19;

d_gear_rear=0.2;
w_gear_rear=0.1;

%% defined antenna data
antenna_length=0.5;    % antenna length (m)
antenna_diameter=0.01; % antenna diameter (m)
Cds_antenna=1;         % antenna section drag coefficient (-)

%% torenbeek equation factors                       
modM=0.0;                     % vertical distance between wing zero lift 
                              % line and tail plane chord line          [-]
                              
f=0.995;                      % taper ratio correction factor           [-]

%% defined configuration data
h0=0.250;                     % dist from wing le to ac,
                              % as a percentage of wing chord         [-]
                             
l_ac=4.4;                     % dist from wing AC to tailplane AC     (m)
Cm0=-0.087;                   % zero lift pitching moment coefficient [-]

save('cessna_172_data')