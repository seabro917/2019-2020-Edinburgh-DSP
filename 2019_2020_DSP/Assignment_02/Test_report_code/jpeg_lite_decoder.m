function x = jpeg_lite_decoder(zipped, info)
% This function recover the image compressed by 'jpeg_lite' function, the
% output image is of same size of the original image.
% Input:
%     zipped: Encoded sequence for the DCT coefficients of difference image.
%     info: Header information of this encoded sequence.
% Output:
%     x: Reconstructed image, in data type of uint8.
% 
% Last modified date: 20/11/19
% Author: Yuchen MU
% Decoded sequence for dct of diff image in uint8.
dct_diff_image_vectorized_uint8 = huff2norm(zipped, info);
% Convert it to double for later on manipulation.
diff_image_vectorized_double = double(dct_diff_image_vectorized_uint8);
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
% Size of the zero_padded image.
size_rows_zeropad = 8*num_of_block_row;
size_columns_zeropad= 8*num_of_block_column;
% Reconstruct the DCT matrix for difference matrix.
dct_diff_image = zeros(size_rows_zeropad, size_columns_zeropad);
for i = 1:size_rows_zeropad
    for j = 1:size_columns_zeropad
        dct_diff_image(i,j) = diff_image_vectorized_double((i-1)*size_columns_zeropad+j);
    end
end
% Scale it back to its original gray value range.
dct_diff_image = ((max_in_diff-min_in_diff)*dct_diff_image+255*min_in_diff)/255;
% Do the IDCT for each 8*8 block to get difference image
diff_image = zeros(size_rows_zeropad, size_columns_zeropad);
block_temp = zeros(8,8);
for n = 1:num_of_block_total
    index_row = ceil(n/num_of_block_column);
    index_column = rem(n,num_of_block_column);
    %     Check whether a block is at the end of current row.
    if(index_column == 0)
        index_column = num_of_block_column;
    end
    block_temp = dct_diff_image(8*(index_row-1)+1:8*index_row, 8*(index_column-1)+1:8*index_column);
   diff_image(8*(index_row-1)+1:8*index_row, 8*(index_column-1)+1:8*index_column) = idct2(block_temp);
end
% Reconstruct the mean image.
mean_image = zeros(8*num_of_block_row, 8*num_of_block_column);
for n = 1:num_of_block_total
    index_row = ceil(n/num_of_block_column);
    index_column = rem(n,num_of_block_column);
    %     Check whether a block is at the end of current row.
    if(index_column == 0)
        index_column = num_of_block_column;
    end
    mean_image(8*(index_row-1)+1:8*index_row, 8*(index_column-1)+1:8*index_column) = ones(8,8)*mean_array_double(n);
end
% Reconstruct the whole image by adding difference image and mean image.
x = uint8(diff_image) + uint8(mean_image);
% Resize to the size of original image.
x = x(1:size_rows,1:size_columns);
end
