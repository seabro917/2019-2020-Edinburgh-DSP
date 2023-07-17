function x = jpeg_lite_decoder(zipped_mean, zipped_diff, info_mean, info_diff)
% Decode the mean image.
mean_decode_sequence = huff2norm(zipped_mean, info_mean);
% Decode the DCT coefficient of the diff image (8*8 block).
dct_diff_img_sequence = huff2norm(zipped_diff, info_diff);
% Reshape the decoded sequence to the size of original image.
mean_img = reshape(mean_decode_sequence, [info_mean.size_rows, info_mean.size_columns]);
dct_diff_img = reshape(dct_diff_img_sequence, [info_diff.size_rows, info_diff.size_columns]);
% Do the inverse DCT to get the difference image.
% Function handle for doing the inverse DCT.
fun_idct = @(block_struct) idct2(block_struct.data);
% Doing the inverse DCT for each 8*8 block to get the difference image.
diff_img_double = blockproc(dct_diff_img, [8 8], fun_idct);
x = mean_img + uint8(diff_img_double);
end

