
%ATTENTION : FILTRER TOUS LES CANAUX DANS LE CANAL :p


input_signal = x;
time_input = t2;
subplot(2,2,1)
plot(time_input,input_signal);
title('Input signal')

%Facteur d'atenuation
lower_limit = 0.6;
upper_limit = 0.9;
alpha_n = (upper_limit-lower_limit).*rand(1) + lower_limit;
damped_signal = input_signal * alpha_n;
subplot(2,2,2)
plot(time_input,damped_signal);
title('Damped signal')

%Ajout bruit AWGN de densité spectrale N0/2
lower_limit = 10;
upper_limit = 12;
SNR = (upper_limit-lower_limit).*rand(1) + lower_limit;
noised_signal = awgn(damped_signal, SNR);
subplot(2,2,3)
plot(time_input,noised_signal);
title('Noisy signal')

%Ajout délai entre 2% et 8% de la longueur de time_input
lower_limit = 0.02;
upper_limit = 0.08;
delay = round(((upper_limit-lower_limit).*rand(1) + lower_limit) * size(time_input,2));
t3 = (0:time_input(2):(delay-1)*time_input(2));
time_delay = horzcat(t3,time_input+delay*time_input(2));
delayed_signal = horzcat(zeros(1,delay),noised_signal);
subplot(2,2,4)
plot(time_delay, delayed_signal);
title('Delayed signal')

