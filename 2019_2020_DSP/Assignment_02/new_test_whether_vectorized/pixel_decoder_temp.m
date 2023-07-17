% Should the size of the image be the inputs of this function?
function x = pixel_decoder_temp(zipped, info)
image_unzipped = huff2norm(zipped, info);
size_rows = info.size_rows;
size_columns = info.size_columns;
x = zeros(size_rows, size_columns);
for i = 1:size_rows
    for j = 1:size_columns
        x(i,j) = image_unzipped((i-1)*size_columns+j);
    end
end
x = uint8(x);
end

