function [zipped_mean, zipped_diff, info_mean, info_diff] = diff_coder_old(x)
% Input:
%   x: Input image.
% Output:
%   zipped_mean: Huffman encoding for the mean image(after quantization).
%   zipped_diff: Huffman encoding for the difference image(after
%   quantization).
%   info_mean: Header information for the encoded mean image.
%   info_diff: Header information for the encoded difference image.
% Function handle used for calculating the mean value for each block of
% size 8*8.
fun = @(block_struct)mean2(block_struct.data) * ones(size(block_struct.data));
% Block operation, result is in 'double' data type, after doing the block
% operation, the resulting mean image has the same size as the input image.
mean_img_double = blockproc(x, [8 8], fun);
% Cinvert double into uint8, this is equal to do the 8 bits quantization.
mean_img_uint8 = uint8(mean_img_double);
% Calculate the difference image, and do the converting (quantization).
diff_img_uint8 = uint8(double(x) - mean_img_double);
% Encode for the mean image.
[zipped_mean, info_mean] = norm2huff(mean_img_uint8);
% Encode for the difference image.
[zipped_diff, info_diff] = norm2huff(diff_img_uint8);
[size_rows, size_columns] = size(x);
info_mean.size_rows = size_rows;
info_mean.size_columns = size_columns;
info_diff.size_rows = size_rows;
info_diff.size_columns = size_columns;
end

