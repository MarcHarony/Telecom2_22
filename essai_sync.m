sync = [1 0 1 1 0 0];
trame = round(rand(1,10));
msg = [sync trame]*2-1;

R = 1000;%débit binaire
Tb = 1/R;%période 1 bit

Ttrame = 0:Tb:15*Tb;%période d'une trame
figure(1);
stairs(Ttrame,msg);
axis([0 15*Tb -1.1 1.1]);

L=3;
alpha = 0.7; %facteur rolloff
beta=30;%facteur suréchantillonnage
Tn = Tb/beta; %periode numerique

h = rcosdesign(alpha,2*L,beta);%FIR
norm_h = h/max(h);%FIR normalise

x = upfirdn(msg, norm_h, beta);%Filtrage et suréchantillonnage 

t2 = 0:15*Tb/length(x):15*Tb*(1-1/length(x));
figure(2)
plot(t2,x);

omega= 2*pi*4/Tb;
port1 = cos(omega*t2);%porteuse

msg_mod = x.*port1;%element wise multiplication

figure(3)
plot(t2,msg_mod);
hold on;
plot(t2,x);

%puissance moyenne signal
%av_power = (1/length(msg_mod) * sum(msg_mod.^2))

gamma = 10;%suréchantillonnage pour rendre le signal "analogique"
msg_an = interpft(msg_mod,gamma*size(msg_mod,2));%méthode interpolation
Ta = Tn/gamma;%periode analogique
fa = 1/Ta;%freq analog

t3 = 0:1/(gamma*length(x)):1-1/(gamma*length(x));
figure(4);
plot(t3,msg_an);

y = abs(fft(msg_an));
y_pos = y(1:(round(length(y)/2)));
f2 = (0:1:length(y_pos)-1);
figure(5);
semilogy(f2,y_pos);
axis([0 700 10 1000]);

%CANAL

figure(6);
input_signal = msg_an;
time_input = t3;
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
t4 = (0:time_input(2):(delay-1)*time_input(2));
time_delay = horzcat(t4,time_input+delay*time_input(2));
delayed_signal = horzcat(zeros(1,delay),noised_signal);
subplot(2,2,4)
plot(time_delay, delayed_signal);
title('Delayed signal')




%RECEPTEUR
y = abs(fft(delayed_signal));
y_pos = y(1:(round(length(y)/2)));%spectre fréquences positives
f2 = (0:1:length(y_pos)-1);

figure(7);
semilogy(f2,y_pos);
axis([0 700 100 1000]);

bande = find(y_pos>=100);
largeur = bande(end) - bande(1);
canal = [bande(1) bande(1)+largeur];

[a1, b1] = butter(9,canal/100,'bandpass');
recep = filter(a1, b1, delayed_signal);

figure(8);
plot(recep)

dwn1 = downsample(recep,gamma);
scale1 = dwn1/max(dwn1);

delta=2^10;
codebook = -1:(2/delta):1;
partition = (-1+(1/delta)):(2/delta):(1-(1/delta));

adc1 = quantiz(scale1,partition,codebook);

figure(9);
plot(adc1)

t4 = 0:1/length(norm_h):1-1/length(norm_h);

adapt = conv(adc1,norm_h.*cos(omega*t4));

figure(10);
plot(adapt)

t5 = (-L*Tb:Tn:L*Tb);

upsampled_adapted_sync_m = conv((upsample(sync*2-1,beta)),norm_h.*cos(omega*t5));
figure(11)
plot(upsampled_adapted_sync_m)
title('Upsampled synch message')

[corr_matrix, lags] = xcorr(adapt, upsampled_adapted_sync_m);
fprintf('length of corr_matrix: %d\n', length(corr_matrix))
[Valeur_Max, max_index] = max(corr_matrix);
index_start = max_index - length(adapt)
trimmed_msg=adapt(index_start:end)

k = index_start+1:beta: index_start+beta*length(msg);
linked_values = adapt(k);

plot(adapt)
title("signal séparé et adapté pour canal 1")
hold on
plot(k,linked_values,'r*')
linked_values;
