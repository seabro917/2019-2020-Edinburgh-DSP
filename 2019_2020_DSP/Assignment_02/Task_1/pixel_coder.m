function [zipped, info] = pixel_coder(x)
% This function do a 'pixel-based' Huffman encoding to the whole original
% image, mean I am encoding all original pixels of the images directly.
% Input:
%     x: Input image, in data type uint8.
% Output:
%     zipped: Encoded sequence of the image.
%     info: Header information of this sequence.

% Last modified date: 20/11/19
% Author: Yuchen MU

% First convert the matrix for the image into a row vector to make sure I
% can recover the image in correct order at receiver side.
[size_rows, size_columns] = size(x);
image_vectorized = zeros(1, size_rows*size_columns);
% Vectorized the input image for later encoding purpose.
for i = 1:size_rows
    for j = 1:size_columns
        image_vectorized((i-1)*size_columns+j) = x(i,j);
    end
end
% Because I vectorize the image by using a matrix of double data type, here
% I have to convert it back to uint8, note that this process is lossless.
image_vectorized_uint8 = uint8(image_vectorized);
% Second do the Huffman coding for this row vector.
[zipped, info] = norm2huff(image_vectorized_uint8);
% Store extra header information for later on reconstruct purpose.
info.size_rows = size_rows;
info.size_columns = size_columns;
end

