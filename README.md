# cochlear-signal-processing
Rudimentary signal processor for cochlear implants

Toolboxes needed:
- Signal Processing Toolbox (https://www.mathworks.com/products/signal.html)
- Communications Toolbox (https://www.mathworks.com/products/communications.html)

signal_processing_final.m is the final design solution, with features as follows
- Equiripple bandpass filter
- 20 channels
- Spaced non-linearly

Output files have been processed by signal_processing_final.m

Test files test the following iterations:
1. Linear spacing of frequency bands.
2. Overlapping of frequency bands.
3. Least Squares filter for the bandpass filter (rather than Equiripple).
5. 20 frequency channels (rather than 16, the original number).
