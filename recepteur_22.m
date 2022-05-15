y = abs(fft(msg_an));

%la partie positive se trouvve dans la première partie
%y_pos = y(round(length(y)/2):length(y)); %partie positive
y_pos = y(1:(round(length(y)/2)));



%y4 = abs(fft(msg_mod4));
%y4_pos = y4(1:round(length(y4)/2));


%f = (0:length(y_pos)/((length(y)/2)):length(y_pos));
f2 = (0:1:length(y_pos)-1);
%f3 = (0:1:length(y4_pos)-1);


figure(6);
semilogy(f2,y_pos);
axis([0 700 20 1000]);
%hold on;
%semilogy(f3,y4_pos);


bands = find(y_pos>=20);
largeur = (bands(end) - bands(1))/N;
canal1 = [bands(1) bands(1)+largeur];
canal2 = [bands(1)+largeur bands(1)+2*largeur];
canal3 = [bands(1)+2*largeur bands(1)+3*largeur];
canal4 = [bands(1)+3*largeur bands(1)+4*largeur];

%{
recep = bandpass(msg_fin,[300 400],1920);
figure(5);
plot(recep);
%}

[a1, b1] = butter(9,canal1/960,'bandpass');
[a2, b2] = butter(9,canal2/960,'bandpass');
[a3, b3] = butter(9,canal3/960,'bandpass');
[a4, b4] = butter(9,canal4/960,'bandpass');
recep1 = filter(a1, b1, msg_fin);
recep2 = filter(a2, b2, msg_fin);
recep3 = filter(a3, b3, msg_fin);
recep4 = filter(a4, b4, msg_fin);

figure(7);
subplot(2,2,1);
plot(recep1);
subplot(2,2,2);
plot(recep2);
subplot(2,2,3);
plot(recep3);
subplot(2,2,4);
plot(recep4);

dwn1 = downsample(recep1,gamma);
dwn2 = downsample(recep2,gamma);
dwn3 = downsample(recep3,gamma);
dwn4 = downsample(recep4,gamma);


figure(8);
subplot(2,2,1);
plot(dwn1);
subplot(2,2,2);
plot(dwn2);
subplot(2,2,3);
plot(dwn3);
subplot(2,2,4);
plot(dwn4);

scale1 = dwn1/max(dwn1);
scale2 = dwn2/max(dwn2);
scale3 = dwn3/max(dwn3);
scale4 = dwn4/max(dwn4);

figure(9);
subplot(2,2,1);
plot(scale1);
subplot(2,2,2);
plot(scale2);
subplot(2,2,3);
plot(scale3);
subplot(2,2,4);
plot(scale4);


delta=2^6;
codebook = -1:(2/delta):1;
partition = (-1+(1/delta)):(2/delta):(1-(1/delta));


adc1 = quantiz(scale1,partition,codebook);
%mieux comprendre quantiz 

figure(10);
plot(adc1)




adapt = conv(adc1,norm_h.*cos(omega*t2*n(1)));

figure(11);
plot(adapt)


