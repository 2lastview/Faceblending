function [image] = reconstructPyramid(pyramid)
% Wiederherstellung des Bildes mithilfe der Laplacepyramide

% x ist die Schleifenvariable
% Anfangswert: die Länge vom Array pyramid -1
% Schrittweite: -1
% Endwert: 1, wobei der letzte angenommene Wert der Laufvariable
% größergleich 1 sein muss
% in jedem Schleifendurchgang wird in die Zelle x von pyramid die Zelle x
% plus der expandierten Pyramide in der Zelle x+1 gespeichert, sodass das 
% Bild immer genauer wird 
for x = length(pyramid)-1:-1:1 
    pyramid{x} = pyramid{x} + expandPyramid(pyramid{x+1});
end

% Bild ist gleich der ersten Zelle der Pyramide
image = pyramid{1};

end