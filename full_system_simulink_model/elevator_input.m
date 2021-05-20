function[u_out]=elevator_input(u_in,clock_time,elev_period,elev_period_start)

if clock_time<elev_period_start
    u_out=0;
elseif clock_time>=elev_period_start+elev_period
    u_out=0;
else
    u_out=u_in;   
    %u_out=u(1)*sin((2*pi/elev_period)*(clock_time-elev_period_start));
end