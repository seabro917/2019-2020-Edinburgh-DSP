function x = diff_decoder_old(zipped_mean, zipped_diff, info_mean, info_diff)
mean_decode_sequence = huff2norm(zipped_mean, info_mean);
diff_decode_sequence = huff2norm(zipped_diff, info_diff);
mean_image = reshape(mean_decode_sequence, [info_mean.size_rows, info_mean.size_columns]);
diff_image = reshape(diff_decode_sequence, [info_diff.size_rows, info_diff.size_columns]);
x = mean_image + diff_image;
end

