% Kunal Jathal

% Fractional Delay Chorus
% =======================

% Now, we want to implement a FRACTIONAL delay chorus filter

% y[n] = x[n] + b0 * x[n - g[n]]

% We want to take in the following arguments:
% Delay Coefficient (b0)
% Input Signal (x[n])
% Delay Amount (g[n]) - this is now a function of time. So we use an LFO to
% vary it with time. Hence 3 new variables introduced are:
% a) LFO Frequency
% b) Minimum delay in MILLISECONDS
% c) Maximum delay in MILLISECONDS

% The difference here now is in the indices retrieved by the LFO.
% Previously, we rounded to the nearest integer sample number. In this case,
% we don't round, and instead construct the sample that the LFO tells us to
% retrieve.


function fracChorus(input, delayCoefficient, minDelay, maxDelay, LFOfrequency)


% Read in audio file
[inputSignal, fs] = wavread(input);

% Play it
sound(inputSignal, fs);

% Convert delays to samples
minDelay = round((minDelay/1000) * fs);
maxDelay = round((maxDelay/1000) * fs);

% We create a buffer to hold the delayed samples that we will need to
% access when building the new signal. The number of samples the buffer
% should be able to hold should be equal to the maximum delay desired.
buffer = zeros(1, maxDelay);

% Create empty output signal
outputSignal = zeros(1,length(inputSignal));

% When accessing the buffer, we need to know which sample to get. Since the
% minimum delay is specified, we know that the sample we need will be the
% minimum delay + the amount specified by the LFO. So the start index will
% always be at least the minimum delay, and we will add this start index to
% the index generated by the LFO to get the buffer index of the sample we
% wish to retrieve.
startIndex = minDelay;
lfoTable = abs(sin(2*pi*LFOfrequency*[0:length(inputSignal)-1]/fs));
bufferIndex = round(lfoTable*(length(buffer)-startIndex)) + startIndex;

% Create the output signal now by constructing it sample by sample
for i=1:length(inputSignal) 
    % We split the sample retrieved by the LFO (bufferIndex) into it's
    % integer and mantissa parts.
    bufferInteger = floor(bufferIndex(i));
    bufferMantissa = bufferIndex(i) - bufferInteger;
    
    % If the LFO retrieves an integer sample, we don't need to worry
    if (bufferMantissa == 0)
        newSample = buffer(bufferIndex(i));
    else
    % If we have a fractional sample number, we need to build the new
    % sample by weighting the previous and next sample accordingly and
    % summing them up. We use the mantissa to compute the weights.
        newSample = ((1 - bufferMantissa) * buffer(bufferInteger)) + (bufferMantissa * buffer(bufferInteger+1));
    end
    
    outputSignal(i) = inputSignal(i) + (delayCoefficient * newSample);

    % Update the buffer as we move forward in time
    buffer(2:end) = buffer(1:end-1);
    buffer(1) = inputSignal(i);
end

% Let's hear our chorus!
sound(outputSignal, fs)

end