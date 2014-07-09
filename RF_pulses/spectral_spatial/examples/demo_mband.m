%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Spectral-Spatial RF Pulse Design for MRI and MRSI MATLAB Package
%
% Authors: Adam B. Kerr and Peder E. Z. Larson
%
% (c)2007-2011 Board of Trustees, Leland Stanford Junior University and
%	The Regents of the University of California. 
% All Rights Reserved.
%
% Please see the Copyright_Information and README files included with this
% package.  All works derived from this package must be properly cited.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Reset SS package globals
%
ss_opt([]);
ss_globals;


%%
fprintf(1, '\nHere''s a C13 multiband slab (6cm) excitation pulse, for pyr+urea dynamic imaging\n');

% setup flip angles and bandwidths, and ripple
df = 0.5e-6 * 30000 * 1070;% 0.5 ppm = gamma_C13 * 30000 * 0.5e-6

mets(5).name = 'lac'; mets(5).f = 165; mets(5).df = 1.5*df; mets(5).ang = 12; mets(5).d = .005;
mets(4).name = 'pyrh'; mets(4).f = 40; mets(4).df = 1*df; mets(4).ang = 2.5; mets(4).d = .015;
mets(3).name = 'ala'; mets(3).f = -45; mets(3).df = 1.5*df; mets(3).ang = 12; mets(3).d = .005;
mets(2).name = 'pyr'; mets(2).f = -230; mets(2).df = 2*df; mets(2).ang = 6; mets(2).d = .002;
mets(1).name = 'urea'; mets(1).f = -465; mets(1).df = 2*df; mets(1).ang = 6; mets(1).d = .002;

Npe = 8;  % number of phase encode steps

% create vectors of angles, ripples, and band edges
clear a_angs d fspec
for n = 1:length(mets)
    a_angs(n) = mets(n).ang*pi/180;
    d(n) = mets(n).d;
    fspec(2*n-1) = mets(n).f - mets(n).df;
    fspec(2*n) = mets(n).f + mets(n).df;
    disp([mets(n).name ' metab fraction remaining after Npe = ' int2str(Npe) ' encodes: ' num2str(cos(a_angs(n))^Npe)])
end
disp('');

ang = max(a_angs);

fmid = (mets(1).f+mets(end).f)/2;
fspec = fspec - fmid;
fctr = 0;

z_thk = 6; z_tb = 4; ss_type = 'Flyback Whole';

ptype = 'ex';
z_ftype='ls';
z_d1 = 0.002;
z_d2 = 0.01;

s_ftype = 'lin';

ss_opt([]);				% Reset all options
opt = ss_opt({'Nucleus', 'Carbon', ...
	      'Max Duration', 20e-3, ...
	      'Num Lobe Iters', 15, ...
	      'Max B1', 1.6, ...
	      'Num Fs Test', 100, ...
	      'Verse Fraction', 0.2, ...
	      'SLR', 0, ...
	      'B1 Verse', 0, ...
	      'Min Order', 1,...
	      'Spect Correct', 1});

[g,rf,fs,z,f,mxy] = ...
    ss_design(z_thk, z_tb, [z_d1 z_d2], fspec, a_angs, d, ptype, ...
	      z_ftype, s_ftype, ss_type, fctr, 0);

g_opt = g;
rf_opt = rf;

% Now compare spectral profiles at z = 0
ftest = [min([fspec -fs/2]):max([fs/2 fspec])];
mxy_new = ss_response_mxy(g_opt, rf_opt, 0, ftest, SS_TS, SS_GAMMA);

figure;
hold on;
nband = length(fspec)/2;
for band = 1:nband, 
    if a_angs(band) > 0, 
	plot(fspec(band*2-1:band*2), ones(1,2)*(sin(a_angs(band))+d(band)+z_d1), 'k--');
	plot(fspec(band*2-1:band*2), ones(1,2)*(sin(a_angs(band))-d(band)-z_d1), ...
	     'k--');
    else
	plot(fspec(band*2-1:band*2), ones(1,2)*(sin(a_angs(band))+d(band)), 'k--');
	plot(fspec(band*2-1:band*2), ones(1,2)*(sin(a_angs(band))-d(band)), ...
	     'k--');
    end;
end;
plot(ftest, abs(mxy_new));
plot([-fs/2 -fs/2], [0 sin(ang)], 'g--');
plot([fs/2 fs/2], [0 sin(ang)], 'g--');
hold off

figure;
subplot(211)
t_opt = [0:length(g_opt)-1] * SS_TS * 1e3;
plot(t_opt, g_opt);
title('Gradient Waveforms');

subplot(212)
plot(t_opt, real(rf_opt),t_opt, imag(rf_opt));
title('RF Waveforms');



% fprintf(1,'Do you want to save file in Chuck''s format? \n');
% ss_save(g_opt,rf_opt,ang,z_thk);

fprintf(1,'Hit any key to continue:\n');
pause;



%%
fprintf(1, '************************************************************\n');
fprintf(1, 'Here''s a C13 multiband slice (5mm) excitation pulse, for pyr dynamic imaging\n');

% setup flip angles and bandwidths, and ripple
df = 0.5e-6 * 30000 * 1070;% 0.5 ppm = gamma_C13 * 30000 * 0.5e-6
clear a_angs d fspec mets
mets(1).name = 'pyr'; mets(1).f = -230; mets(1).df = 2*df; mets(1).ang = 3.3; mets(1).d = .005;
mets(2).name = 'ala'; mets(2).f = -45; mets(2).df = 1.3*df; mets(2).ang = 20; mets(2).d = .015;
mets(3).name = 'pyrh'; mets(3).f = 40; mets(3).df = 1*df; mets(3).ang = 0; mets(3).d = .02;
mets(4).name = 'lac'; mets(4).f = 165; mets(4).df = 1.3*df; mets(4).ang = 20; mets(4).d = .01;

Npe = 8;  % number of phase encode steps

% create vectors of angles, ripples, and band edges
for n = 1:length(mets)
    a_angs(n) = mets(n).ang*pi/180;
    d(n) = mets(n).d;
    fspec(2*n-1) = mets(n).f - mets(n).df;
    fspec(2*n) = mets(n).f + mets(n).df;
    disp([mets(n).name ' metab fraction remaining after Npe = ' int2str(Npe) ' encodes: ' num2str(cos(a_angs(n))^Npe)])
end
disp('');

ang = max(a_angs);

fmid = (mets(1).f+mets(end).f)/2;
fspec = fspec - fmid;
fctr = 0;

z_thk = 0.5; % 5 mm
z_tb = 3;

ptype = 'ex'; z_ftype='ls';
z_d1 = 0.01; z_d2 = 0.01;

s_ftype = 'lin';
ss_type = 'EP Whole';

ss_opt([]);				% Reset all options
opt = ss_opt({'Nucleus', 'Carbon', ...
	      'Max Duration', 20e-3, ...
	      'Num Lobe Iters', 15, ...
	      'Max B1', 0.85, ...
	      'Num Fs Test', 100, ...
	      'Verse Fraction', 0.8, ...
	      'SLR', 0, ...
	      'B1 Verse', 0, ...
	      'Min Order', 1,...
	      'Spect Correct', 1});

[g,rf,fs,z,f,mxy] = ...
    ss_design(z_thk, z_tb, [z_d1 z_d2], fspec, a_angs, d, ptype, ...
	      z_ftype, s_ftype, ss_type, fctr, 0);

g_opt = g;
rf_opt = rf;

% Now compare spectral profiles at z = 0
ftest = [min([fspec -fs/2]):max([fs/2 fspec])];
mxy_new = ss_response_mxy(g_opt, rf_opt, 0, ftest, SS_TS, SS_GAMMA);

figure;
hold on;
nband = length(fspec)/2;
for band = 1:nband, 
    if a_angs(band) > 0, 
	plot(fspec(band*2-1:band*2), ones(1,2)*(sin(a_angs(band))+d(band)+z_d1), 'k--');
	plot(fspec(band*2-1:band*2), ones(1,2)*(sin(a_angs(band))-d(band)-z_d1), ...
	     'k--');
    else
	plot(fspec(band*2-1:band*2), ones(1,2)*(sin(a_angs(band))+d(band)), 'k--');
	plot(fspec(band*2-1:band*2), ones(1,2)*(sin(a_angs(band))-d(band)), ...
	     'k--');
    end;
end;
plot(ftest, abs(mxy_new));
plot([-fs/2 -fs/2], [0 sin(ang)], 'g--');
plot([fs/2 fs/2], [0 sin(ang)], 'g--');
hold off

figure;
subplot(211)
t_opt = [0:length(g_opt)-1] * SS_TS * 1e3;
plot(t_opt, g_opt);
title('Gradient Waveforms');

subplot(212)
plot(t_opt, real(rf_opt),t_opt, imag(rf_opt));
title('RF Waveforms');


return;