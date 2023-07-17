function x = pixel_decoder(zipped, info)
% This function decode the sequence of 'pixel_code' and reconstruct the
% Input:
%     zipped: Encoded sequence of the image.
%     info: Header information of this sequence.
% Output:
%     x: Reconstructed image, in data type uint8.

% Last modified date: 20/11/19
% Author: Yuchen MU

% Decode the sequence.
image_unzipped = huff2norm(zipped, info);
% Read the size information of original image and reconstruct the image.
size_rows = info.size_rows;
size_columns = info.size_columns;
x = zeros(size_rows, size_columns);
for i = 1:size_rows
    for j = 1:size_columns
        x(i,j) = image_unzipped((i-1)*size_columns+j);
    end
end
% This is a lossless process, not quantization, just keep the data type of
% the output in uint8.
x = uint8(x);
end

