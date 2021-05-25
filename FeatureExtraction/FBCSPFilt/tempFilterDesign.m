function tempFilter = tempFilterDesign(tempFilterOpts)
N = size(tempFilterOpts.freqBands,1);
tempFilter = cell(1,N);

for i = 1:N
    B_0 = tempFilterOpts.freqBands(i,1);
    B_1 = tempFilterOpts.freqBands(i,2);
    delta = tempFilterOpts.delta;
    A = [0 1 0];                % band type: 0='stop', 1='pass'
    dev = [tempFilterOpts.attenuation 
        tempFilterOpts.ripple
        tempFilterOpts.attenuation]; % ripple/attenuation spec
    fs = tempFilterOpts.fs;
    
    F = [B_0 - delta B_0 B_1 B_1 + delta];  % band limits
    [M,Wn,beta,typ] = kaiserord(F,A,dev,fs);  % window parameters
    tempFilter{1,i} = fir1(M, Wn, typ, kaiser(M+1,beta)); % filter design
end

end