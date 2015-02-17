% Schliesst alle Figuren und laufenden Matlab Anwendungen
close all
clear

% Oeffnet Dialogboxen zur Auswahl der Eingabebilder
[FileName1,PathName1,FilterIndex1] = uigetfile({'*.jpg;*.tif;*.png;*.gif','All Image Files'},'Select the first image');
[FileName2,PathName2,FilterIndex2] = uigetfile({'*.jpg;*.tif;*.png;*.gif','All Image Files'},'Select the second image');

% Setzt den Pfad zu den Bildern aus dem Dateinamen und dem Namen des
% beinhaltenden Orders zusammen
path1=[PathName1 FileName1];
path2=[PathName2 FileName2];

% Speichert die Eingabebilder zur Weiterverarbeitung im double Format ab
imga = im2double(imread(path1));
imgb = im2double(imread(path2));

% Detektion des Gesichts, der Augen und Lippen.
% Rotation.
% Zuschneiden der Bilder auf Größe des Gesichts.
[imga, eyeLeftXa, eyeLeftYa, eyeRightXa, eyeRightYa, lipsXa, lipsYa] = skinmap(imga);
[imgb, eyeLeftXb, eyeLeftYb, eyeRightXb, eyeRightYb, lipsXb, lipsYb] = skinmap(imgb);

% Das Bild mit der kleineren Höhe wird an das Bild mit der größeren Höhe
% angepasst. Die Koordinaten für Augen und Lippen müssen entsprechend
% aktualisiert werden.
if size(imga, 1) >= size(imgb, 1)
    heightOld = size(imga, 1);
    widthOld = size(imga, 2);
    
    imga = imresize(imga, [size(imgb, 1) size(imgb, 2)]);
    
    heightNew = size(imga, 1);
    widthNew = size(imga, 2);
    
    eyeLeftXa = round((widthNew/widthOld) * eyeLeftXa); 
    eyeLeftYa = round((heightNew/heightOld) * eyeLeftYa);
    eyeRightXa = round((widthNew/widthOld) * eyeRightXa); 
    eyeRightYa = round((heightNew/heightOld) * eyeRightYa);
    lipsXa = round((widthNew/widthOld) * lipsXa);
    lipsYa = round((heightNew/heightOld) * lipsYa);
elseif size(imga, 1) < size(imgb, 1)
    heightOld = size(imgb, 1);
    widthOld = size(imgb, 2);
    
    imgb = imresize(imgb, [size(imga, 1) size(imga, 2)]);
    
    heightNew = size(imgb, 1);
    widthNew = size(imgb, 2);
    
    eyeLeftXb = round((widthNew/widthOld) * eyeLeftXb); 
    eyeLeftYb = round((heightNew/heightOld) * eyeLeftYb);
    eyeRightXb = round((widthNew/widthOld) * eyeRightXb); 
    eyeRightYb = round((heightNew/heightOld) * eyeRightYb);
    lipsXb = round((widthNew/widthOld) * lipsXb);
    lipsYb = round((heightNew/heightOld) * lipsYb);
end

% horizontale und vertikale Anpassung der Bilder aneinander.
xLeft = [eyeLeftXa, eyeRightXa, lipsXa];
yLeft = [eyeLeftYa, eyeRightYa, lipsYa];
xRight = [eyeLeftXb, eyeRightXb, lipsXb];
yRight = [eyeLeftYb, eyeRightYb, lipsYb];
[imga, imgb] = align(imga, imgb, xLeft, yLeft, xRight, yRight);

% Blending der beiden Gesichter zu einem aus zwei Gesichtshälften
% bestehenden Bild.
resultImg = blend(imga, imgb);
figure; imshow(resultImg);