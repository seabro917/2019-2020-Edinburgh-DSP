function [zipped, info] = diff_coder(x)
% This function compresses the image by applying Huffman coding to the mean
% image and difference image of the original image. A zero padding
% operation is also taken in order to deal with case where number of rows
% or columns of the original image is not interger multiple of 8(e.g.spine.jpg).
% (since mean image was created based on 8*8 block operation) Note that this
% function also applies for case where no zero padding is needed(e.g.
% cameraman.jpg).
% Input:
%     x: Input original image, in data type of uint8.
% Output:
%     zipped: Encoded sequence for the difference image.
%     info: Header information of this encoded sequence.
%
% Last modified date: 20/11/19
% Author: Yuchen MU


% Convert image to double for later manipulation.This is a lossless
% process.
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
% Final image after zero padding.
zero_pad_img_original_double = [zero_pad_temp,zero_column];

% ------Block split operation-------
[size_row_zeropad, size_columns_zeropad] = size(zero_pad_img_original_double);
% How many blocks for each row and column of the image.
num_of_block_row = size_row_zeropad/8;
num_of_block_column = size_columns_zeropad/8;
% Total number of blocks.
num_of_block_total = num_of_block_row*num_of_block_column;
% Calculate mean for each block and create the whole mean image(in double type)
mean_array = zeros(1,num_of_block_total);
mean_image_double = zeros(size_row_zeropad, size_columns_zeropad);
block_mean_temp = zeros(8,8);

% Go through all blocks and store the temporary mean value.
for n = 1:num_of_block_total
    %     To find out which block the current block is.
    index_row = ceil(n/num_of_block_column);
    index_column = rem(n,num_of_block_column);
    %     Check whether a block is at the end of current row.
    if(index_column == 0)
        index_column = num_of_block_column;
    end
    %     Locate the corresponding 64bits of the image based on the number of
    %     current block.
    block_mean_temp = zero_pad_img_original_double(8*(index_row-1)+1:8*index_row, 8*(index_column-1)+1:8*index_column);
    mean_array(n) = calculate_mean_88(block_mean_temp);
    %     Creat the mean image based on the calculated mean value of each
    %     block.
    mean_image_double(8*(index_row-1)+1:8*index_row, 8*(index_column-1)+1:8*index_column) = ones(8,8)*mean_array(n);
end
% Resize the mean image back to the size of original image,
% since we will need to substract it from the original image.
mean_image_double = mean_image_double(1:size_rows, 1:size_columns);

% Calculate the difference image.
diff_image = img_original_double - mean_image_double;
% In order to make sure we do not lose too much information,
% scale the gray value range of diff_image to 0 to 255(correspond to the
% range of 8 bits quantization).
min_in_diff = min(min(diff_image));
max_in_diff = max(max(diff_image));
diff_image = 255*((diff_image-min_in_diff)/(max_in_diff-min_in_diff));
% Vectoried the difference image.
diff_image_vectorized = zeros(1, size_rows*size_columns);
% Vectorized the diff image for later encoding purpose.
for i = 1:size_rows
    for j = 1:size_columns
        diff_image_vectorized((i-1)*size_columns+j) = diff_image(i,j);
    end
end
% Finally, quantize this vectorized diff image, this is what we will encode.
diff_image_vectorized_uint8 = uint8(diff_image_vectorized);

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
% I need these values to scale the gray value of difference image back to
% its original gray value range at the reconstruction side.
info.max_diff_value = max_in_diff;
info.min_diff_value = min_in_diff;
end

% Function for calculating the mean for a 8*8 bolck.
function res = calculate_mean_88(A)
res = sum(sum(A)) / 64;
end

% Function for finding how many rows/columns are needed for zero padding.
% If no need to zero pad, then it returns 0.
function res = zero_pad_check(x)
temp = rem(x, 8);
if(temp==0)
    res = 0;
else
    res = 8 - temp;
end
end
