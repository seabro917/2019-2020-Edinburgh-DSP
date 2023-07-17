function x = diff_decoder(zipped, info)
% This function recover the image compressed by 'diff_coder' function, the
% output image is of same size of the original image.
% Input:
%     zipped: Encoded sequence for the difference image.
%     info: Header information of this encoded sequence.
% Output:
%     x: Reconstructed image, in data type of uint8.
% 
% Last modified date: 20/11/19
% Author: Yuchen MU
% Decoded sequence for diff image in uint8 by calling the function of
% Huffman decoding.
diff_image_vectorized_uint8 = huff2norm(zipped, info);
% Convert it to double for later on manipulation.
diff_image_vectorized_double = double(diff_image_vectorized_uint8);
% Decoded mean array in uint8.
mean_array_uint8 = huff2norm(info.mean_array_zipped, info.mean_array_info);
% Convert it to double for later on manipulation.
mean_array_double = double(mean_array_uint8);
% Read extra information from header to reconstruct the image.
num_of_block_row = info.num_of_block_row;
num_of_block_column = info.num_of_block_column;
num_of_block_total = info.num_of_block_total;
size_rows = info.size_rows;
size_columns = info.size_columns;
max_in_diff = info.max_diff_value;
min_in_diff = info.min_diff_value;
% Reconstruct the difference image and scale it back to its original gray
% value range.
diff_image = zeros(size_rows, size_columns);
for i = 1:size_rows
    for j = 1:size_columns
        diff_image(i,j) = diff_image_vectorized_double((i-1)*size_columns+j);
    end
end
% Scale it back to its original gray value range.
diff_image = ((max_in_diff-min_in_diff)*diff_image+255*min_in_diff)/255;
% Reconstruct the mean image.
mean_image = zeros(8*num_of_block_row, 8*num_of_block_column);
for n = 1:num_of_block_total
    index_row = ceil(n/num_of_block_column);
    index_column = rem(n,num_of_block_column);
    %     Check whether a block should be at the end of current row.
    if(index_column == 0)
        index_column = num_of_block_column;
    end
    mean_image(8*(index_row-1)+1:8*index_row, 8*(index_column-1)+1:8*index_column) = ones(8,8)*mean_array_double(n);
end
% Resize the mean image to the size of the original image.
mean_image = mean_image(1:size_rows, 1:size_columns);
% Reconstruct the whole image by adding difference image and mean image.
x = uint8(diff_image) + uint8(mean_image);
end
