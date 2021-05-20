function[header,control_surfaces_cmd,throttle_cmd,trim_cmd]=convert_control_inputs_to_bytes(elevator,aileron,rudder,throttle,trimtab)
% header
header=[uint8(68) uint8(65) uint8(84) uint8(65)];

% no command condition
no_cmd=single(-999);

% surface header bytes
%surface_header=typecast(uint8([uint8(8) uint8(0) uint8(0) uint8(0)]),'single');

% control surface bytes
%control_surfaces_cmd=[surface_header elevator aileron rudder no_cmd no_cmd no_cmd no_cmd no_cmd];
control_surfaces_cmd=[1.1210388e-44 elevator aileron rudder no_cmd no_cmd no_cmd no_cmd no_cmd];


% throttle header bytes
%throttle_header=typecast(uint8([uint8(25) uint8(0) uint8(0) uint8(0)]),'single');

% throttle command
%throttle_cmd=[throttle_header throttle no_cmd no_cmd no_cmd no_cmd no_cmd no_cmd no_cmd];
throttle_cmd=[3.5032462e-44 throttle no_cmd no_cmd no_cmd no_cmd no_cmd no_cmd no_cmd];

% trim header bytes
%trim_header=typecast(uint8([uint8(13) uint8(0) uint8(0) uint8(0)]),'single');

% trim command
%trim_cmd=[trim_header trimtab no_cmd no_cmd no_cmd no_cmd no_cmd no_cmd no_cmd];
trim_cmd=[1.8216880e-44 trimtab no_cmd no_cmd no_cmd no_cmd no_cmd no_cmd no_cmd];

end