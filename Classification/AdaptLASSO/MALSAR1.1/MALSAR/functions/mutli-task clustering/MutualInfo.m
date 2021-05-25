%% FUNCTION LSSMTC
%   compute the mutual information
%
%% LICENSE
%   This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%   Copyright (C) 2011 - 2012 Quanquan Gu, Jiayu Zhou, and Jieping Ye
%
%   You are suggested to first read the Manual.
%   For any problem, please contact with Jiayu Zhou via jiayu.zhou@asu.edu
%
%   Last modified on June 17, 2012.
%

function MIhat = MutualInfo(L1,L2)
%   mutual information

%===========    
L1 = L1(:);
L2 = L2(:);
if size(L1) ~= size(L2)
    error('size(L1) must == size(L2)');
end
L1 = L1 - min(L1) + 1;      %   min (L1) <- 1;
L2 = L2 - min(L2) + 1;      %   min (L2) <- 1;
%===========    make bipartition graph  ============
nClass = max(max(L1), max(L2));
G = zeros(nClass);
for i=1:nClass
    for j=1:nClass
        G(i,j) = length(find(L1 == i & L2 == j));
    end
end
sumG = sum(G(:));
%===========    calculate MIhat
P1 = sum(G,2);  P1 = P1/sumG;
P2 = sum(G,1);  P2 = P2/sumG;
H1 = sum(-P1.*log2(P1));
H2 = sum(-P2.*log2(P2));
P12 = G/sumG;
PPP = P12./repmat(P2,nClass,1)./repmat(P1,1,nClass);
PPP(abs(PPP) < 1e-12) = 1;
MI = sum(P12(:) .* log2(PPP(:)));
MIhat = MI / max(H1,H2);

MIhat = real(MIhat);

