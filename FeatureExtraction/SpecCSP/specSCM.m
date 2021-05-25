function SCMs = specSCM(EEG)
    [N, L, C] = size(EEG);   
    v = 1:C; v = v(ones(C,1),:); v = v(:);
    
    EEG = permute(EEG,[3 2 1]);
    EEG = reshape(EEG,[C L*N]);
    EEG_temp1 = repmat(EEG,[C 1]);
    EEG_temp2 = EEG(v,:);
    EEG = EEG_temp2.*conj(EEG_temp1);
    
    % Normalization
    % EEG = EEG ./ repmat( sum(EEG(1:(C+1):C*C,:),1), [C*C 1]);
    
    SCMs = reshape(EEG,[C C L N]);   
end