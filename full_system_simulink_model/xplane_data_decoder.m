function[vInd_kias,vTrue_ktas,n,q,roll_angle,yaw_rate,eta,delta_a,delta_r,throttle,delta_tt]=xplane_data_decoder(data_input)

vInd_kias=data_input(2,1);
vTrue_ktas=data_input(2,1);

n=data_input(6,2);

eta=data_input(2,3);
delta_a=data_input(3,3);
delta_r=data_input(4,3);

delta_tt=data_input(2,4);

q=data_input(2,5);
yaw_rate=data_input(4,5);

roll_angle=data_input(3,6);

throttle=data_input(2,8);


