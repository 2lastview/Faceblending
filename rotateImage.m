% Methodenparameter:
%
% image ... Das zu rotierende Bild.
% 
% xLE ... x Koordinate linkes Auge. 
% yLE ... y Koordinate linkes Auge.
% xRE ... x Koordinate rechtes Auge.
% yRE ... y Koordinate rechtes Auge.
% xL ... x Koordinate Lippe.
% yL ... y Koordinate Lippe.
%
% Rückgabewerte:
%
% xLE ... neue x Koordinate linkes Auge nach Rotation. 
% yLE ... neue y Koordinate linkes Auge nach Rotation.
% xRE ... neue x Koordinate rechtes Auge nach Rotation.
% yRE ... neue y Koordinate rechtes Auge nach Rotation.
% xL ... neue x Koordinate Lippe nach Rotation.
% yL ... neue y Koordinate Lippe nach Rotation.

function [result, xLE, yLE, xRE, yRE, xL, yL] = rotateImage(image, xLE, yLE, xRE, yRE, xL, yL)

% Steigung des Vektors zwischen den Augen.
m = (yRE - yLE)/(xRE - xLE);
degree = -atand(m);
    
% Sonderfall: Bei 0 grad Steigung wird nicht rotiert.
if(degree == 0) 
    result = image;
else
    % Das Bild wird mit der Methode rotate rotiert.
    result = rotate(image, degree);
    
    % Es wird jeweils eine Matrix für die Punkte von linkem und rechtem
    % Auge, sowie die Lippen erstellt. Diese Matrizen werden dann gleich
    % wie das Bild selbst mit der Methode rotate rotiert. Die rotierten
    % Punkte können anschließend mit find in der Matrix gefunden und
    % zurückgegeben werden.
    matLE = zeros([size(image, 1) size(image, 2)]);
    matLE(yLE, xLE) = 1;
    matLE = rotate(matLE, degree);
    [yLE, xLE] = find(matLE == 1);
    
    matRE = zeros([size(image, 1) size(image, 2)]);
    matRE(yRE, xRE) = 1;
    matRE = rotate(matRE, degree);
    [yRE, xRE] = find(matRE == 1);
    
    matL = zeros([size(image, 1) size(image, 2)]);
    matL(yL, xL) = 1;
    matL = rotate(matL, degree);
    [yL, xL] = find(matL == 1);
end

end
