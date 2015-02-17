function[out]=reducePyramid(img)
%img...Eingabebild
%Funktion zum verkleinern eines Bildes auf die halbe Groeße des Bildes
%mittels eines Gaussfilters

cw = 0.375; % kernel centre weight, gew�hlt gleich wie der MATLAB funktion - impyramid, 0.6 in the Paper
ic = 0.25;  % kernel koeffizienten zwischen kernel centre weight und aussere koeffizienten
ac = ic-cw/2; % aussere kernel koeffizienten
     
kern = [ac ic cw ic ac];
% berechnet der Kernel anhand der Kronecker tensor product 
kernel = kron(kern,kern');

imgsize = size(img);

%Ausgabebild hat nur die halbe Groeße des Eingabebildes
out=zeros(ceil([imgsize(1) imgsize(2)]/2)); 
for p = 1:size(img,3) %Schleifendurchlaeufe werden durch das Format des Bildes bestimmt (grayscale 1 Durchlauf, rgb 3 Durchlaeufe) 
	imgtemp = img(:,:,p);                                               
	imgtemp = imfilter(imgtemp,kernel,'replicate','same');
	% halbieren der Stützstellen des gefilterten Bildes, es werden nur Werte jeder zweiten Zeile und jeder zweiten Spalte ausgewählt
    out(:,:,p) = imgtemp(1:2:imgsize(1),1:2:imgsize(2)); 
end
