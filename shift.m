% Methodenparameter:
% 
% image ... Das zu bewegende Bild.
% sx ... Anzahl der Pixel um welche in x Richtung verschoben werden soll.
% sy ... Anzahl der Pixel um welche in y Richtung verschoben werden soll.
%
%
% Rückgabewerte:
%
% result ... Verschobenes Bild.

function [result] = shift(image, sx, sy)

    result = zeros(size(image));
    tmp = zeros(size(image));
    
    % Shiften des Bildes in x Richtung. 
    % Falls x positiv ist soll das Bild um die mit sx speizifizierte Anzahl
    % von Pixel nach rechts bewegt werden. Es werden alle Pixelwerte von 1
    % bis end-sx in eine temporäre Matrix an die Stellen sx+1 bis end
    % kopiert.
    % Anderfalls muss das Bild bei einem sx Wert von 0 garnicht, oder bei
    % einem negativen Wert in die andere Richtung verschoben werden. Es
    % werden alle Pixelwerte von 1-sx bis end in eine temporäre Matrix an
    % die Stellen 1 bis end+sx kopiert.
    if(abs(sx) > 0)
        if(sx > 0)
            tmp(:, (sx+1):end, :) = image(:, 1:(end-sx), :);
        else
            tmp(:, 1:(end+sx), :) = image(:, (1-sx):end, :);    
        end
    else
        tmp = image;
    end
    
    % Shiften des Bildes in y Richtung.
    % Gleiche Vorgehensweise wie beim Verschieben in x Richtung
    if(abs(sy) > 0)
        if(sy > 0)
            result((sy+1):end, :, :) = tmp(1:(end-sy), :, :);
        else
            result(1:(end+sy), :, :) = tmp((1-sy):end, :, :);    
        end
    else
        result = tmp;
    end

end
