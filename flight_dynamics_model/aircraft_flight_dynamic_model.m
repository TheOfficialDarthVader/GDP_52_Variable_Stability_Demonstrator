function[A,B,C,D,aircraft_constants]=aircraft_flight_dynamic_model(data_file_name,V,h_cg)
%% author
% Declan Clifford
% please contact me at declan.clifford01@gmail.com for questions relating
% to this code

%% description
% this code calculates the aerodynamic stability and control derivatives
% of a user inputted aircraft for a specific flight speed and centre of 
% gravity configuration, and arranges them in state space matrix form.

% this code is split into five sections:
% section 1:
% deriving the necessary geometry of the aircraft based on the user
% inputted data file

% section 2:
% peforming a lift and moment balance on the aircraft to determine its
% trimmed flight characteristics i.e. lift coefficients, lift curve slopes,
% etc

% section 3:
% performing a drag audit of the aircraft. a matlab live script has been
% provided separately which shows the audit in more detail

% section 4:
% calculating the non-dimensional aerodynamic stability and control 
% derivatives

% section 5: 
% arranging the derivatives into state space matrix form

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function inputs:

% data_file_name (-):
% the name of the .mat file which contains all of the neccessary
% information of the aircraft desired to be modelled. please see and follow
% the format of the ac_specs_sherwood_scout.m and ac_specs_cessna_172.m
% files when creating new data input files.

% V (m/s):
% aircraft flight speed in m/s.

% h_cg (-):
% distance between the wing leading edge and aircraft centre of gravity as
% a percentage of mean wing aerodynamic chord.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function outputs:

% A, B, C, D:
% aircraft state space matrices

% aircraft_constants:
% a selection of constants used during stick force modelling. these must be
% redefined accordingly in the aircraft_control_model_initialisation_v2.m
% script

%% how to use this function
% step 1:
% run the aircraft data input.m file, for example run
% ac_specs_sherwood_scout.m

% step 2:
% fill in the function inputs.
% data_file_name should be replaced with the name of the .mat file
% generated by the previosuly ran aircraft data input file.
% in this case the generated .mat file is 'sherwood_scout_data.mat'.
% likewise enter a flight speed and centre of gravity location

% this will then generate the necessary state space matrices to create a
% linear flight dynamics model of the aircraft.

%% load defined aircraft data data file
load(data_file_name,'-mat')

%% section 1: basic derived aircraft geometry data %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% derived main wing data
c_w=(c_w_root+c_w_tip)/2;     % wing reference chord          [m]
s_w=b_w*c_w;                  % wing planform area            [m^2]
s_ref=s_w;                    % reference area                [m^2]
s_w_wet=s_w*2;                % wing wetted area              [m^2]
tc_w=(tc_w_root+tc_w_tip)/2;  % average thickness/chord ratio [-]
AR_w=(b_w^2)/s_w;             % wing aspect ratio             [-]

% derived horizontal tail data
c_tp=(c_tp_root+c_tp_tip)/2;    % horizontal tail reference chord [m]
c_e=stab_e_ratio*c_tp;          % elevator reference chord        [m]
s_tp=b_tp*c_tp;                 % horizontal tail reference area  [m^2]
s_tp_wet=s_tp*2;                % horizontal tail wetted area     [m^2]
s_e=b_tp*c_e;                   % elevator reference area         [m^2]
AR_tp=(b_tp^2)/s_tp;            % tail plane aspect ratio         [-]
tc_tp=(tc_tp_root+tc_tp_tip)/2; % average horizontal tail...
                                % thickness/chord ratio           [-]

% derived fuselage data
A_f=b_f_h*b_f_w;                % fuselage max cross section area [m^2]

% derived vertical tail data
c_tp_v=(c_tp_v_root+c_tp_v_tip)/2;    % vertical tail reference chord [m]
s_tp_v=b_tp_v*c_tp_v;                 % vertical tail reference area  [m^2]
s_tp_v_wet=s_tp_v*2;                  % vertical tail wetted area     [m^2]
tc_tp_v=(tc_tp_v_root+tc_tp_v_tip)/2; % average vertical tail...
                                      % thickness/chord ratio         [-]

% derived configuration data
l_t=l_ac-(c_w*(h_cg-h0));        % dist from tail ac to cg             [m]
lw=(h_cg-h0)*c_w;                % dist from wing ac to cg             [m]
K=s_tp*l_t/(s_w*c_w);            % tail volume fraction                [-]

%% section 2: peform aerodynamic calculations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% steady level flight load factor at 1g [-]
n=1;                                

% total aircraft lift coeff     [-]
CLtot=n*m*g/(0.5*rho*(V^2)*s_w);    

% tailplane lift coefficient
CL_tp=(Cm0+CLtot*(h_cg-h0))/(((s_tp/s_w)*(h_cg-h0))+K); % tail lift coeff [-]

% main wing lift curve slope
% according to torenbeek's method given in "synthesis of subsonic airplane
% design"
% jone's edge velocity factor
E=1.0+(2*tr)/(AR_w*(1.0+tr));     

% main wing lift curve slope [rad^-1]                          
dCL_w_dalpha=f*(a0/(E+(a0/(pi*AR_w)))); 

% main wing lift coefficient [-]
CL_w=CLtot-CL_tp*(s_tp/s_w);

% aircraft fuselage datum angle of attack [rad]
alpha_f=(CL_w/dCL_w_dalpha)+alpha0-alpha_ws;
                                             
% main wing angle of attack [rad]
alpha_w=alpha_f+alpha_ws;

% downwash calculations
% according to torenbeek's method given in "synthesis of subsonic airplane
% design"
    % distance factor between wing and tail plane [m]
    r=2*l_ac/b_w;

    % main wing downwash at tail [rad]
    epsilon=1.75*(CL_w/(((pi*AR_w*(tr*r)^0.25))*...
            (1.0+modM)));

    % downwash slope [rad^-1]
    depsilon_dalpha=1.75*(dCL_w_dalpha/(((pi*AR_w*(tr*r)^0.25))*...
                    (1+modM)));

% tail effective angle of attack [rad]
alpha_tp_eff=alpha_f+alpha_ts-epsilon;

% tail lift curve slope [rad^-1]
% ESDU data sheets give correction factors for a1 which depend on the
% aircraft configuration and should be applied on a case by case basis
% this value does not consider downwash effects from the main wing!!!
dCL_tp_dalpha=a1;

% total lift curve slope [rad^-1]
dCLtot_dalpha=dCL_w_dalpha+dCL_tp_dalpha*(s_tp/s_w);

% total aircraft zero lift angle [rad]
alpha0tot=alpha_f-(CLtot/dCLtot_dalpha);

% stick fixed static margin [-]
    % normalised as a percentage of wing chord
    % this stick fixed equation seemingly gives a closer match to the x-plane
    % aircraft's performance. this equation ignores the effects of downwash 
    % from the main wing on the tail plane. however, it gives a less "accurate"
    % comparison with experimental derivative data.
    % hs_sf=h0-h_cg+K*(dCL_tp_dalpha/dCLtot_dalpha);

    % this stick fixed equation is the more "realistic" one, taking into account
    % downwash from the main wing on the tail plane. this will give a more
    % "realisitc" representation of the real sherwood scout and gives, and a
    % more "accurate" comparison with experimental derivative data, however
    % it doesn't give as close a match with the performance of the x-plane 
    % sherwood scout.
    hs_sf=-(h_cg-h0)+K*(a1/dCL_w_dalpha)*(1-depsilon_dalpha);

% neutral point [-]
% normalised as a percentage of wing chord
hn=h0+K*(dCL_tp_dalpha/dCLtot_dalpha);

% STICK FREE TRIM CONTROL SURFACE DEFLECTIONS
    % trimtab angle for zero hinge [rad] (STICK FREE)
    beta=(CL_tp-((a1-(a2*(b1/b2))))*alpha_tp_eff)/(a3-a2*(b3/b2));                       

    % elevator angle for steady level flight [rad] (STICK FREE)
    eta=(CL_tp-(a1*alpha_tp_eff)-(a3*beta))/a2; 

% % STICK FIXED TRIM CONTROL SURFACE DEFLECTIONS
% leave this commented out unless you want to overwrite the stick free 
    % control surface deflections
    
    % % elevator angle for steady level flight [rad] (STICK FIXED)
    % eta=(CL_tp-(a1*alpha_tp_eff))/a2;
    
    % % trim tab angle (STICK FIXED)
    % beta=0.0;                                   

% drag curve slope [-]
% the drag curve slope dCD/dalpha can be found as (dCD/dCL)*(dCL/dalpha)
% dCD/dCL can be found by differentiating the equation CD=CD0+CDi or
% CD=CD0+(CL^2)/(pi*AR*e) with respect to CL, so dCD/dCL = 2*CL/(pi*AR*e)
dCD_dCL=2*CLtot/(pi*AR_w*e_w);

% total aircraft drag curve slope (rad^-1)
dCD_dalpha=dCD_dCL*dCLtot_dalpha; % aircraft drag curve slope [rad^-1]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% form aircraft_constants data set
aircraft_constants(1)=n;
aircraft_constants(2)=m;
aircraft_constants(3)=g;
aircraft_constants(4)=rho;

aircraft_constants(5)=s_w;
aircraft_constants(6)=s_tp;
aircraft_constants(7)=K;
aircraft_constants(8)=AR_w;
aircraft_constants(9)=s_e;
aircraft_constants(10)=c_e;

aircraft_constants(11)=Cm0;
aircraft_constants(12)=h_cg;
 aircraft_constants(13)=h0;

aircraft_constants(14)=dCL_w_dalpha;
aircraft_constants(15)=dCLtot_dalpha;

aircraft_constants(16)=alpha0;
aircraft_constants(17)=alpha0tot;
aircraft_constants(18)=alpha_ws;
aircraft_constants(19)=alpha_ts;

aircraft_constants(20)=e_w;

aircraft_constants(21)=beta;
aircraft_constants(22)=eta;

aircraft_constants(23)=b1;
aircraft_constants(24)=b2;
aircraft_constants(25)=b3;

aircraft_constants(26)=G;
aircraft_constants(27)=l_m;

aircraft_constants(28)=tr;
aircraft_constants(29)=r;
aircraft_constants(30)=modM;

%% aircraft drag audit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% here we follow the drag component build up method outlined by 
% S.Gudmundsson under Section 15.4.6: "The Component Drag Build-Up Method" 
% in "General Aviation Aircraft Design". The method has been simplified to 
% the sections only considering the drag of a low speed light aircraft of 
% simple geometry (i.e. unswept wings). Many of the methods and procedures 
% Gudmundsson describes are taken from Hoerner's "Fluid Dynamic Drag".
%
% This method considers the drag of the entire aircraft as split into 
% three distinct groups:
%
% Parasite Drag
% Vortex Induced Drag
% Miscellaneous Drag

% DRAG COMPONENTS NOT CONSIDERED HERE
% drag to due rivets
% engine exhaust drag
% trim drag

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% main wing %%%%
%%%% wing reynolds numbers
Re_w_root_cutoff=38.21*(c_w_root/kappa); % wing root cutoff...
                                         % reynolds number [-]
                                         
Re_w_tip_cutoff=38.21*(c_w_tip/kappa);   % wing tip cutoff...
                                         % reynolds number [-]
                                         
Re_w_cutoff=38.21*(c_w/kappa);           % average wing cutoff...
                                         % reynolds number [-]

Re_w_root=V*c_w_root/nu;              % wing root reynolds number [-]
Re_w_tip=V*c_w_tip/nu;                % wing tip reynolds number  [-]
Re_w=V*c_w/nu;                        % average wing reynolds number [-]

% if calculated reynolds number exceeds cutoff reynolds number
% then use cutoff reynolds number.
% check at wing root
if Re_w_root>Re_w_root_cutoff
    Re_w_root=Re_w_root_cutoff;
else 
    Re_w_root=Re_w_root;
end
% check at wing tip
if Re_w_tip>Re_w_tip_cutoff
    Re_w_tip=Re_w_tip_cutoff;
else 
    Re_w_tip=Re_w_tip;
end
% check over average wing conditions
if Re_w>Re_w_cutoff
    Re_w=Re_w_cutoff;
else
    Re_w=Re_w;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Young's two step mixed-laminar flow skin friction method:

% location where laminar boundary layer becomes turbulent
% normalised by wing chord [-]
xtr_w_root_upper=0.20;  % at upper surface root aerofoil
xtr_w_root_lower=0.20;  % at lower surface root aerofoil
xtr_w_tip_upper=0.20;   % at upper surface tip aerofoil
xtr_w_tip_lower=0.20;   % at lower surface root aerofoil

% location of boundary layer normalised by wing chord at wing root
x0_w_root_upper=36.9*((xtr_w_root_upper)^0.625)*((1/Re_w_root)^0.375);
x0_w_root_lower=36.9*((xtr_w_root_lower)^0.625)*((1/Re_w_root)^0.375);

% location of boundary layer normalised by wing chord at wing tip
x0_w_tip_upper=36.9*((xtr_w_tip_upper)^0.625)*((1/Re_w_tip)^0.375);
x0_w_tip_lower=36.9*((xtr_w_tip_lower)^0.625)*((1/Re_w_tip)^0.375);
          
Cf_w_root_upper=(0.074/(Re_w_root^0.2))*...
                (1-((xtr_w_root_upper-x0_w_root_upper)/c_w_root))^0.8;
            
Cf_w_root_lower=(0.074/(Re_w_root^0.2))*...
                (1-((xtr_w_root_lower-x0_w_root_lower)/c_w_root))^0.8;
            
Cf_w_root=(Cf_w_root_upper+Cf_w_root_lower)/2;

Cf_w_tip_upper=(0.074/(Re_w_tip^0.2))*...
               (1-((xtr_w_tip_upper-x0_w_tip_upper)/c_w_tip))^0.8;
Cf_w_tip_lower=(0.074/(Re_w_tip^0.2))*...
               (1-((xtr_w_tip_lower-x0_w_tip_lower)/c_w_tip))^0.8;
Cf_w_tip=(Cf_w_tip_upper+Cf_w_tip_lower)/2;

Cf_w_mixed=(Cf_w_root+Cf_w_tip)/2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% assuming fully turbulent flow for wing:
Cf_w_root_turb=0.455/((log10(Re_w_root))^2.58);
Cf_w_tip_turb=0.455/((log10(Re_w_tip))^2.58);
Cf_w_turb=(Cf_w_root_turb+Cf_w_tip_turb)/2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% select Cf_w:
% choosing between the mixed and turbulent calculation
% its safer to use the fully turbulent value as the mixed value comes from
% guesses on where the transition point is on the upper and lower wing
% surfaces
%Cf_w=Cf_w_mixed;
Cf_w=Cf_w_turb;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% calculate wing drag count contribution:
% wing skin friction drag coefficient [dim]
% this term is weighted according to the main wing reference area
CDf_w=(s_w_wet/s_ref)*Cf_w;

% jenkinson's wing form factor [dim]
FF_w=(3.3*(tc_w)-(0.008*(tc_w)^2)+27*(tc_w)^3)*cos(gamma_mid_chord_w)+1;

% main wing interference factor [dim]
IF_w=1.1;

CD0_w=CDf_w*FF_w*IF_w;           % wing profile drag coefficient [-]

CD0_w_counts=CD0_w*1e4;          % wing drag counts [-]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% horizontal tail %%%%
%%%% horizontal tail reynolds number
Re_tp_root_cutoff=38.21*(c_tp_root/kappa); % horizontal tail root cutoff...
                                           % reynolds number [-]
                                           
Re_tp_tip_cutoff=38.21*(c_tp_tip/kappa);   % horizontal tail tip cutoff...
                                           % reynolds number [-]
Re_tp_cutoff=38.21*(c_tp/kappa);           % average horizontal tail...
                                           % cutoff reynolds number [-]

Re_tp_root=V*c_tp_root/nu;    % horizontal tail root reynolds number [-]
Re_tp_tip=V*c_tp_tip/nu;      % horizontal tail tip reynolds number  [-]
Re_tp=V*c_tp/nu;           % average horizontal tail reynolds number [-]

% if calculated reynolds number exceeds cutoff reynolds number
% then use cutoff reynolds number.
% check at horizontal tail root
if Re_tp_root>Re_tp_root_cutoff
    Re_tp_root=Re_tp_root_cutoff;
else 
    Re_tp_root=Re_tp_root;
end
% check at horizontal tail tip
if Re_tp_tip>Re_tp_tip_cutoff
    Re_tp_tip=Re_tp_tip_cutoff;
else 
    Re_tp_tip=Re_tp_tip;
end
% check over average horizontal tail conditions
if Re_tp>Re_tp_cutoff
    Re_tp=Re_tp_cutoff;
else
    Re_tp=Re_tp;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% assuming fully turbulent flow for tail
Cf_tp_root_turb=0.455/((log10(Re_tp_root))^2.58);
Cf_tp_tip_turb=0.455/((log10(Re_tp_tip))^2.58);
Cf_tp_turb=(Cf_tp_root_turb+Cf_tp_tip_turb)/2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% calculate horiz tail drag count contribution
% horizontal tail skin friction drag coefficient [dim]
% this term is weighted according to the main wing reference area
CDf_tp=(s_tp_wet/s_ref)*Cf_tp_turb;

% jenkinson's tail form factor [dim]
FF_tp=(3.52*(tc_tp))*cos(gamma_mid_chord_tp)+1;

% horizontal tail interference factor [dim]
IF_tp=1.2;

CD0_tp=CDf_tp*FF_tp*IF_tp;         % horiz tail profile drag coefficient

CD0_tp_counts=CD0_tp*1e4;          % horiz tail drag counts

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% vertical tail %%%%
%%%% vertical tail reynolds numbers
Re_tp_v_root_cutoff=38.21*(c_tp_v_root/kappa); % vertical tail root...
                                               % cutoff reynolds number [-]
                                                 
Re_tp_v_tip_cutoff=38.21*(c_tp_v_tip/kappa);   % vertical tail tip...
                                               % cutoff reynolds number [-]
                                                 
Re_tp_v_cutoff=38.21*(c_tp_v/kappa);           % average vertical tail...
                                               % cutoff reynolds number [-]

Re_tp_v_root=V*c_tp_v_root/nu;              % vertical tail...
                                               % root reynolds number [-]
                                               
Re_tp_v_tip=V*c_tp_v_tip/nu;                % vertical tail...
                                               % tip reynolds number  [-]

Re_tp_v=V*c_tp_v/nu;                        % average vertical...
                                               % tail reynolds number [-]

% if calculated reynolds number exceeds cutoff reynolds number
% then use cutoff reynolds number.
% check at vertical tail root
if Re_tp_v_root>Re_tp_v_root_cutoff
    Re_tp_v_root=Re_tp_v_root_cutoff;
else 
    Re_tp_v_root=Re_tp_v_root;
end
% check at vertical tail tip
if Re_tp_v_tip>Re_tp_v_tip_cutoff
    Re_tp_v_tip=Re_tp_v_tip_cutoff;
else 
    Re_tp_v_tip=Re_tp_v_tip;
end
% check over average vertical tail conditions
if Re_tp_v>Re_tp_v_cutoff
    Re_tp_v=Re_tp_v_cutoff;
else
    Re_tp_v=Re_tp_v;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% assuming fully turbulent flow for vertical tail
Cf_tp_v_root_turb=0.455/((log10(Re_tp_v_root))^2.58);
Cf_tp_v_tip_turb=0.455/((log10(Re_tp_v_tip))^2.58);
Cf_tp_v_turb=(Cf_tp_v_root_turb+Cf_tp_v_tip_turb)/2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% vertical tail skin friction drag coefficient [dim]
% this term is weighted according to the main wing reference area
CDf_tp_v=(s_tp_v_wet/s_ref)*Cf_tp_v_turb;

% jenkinson's tail form factor [dim]
FF_tp_v=(3.52*(tc_tp_v))*cos(gamma_mid_chord_tp_v)+1;

% vertical tail interference factor [dim]
IF_tp_v=1.2;

CD0_tp_v=CDf_tp_v*FF_tp_v*IF_tp_v;         % vertical tail drag coefficient

CD0_tp_v_counts=CD0_tp_v*1e4;              % vertical tail drag counts

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% fuselage %%%%
% fuselage reynolds number
Re_f=V*c_f/nu;                 % fuselage reynolds number
Re_f_cutoff=38.21*(c_f/kappa); % fuselage cutoff reynolds number

if Re_f>Re_f_cutoff
    Re_f=Re_f_cutoff;
else 
    Re_f=Re_f;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% assume fully turbulent flow for fuselage
Cf_f=0.455/((log10(Re_f))^2.58); % fuselage skin friction coefficient

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% drag count contribution of fuselage
CDf_f=(s_f_wet/s_ref)*Cf_f;       % fuselage skin friction drag coefficient

f=c_f/sqrt(4*A_f/pi);             % fuselage fineness ratio [-]
FF_f=1+(2.2/(f^1.5))+(3.8/(f^3)); % fuselage form factor

CD0_f=CDf_f*FF_f;

CD0_f_counts=CD0_f*1e4;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% vortex induced drag contributions %%%%
% main wing vortex induced drag count contribution
CDi_w=((CL_w^2)/...
      (pi*AR_w))*(1+delta_w); % main wing induced drag coeff [-]

CDi_w_counts=CDi_w*1e4;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% horizontal tail vortex induced drag count contribution
CDi_tp=(((CL_tp^2)/...
       (pi*AR_tp))*(1+delta_tp))*s_tp/s_w; % tail induced drag coeff [-]

CDi_tp_counts=CDi_tp*1e4;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% wing struts %%%%
%%%% wing strut drag count contribution
Re_strut=V*c_strut/nu;

Cf_strut=0.455/((log10(Re_strut))^2.58);

IF_wing_strut=1.2;

CD0_strut=(2*Cf_strut*(1+tc_strut)+(tc_strut)^2)*...
          (L_strut*c_strut/s_ref)*IF_wing_strut;

CD0_strut_counts=CD0_strut*1e4;

% drag counts of all struts
CD0_strut_counts=CD0_strut_counts*num_wing_struts;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% jury struts %%%%
% jury strut drag count contribution
Re_jury_strut=V*c_strut/nu;

Cf_jury_strut=0.455/((log10(Re_jury_strut))^2.58);

IF_jury_strut=1.2;

CD0_jury_strut=(2*Cf_jury_strut*(1+tc_jury_strut)+...
               (tc_jury_strut)^2)*...
               (L_jury_strut*c_jury_strut/s_ref)*IF_jury_strut;

CD0_jury_strut_counts=CD0_jury_strut*1e4;

% drag counts of all jury struts
CD0_jury_strut_counts=CD0_jury_strut_counts*num_jury_struts;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% tail struts %%%%
% tail strut drag count contribution
Re_tail_strut=V*c_tail_strut/nu;

Cf_tail_strut=0.455/((log10(Re_tail_strut))^2.58);

IF_tail_strut=1.2;

CD0_tail_strut=(2*Cf_tail_strut*...
               (1+tc_tail_strut)+(tc_tail_strut)^2)*...
               (L_tail_strut*c_tail_strut/s_ref)*IF_tail_strut;

CD0_tail_strut_counts=CD0_tail_strut*1e4;

% drag counts of all tail struts
CD0_tail_strut_counts=CD0_tail_strut_counts*num_tail_struts;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% tail bracing cables %%%%
% tail bracing cable drag count contribution
CD0_tail_cable=Cds_cable*(d_tail_cable*L_tail_cable/s_ref);

CD0_tail_cable_counts=CD0_tail_cable*1e4;

CD0_tail_cable_counts=CD0_tail_cable_counts*num_tail_bracing_cables;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% landing gear %%%%
% landing gear and strut drag count contribution

if contains(data_file_name,'sherwood_scout_data.mat')
    CD0_fixed_gear=1.151;
else
    CD0_fixed_gear=0.45;
end

CD0_gear_front=((d_gear_front*w_gear_front)/s_ref)*CD0_fixed_gear;
CD0_gear_rear=((d_gear_rear*w_gear_rear)/s_ref)*0.25;

CD0_gear=CD0_gear_front+CD0_gear_rear;
CD0_gear_counts=CD0_gear*1e4;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% cockpit window %%%%
% conventional cockpit window drag count contribution
CD0_window=0.002*A_f/s_w;
CD0_window_counts=CD0_window*1e4;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% antenna %%%%
% antenna drag count contribution
CD0_antenna=Cds_antenna*(antenna_diameter*antenna_length/s_ref);

CD0_antenna_counts=CD0_antenna*1e4;

CD0_antenna_counts=CD0_antenna_counts*2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% total drag %%%%
% total drag count contribution
CDtot_counts=CD0_w_counts+...
             CD0_tp_counts+...
             CD0_tp_v_counts+...
             CD0_f_counts+...
             CDi_w_counts+...
             CDi_tp_counts+...
             CD0_strut_counts+...
             CD0_jury_strut_counts+...
             CD0_tail_strut_counts+...
             CD0_tail_cable_counts+...
             CD0_gear_counts+...
             CD0_window_counts+...
             CD0_antenna_counts;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% drag count breakdown via chart %%%%
% leave this commented out unless you want to see the drag count
% breakdown everytime you run the model

% % X=categorical({'Wing', 'Tail', 'Fuselage', 'Struts',...
% %                'Cables', 'Gear','Induced','Other'});
% % 
% % X=reordercats(X,{'Wing', 'Tail', 'Fuselage', 'Struts',...
% %                  'Cables', 'Gear','Induced','Other'});
% % 
% % % WITH CRUD factor             
% % Y=[CD0_w_counts*1.25,...
% %    (CD0_tp_counts+CD0_tp_v_counts)*1.25,...
% %    CD0_f_counts*1.25,...
% %    (CD0_strut_counts+CD0_tail_strut_counts+CD0_jury_strut_counts)*1.25,...
% %    (CD0_tail_cable_counts)*1.25,...
% %    CD0_gear_counts*1.25,...
% %    (CDi_w_counts+CDi_tp_counts),...
% %    (CD0_window_counts+CD0_antenna_counts)*1.25];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% CRUD factor %%%%
% apply gundmundsson's CRUD factor
CDtot_counts=((CDtot_counts-(CDi_w_counts+CDi_tp_counts))*1.25)+...
             (CDi_w_counts+CDi_tp_counts);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% total aircraft drag coefficient
CD=CDtot_counts/1e4;

%% stability and control derivatives %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% non-dimensional aerodynamic stability derivatives %%%%
xu=(engtyp-2)*CD;
xw=CLtot-dCD_dalpha;

zu=-2*CLtot;
zw=-(dCLtot_dalpha+CD);
zq=-K*a1;

zwd=zq*depsilon_dalpha;
mu=0;
mw=-hs_sf*dCLtot_dalpha;

mq=zq*l_t/c_w;
mwd=mq*depsilon_dalpha;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% control derivatives %%%%
xelv=-2*(s_tp/s_w)*(1/(pi*AR_tp*e_tp))*CL_tp*a2;
zelv=(-s_tp/s_w)*a2;
melv=-K*a2;

xthr=1;
zthr=0;
mthr=0;

%% state_space_matrices %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% dimensional derivative conversion %%%%
% converts the nondimensional aerodynamic derivatives into dimensional 
% aerodynamic derivatives which can be used to form the matrices necessary 
% for state space representation
xudim=0.5*rho*V*s_w*xu;
xwdim=0.5*rho*V*s_w*xw;

zudim=0.5*rho*V*s_w*zu;
zwdim=0.5*rho*V*s_w*zw;
zwddim=0.5*rho*s_w*c_w*zwd;
zqdim=0.5*rho*V*s_w*c_w*zq;

mudim=0.5*rho*V*s_w*c_w*mu;
mwdim=0.5*rho*V*s_w*c_w*mw;
mwddim=0.5*rho*s_w*c_w^2*mwd;
mqdim=0.5*rho*V*s_w*c_w^2*mq;

xelvdim=0.5*rho*V^2*s_w*xelv;
zelvdim=0.5*rho*V^2*s_w*zelv;
melvdim=0.5*rho*V^2*s_w*c_w*melv;

xthrdim=0.5*rho*V^2*s_w*xthr;
zthrdim=0.5*rho*V^2*s_w*zthr;
mthrdim=0.5*rho*V^2*s_w*c_w*mthr;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% forming longitudinal state space matrices %%%%
M = [m 0 0 0;
     0 (m - zwddim) 0 0;
     0 -mwddim Iyy 0;
     0 0 0 1];
     
Ap = [xudim xwdim 0 (-m*g*cos(gamma0));
      zudim zwdim (zqdim + m*V) (-m*g*sin(gamma0));
      mudim mwdim mqdim 0;
      0 0 1 0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% old Bp -- this assumes we have thrust and gust control terms %%%%
Bp = [xelvdim xthrdim xudim xwdim;
      zelvdim zthrdim zudim zwdim
      melvdim mthrdim mudim mwdim
      0 0 0 0];
% forming C and D matrices for old Bp
C=eye(4);     % identity matrix
D=zeros(4,4); % zero matrix 4x4

% new Bp -- this removes the thrust and gust control terms

% Bp = [xelvdim;
%       zelvdim;
%       melvdim;
%       0];
% % forming C and D matrices for new Bp
% C=eye(4);     % identity matrix
% D=zeros(4,1); % zero matrix 4x1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% forming A and B matrices %%%%
A=M\Ap;
B=M\Bp;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% forming eigenvalues of 'A' matrix %%%%
% eigenvalues_A=eig(A);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% phugoid and SPO characteristics %%%%
% % natural frequency and SPPO analysis
% % lanchester phugoid approximation natural frequency 
% omega_n_lanchester=g*sqrt(2)/uinf;
% 

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%% phugoid %%%%
% % phugoid natural frequency
% omega_n_phugoid=sqrt(real(eigenvalues_A(3))^2+imag(eigenvalues_A(3))^2);
% % phugoid damping factor
% zeta_phugoid=-real(eigenvalues_A(3))/omega_n_phugoid;
% % phugoid half life
% t_half_phugoid=log(1/2)/real(eigenvalues_A(3));
% % phugoid period
% T_phugoid=2*pi/(imag(eigenvalues_A(3)));
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%% SPPO %%%%
% % SPO natural frequency
% omega_n_SPO=sqrt(real(eigenvalues_A(1))^2+imag(eigenvalues_A(1))^2);
% % SPO damping factor
% zeta_SPO=-real(eigenvalues_A(1))/omega_n_SPO;
% % SPO half life
% t_half_SPO=log(1/2)/real(eigenvalues_A(1));
% % SPO period
% T_SPO=2*pi/(imag(eigenvalues_A(1)));