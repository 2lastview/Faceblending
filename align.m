% Methodenparameter:
%
% imga ... linkes Bild.
% imgb ... rechtes Bild.
%
% xLeft ... x Koordinaten f�r linkes und rechtes Auge, sowie Lippenmittelpunkt
%           im linken Bild.
% yLeft ... y Koordinaten f�r linkes und rechtes Auge, sowie Lippenmittelpunkt
%           im linken Bild.
%
% xRight ... x Koordinaten f�r linkes und rechtes Auge, sowie Lippenmittelpunkt
%            im rechten Bild.
% yRight ... y Koordinaten f�r linkes und rechtes Auge, sowie Lippenmittelpunkt
%            im rechten Bild.
%
%
% R�ckgabewerte:
%
% imga ... Aktualisiertes linkes Bild.
% imgb ... Aktualisiertes rechtes Bild.

function [imga, imgb] = align(imga, imgb, xLeft, yLeft, xRight, yRight)

% x und y Koordinaten des linken Auges f�r imga. 
xLEa = xLeft(1); 
yLEa = yLeft(1);

% x und y Koordinaten des rechten Auges f�r imga. 
xREa = xLeft(2);
yREa = yLeft(2);

% x und y Koordinaten der Lippen f�r imga. 
xLa = xLeft(3);
yLa = yLeft(3);

% x und y Koordinaten des linken Auges f�r imgb. 
xLEb = xRight(1); 
yLEb = yRight(1);

% x und y Koordinaten des rechten Auges f�r imgb. 
xREb = xRight(2);
yREb = yRight(2);

% x und y Koordinaten der Lippen f�r imgb.
xLb = xRight(3);
yLb = yRight(3);

% Abstand zwischen Augenmittelpunkt und Lippenmittelpunkt.
dLipsA = yLa - yLEa;
dLipsB = yLb - yLEb;

% In diesem Schritt wird der Abstand zwischen Augenmittelpunkt und
% Lippenmittelpunkt aneinander angepasst. Das Bild, dessen Abstand
% zwischen Augenmittelpunkt und Lippenmittelpunkt gr��er ist, wird um die 
% Differenz der beiden Abst�nde in der H�he gestaucht.
% Die Bilder m�ssen nach Ausf�hrung von imresize die gleiche H�he und
% Breite aufweisen. Deshalb wird das gestauchte Bild in eine Matrix mit der
% alten H�he und Breite �bertragen.
if dLipsA < dLipsB
    newHeight = size(imgb, 1) - (dLipsB - dLipsA);
    imgb = imresize(imgb, [newHeight size(imgb, 2)]);
    
    % Das gestauchte Bild soll in diese tempor�re Matrix �bertragen werden.
    % H�he und Breite sind gleich wie beim Originalbild.
    tmp = zeros(size(imga));
    
    for i = 1:size(imgb, 1)
        for j = 1:size(imgb, 2)
            tmp(i,j,1) = imgb(i,j,1);
            tmp(i,j,2) = imgb(i,j,2);
            tmp(i,j,3) = imgb(i,j,3);
        end
    end
    
    % Punkte f�r linkes und rechtes Auge, sowie f�r die Lippen m�ssen
    % angepasst werden.
    yLEb = yLEb - (dLipsB - dLipsA);
    yREb = yREb - (dLipsB - dLipsA);
    yLb = yLb - (dLipsB - dLipsA);
    
    imgb = tmp;
elseif dLipsA > dLipsB
    newHeight = size(imga, 1) - (dLipsA - dLipsB);
    imga = imresize(imga, [newHeight size(imga, 2)]);
    
    tmp = zeros(size(imgb));
    
    for i = 1:size(imga, 1)
        for j = 1:size(imga, 2)
            tmp(i,j,1) = imga(i,j,1);
            tmp(i,j,2) = imga(i,j,2);
            tmp(i,j,3) = imga(i,j,3);
        end
    end
    
    yLEa = yLEa - (dLipsA - dLipsB);
    yREa = yREa - (dLipsA - dLipsB);
    yLa = yLa - (dLipsA - dLipsB); 
    
    imga = tmp;
end

% x und y Koordinaten des Mittelpunkts zwischen Augen und Lippen in imga.  
xCenterA = round(xLEa + ((xREa-xLEa)/2));
yCenterA = round(yLEa + ((yLa-yLEa)/2));

% x und y Koordinaten des Mittelpunkts zwischen Augen und Lippen in imgb. 
xCenterB = round(xLEb + ((xREb-xLEb)/2));
yCenterB = round(yLEb + ((yLb-yLEb)/2));

% x und y Koordinaten des Mittelpunkts der Bilder.
xCenterI = round(size(imga, 2)/2);
yCenterI = round(size(imga, 1)/2);

% Der Augenmittelpunkt wird horizontal der x Koordinate des 
% Bildzentrums angepasst. Es wird festgestellt ob sich der Augenmittelpunkt 
% den Augen rechts oder links vom Bildzentrum befindet. Darauf folgt eine 
% Anpassung mit der Methode shift in die entsprechende Richtung.
if xCenterA < xCenterI
    move = xCenterI - xCenterA;
    imga = shift(imga, move, 0);
elseif xCenterA > xCenterI
    move = xCenterA - xCenterI;
    imga = shift(imga, -move, 0);
end

if xCenterB < xCenterI
    move = xCenterI - xCenterB;
    imgb = shift(imgb, move, 0);
elseif xCenterB > xCenterI
    move = xCenterB - xCenterI;
    imgb = shift(imgb, -move, 0);
end

% Es erfolgt noch eine Anpassung des Punktes zwischen Augenmittelpunkt und
% Lippen (ungef�hre Position der Nase) an das Zentrum im Bild. Es wird 
% festgestellt ob sich der Nasenpunkt unterhalb oder oberhalb des
% Bildzentrums befindet. Darauf erfolgt eine Anpassung mit der Methode 
% shift in die entsprechende Richtung.
if yCenterA < yCenterI
    move = yCenterI - yCenterA;
    imga = shift(imga, 0, move);
elseif yCenterA > yCenterI
    move = yCenterA - yCenterI;
    imga = shift(imga, 0, -move);
end

if yCenterB < yCenterI
    move = yCenterI - yCenterB;
    imgb = shift(imgb, 0, move);
elseif yCenterB > yCenterI
    move = yCenterB - yCenterI;
    imgb = shift(imgb, 0, -move);
end

end