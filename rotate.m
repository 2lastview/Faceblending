% Methodenparameter:
% 
% image ... Zu rotierendes Bild.
% degree ... Grad um die das Bild gedreht werden soll.
%
%
% Rückgabewerte:
%
% result ... Rotiertes Bild.

function [result] = rotate(image, degree)
    
% Mittelpunkt des Bildes berechnen
midx=ceil((size(image,1)+1)/2);
midy=ceil((size(image,2)+1)/2);
        
% Leeres Bild mit selber Größe wie das Eingabebild wird erstellt.
rotatedImage=zeros(size(image));
        
% Umwandlung von Grad in Radiant.
rad = degree*pi/180;

% Rotiertes Bild wird berechnet.
for i=1:size(image,1)
    for j=1:size(image,2)

        % Rotationsmatrix wird auf jeden Punkt des Bildest
        % angewandt.
        x= (i-midx)*cos(rad)-(j-midy)*sin(rad);
        y= (i-midx)*sin(rad)+(j-midy)*cos(rad);
        x=round(x)+midx;
        y=round(y)+midy;

        if (x>=1 && y>=1 && x<=size(image,1) && y<=size(image,2)) 
            if size(image, 3) == 3
                rotatedImage(i, j, 1) = image(x, y, 1);
                rotatedImage(i, j, 2) = image(x, y, 2);
                rotatedImage(i, j, 3) = image(x, y, 3);
            else
                rotatedImage(i, j) = image(x, y);
            end
        end
    end
end
    result = rotatedImage;
end 
