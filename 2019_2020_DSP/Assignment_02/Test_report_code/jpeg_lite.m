function [zipped, info] = jpeg_lite(x)
% This function compresses the image by applying Huffman coding to the mean
% image and DCT coefficients of difference image of the original image (after 
% quantization).I create mean image by a 8*8 block operation, also, the DCT 
% is applied to each 8*8 block of difference image. Like what I did in 
% 'diff_coder', A zero padding operation is also taken in order to deal with 
% case where number of rows or columns of the original image is not integer
% multiple of 8(e.g.spine.jpg). (since mean image was created based on 8*8
% block operation) Note that this function also applies for case where no
% zero padding is needed(e.g. cameraman.jpg).
% Input:
%     x: Input original image, in data type of uint8.
% Output:
%     zipped: Encoded sequence for the DCT coefficients of difference image.
%     info: Header information of this encoded sequence.
%
% Last modified date: 20/11/19
% Author: Yuchen MU
% Convert image to double for later manipulation.
img_original_double = double(x) ;
% Size of the original image.
[size_rows, size_columns] = size(x);
% ------Zero padding operation, if no zero paddding is needed, then the
% variable 'zeropad_rows_needed' and 'zeropad_columns_needed'are both
% zeros, which has no effect on the original image----------
zeropad_rows_needed = zero_pad_check(size_rows);
zeropad_columns_needed = zero_pad_check(size_columns);
% Start zero padding with rows.
zero_row = zeros(zeropad_rows_needed, size_columns);
zero_pad_temp = [img_original_double;zero_row];
% Then zero pad columns.
zero_column = zeros(size_rows+zeropad_rows_needed, zeropad_columns_needed);
% Final zero-padded image.
zero_pad_img_original_double = [zero_pad_temp,zero_column];
% ------Block split operation-------
[size_rows_zeropad, size_columns_zeropad] = size(zero_pad_img_original_double);
% How many blocks for each row and column of the image.
num_of_block_row = size_rows_zeropad/8;
num_of_block_column = size_columns_zeropad/8;
% Total number of blocks.
num_of_block_total = num_of_block_row*num_of_block_column;
% Calculate mean for each block and create the whole mean image(in double type)
mean_array = zeros(1,num_of_block_total);
mean_image_double = zeros(size_rows_zeropad, size_columns_zeropad);
block_temp = zeros(8,8);
for n = 1:num_of_block_total
    index_row = ceil(n/num_of_block_column);
    index_column = rem(n,num_of_block_column);
    %     Check whether a block is at the end of current row.
    if(index_column == 0)
        index_column = num_of_block_column;
    end
    block_temp = zero_pad_img_original_double(8*(index_row-1)+1:8*index_row, 8*(index_column-1)+1:8*index_column);
    mean_array(n) = calculate_mean_88(block_temp);
    mean_image_double(8*(index_row-1)+1:8*index_row, 8*(index_column-1)+1:8*index_column) = ones(8,8)*mean_array(n);
end
% Calculate the difference image.This time since we will do block operation
% on difference image, we directly subtract mean image from the original
% image, and do resize after decoding at receiver side.
diff_image =  zero_pad_img_original_double - mean_image_double;
% Do the 8*8 block DCT on each block of the difference image.
diff_image_dct_matrix = zeros(size_rows_zeropad, size_columns_zeropad);
block_temp = zeros(8,8);
for n = 1:num_of_block_total
    index_row = ceil(n/num_of_block_column);
    index_column = rem(n,num_of_block_column);
    %     Check whether a block is at the end of current row.
    if(index_column == 0)
        index_column = num_of_block_column;
    end
    block_temp = diff_image(8*(index_row-1)+1:8*index_row, 8*(index_column-1)+1:8*index_column);
%     Store the DCT for current 8*8 block into the final DCT image of difference image. 
   diff_image_dct_matrix(8*(index_row-1)+1:8*index_row, 8*(index_column-1)+1:8*index_column) = dct2(block_temp);
end
% In order to make sure we do not lose too much information,
% scale the gray value range of dct matrix to 0 to 255.
min_in_diff = min(min(diff_image_dct_matrix));
max_in_diff = max(max(diff_image_dct_matrix));
diff_image_dct_matrix = 255*((diff_image_dct_matrix-min_in_diff)/(max_in_diff-min_in_diff));
% Vectoried the DCT coefficients of difference image.
diff_image_dct_vectorized = zeros(1, size_rows_zeropad *size_columns_zeropad);
% Vectorized the DCT matrix of difference image for later encoding purpose.
for i = 1:size_rows_zeropad
    for j = 1:size_columns_zeropad
        diff_image_dct_vectorized((i-1)*size_columns_zeropad+j) = diff_image_dct_matrix(i,j);
    end
end
% Quantize this vectorized DCT array of diff image, this is what we will encode.
diff_image_vectorized_uint8 = uint8(diff_image_dct_vectorized);
% Quantized the mean array, note that we don't need the whole mean image,
% since the values of mean image inside each 8*8 block are same, if we encode 
% the whole mean image, it will introduce redundancy.
mean_array_uint8 = uint8(mean_array);
% Encode the mean array and later store it in the header of this function.
[zipped_mean, info_mean] = norm2huff(mean_array_uint8);
% Encode the difference image.
[zipped, info] = norm2huff(diff_image_vectorized_uint8);
% Put extra information in the header for later on recover purpose.
info.size_rows = size_rows;
info.size_columns = size_columns;
info.num_of_block_row = num_of_block_row;
info.num_of_block_column = num_of_block_column;
info.num_of_block_total = num_of_block_total;
info.mean_array_zipped = zipped_mean;
info.mean_array_info = info_mean;
info.max_diff_value = max_in_diff;
info.min_diff_value = min_in_diff;
end
% Function for calculating the mean for a 8*8 bolck.
function res = calculate_mean_88(A)
res = sum(sum(A)) / 64;
end
% Function for finding how many rows/columns are needed for zero padding.
% If no zero padding is needed, this function returns 0.
function res = zero_pad_check(x)
temp = rem(x, 8);
if(temp==0)
    res = 0;
else
    res = 8 - temp;
end
end
