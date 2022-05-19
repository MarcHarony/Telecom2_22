%Emetteur

R = 64;%débit binaire
Tb = 1/R;%durée bit

trame = round(rand(1,65)); %creates random vector
msg = trame*2-1;%code nrz
trame2 = round(rand(1,65)); %creates random vector
msg2 = trame2*2-1;%code nrz
trame3 = round(rand(1,65)); %creates random vector
msg3 = trame3*2-1;%code nrz
trame4 = round(rand(1,65)); %creates random vector
msg4 = trame4*2-1;%code nrz


N=4;%nombre de canaux
n = [1 2 3 4];%canal n

t = (0:Tb:1);%timespace

figure(1);
subplot(2,2,1);
stairs(t,trame);
axis([0 1.1 -1.5 1.5]);
subplot(2,2,2);
stairs(t,trame2);
axis([0 1.1 -1.5 1.5]);
subplot(2,2,3);
stairs(t,trame3);
axis([0 1.1 -1.5 1.5]);
subplot(2,2,4);
stairs(t,trame4);
axis([0 1.1 -1.5 1.5]);

%figure(2);
%stairs(t,msg);
%axis([0 1.1 -1.5 1.5]);

omega= 2*pi*2/Tb;
L=3;
alpha = 0.2; %facteur rolloff
beta=30;%facteur suréchantillonnage
Tn = Tb/beta; %periode numerique


h = rcosdesign(alpha,2*L,beta);
norm_h = h/max(h);%fir normalise

x = upfirdn(msg, norm_h, beta);
x2 = upfirdn(msg2, norm_h, beta);
x3 = upfirdn(msg3, norm_h, beta);
x4 = upfirdn(msg4, norm_h, beta);

t2 = (0:1/(length(x)-1):1);

figure(200)
subplot(2,2,1);
plot(t2,x);
subplot(2,2,2);
plot(t2,x2);
subplot(2,2,3);
plot(t2,x3);
subplot(2,2,4);
plot(t2,x4);



%pas de porteuse pour le premier canal
port1 = cos(omega*n(1)*t2);
msg_mod = x.*port1;%element wise multiplication
port2 = cos(omega*n(2)*t2);
msg_mod2 = x2.*port2;
port3 = cos(omega*n(3)*t2);
msg_mod3 = x3.*port3;
port4 = cos(omega*n(4)*t2);
msg_mod4 = x4.*port4;

figure(2)
subplot(2,2,1);
plot(t2,msg_mod);
hold on;
plot(t2,x);
subplot(2,2,2);
plot(t2,msg_mod2);
subplot(2,2,3);
plot(t2,msg_mod3);
subplot(2,2,4);
plot(t2,msg_mod4);


amp = 0.2;%amplification signal de sortie

msg_fin = amp * (msg_mod + msg_mod2 + msg_mod3 + msg_mod4);


gamma = 10;%suréchantillonnage pour rendre le signal "analogique"
msg_an = interpft(msg_fin,gamma*size(msg_fin,2));%méthode interpolation
ta = Tn/gamma;%periode analogique
fa = 1/ta;%freq analog

t3 = (0:1/((length(msg_an)-1)):1);

figure(3);
plot(t3,msg_an);
%Tn = 1/1920 = 1/30*64


%controler la puissance avec des unités (p ex watt)
%prendre en compte l'impédance du câble
%var en volt2 divisé par impédance du câble



y = abs(fft(msg_an));
%la partie positive se trouvve dans la première partie
%y_pos = y(round(length(y)/2):length(y)); %partie positive
y_pos = y(1:(round(length(y)/2)));
%y4 = abs(fft(msg_mod4));
%y4_pos = y4(1:round(length(y4)/2));
f2 = (0:1:length(y_pos)-1);
%f3 = (0:1:length(y4_pos)-1);
figure(4);
semilogy(f2,y_pos);
axis([0 700 20 1000]);


%{
figure(6);
plot(psd(spectrum.periodogram,msg_fin,'Fs',1920,'NFFT',length(msg_fin)));
%}


%{
[h,st] = rcosfir(a,[-L*Tb;L*Tb],beta,1,filterType); %x(t) convo h(t) = y(t)
y=conv(msg,h);
plot(t,y);
%}


%largeur = porteuse plus ou moins L*TB

%{

Affichage avec interpolation

x2=interp(x,40);
t3=(0:1/(length(x2)-1):1);
port2 = cos(omega*t3);
msg_mod2 = x2.*port2;
plot(t3,x2);
hold on;
plot(t3,msg_mod2);
grid on;
%}