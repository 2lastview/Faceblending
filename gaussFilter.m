% Diese Funktion soll das verhalten von imfilter und fspecial für den Gauss
% Filter nachstellen. Uebergeben werden ein Bild in img, Die Groesse des Filters
% in N und sigma

function filteredImage = gaussFilter(img,N,sigma)
 [x y]=meshgrid(round(-N/2):round(N/2), round(-N/2):round(N/2));
 f=exp(-x.^2/(2*sigma^2)-y.^2/(2*sigma^2));
 f=f./sum(f(:));

 filteredImage = conv2(img,f,'same');
end
 