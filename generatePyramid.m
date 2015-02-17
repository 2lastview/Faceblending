function [imgpyr]= generatePyramid (img, type, n)
%img...Eingabebild in double Format
%n...Tiefe der Bildpyramide

%Array mit einer Zeile und n-Spalten
imgpyr = cell(1,n); 


%Erstellen der Bildpyramide durch das verkleinern des Eingabebildes
imgpyr{1}=im2double(img);
for i= 2:n
    % anhand reducePyramid
    imgpyr{i}=reducePyramid(imgpyr{i-1});
     
end

for i = n-1:-1:1 % Grösse des Bildes anpassen 
    outputsize = size(imgpyr{i+1})*2-1; 
	imgpyr{i} = imgpyr{i}(1:outputsize(1),1:outputsize(2),:);
end

for i = 1:(n-1)
    imgpyr{i} = imgpyr{i}-expandPyramid(imgpyr{i+1});
end
    

end
