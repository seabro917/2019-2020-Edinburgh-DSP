# 2019-2020-Edinburgh-DSP
My designs and solutions for M.Sc. DSP course assignments & labs.

Please note that same assignments are not included in this course syllabus currently.
# Assignmens
## Assignment 1
This assignment is about writing the `resample` function manually, which is used for resampling the given signal at a specific sampling frequency.

### Basic design idea
This is established with the idea of *Interpolation* and *Decimication*, e.g., if we have a signal originally sampled at `5kHz` ($F_x$) , our target is to resample it to `8kHz` ($F_y$), we first find the least common multiple `(40kHz)` of these two frequencies, upsampling the signal to this frequency via interpolation in time domain, then downsample the resulting signal to the target frequency via decimation. The upsampling and downsampling factors are denoted by $I$ and $D$, standing for interpolation and decimation, respectively.

### Several points
- For Interpolation: When we do the upsampling (interpolation process), the resulting signal's spectrum is a ***repetitive compressed*** version of the original signal (value of `I` will decide how many copies we have in the frequency domain). Before performing the decimation, we only want the spectrum which contains the frequency content of our original signal within its Nyquist rate, thus, filtering is needed.

- For Decimation: Assume we want to resample the original signal to a higher sampling frequency, then we must pay attention to the ***aliasing*** issues when doing the decimation (recall the Nyquist theorem). Therefore, apart from the filter described above after the interpolation process, before performing decimation, we need another filter to filter out any frequency content beyond half of the target sampling frequency ($F_y/2$).

- In real implementation, these two filters can be combined to a single anti-aliasing filter, whose frequency response is:

$$H(w_v) = \begin{cases} 
               1 & 0 \leq \|w_v| \leq min(\pi/D, \pi/I) \\
               0 & otherwise 
           \end{cases}$$

While decimation is always **lossy**, interpolation is **not**.

<p align="center">
<img src = "https://github.com/seabro917/2019-2020-Edinburgh-DSP/blob/main/task_1.png" width = "400"/> <img src = "https://github.com/seabro917/2019-2020-Edinburgh-DSP/blob/main/task_2.png" width = "400"/>
</p>
 
<p align="center">
 <sub>*From top to bottom, left to right: Fig. 1 to Fig. 3 (for Task 1, resampling from 5kHz to 8kHz), Fig. 4 to Fig. 6 (for Task 2, resampling the convolution result of two signals).</sub> 
</p>

<p align="center">
 <sub>Fig. 1: Fourier transform of the original signal sampled at 5kHz.</sub>
 <sub>Fig. 2: Fourier transform of the signal after interleaving with zeros.</sub>
 <sub>Fig. 3: Fourier transform of the final resampled signal at sampling frequency of 8kHz.</sub>
 <sub>Fig. 4: Fourier transform of the convolved signal returned by my code (at sampling frequency 8kHz).</sub>
 <sub>Fig. 5: Fourier transform of the convolved signal, by MATLAB "resample" function (at sampling frequency 8kHz).</sub>
 <sub>Fig. 6: Difference between the convolved signal returned by my code and MATLAB "resample" function.</sub>
</p>

## Assignment 2
This assignment is about designing encoder and decoder for digital image compression and reconstruction.
### Basic pixel-based source coder - Encoding the pixel
Directly quantizing, encoding (using the Huffman scheme) and transmitting the value of each pixel, without any other modifications. Information about the original image, such as image size, etc is stored in the header and transmitted together for receiver side reconstruction purpose.
### Mean and difference source coder - Encoding the "difference"
Apply a mean filer (sliding window) to each block of the original image, substract the calculated mean from each pixel value within this block. Instead of transmitting the value of each pixel, we transmit the difference between pixel value and the calculated mean. Again, Huffman encoding is also applied before transmitting. Calculated mean for each block is also stored in the header for later reconstruction purpose.
### JPEG lite source coder - Encoding the DCT coefficients of the "difference"
After calculating the "difference image" as shown above, here we apply the DCT ([discrete cosine transform](https://en.wikipedia.org/wiki/Discrete_cosine_transform)) to the difference image, and encoding the resulting DCT coefficients with Huffman coding.
### Result
<p align="center">
<img src = "https://github.com/seabro917/2019-2020-Edinburgh-DSP/blob/main/comparison.png" width = "820"/>
</p>
<p align="center">
 <sub>Fig. 7: (a): Original image. (b): Reconstructed image by pixel-based method. (c): Reconstructed image by mean and difference image. (d): Reconstructed image by mean image and DCT of difference image.</sub>
</p>


| Sample image   | Pixel encoder | Mean and diff encoder |    DCT encoder     |
|:--------------:|:-------------:|:---------------------:| :----------------: |
| cameraman.jpg  | 0.8896 / Inf  | 0.5726 / 24.1140dB    | 0.1903 / 24.1135dB |
| spine.jpg      | 0.4923 / Inf  | 0.4083 / 25.0871dB    | 0.1938 / 25.0703dB |
| lighthouse.png | 0.9347 / Inf  | 0.7344 / 22.8299dB    | 0.4199 / 22.8207dB |
| peppers.png    | 0.9210 / Inf  | 0.6551 / 26.8131dB    | 0.3689 / 26.7917dB |

 
<p align="center">
<sub>Table. 1: Summary of compression ratio and PSNR performance of three methods on different samples images.</sub>
</p>
 
### Some flowcharts
<p align="center">
<img src = "https://github.com/seabro917/2019-2020-Edinburgh-DSP/blob/main/flowchart_diff_encoder.png" width = "420"/> <img src = "https://github.com/seabro917/2019-2020-Edinburgh-DSP/blob/main/flowchart_lite_jpeg_encoder.png" width = "400"/>
<p/>
<p align="center">
 <sub>Fig. 8: Flowcharts for the designed difference encoder (left) and lite JPEG encoder (right)</sub>
<p/>



# Labs
Solutions to each lab session's task. Topics are mainly about 1D 2D convolution, LTI system process, digital image processing, power spectrum estimation methods, etc.
