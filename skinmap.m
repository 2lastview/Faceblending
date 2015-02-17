% Methodenparameter:
%
% image ... Das zu untersuchende Bild.
%
%
% Rückgabewerte: 
%
% result ... Die ausgeschnittene Gesichtsregion.
% eyeLeftX ... x Koordinate des linken Auges.
% eyeLeftY ... y Koordinate des linken Auges.
% eyeRightX ... x Koordinate des rechten Auges.
% eyeRightY ... y Koordinate des rechten Auges.
% lipsX ... x Koordinate des Lippen.
% lipsY ... y Koordinate des Lippen.

function [result, eyeLeftX, eyeLeftY, eyeRightX, eyeRightY, lipsX, lipsY] = skinmap(image)

% Berechnung der Hautregionen.
% REFERENZ: http://www.wseas.us/e-library/conferences/2011/Mexico/CEMATH/CEMATH-20.pdf
%
% Es soll mithile des YCbCr Farbraums eine SkinMap berechnet werden. D.h.
% es wird ein Binärbild erzeugt, in welchem all jene Pixel die eine
% bestimmte Bedingung erfüllen als Hautpixel angenommen werden.
image_ycbcr = rgb2ycbcr(image);
image_ycbcr = im2uint8(image_ycbcr);
cb = image_ycbcr(:,:,2);
cr = image_ycbcr(:,:,3);

skin = (cb >= 77) & (cb <= 127) & (cr >= 133) & (cr <= 173);
skin = im2double(skin);

% Um das Ergebnis zu verbessern wird ein Grauwertbild der Hautregion
% erzeugt. Aus diesem kann ein Schwellwert zur endgültigen Berechnung eines
% Binärbildes gewonnen werden. Kleine Löcher im Bild werden mit imfill
% aufgefüllt. Da nach einer größeren Region im Bild gesucht wird, werden
% alle Regionen deren Größe kleiner als 1890 Pixel ist geschlossen.
image_gray = rgb2gray(image);
image_gray = image_gray .* skin;
level = graythresh(image_gray);
image_binary = im2bw(image_gray, level);
image_binary = imfill(image_binary, 'holes');

image_labeled = bwareaopen(image_binary, 1890); 
image_labeled = bwlabel(image_labeled, 8);

% Es werden die Regionprops errechnet. Als Kanditat für die Gesichtsregion
% gilt jene Region die am größten ist.
% Mit den Werten der BoundingBox der gewählten Region, kann diese mit
% imcrop ausgeschnitten werden.
faceProps = regionprops(image_labeled, skin, 'all');
[num area] = max([faceProps.Area]);

x = faceProps(area).BoundingBox(1);
y = faceProps(area).BoundingBox(2);
width = faceProps(area).BoundingBox(3);
height = faceProps(area).BoundingBox(4);

image = imcrop(image, [x y width height]);


% Berechnung der Augenregionen.
% REFERENZ: http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=4530500
%
% Zur Berechnung einer EyeMap wird wieder vom YCbCr Farbraum gebrauch
% gemacht. 
image_ycbcr = rgb2ycbcr(image);

y = image_ycbcr(:,:,1);
cb = image_ycbcr(:,:,2);
cr = image_ycbcr(:,:,3);

% Qudrierung und Normalisierung in den Bereich [0 1] von cb.
cb2 = cb.^2;
cbN = (cb2 - min(cb2(:)))*(1/(max(cb2(:))-min(cb2(:))));

% Qaudrierung und Normalisierung in den Bereich [0 1] von cr.
cr2 = (1-cr).^2;
crN = (cr2 - min(cr2(:)))*(1/(max(cr2(:))-min(cr2(:))));

% Berechnung des Werts des Quotienten von cb und cr mit anschließender
% Normalisierung in den Bereich [0 1].
divCbCr = cb./cr;
divCbCrN = (divCbCr - min(divCbCr(:)))*(1/(max(divCbCr(:))-min(divCbCr(:))));

% Berechnung der EyeMapC wie in der Referenz beschrieben, sowie
% anschließende Histogramequalisierung.
EyeMapC = (cbN + crN + divCbCrN)/3;
EyeMapC = histeq(EyeMapC);

% Berechnung der EyeMapL durch imdilate sowie imerode. 
SE = strel('disk', 4);
UP = imdilate(y, SE);
DOWN = imerode(y, SE);

EyeMapL = UP./(DOWN+1);

% Die endgültige EyeMap wird durch eine Multiplikation der beiden
% Berechnungen von EyeMapC und EyeMapL erreicht. Auf die EyeMap wird noch
% einmal eine Histogramequalisierung sowie eine Normlaisierung in den
% Bereich [0 1] durchgeführt.
EyeMap = EyeMapC.*EyeMapL;

EyeMap = imdilate(EyeMap, SE);
EyeMap = histeq(EyeMap);
EyeMap = (EyeMap - min(EyeMap(:)))*(1/(max(EyeMap(:))-min(EyeMap(:))));
EyeMap = im2bw(EyeMap, 0.975);

% Berechnung der Regionprops der EyeMap. Diese werden bei der späteren
% Bestimmung der Augenpaare benötigt.
STATS = regionprops(EyeMap, 'all');


% Berechnung der Lippenregion.
% REFERENZ: http://www.jweet.science-line.com/attachments/article/10/J.%20World.%20Elect.%20Eng.%20Tech.%201(1)%2012-16,%202012,.pdf
%
% Es wird eine LipMap berechnet. Diese dient nicht nur dazu ein weiteres
% Merkmal im Gesicht erkennen zu können, sondern auch um später mögliche
% Augenpaare besser berechnen zu können.
image_ycbcr = rgb2ycbcr(image);
cb = image_ycbcr(:,:,2);
cr = image_ycbcr(:,:,3);

image_hsv = rgb2hsv(image);
s = image_hsv(:,:,2);

cr2 = cr.^2;
crN = (cr2 - min(cr2(:)))*(1/(max(cr2(:))-min(cr2(:))));

divCrCb = cr./cb;
divCrCbN = (divCrCb - min(divCrCb(:)))*(1/(max(divCrCb(:))-min(divCrCb(:))));

n = 0.95*sum(crN(:))/sum(divCrCbN(:));

LipMap = crN .* (crN - n*divCrCbN).^2;
LipMap = (LipMap - min(LipMap(:)))*(1/(max(LipMap(:))-min(LipMap(:))));
LipMap = s .* LipMap;
level = graythresh(LipMap);
LipMap_binary = im2bw(LipMap, level);


% Berechnung der Augenpaare.
% REFERENZ 1: http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=4530500
% REFERENZ 2: http://hal.archives-ouvertes.fr/docs/00/37/43/66/PDF/article_ivcnz2006.pdf
%
% Es werden alle möglichen Kombinationen von Augenpaaren durchgegangen, und
% überprüft ob es sich dabei wirklich um Augen handeln kann.
eyeLeftX = 0;
eyeLeftY = 0;
eyeRightX = 0;
eyeRightY = 0;
lipsX = 0;
lipsY = 0;
for i = 1:length(STATS)-1
    
    % Der Centroid ersten Auges.
    centroidX1 = STATS(i).Centroid(1);
    centroidY1 = STATS(i).Centroid(2);
    
    % Die BoundingBox des ersten Auges.
    x1 = STATS(i).BoundingBox(1);
    y1 = STATS(i).BoundingBox(2);
    width1 = STATS(i).BoundingBox(3);
    height1 = STATS(i).BoundingBox(4);
    
    % Berechnung des BildZentrums in x Richtung.
    center = round(size(EyeMap, 2)/2);
    % Berechnung einer Schnittstelle um 5/8tel von oben.
    bottom = round(5*size(EyeMap, 1)/8);
    
    for j = (i+1):length(STATS)
        
        % Der Centroid des zweiten Auges.
        centroidX2 = STATS(j).Centroid(1);
        centroidY2 = STATS(j).Centroid(2);
        
        % Die BoundingBox des zweiten Auges.
        x2 = STATS(j).BoundingBox(1);
        y2 = STATS(j).BoundingBox(2);
        width2 = STATS(j).BoundingBox(3);
        height2 = STATS(j).BoundingBox(4);
        
        % Es wird die Steigung der Geraden zwischen den beiden Centroiden 
        % berechnet.
        if centroidY1 >= centroidY2
            m = centroidY1 - centroidY2;
        else
            m = centroidY2 - centroidY1;
        end
        
        if centroidX1 >= centroidX2
            m = m/(centroidX1 - centroidX2);
        else
            m = m/(centroidX2 - centroidX1);
        end
        
        % R1: Die Steigung muss zwischen 1 und -1 liegen. Das Augenpaar 
        % darf höchstens um 45 Grad geneigt sein.
        R1 = (m <= 1) && (m >= -1);
        R10 = abs(STATS(i).Orientation-STATS(j).Orientation) <= 45;
        
        % R2-R3: Es wird davon ausgegangen, dass nachdem eine Gesichtsregion
        % bereits gefunden wurde, der x Wert einer Centroiden links und
        % einer rechts des BildZentrums liegt. Diese Voraussetzung wird mit
        % der xor Funktion überprüft.
        R2 = (centroidX2 >= center) && (centroidX1 <= center);
        R3 = (centroidX1 >= center) && (centroidX2 <= center);
        
        % R4-R5: Es wird davon ausgegangen, dass die Augen im oberen
        % Bereich des Bildes liegen. Es werden also alle Punkte
        % ausgeschlossen welche unterhalb von bottom liegen. 
        R4 = (y1 <= bottom) && (y1 + height1 <= bottom);
        R5 = (y2 <= bottom) && (y2 + height2 <= bottom);
        
        % R6-R7: Es werden die Verhältnisse der Haupt- und Nebenachsen der
        % Augenregionen überprüft. Breite geiteilt durch Höhe dieser beiden
        % Längen sollte statistisch gesehen (REFERENZ 2 Seite 3) 2
        % betragen.
        ratioa = (STATS(i).MajorAxisLength/STATS(i).MinorAxisLength);
        ratiob = (STATS(j).MajorAxisLength/STATS(j).MinorAxisLength);
        R6 = (ratioa > 1) && (ratioa < 3);
        R7 = (ratiob > 1) && (ratiob < 3);
        
        % R8-R9: Es wird überprüft ob die die beiden Hauptachsen die
        % gleiche Ausrichtung haben, da diese bei zwei Augen übereinstimmen
        % sollte.
        dij = (width1+width2)/2;
        R8 = 2*dij > (STATS(i).MajorAxisLength+STATS(j).MajorAxisLength)/2;
        R9 = 2*dij < 3*(STATS(i).MajorAxisLength+STATS(j).MajorAxisLength)/2;
        
        % R11: Der Flächenunterschied zwischen einer Region sollte
        % nicht doppelt so groß wie der der anderen. Mit dieser Abfrage
        % sollen vor allem kleine Regionen welche mit sehr viel größeren
        % Regionen verglichen werden sofort eliminiert werden.
        R11 = max(STATS(i).Area, STATS(j).Area)/min(STATS(i).Area, STATS(j).Area) <= 2;
        
        % R12: Es werden die durchschnittlichen Grauwerte in den
        % Augenregionen verglichen. Diese sollten sich nicht allzusehr
        % unterscheiden, da beide Augen die selber Charakteristika
        % aufweisen.
        mean1_image = rgb2gray(imcrop(image, [x1 y1 width1 height1]));
        mean2_image = rgb2gray(imcrop(image, [x2 y2 width2 height2]));
        mean1 = mean(mean1_image(:));
        mean2 = mean(mean2_image(:));
        R12 = max(mean1, mean2)/min(mean1, mean2) < 1.5;
                        
        if R1 && xor(R2, R3) && (R4 && R5) && (R6 && R7) && (R8 && R9) && R10 && R11 && R12
            
            X1 = centroidX1;
            Y1 = centroidY1;
            X2 = centroidX2;
            Y2 = centroidY2;
            
            % Es wird festgestellt welches das linke und welches das rechte
            % Auge ist.
            if X1 < X2
                xLeft = X1;
                yLeft = Y1;
                xRight = X2;
                yRight = Y2;
            else 
                xLeft = X2;
                yLeft = Y2;
                xRight = X1;
                yRight = Y1;
            end
            
            % Die Distanz zwischen den beiden Centroiden wird berechnet.
            distance = sqrt(((xRight-xLeft).^2)+((max(Y1, Y2)-min(Y1, Y2)).^2));
            % Der x Wert für das Zentrum zwischen den Centroiden.
            centerX = round(xLeft + (xRight-xLeft)/2);
            % Der y Wert für das Zentrum zwischen den Centroiden.
            centerY = round(min(yLeft, yRight) + (max(yLeft, yRight)-min(yLeft, yRight))/2);
            
            % Um die ungefähre Lage der Lippen zu berechnen wird die Gerade
            % zweischen den beiden Centroiden berechnet. Diese wird dann
            % parallel um die Distanz zwischen den Centroiden verschoben,
            % und mit der Ortogonalen Geraden, welche durch das Zentrum
            % zwischen den beiden Centroiden verläuft, geschnitten. Dieser
            % Punkt wird dann als vorläufiger Zentrum der Lippen verwendet.
            m = (yLeft-yRight)/(xLeft-xRight);
            q = yLeft - m*xLeft;
            mO = -1/m;
            qO = centerY - mO*centerX; 
            mP = m;
            qP = q + distance;

            lipX = round((qO-qP)/(mP-mO));
            lipY = round(mP*lipX + qP);
            
            % Region in welcher sich die Lippen befinden sollten.
            lipBoxX = round(lipX-distance/2);
            lipBoxY = round(lipY-distance/2);
            lipBoxWidth = distance;
            lipBoxHeight = distance;
            
            % Die Fläche der BoundingBox der Lippenregion.
            lipBoxArea = lipBoxWidth*lipBoxHeight;
            % Die Fläche der BoundingBox der ersten Augenregion.
            area1 = STATS(i).BoundingBox(3)*STATS(i).BoundingBox(4);
            % Die Fläche der BoundingBox der zweiten Augenregion.
            area2 = STATS(j).BoundingBox(3)*STATS(j).BoundingBox(4);
            
            % Mit der ersten Abfrage können Augenpaare, deren BoundingBox
            % Fläche sehr klein sind eliminiert werden. Das geschieht dann
            % wenn die Fläche der Lippenregion die der beiden Augenregionen
            % zu stark übersteigt.
            % Mit der zweiten Abfrage wird sichergestellt, dass sich die
            % Augen auch über den Lippen befinden.
            if 100*(area1+area2) > lipBoxArea
                if (lipY > yLeft) && (lipY > yRight)
                    
                    % Berechnung der Regionprops für die LipMap.
                    lipProps = regionprops(LipMap_binary, 'all');
                    
                    for k = 1:size(lipProps, 1)
                        
                        % Der Centroid der Lippenregion aus lipProps.
                        centerLipX = lipProps(k).Centroid(1);
                        centerLipY = lipProps(k).Centroid(2);
                        
                        x = lipProps(k).BoundingBox(1);
                        y = lipProps(k).BoundingBox(2);
                        width = lipProps(k).BoundingBox(3);
                        height = lipProps(k).BoundingBox(4);
                        
                        % L1: Die Höhe der BoundingBox der Lippen sollte
                        % größer als die Breite sein. 
                        L1 = width > height;
                        
                        % L2-L3: Der Centroid der Lippen sollte innerhalb
                        % der BoundingBox der Lippenregion liegen.
                        L2 = (centerLipX >= lipBoxX) && (centerLipX <= lipBoxX+lipBoxWidth);
                        L3 = (centerLipY >= lipBoxY) && (centerLipY <= lipBoxY+lipBoxHeight);
                        
                        % L4: Die Lippenregion aus den lipProps sollte
                        % ungefähr in der Mitte der berechneten
                        % Lippenregion liegen. Es wird überprüft ob auf
                        % ein Teil davon links, und ein Teil
                        % davon rechts vom Zentrum der berechneten
                        % Lippenregion liegt.
                        lipBoxCenter = lipBoxX + round(lipBoxWidth/2);
                        L4 = (x <= lipBoxCenter) && (x+width >= lipBoxCenter);
                        
                        % L5: Der Größenunterschied zwischen der
                        % berechneten Lippenregion und der Lippenregion aus
                        % den lipProps sollte nicht zu unterschiedlich sein.
                        L5 = 100*(width*height) > lipBoxArea;
                                                
                        if L1 && (L2 && L3) && L4 && L5
                            
                            % Koordinaten der Augen.
                            eyeLeftX = round(xLeft);
                            eyeLeftY = round(yLeft);
                            eyeRightX = round(xRight);
                            eyeRightY = round(yRight);
                            
                            % Koordinaten der Lippen.
                            lipsX = round(x + (width/2));
                            lipsY = round(y + (height/2));
                            
                            % Koordinaten der berechneten Lippenregion. Wird 
                            % zur Ausgabe in einem Plot verwendet.
                            lBoxX1 = [lipBoxX lipBoxX+lipBoxWidth lipBoxX+lipBoxWidth lipBoxX lipBoxX];
                            lBoxY1 = [lipBoxY lipBoxY lipBoxY+lipBoxHeight lipBoxY+lipBoxHeight lipBoxY];
                            
                            % Koordinaten der eigentlichen Lippenregion.
                            % Wird zur Ausgabe in einem Plot verwendet.
                            lBoxX2 = [x x+width x+width x x];
                            lBoxY2 = [y y y+height y+height y];
                        end
                    end
                end
            end
        end
    end
end

% Anzeige der gefundenen Augen und Lippen.
figure; imagesc(image);
hold on;
% Markiert das linke Auge (rot)
plot(eyeLeftX, eyeLeftY, 'r.', 'MarkerSize', 20);
% Markiert das rechte Auge (rot)
plot(eyeRightX, eyeRightY, 'r.', 'MarkerSize', 20);
% Markiert das Lippenzentrum (grün)
plot(lipsX, lipsY, 'g.', 'MarkerSize', 20);
% Berechnete Lippenregion.
plot(lBoxX1, lBoxY1, 'r', 'LineWidth', 2);
% Lippenregion.
plot(lBoxX2, lBoxY2, 'LineWidth', 2);

% Rotation des Bildes, sowie der Punkte für Augen und Lippen.
[image, eyeLeftX, eyeLeftY, eyeRightX, eyeRightY, lipsX, lipsY] = rotateImage(image, eyeLeftX, eyeLeftY, eyeRightX, eyeRightY, lipsX, lipsY);

% Berechnung der Gesichtsregion.
% REFERENZ: http://www.csee.wvu.edu/~richas/papers/tkjse.pdf
%
% Es werden die vier Punkte berechnet nach denen die Gesichtsregion
% aus dem Originalbild ausgeschnitten werden soll. Dabei gibt die Hälfte
% der Distanz zwischen den beiden Augen die Entfernung an, nach welcher in
% x und y Richtung, von Augen und Lippen aus, nach außen gegangen wird.
% Sollte einer der Punkte außerhalb des Bildbereichs liegen, wird dies
% korrigiert.
i1 = eyeLeftX;
i2 = eyeLeftY; 

j1 = lipsX;
j2 = lipsY; 

k1 = eyeRightX;
k2 = eyeRightY; 

D = k1 - i1;

X1 = i1 - (1/2)*D;
if X1 > size(image, 2)
    X1 = size(image, 2);
end

X4 = i1 - (1/2)*D;
if X4 > size(image, 2)
    X4 = size(image, 2);
end

X2 = k1 + (1/2)*D;
if X2 > size(image, 2)
    X2 = size(image, 2);
end

X3 = k1 + (1/2)*D;
if X3 > size(image, 2)
    X3 = size(image, 2);
end

Y1 = i2 - (1/2)*D;
if Y1 > size(image, 1)
    Y1 = size(image, 1);
end

Y2 = i2 - (1/2)*D;
if Y2 > size(image, 1)
    Y2 = size(image, 1);
end

Y3 = j2 + (1/2)*D;
if Y3 > size(image, 1)
    Y3 = size(image, 1);
end

Y4 = j2 + (1/2)*D;
if Y4 > size(image, 1)
    Y4 = size(image, 1);
end

% Die ausgeschnittene Gesichtsregion.
result = imcrop(image, [X1 Y1 round(X2-X1) round(Y4-Y1)]);

% Die Punkte für Augen und Lippen müssen an das neue Bild der
% Gesichtsregion angepasst werden.
eyeLeftX = round(eyeLeftX-((size(image, 2)-size(result, 2))-(size(image, 2)-X2)));
eyeLeftY = round(eyeLeftY-((size(image, 1)-size(result, 1))-(size(image, 1)-Y4)));

eyeRightX = round(eyeRightX-((size(image, 2)-size(result, 2))-(size(image, 2)-X2)));
eyeRightY = round(eyeRightY-((size(image, 1)-size(result, 1))-(size(image, 1)-Y4)));

lipsX = round(lipsX-((size(image, 2)-size(result, 2))-(size(image, 2)-X2)));
lipsY = round(lipsY-((size(image, 1)-size(result, 1))-(size(image, 1)-Y4)));

end