function [resultImg] = blend(img1, img2)

v = round(size(img2,2)/2);
stufe = 5;  % pyramid level

% Ruft die generatePyramid Funktion fuer jedes der Bilder um die Laplace
% Pyramide zu bilden
a = generatePyramid(img1,'lap',stufe);
b = generatePyramid(img2,'lap',stufe);

mask1 = zeros(size(img1));
mask1(:,1:v,:) = 1;

mask2 = 1-mask1;
filt = fspecial('gauss',30,15);

mask1 = imfilter(mask1,filt,'replicate');
mask2 = imfilter(mask2,filt,'replicate');

blended = cell(1,stufe);
for p = 1:stufe
	[Mp Np ~] = size(a{p});
	mask1p = imresize(mask1,[Mp Np]);
	mask2p = imresize(mask2,[Mp Np]);
	blended{p} = a{p}.*mask1p + b{p}.*mask2p;
end

% Ruft reconstructPyramid auf, um das geblendete Ausgabebild zu erstellen
resultImg = reconstructPyramid(blended);

end