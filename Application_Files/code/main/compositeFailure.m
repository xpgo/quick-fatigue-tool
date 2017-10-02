function [] = compositeFailure(N, L)
%COMPOSITEFAILURE    QFT function to calculate composite failure criteria.
%   This function calculates composite failure criteria according to the
%   maximum stress, Tsai-Hill, Tsai-Wu, Azzi-Tsai-Hill and Hashin criteria.
%   
%   COMPOSITEFAILURE is used internally by Quick Fatigue Tool. The user is
%   not required to run this file.
%
%   
%   Quick Fatigue Tool 6.11-04 Copyright Louis Vallance 2017
%   Last modified 02-Oct-2017 13:11:53 GMT
    
    %%


% Get the number of groups for the analysis
G = getappdata(0, 'numberOfGroups');

% Get the group ID buffer
groupIDBuffer = getappdata(0, 'groupIDBuffer');

% Initialize output variables
MSTRS = linspace(-1.0, -1.0, N);
MSTRN = linspace(-1.0, -1.0, N);
TSAIH = linspace(-1.0, -1.0, N);
TSAIW = linspace(-1.0, -1.0, N);
TSAIWTT = linspace(-1.0, -1.0, N);
k = linspace(-1.0, -1.0, N);
AZZIT = linspace(-1.0, -1.0, N);
HSNFTCRT = linspace(-1.0, -1.0, N);
HSNFCCRT = linspace(-1.0, -1.0, N);
HSNMTCRT = linspace(-1.0, -1.0, N);
HSNMCCRT = linspace(-1.0, -1.0, N);

startID = 1.0;
totalCounter = 1.0;

for groups = 1:G
    if strcmpi(groupIDBuffer(1.0).name, 'default') == 1.0
        % There is one, default group
        
        % Store the current material
        setappdata(0, 'message_groupMaterial', getappdata(0, 'material'))
    else
        % Assign group parameters to the current set of analysis IDs
        [N, ~] = group.switchProperties(groups, groupIDBuffer(groups));
        
        % Store the current material
        setappdata(0, 'message_groupMaterial', groupIDBuffer(groups).material)
    end
    
    % Get fail stress properties
    Xt = getappdata(0, 'failStress_tsfd');
    Xc = getappdata(0, 'failStress_csfd');
    Yt = getappdata(0, 'failStress_tstd');
    Yc = getappdata(0, 'failStress_cstd');
    Zt = getappdata(0, 'failStress_tsttd');
    Zc = getappdata(0, 'failStress_csttd');
    S = getappdata(0, 'failStress_shear');
    Fc12 = getappdata(0, 'failStress_cross12');
    Fc23 = getappdata(0, 'failStress_cross23');
    B12 = getappdata(0, 'failStress_limit12');
    B23 = getappdata(0, 'failStress_limit23');
    
    % Get fail strain properties
    Xet = getappdata(0, 'failStrain_tsfd');
    Xec = getappdata(0, 'failStrain_csfd');
    Yet = getappdata(0, 'failStrain_tstd');
    Yec = getappdata(0, 'failStrain_cstd');
    Se = getappdata(0, 'failStrain_shear');
    E = getappdata(0, 'E');
    kp = getappdata(0, 'kp');
    np = getappdata(0, 'np');
    v = getappdata(0, 'poisson');
    
    % Get Hashin properties
    alpha = getappdata(0, 'hashin_alpha');
    Xht = getappdata(0, 'hashin_lts');
    Xhc = getappdata(0, 'hashin_lcs');
    Yht = getappdata(0, 'hashin_tts');
    Yhc = getappdata(0, 'hashin_tcs');
    Sl = getappdata(0, 'hashin_lss');
    St = getappdata(0, 'hashin_tss');
    
    % Check if there is enough data for maximum stress, Tsai-Hill, Tsai-Wu and Azzi-Tsai-Hill theory
    if isempty(Xt) == 1.0 || isempty(Xc) == 1.0 || isempty(Yt) == 1.0 || isempty(Yc) == 1.0
        failStressGeneral = -1.0;
    else
        failStressGeneral = 1.0;
    end
    
    % Check if there is enough data for Tsai-Wu (through-thickness)
    if isempty(Yt) == 1.0 || isempty(Yc) == 1.0 || isempty(Zt) == 1.0 || isempty(Zc) == 1.0
        tsaiWuTT = -1.0;
    else
        tsaiWuTT = 1.0;
    end
    
    % Check if there is enough data for fail strain
    if ((isempty(E) == 1.0 || isempty(kp) == 1.0 || isempty(np) == 1.0) && (isempty(v) == 1.0 || isempty(E) == 1.0)) ||...
            (isempty(Xet) == 1.0 || isempty(Xec) == 1.0 || isempty(Yet) == 1.0 || isempty(Yec) == 1.0 || isempty(Se) == 1.0)
        failStrain = -1.0;
    elseif (isempty(kp) == 1.0 || isempty(np) == 1.0) && isempty(E) == 0.0
        failStrain = 0.0;
        sectionG = E/(2.0*(1.0 + v));
    else
        failStrain = 1.0;
    end
    
    % Check if there is enough data for Hashin
    if isempty(Xht) == 1.0 || isempty(Xhc) == 1.0 || isempty(Yht) == 1.0 || isempty(Yhc) == 1.0 || isempty(Sl) == 1.0 || isempty(St) == 1.0
        hashin = -1.0;
    else
        hashin = 1.0;
    end
    
    if failStressGeneral == -1.0 && tsaiWuTT == -1.0 && failStrain == -1.0 && hashin == -1.0
        totalCounter = totalCounter + N;
        continue
    end
    
    % Get stress tensor
    S11 = getappdata(0, 'Sxx');
    S22 = getappdata(0, 'Syy');
    S33 = getappdata(0, 'Szz');
    S12 = getappdata(0, 'Txy');
    S13 = getappdata(0, 'Txz');
    S23 = getappdata(0, 'Tyz');
    
    S11 = S11(startID:(startID + N) - 1.0, :);
    S22 = S22(startID:(startID + N) - 1.0, :);
    S33 = S33(startID:(startID + N) - 1.0, :);
    S12 = S12(startID:(startID + N) - 1.0, :);
    S13 = S13(startID:(startID + N) - 1.0, :);
    S23 = S23(startID:(startID + N) - 1.0, :);
    
    X = zeros(1.0, L);
    Y = zeros(1.0, L);
    
    Xe = zeros(1.0, L);
    Ye = zeros(1.0, L);
    
    % Initialize Tsai-Wu parameters
    if failStressGeneral ~= -1.0
        F1 = (1.0/Xt) + (1.0/Xc);
        F2 = (1.0/Yt) + (1.0/Yc);
        F11 = -(1.0/(Xt*Xc));
        F22 = -(1.0/(Yt*Yc));
        F66 = 1.0/S^2.0;
        
        if isempty(B12) == 0.0
            F12 = (1.0/(2.0*B12^2.0)) * (1.0 - ((1.0/Xt) + (1.0/Xc) + (1.0/Yt) + (1.0/Yc))*(B12) + ((1.0/(Xt*Xc)) + (1.0/(Yt*Yc)))*(B12^2.0));
        else
            F12 = Fc12*sqrt(F11*F22);
        end
    end
    
    % Initialize Tsai-Wu (through-thickness) parameters
    if tsaiWuTT ~= -1.0
        F2 = (1.0/Yt) + (1.0/Yc);
        F3 = (1.0/Zt) + (1.0/Zc);
        F22 = -(1.0/(Yt*Yc));
        F33 = 1.0/(Zt*Zc);
        
        if isempty(B23) == 0.0
            F23 = (1.0/(2.0*B23^2.0)) * (1.0 - ((1.0/Yt) + (1.0/Yc) + (1.0/Zt) + (1.0/Zc))*(B23) + ((1.0/(Yt*Yc)) + (1.0/(Zt*Zc)))*(B23^2.0));
        else
            F23 = Fc23*sqrt(F22*F33);
        end
    end
    
    for i = 1:N
        %% Get the stresses at the current item
        S11i = S11(i, :);
        S22i = S22(i, :);
        S33i = S33(i, :);
        S12i = S12(i, :);
        S13i = S13(i, :);
        S23i = S23(i, :);
        
        %% Check for out-of-plane stress components
        if any(S33i) == 1.0 || any(S13i) == 1.0 || any(S23i) == 1.0
            messenger.writeMessage(132.0)
        end
        
        %% FAIL STRESS CALCULATION
        if failStressGeneral == 1.0
            % Tension-compression split
            X(S11i >= 0.0) = Xt;
            X(S11i < 0.0) = Xc;
            
            Y(S22i >= 0.0) = Yt;
            Y(S22i < 0.0) = Yc;
            
            % Failure calculation
            MS11 = S11i./X;
            MS22 = S22i./Y;
            MS12 = abs(S12./S);
            MSTRS(totalCounter) = max(max([MS11; MS22; MS12]));
            
            TSAIH(totalCounter) = max((S11i.^2.0./X.^2.0) - ((S11i.*S22i)./X.^2.0) + (S22i.^2.0./Y.^2.0) + (S12i.^2.0./S.^2.0));
            TSAIW(totalCounter) = max((F1.*S11i) + (F2.*S22i) + (F11.*S11i.^2.0) + (F22.*S22i.^2.0) + (F66.*S12i.^2.0) + (2.0.*F12.*S11i.*S22i));
            AZZIT(totalCounter) = max((S11i.^2.0./X.^2.0) - (abs((S11i.*S22i))/X.^2.0) + (S22i.^2.0./Y.^2.0) + (S12i.^2.0./S.^2.0));
        end
        
        if tsaiWuTT == 1.0
            k(totalCounter) = max(S12i./S23i);
            
            TSAIWTT(totalCounter) = max((F2.*S22i) + (F3.*S33i) + (F22.*S22i.^2.0) + (F33*S33i.^2.0) + (2.0.*F23.*S22i.*S33i));
        end
        
        %% FAIL STRAIN CALCULATION
        if failStrain == 1.0            
            [E11i, ~, ~, ~] = css2e(S11i, E, kp, np);
            [E22i, ~, ~, ~] = css2e(S22i, E, kp, np);
            [E12i, ~, ~, ~] = css2e(S12i, E, kp, np);
            
            E11i = E11i(1.0 + length(E11i) - L:end);
            E22i = E22i(1.0 + length(E22i) - L:end);
            E12i = E11i(1.0 + length(E12i) - L:end);
        elseif failStrain == 0.0
            E11i = S11i./E;
            E22i = S22i./E;
            E12i = S12i./sectionG;
        end
        
        if failStrain ~= -1.0
            % Tension-compression split
            Xe(E11i >= 0.0) = Xet;
            Xe(E11i < 0.0) = Xec;
            
            Ye(E22i >= 0.0) = Yet;
            Ye(E22i < 0.0) = Yec;
            
            ME11 = E11i./Xe;
            ME22 = E22i./Ye;
            ME12 = abs(E12i./Se);
            MSTRN(totalCounter) = max(max([ME11; ME22; ME12]));
        end
        
        %% HASHIN CALCULATION
        if hashin == 1.0
            HSNFTCRTi = zeros(1.0, L);
            HSNFCCRTi = zeros(1.0, L);
            HSNMTCRTi = zeros(1.0, L);
            HSNMCCRTi = zeros(1.0, L);
            
            for j = 1:L
                % Mode I/II
                if S11i(j) >= 0.0
                    HSNFTCRTi(j) = (S11i(j)/Xht)^2.0 + alpha*(S12i(j)/Sl)^2.0;
                else
                    HSNFCCRTi(j) = (S11i(j)/Xhc)^2.0;
                end
                
                % Mode III/IV
                if S22(j) >= 0.0
                    HSNMTCRTi(j) = (S22i(j)/Yht)^2.0 + (S12i(j)/Sl)^2.0;
                else
                    HSNMCCRTi(j) = (S22i(j)/(2.0*St))^2.0 + ((Yhc/(2.0*St))^2.0 - 1.0)*(S22i(j)/Yhc) + (S12i(j)/Sl)^2.0;
                end
            end
            
            HSNFTCRT(totalCounter) = max(HSNFTCRTi);
            HSNFCCRT(totalCounter) = max(HSNFCCRTi);
            HSNMTCRT(totalCounter) = max(HSNMTCRTi);
            HSNMCCRT(totalCounter) = max(HSNMCCRTi);
        end
        
        totalCounter = totalCounter + 1.0;
    end
    
    % Update the start ID
    startID = startID + N;
end

%% Remove INF values of K
k(isinf(k)) = 0.0;

%% Inform the user if composite has failed
N_MSTRS = length(MSTRS(MSTRS >= 1.0));
N_MSTRN = length(MSTRN(MSTRN >= 1.0));
N_TSAIH = length(TSAIH(TSAIH >= 1.0));
N_TSAIW = length(TSAIW(TSAIW >= 1.0));
N_TSAIWTT = length(TSAIWTT(TSAIWTT >= (1.0 - k.^2.0)));
N_AZZIT = length(AZZIT(AZZIT >= 1.0));
N_HSNFTCRT = length(HSNFTCRT(HSNFTCRT >= 1.0));
N_HSNFCCRT = length(HSNFCCRT(HSNFCCRT >= 1.0));
N_HSNMTCRT = length(HSNMTCRT(HSNMTCRT >= 1.0));
N_HSNMCCRT = length(HSNMCCRT(HSNMCCRT >= 1.0));

setappdata(0, 'MSTRS', N_MSTRS)
setappdata(0, 'MSTRN', N_MSTRN)
setappdata(0, 'TSAIH', N_TSAIH)
setappdata(0, 'TSAIW', N_TSAIW)
setappdata(0, 'TSAIWTT', N_TSAIWTT)
setappdata(0, 'AZZIT', N_AZZIT)
setappdata(0, 'HSNFTCRT', N_HSNFTCRT)
setappdata(0, 'HSNFCCRT', N_HSNFCCRT)
setappdata(0, 'HSNMTCRT', N_HSNMTCRT)
setappdata(0, 'HSNMTCRT', N_HSNMCCRT)

if N_MSTRS > 0.0
    messenger.writeMessage(290.0)
end
if N_TSAIH > 0.0
    messenger.writeMessage(291.0)
end
if N_TSAIW > 0.0
    messenger.writeMessage(292.0)
end
if N_TSAIWTT > 0.0
    messenger.writeMessage(293.0)
end
if N_AZZIT > 0.0
    messenger.writeMessage(294.0)
end
if N_MSTRN > 0.0
    messenger.writeMessage(295.0)
end
if N_HSNFTCRT > 0.0
    messenger.writeMessage(296.0)
end
if N_HSNFCCRT > 0.0
    messenger.writeMessage(297.0)
end
if N_HSNMTCRT > 0.0
    messenger.writeMessage(298.0)
end
if N_HSNMCCRT > 0.0
    messenger.writeMessage(299.0)
end

%% Write output to file
if (failStressGeneral ~= -1.0) || (tsaiWuTT ~= -1.0) || (failStrain ~= -1.0) || (hashin ~= -1.0)
    % Check if there is failure 
    FAIL_ALL = [N_MSTRS, N_TSAIH, N_TSAIW, N_TSAIWTT, N_AZZIT, N_MSTRN, N_HSNFTCRT, N_HSNFCCRT, N_HSNMTCRT, N_HSNMCCRT];
    if any(FAIL_ALL) == 0.0
        messenger.writeMessage(301.0)
    end
    
    mainIDs = getappdata(0, 'mainID');
    subIDs = getappdata(0, 'subID');
    
    data = [mainIDs'; subIDs'; MSTRS; MSTRN; TSAIH; TSAIW; TSAIWTT; AZZIT; HSNFTCRT; HSNFCCRT; HSNMTCRT; HSNMCCRT]';
    
    % Print information to file
    root = getappdata(0, 'outputDirectory');
    
    if exist(sprintf('%s/Data Files', root), 'dir') == 0.0
        mkdir(sprintf('%s/Data Files', root))
    end
    
    dir = [root, 'Data Files/composite-criteria.dat'];
    
    fid = fopen(dir, 'w+');
    
    fprintf(fid, 'COMPOSITE FAILURE\r\n');
    fprintf(fid, 'Job:\t%s\r\nLoading:\t%.3g\t%s\r\n', getappdata(0, 'jobName'), getappdata(0, 'loadEqVal'), getappdata(0, 'loadEqUnits'));
    
    fprintf(fid, 'Main ID\tSub ID\tMSTRS\tMSTRN\tTSAIH\tTSAIW\tTSAIWTT\tAZZIT\tHSNFTCRT\tHSNFCCRT\tHSNMTCRT\tHSNMCCRT\r\n');
    fprintf(fid, '%.0f\t%.0f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\r\n', data');
    
    fclose(fid);
    
    messenger.writeMessage(129.0)
else
    messenger.writeMessage(300.0)
end