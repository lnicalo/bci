function SCMs = SCM(EEG)
    [N, L, C] = size(EEG);   
    v = 1:C; v = v(ones(C,1),:); v = v(:);
    
    EEG_temp = permute(EEG,[3 2 1]);
    EEG_temp = reshape(EEG_temp,[C L*N]);
    EEG_temp1 = repmat(EEG_temp,[C 1]);
    EEG_temp2 = EEG_temp(v,:);
    EEG_temp = EEG_temp2.*conj(EEG_temp1);
    SCMs = reshape(EEG_temp,[C C L N]);
    SCMs = permute(SCMs,[4 2 1 3]);
end