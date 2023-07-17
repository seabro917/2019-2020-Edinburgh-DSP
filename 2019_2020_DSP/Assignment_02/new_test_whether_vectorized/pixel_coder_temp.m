function [zipped, info] = pixel_coder_temp(x)
% First convert the matrix for the image into a row vector to simulate what we have in
% practical transmitting.
[size_rows, size_columns] = size(x);
% image_vectorized = zeros(1, size_rows*size_columns);
% % Vectorized the input image for later encoding purpose.
% for i = 1:size_rows
%     for j = 1:size_columns
%         image_vectorized((i-1)*size_columns+j) = x(i,j);
%     end
% end
% % Second do the Huffman coding for this row vector.
% image_vectorized_uint8 = uint8(image_vectorized);
[zipped, info] = norm2huff(x);
info.size_rows = size_rows;
info.size_columns = size_columns;
end

