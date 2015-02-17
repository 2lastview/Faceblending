function [result] = expandPyramid(image)
% Erweiterung des Bildes mithilfe der Pyramide
% image = Eingabebild

% loading = Gewichtungsfunktion
% loading = 0.375, da 0.375 am ehesten die Gaußsche Form aufweißt
% die Werte für kernelWidth, loading und matrix wurden anhand dieser Quelle ausgewählt:
% "The Laplacian Pyramid as a Compact Image Code" von Burt und Adelson
% IEEE Transactions on Communications, nr 4, vol 31, April 1983
% http://persci.mit.edu/pub_pdfs/pyramid83.pdf
% }
loading = 0.375;
matrix = [0.25-loading/2 0.25 loading 0.25 0.25-loading/2]; 

% kron = Kronecker Tensor Produkt, dabei werden zwei Matrizen A und B mit 
% verschiedenen Dimensionen so multipilziert, dass eine gemeinsame Matrix
% entsteht, d.h. jedes Element der Matrix a wird mit der gesamten Matrix B
% multipliziert
kernel = kron(matrix, matrix') * 4;

% kernelWidth = Kernelbreite
kernelWidth = 5;
% loading zu [A00, A01; A10, A11] mit 4 Kernels erweitern
kernel00 = kernel(1:2:kernelWidth, 1:2:kernelWidth); % 3 * 3
kernel01 = kernel(1:2:kernelWidth, 2:2:kernelWidth); % 3 * 2
kernel10 = kernel(2:2:kernelWidth, 1:2:kernelWidth); % 2 * 3
kernel11 = kernel(2:2:kernelWidth, 2:2:kernelWidth); % 2 * 2

overallSize = size(image(:, :, 1)) * 2 - 1;
result = zeros(overallSize(1), overallSize(2), size(image, 3));

% Schleifenvariable x
% Anfangswert = 1
% Endwert = die Größe von der 3. Dimension des Eingabebildes
% Schrittweite = 1
for x = 1:size(image,3)
	padImage = image(:,:,x);
    
    % padarray füllt das Bild mit definierten Elementen auf 
    % füllt das Bild zuerst mit 0 Elementen in der 1. Dimension und einem
    % Element in der 2. Dimension auf, das Ergebnis ist das hPadImage -
    % horizontales Auffüllen
    % und danach genau umgekehrt mit Ergebnis im vPadImage - vertikales
    % Auffüllen
    % replicate = kopiert die angrenzenden Elemente
    % bei der Richtung wird das Default 'both' genommen, das die Felder 
    % vor dem ersten und nach dem letzten Element jeder Dimension auffüllt
	horizontalPadImage = padarray(padImage, [0 1], 'replicate');
	horizontalPadImage2 = padarray(padImage, [1 0], 'replicate');
	
    % Filter das Bild padImage mit dem Kernel kernel00
    % dabei wir angenommen, dass die Pixel außerhalb des Randes gleich
    % denen sind, die genau am Rand sitzen
    % und, dass das Outputbild die gleiche Größe wie das Inputbild hat
	image00 = imfilter(padImage, kernel00, 'replicate', 'same');
    
    % da imfilter 'valid' nicht unterstützt, wird bei den weiteren
    % Filterungen conv2 statt imfilter verwendet
    % valid liefert nur diejenigen Werte des Bildrandes zurück, die keine
    % Nullwerte sind
	image01 = conv2(horizontalPadImage2, kernel01, 'valid');
	image10 = conv2(horizontalPadImage, kernel10, 'valid');
	image11 = conv2(padImage, kernel11, 'valid');
	
    % das Ausgabebild wird mit den gefilterten Bildstücken gefüllt
	result(1:2:overallSize(1), 1:2:overallSize(2), x) = image00;
    result(1:2:overallSize(1), 2:2:overallSize(2), x) = image01;
	result(2:2:overallSize(1), 1:2:overallSize(2), x) = image10;
	result(2:2:overallSize(1), 2:2:overallSize(2), x) = image11;
end

end
