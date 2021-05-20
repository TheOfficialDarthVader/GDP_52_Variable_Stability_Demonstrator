%% full system simulink model initialisation script
% this script is necessary to initialise the full system simulink model.
% please read this script in detail before running the SIMULINK model.

%% clear workspace and console
clear all
clc

%% simulation controls
t=10;       % simulation time  (s)
dt=1/100;   % time step        (s)
nts=t/dt;   % number of steps  [-]

%% form initial control vector
% only used if "Predefined Input" is selected after double clicking on the 
% "control inputs" block
elev_amplitude=15*pi/180; % elevator doublet input amplitude [rad]
elev_period_start=5;      % elevator doublet input start time [s]
elev_period=1;            % elevator doublet period [s]

%% saturation and constraints
% init_altitude=200;           % initial aircraft altitude     (m)
elev_sat=28*pi/180;          % elevator saturation           (rad)
ail_sat=30*pi/180;           % aileron saturation            (rad)
rud_sat=28*pi/180;           % rudder saturation             (rad)
thr_sat=1;                   % throttle saturation           [-]
control_surface_feedback=10; % control surface feedback term [-]
actuator_rate=115*pi/180;    % actuator slew rate            (rad/s)

%% system cutoffs
elev_cutoff=35*pi/180;

% load factor cutoff polynomial constants
% positive load factor np=ap*Va^2+bp*Va
% negative load factor nn=an*Va^2+bn*Va
ap=-3.7961;
bp=25.796;

an=-9.8783;
bn=-41.787;

% the remaining cut-offs are found in the simulink model in the 
% "system safety cutoffs" block

%% controller gains

% actuator signal tracking model PD gains
ppgain_P=-86.717674561182620;
ppgain_D=0.637114873357555;

% actuator PD gains
ppgain_actuator_P=20.729870007825970;
ppgain_actuator_D=1.076123507883140e+02;

%% load base sherwood scout data
aircraft='sherwood_scout_data.mat';
uinf=43.21; % aircraft flight speed [m/s]
% c.g. limits 0.223=forward, 0.2935=centre, 0.364=aft
h=0.2935;    % aircraft wing chord normalised c.g. location [-]

[A_sc,B_sc,C_sc,D_sc,base_scout_aircraft_constants]=aircraft_flight_dynamic_model(aircraft,uinf,h);                                              
n=base_scout_aircraft_constants(1);
m=base_scout_aircraft_constants(2);
g=base_scout_aircraft_constants(3);
rho=base_scout_aircraft_constants(4);

s_w=base_scout_aircraft_constants(5);
s_tp=base_scout_aircraft_constants(6);
K=base_scout_aircraft_constants(7);
AR_w=base_scout_aircraft_constants(8);
s_e=base_scout_aircraft_constants(9);
c_e=base_scout_aircraft_constants(10);

Cm0=base_scout_aircraft_constants(11);
h_cg=base_scout_aircraft_constants(12);
h0=base_scout_aircraft_constants(13);

dCL_w_dalpha=base_scout_aircraft_constants(14);
dCLtot_dalpha=base_scout_aircraft_constants(15);

alpha0=base_scout_aircraft_constants(16);
alpha0tot=base_scout_aircraft_constants(17);
alpha_ws=base_scout_aircraft_constants(18);
alpha_ts=base_scout_aircraft_constants(19);

e_w=base_scout_aircraft_constants(20);

beta=base_scout_aircraft_constants(21);
eta=base_scout_aircraft_constants(22);

b1=base_scout_aircraft_constants(23);
b2=base_scout_aircraft_constants(24);
b3=base_scout_aircraft_constants(25);

G=base_scout_aircraft_constants(26);
l_m=base_scout_aircraft_constants(27);

tr=base_scout_aircraft_constants(28);
r=base_scout_aircraft_constants(29);
modM=base_scout_aircraft_constants(30);

% reducing B matrix to just the elevator control terms
B_sc=B_sc(:,1);
% adjusting the D matrix corresponding to the change in the B matrix
D_sc=D_sc(1,:);

x_sc(1)=0.0;   % initial ub      (m/s)
x_sc(2)=0.0;   % initial wb      (m/s)
x_sc(3)=0.0;   % initial qb      (rad/s)
x_sc(4)=0.0;   % initial theta   (rad)

x_sc=x_sc';    % rotate to column vector

%% load base cessna 172 data
aircraft='cessna_172_data.mat';
uinf=63;     % aircraft flight speed [m/s]
h=0.2405;    % aircraft wing chord normalised c.g. location [-]

[A_ce,B_ce,C_ce,D_ce,base_cessna_aircraft_constants]=aircraft_flight_dynamic_model(aircraft,uinf,h);
                                                
n_ce=base_cessna_aircraft_constants(1);
m_ce=base_cessna_aircraft_constants(2);
g_ce=base_cessna_aircraft_constants(3);
rho_ce=base_cessna_aircraft_constants(4);

s_w_ce=base_cessna_aircraft_constants(5);
s_tp_ce=base_cessna_aircraft_constants(6);
K_ce=base_cessna_aircraft_constants(7);
AR_w_ce=base_cessna_aircraft_constants(8);
s_e_ce=base_cessna_aircraft_constants(9);
c_e_ce=base_cessna_aircraft_constants(10);

Cm0_ce=base_cessna_aircraft_constants(11);
h_cg_ce=base_cessna_aircraft_constants(12);
h0_ce=base_cessna_aircraft_constants(13);

dCL_w_dalpha_ce=base_cessna_aircraft_constants(14);
dCLtot_dalpha_ce=base_cessna_aircraft_constants(15);

alpha0_ce=base_cessna_aircraft_constants(16);
alpha0tot_ce=base_cessna_aircraft_constants(17);
alpha_ws_ce=base_cessna_aircraft_constants(18);
alpha_ts_ce=base_cessna_aircraft_constants(19);

e_w_ce=base_cessna_aircraft_constants(20);

beta_ce=base_cessna_aircraft_constants(21);
eta_ce=base_cessna_aircraft_constants(22);

b1_ce=base_cessna_aircraft_constants(23);
b2_ce=base_cessna_aircraft_constants(24);
b3_ce=base_cessna_aircraft_constants(25);

G_ce=base_cessna_aircraft_constants(26);
l_m_ce=base_cessna_aircraft_constants(27);

tr_ce=base_cessna_aircraft_constants(28);
r_ce=base_cessna_aircraft_constants(29);
modM_ce=base_cessna_aircraft_constants(30);

% reducing B matrix to just the elevator control terms
B_ce=B_ce(:,1);
% adjusting the D matrix corresponding to the change in the B matrix
D_ce=D_ce(1,:);

x_ce(1)=0.0;   % initial ub      (m/s)
x_ce(2)=0.0;   % initial wb      (m/s)
x_ce(3)=0.0;   % initial qb      (rad/s)
x_ce(4)=0.0;   % initial theta   (rad)

x_ce=x_ce';    % rotate to column vector


%% load target aircraft

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scout CG 0.1
aircraft='sherwood_scout_data.mat';
uinf=43.21; % target aircraft flight speed [m/s]
h=0.1;    % target aircraft wing chord normalised c.g. location [-]

[A_sc_CG_10,B_sc_CG_10,~,~,consts_sc_CG_10]=aircraft_flight_dynamic_model(aircraft,uinf,h);
A_sc_CG_10=A_sc_CG_10(2:3,2:3); % reduce A matrix to SPPO approx
B_sc_CG_10=B_sc_CG_10(2:3,1:1); % reduce B matrix to SPPO approx

alpha0tot_sc_CG_10=consts_sc_CG_10(17);
beta_sc_CG_10=consts_sc_CG_10(21);
eta_sc_CG_10=consts_sc_CG_10(22);
h_sc_CG_10=h;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scout CG 0.223
aircraft='sherwood_scout_data.mat';
uinf=43.21; % target aircraft flight speed [m/s]
h=0.223;    % target aircraft wing chord normalised c.g. location [-]

[A_sc_CG_22,B_sc_CG_22,~,~,consts_sc_CG_22]=aircraft_flight_dynamic_model(aircraft,uinf,h);
A_sc_CG_22=A_sc_CG_22(2:3,2:3); % reduce A matrix to SPPO approx
B_sc_CG_22=B_sc_CG_22(2:3,1:1); % reduce B matrix to SPPO approx

alpha0tot_sc_CG_22=consts_sc_CG_22(17);
beta_sc_CG_22=consts_sc_CG_22(21);
eta_sc_CG_22=consts_sc_CG_22(22);
h_sc_CG_22=h;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scout CG 0.2935
aircraft='sherwood_scout_data.mat';
uinf=43.21; % target aircraft flight speed [m/s]
h=0.2935;    % target aircraft wing chord normalised c.g. location [-]

[A_sc_CG_29,B_sc_CG_29,~,~,consts_sc_CG_29]=aircraft_flight_dynamic_model(aircraft,uinf,h);
A_sc_CG_29=A_sc_CG_29(2:3,2:3); % reduce A matrix to SPPO approx
B_sc_CG_29=B_sc_CG_29(2:3,1:1); % reduce B matrix to SPPO approx

alpha0tot_sc_CG_29=consts_sc_CG_29(17);
beta_sc_CG_29=consts_sc_CG_29(21);
eta_sc_CG_29=consts_sc_CG_29(22);
h_sc_CG_29=h;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scout CG 0.364
aircraft='sherwood_scout_data.mat';
uinf=43.21; % target aircraft flight speed [m/s]
h=0.364;    % target aircraft wing chord normalised c.g. location [-]

[A_sc_CG_36,B_sc_CG_36,~,~,consts_sc_CG_36]=aircraft_flight_dynamic_model(aircraft,uinf,h);
A_sc_CG_36=A_sc_CG_36(2:3,2:3); % reduce A matrix to SPPO approx
B_sc_CG_36=B_sc_CG_36(2:3,1:1); % reduce B matrix to SPPO approx

alpha0tot_sc_CG_36=consts_sc_CG_36(17);
beta_sc_CG_36=consts_sc_CG_36(21);
eta_sc_CG_36=consts_sc_CG_36(22);
h_sc_CG_36=h;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scout CG 0.55
aircraft='sherwood_scout_data.mat';
uinf=43.21; % target aircraft flight speed [m/s]
h=0.55;    % target aircraft wing chord normalised c.g. location [-]

[A_sc_CG_55,B_sc_CG_55,~,~,consts_sc_CG_55]=aircraft_flight_dynamic_model(aircraft,uinf,h);
A_sc_CG_55=A_sc_CG_55(2:3,2:3); % reduce A matrix to SPPO approx
B_sc_CG_55=B_sc_CG_55(2:3,1:1); % reduce B matrix to SPPO approx

alpha0tot_sc_CG_55=consts_sc_CG_55(17);
beta_sc_CG_55=consts_sc_CG_55(21);
eta_sc_CG_55=consts_sc_CG_55(22);
h_sc_CG_55=h;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cessna 172 CG 0.143
aircraft='cessna_172_data.mat';
uinf=63; % target aircraft flight speed [m/s]
h=0.143;    % target aircraft wing chord normalised c.g. location [-]

[A_ce_CG_14,B_ce_CG_14,~,~,consts_ce_CG_14]=aircraft_flight_dynamic_model(aircraft,uinf,h);
A_ce_CG_14=A_ce_CG_14(2:3,2:3); % reduce A matrix to SPPO approx
B_ce_CG_14=B_ce_CG_14(2:3,1:1); % reduce B matrix to SPPO approx

alpha0tot_ce_CG_14=consts_ce_CG_14(17);
beta_ce_CG_14=consts_ce_CG_14(21);
eta_ce_CG_14=consts_ce_CG_14(22);
h_ce_CG_14=h;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cessna 172 CG 0.2405
aircraft='cessna_172_data.mat';
uinf=63; % target aircraft flight speed [m/s]
h=0.2405;    % target aircraft wing chord normalised c.g. location [-]

[A_ce_CG_24,B_ce_CG_24,~,~,consts_ce_CG_24]=aircraft_flight_dynamic_model(aircraft,uinf,h);
A_ce_CG_24=A_ce_CG_24(2:3,2:3); % reduce A matrix to SPPO approx
B_ce_CG_24=B_ce_CG_24(2:3,1:1); % reduce B matrix to SPPO approx

alpha0tot_ce_CG_24=consts_ce_CG_24(17);
beta_ce_CG_24=consts_ce_CG_24(21);
eta_ce_CG_24=consts_ce_CG_24(22);
h_ce_CG_24=h;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cessna 172 CG 0.338
aircraft='cessna_172_data.mat';
uinf=63; % target aircraft flight speed [m/s]
h=0.338;    % target aircraft wing chord normalised c.g. location [-]

[A_ce_CG_34,B_ce_CG_34,~,~,consts_ce_CG_34]=aircraft_flight_dynamic_model(aircraft,uinf,h);
A_ce_CG_34=A_ce_CG_34(2:3,2:3); % reduce A matrix to SPPO approx
B_ce_CG_34=B_ce_CG_34(2:3,1:1); % reduce B matrix to SPPO approx

alpha0tot_ce_CG_34=consts_ce_CG_34(17);
beta_ce_CG_34=consts_ce_CG_34(21);
eta_ce_CG_34=consts_ce_CG_34(22);
h_ce_CG_34=h;

%% update simulink model
set_param(bdroot,'SimulationCommand','Update')

% %% run simulink model
% sim('aircraft_control_model_v2.slx')
% %% extracting time vector from SimulationOutput
% % time vector (s)
% time=ans.tout;  % time (s)

