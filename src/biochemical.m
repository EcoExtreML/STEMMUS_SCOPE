function biochem_out = biochemical(biochem_in, sfactor, Ci_input)

    if isnan(sfactor)
        sfactor = 1;
    end
    % Tmin=min(min(TT));
    % if Tmin<0
    %   sfactor= sfactor*0.3;
    % end
    % Date:     21 Sep 2012
    % Update:   20 Feb 2013
    % Update:      Aug 2013: correction of L171: Ci = Ci*1e6 ./ p .* 1E3;
    % Update:   2016-10 - (JAK) major rewrite to accomodate an iterative solution to the Ball-Berry equation
    %                   - also allows for g_m to be specified for C3 plants, but only if Ci_input is provided.
    % Authors:  Joe Berry and Christiaan van der Tol, Ari Kornfeld, contributions of others.
    % Sources:
    %           Farquhar et al. 1980, Collatz et al (1991, 1992).
    %
    % This function calculates:
    %    - stomatal resistance of a leaf or needle (s m-1)
    %    - photosynthesis of a leaf or needle (umol m-2 s-1)
    %    - fluorescence of a leaf or needle (fraction of fluor. in the dark)
    %
    % Usage:
    % biochem_out = biochemical(biochem_in)
    % the function was tested for Matlab R2013b
    %
    % Calculates net assimilation rate A, fluorescence F using biochemical model
    %
    % Input (units are important):
    % structure 'biochem_in' with the following elements:
    % Knparams   % [], [], []           parameters for empirical Kn (NPQ) model: Kn = Kno * (1+beta).*x.^alpha./(beta + x.^alpha);
    %       [Kno, Kn_alpha, Kn_beta]
    %  or, better, as individual fields:
    %   Kno                                     Kno - the maximum Kn value ("high light")
    %   Kn_alpha, Kn_beta                      alpha, beta: curvature parameters
    %
    % Cs        % [ppmV or umol mol]    initial estimate of conc. of CO2 in the
    %                                   ...bounary layer of the leaf
    % Q         % [umol photons m-2 s-1]net radiation, PAR
    % fPAR     % [0-1]                 fraction of incident light that is absorbed by the leaf (default = 1, for compatibility)
    % T         % [oC or K]             leaf temperature
    % eb        % [hPa = mbar]          intial estimate of the vapour pressure in leaf boundary layer
    % O         % [mmol/mol]            concentration of O2 (in the boundary
    %                                   ...layer, but no problem to use ambient)
    % p         % [hPa]                 air pressure
    % Vcmax25 (Vcmo)  % [umol/m2/s]     maximum carboxylation capacity @ 25 degC
    % BallBerrySlope (m) % []           Ball-Berry coefficient 'm' for stomatal regulation
    % BallBerry0 % []              (OPTIONAL) Ball-Berry intercept term 'b' (if present, an iterative solution is used)
    %                                     setting this to zeo disables iteration. Default = 0.01
    %
    % Type      % ['C3', 'C4']          text parameter, either 'C3' for C3 or any
    %                                   ...other text for C4
    % tempcor   % [0, 1]               boolean (0 or 1) whether or not
    %                                   ...temperature correction to Vcmax has to be applied.
    % Tparams  % [],[],[K],[K],[K]     vector of 5 temperature correction parameters, look in spreadsheet of PFTs.
    %                                     Only if tempcor=1, otherwise use dummy values
    % ...Or replace w/ individual values:
    % slti        []              slope of cold temperature decline (C4 only)
    % shti        []              slope of high temperature decline in photosynthesis
    % Thl         [K]             T below which C4 photosynthesis is <= half that predicted by Q10
    % Thh         [K]             T above which photosynthesis is <= half that predicted by Q10
    % Trdm        [K]             T at which respiration is <= half that predicted by Q10

    % effcon    [mol CO2/mol e-]  number of CO2 per electrons - typically 1/5 for C3 and 1/6 for C4

    % RdPerVcmax25 (Rdparam)  % []     respiration as fraction of Vcmax25
    % stressfactor [0-1]               stress factor to reduce Vcmax (for
    %                                   example soil moisture, leaf age). Use 1 to "disable" (1 = no stress)
    %  OPTIONAL
    % Kpep25 (kp)   % [umol/m2/s]         PEPcase activity at 25 deg C (defaults to Vcmax/56
    % atheta      % [0-1]                  smoothing parameter for transition between Vc and Ve (light- and carboxylation-limited photosynthesis)
    % useTLforC3  % boolean              whether to enable low-temperature attenuation of Vcmax in C3 plants (its always on for C4 plants)
    % po0         %  double            Kp,0 (Kp,max) = Fv/Fm (for curve fitting)
    % g_m         % mol/m2/s/bar      Mesophyll conductance (default: Infinity, i.e. no effect of g_m)

    % Note: always use the prescribed units. Temperature can be either oC or K
    % Note: input can be single numbers, vectors, or n-dimensional
    % matrices
    %
    % Output:
    % structure 'biochem_out' with the following elements:
    % A         % [umol/m2/s]           net assimilation rate of the leaves
    % Cs        % [umol/m3]             CO2 concentration in the boundary layer
    % eta0      % []                    fluorescence as fraction of dark
    %                                   ...adapted (fs/fo)
    % rcw       % [s m-1]               stomatal resistance
    % qE        % []                    non photochemical quenching
    % fs        % []                    fluorescence as fraction of PAR
    % Ci        % [umol/m3]             internal CO2 concentration
    % Kn        % []                    rate constant for excess heat
    % fo        % []                    dark adapted fluorescence (fraction of aPAR)
    % fm        % []                    light saturated fluorescence (fraction of aPAR)
    % qQ        % []                    photochemical quenching
    % Vcmax     % [umol/m2/s]           carboxylation capacity after
    %                                   ... temperature correction
    A = [];
    Ag = [];
    Vc = [];
    Vs = [];
    Ve = [];
    CO2_per_electron = [];
    if nargin < 2
        Ci_input = [];
    end
    %% input
    % environmental
    if isfield(biochem_in, 'Cs')
        %   assert(all(biochem_in.Cs(:) >=0), 'Negative CO2 (Cs) is not allowed!');
        Cs         = max(0, biochem_in.Cs); % just make sure we don't deal with illegal values
    else
        % if Cs is missing, Ci must have been supplied. Forcing Cs = NaN invalidates rcw & gs.
        Cs         = NaN; % biochem_in.Ci;
    end
    Q             = biochem_in.Q;
    % assert(all(Q(:) >=0), 'Negative light is not allowed!');
    if all(Q(:) >= 0)
    else
        Q = abs(Q);
    end

    assert(all(isreal(Q(:))), 'Complex-values are not allowed for PAR!');
    % assert(all(Cs(:) >=0), 'Negative CO2 concentration is not allowed!');
    if all(isreal(Cs(:)))
    else
        Cs = real(Cs);
    end

    if all(Cs(:) >= 0)
    else
        Cs = abs(Cs);
    end
    % assert(all(isreal(Cs(:))), 'Complex-values are not allowed for CO2 concentration!');

    T             = biochem_in.T + 273.15 * (biochem_in.T < 200); % convert temperatures to K if not already
    eb            = biochem_in.eb;
    O             = biochem_in.O;
    p             = biochem_in.p;
    ei            = biochem_in.ei;
    phwsf         = biochem_in.phwsf;
    plantHydraulics = biochem_in.plantHydraulics;

    gsMethod      = biochem_in.gsMethod;
    g1Med         = biochem_in.g1Med;
    g0Med         = biochem_in.g0Med;

    % physiological
    Type          = biochem_in.Type;
    if isfield(biochem_in, 'Vcmax25')
        % new field names
        Vcmax25       = biochem_in.Vcmax25;
        BallBerrySlope = 9;
        if isfield(biochem_in, 'BallBerrySlope')  % with g_m and Ci specified, we don't pass BBslope
            BallBerrySlope = biochem_in.BallBerrySlope;
        end
        RdPerVcmax25       = biochem_in.RdPerVcmax25;
    else
        % old field names: Vcmo, m, Rdparam
        Vcmax25       = biochem_in.Vcmo;
        BallBerrySlope = biochem_in.m;
        RdPerVcmax25       = biochem_in.Rdparam;
    end
    BallBerry0 = 0.01; % default value
    if isfield(biochem_in, 'BallBerry0')
        BallBerry0 = biochem_in.BallBerry0;
    end
    if isfield(biochem_in, 'effcon')
        effcon        = biochem_in.effcon;
    elseif strcmpi('C3', Type)
        effcon =  1 / 5;
    else
        effcon = 1 / 6; % C4
    end

    % Mesophyll conductance: by default we ignore its effect
    %  so Cc = Ci - A/gm = Ci
    g_m = Inf;
    if isfield(biochem_in, 'g_m')
        g_m = biochem_in.g_m * 1e6; % convert from mol to umol
    end

    % SCOPE provides PAR as APAR, so default (for SCOPE) = 1
    %    The curve-fitting GUI may not be providing APAR and should therefore explicitly set fPAR
    fPAR = 1;  % fraction of incident light that is absorbed by the leaf
    if isfield(biochem_in, 'fPAR')
        fPAR = biochem_in.fPAR;
    end

    % physiological options
    tempcor       = biochem_in.tempcor;
    stressfactor  = biochem_in.stressfactor;
    % model_choice  = biochem_in.Fluorescence_model;
    if isfield(biochem_in, 'useTLforC3')
        useTLforC3   = biochem_in.useTLforC3;
    else
        useTLforC3 = false;
    end

    % fluoeresence
    if isfield(biochem_in, 'Knparams')
        Knparams      = biochem_in.Knparams;
    elseif isfield(biochem_in, 'Kn0')
        Knparams = [biochem_in.Kn0, biochem_in.Kn_alpha, biochem_in.Kn_beta];
    elseif isfield(biochem_in, 'Fluorescence_model') && biochem_in.Fluorescence_model == 0
        % default drought values:
        Knparams = [5.01, 1.93, 10];
    else
        % default general values (cotton dataset)
        Knparams = [2.48, 2.83, 0.114];
    end

    if isfield(biochem_in, 'po0')
        po0 = biochem_in.po0;
    else
        po0 = [];
    end

    % physiological temperature parameters: temperature sensitivities of Vcmax, etc
    if isfield(biochem_in, 'Tparams')
        Tparams = biochem_in.Tparams;
        slti        = Tparams(1);
        shti        = Tparams(2);
        Thl         = Tparams(3);
        Thh         = Tparams(4);
        Trdm        = Tparams(5);
    else
        slti        = biochem_in.slti;
        shti        = biochem_in.shti;
        Thl         = biochem_in.Thl;
        Thh         = biochem_in.Thh;
        Trdm        = biochem_in.Trdm;
    end

    %  NOTE: kpep (kp), atheta parameters in next section

    %% parameters (at optimum temperature)
    Tref        = 25 + 273.15;        % [K]           absolute temperature at 25 oC

    Kc25       = 350;              % [ubar]        kinetic coefficient (Km) for CO2 (Von Caemmerer and Furbank, 1999)
    Ko25       = 450;              % [mbar]        kinetic coeeficient (Km) for  O2 (Von Caemmerer and Furbank, 1999)
    spfy25     = 2600;      %  specificity (tau in Collatz e.a. 1991)
    %     This is, in theory, Vcmax/Vomax.*Ko./Kc, but used as a separate parameter

    Kpep25       = (Vcmax25 / 56) * 1E6;      % []      (C4) PEPcase rate constant for CO2, used here: Collatz et al: Vcmax25 = 39 umol m-1 s-1; kp = 0.7 mol m-1 s-1.
    if isfield(biochem_in, 'Kpep25')
        Kpep25 = biochem_in.kpep;
    elseif isfield(biochem_in, 'kp')
        Kpep25 = biochem_in.kp;
    end
    if isfield(biochem_in, 'atheta')
        atheta = biochem_in.atheta;
    else
        atheta      = 0.8;
    end

    % electron transport and fluorescence
    Kf          = 0.05;             % []            rate constant for fluorescence
    % Kd          = 0.95;             % []           rate constant for thermal deactivation at Fm
    Kd          = max(0.8738,  0.0301 * (T - 273.15) + 0.0773);
    Kp          = 4.0;              % []            rate constant for photochemisty

    % note:  rhoa/Mair = L/mol (with the current units) = 24.039 L/mol
    %    and  V/n = RT/P ==>  T = 292.95 K @ 1 atm (using R_hPa = 83.144621; 1 atm = 1013.25 hPa)
    %   ??!!  These values are used only for rcw, however.
    rhoa        = 1.2047;           % [kg m-3]       specific mass of air
    Mair        = 28.96;            % [g mol-1]      molecular mass of dry air

    %% convert all to bar: CO2 was supplied in ppm, O2 in permil, and pressure in mBar
    ppm2bar =  1e-6 .* (p .* 1E-3);
    Cs          = Cs .* ppm2bar;
    O           = (O * 1e-3) .* (p .* 1E-3) .* strcmp('C3', Type);    % force O to be zero for C4 vegetation (this is a trick to prevent oxygenase)
    Kc25       = Kc25 * 1e-6;
    Ko25       = Ko25 * 1e-3;

    %% temperature corrections
    qt          = 0.1 * (T - Tref) * tempcor;  % tempcorr = 0 or 1: this line dis/enables all Q10 operations
    TH          = 1 + tempcor * exp(shti .* (T   - Thh));
    % TH          = 1 + tempcor* exp((-220E3+703*T)./(8.314*T));
    TL          = 1 + tempcor * exp(slti .* (Thl - T));

    QTVc   =  2.1; % Q10 base for Vcmax and Kc
    Kc     = Kc25 * exp(log(2.1) .* qt);
    Ko     = Ko25 * exp(log(1.2) .* qt);
    kpepcase = Kpep25 .* exp(log(1.8) .* qt);  % "pseudo first order rate constant for PEP carboxylase WRT pi (Collatz e.a. 1992)

    % jak 2014-12-04: Add TL for C3 as well, works much better with our cotton temperature dataset (A-T)
    if strcmpi(Type, 'C3') && ~useTLforC3
        Vcmax = Vcmax25 .* exp(log(QTVc) .* qt) ./ TH;% * sfactor;
    else
        Vcmax = Vcmax25 .* exp(log(QTVc) .* qt) ./ (TL .* TH);% * sfactor;
    end

    % check it PHS open
    if plantHydraulics          % PHS open, use phwsf
        Vcmax = Vcmax .* phwsf;
    else                           % PHS close, use sfactor
        Vcmax = Vcmax .* sfactor;
    end

    % specificity (tau in Collatz e.a. 1991)
    spfy        = spfy25 * exp(log(0.75) .* qt);

    % "Dark" Respiration
    Rd          = RdPerVcmax25 * Vcmax25 .* exp(log(1.8) .* qt) ./ (1 + exp(1.3 * (T - Trdm)));

    %% calculation of potential electron transport rate
    if isempty(po0)  % JAK 2015-12: User can specify po0 from measured data
        po0     = Kp ./ (Kf + Kd + Kp);         % maximum dark photochemistry fraction, i.e. Kn = 0 (Genty et al., 1989)
    end
    Je          = 0.5 * po0 .* Q .* fPAR;          % potential electron transport rate (JAK: add fPAR)

    %% calculation of the intersection of enzyme and light limited curves
    % this is the original Farquhar model
    Gamma_star         = 0.5 .* O ./ spfy; % [bar]       compensation point in absence of Rd (i.e. gamma*) [bar]

    % Don't bother with...
    % Gamma: CO2 compensation point including Rd: solve Ci for 0 = An = Vc - Rd,
    %  assuming Vc dominates at CO2 compensation point according to Farquar 1980. (from Leuning 1990)
    %  This gives a realistic value for C4 as well (in which O and Gamma_star = 0)
    % Gamma = (Gamma_star .* Vcmax  +   Rd .* MM_consts)  ./ (Vcmax - Rd); % C3
    if strcmp(Type, 'C3')
        MM_consts = (Kc .* (1 + O ./ Ko)); % Michaelis-Menten constants
        Vs_C3 = (Vcmax25 / 2) .* exp(log(1.8) .* qt);
        %  minimum Ci (as fraction of Cs) for BallBerry Ci. (If Ci_input is present we need this only as a placeholder for the function call)
        minCi = 0.3;
    else
        % C4
        MM_consts = 0; % just for formality, so MM_consts is initialized
        Vs_C3 = 0;     %  the same
        minCi = 0.1;  % C4
    end

    %% calculation of Ci (internal CO2 concentration)
    RH = min(1, eb ./ equations.satvap(T - 273.15)); % jak: don't allow "supersaturated" air! (esp. on T curves)
    VPD_l2b = max(0.0001, ei-eb);
    warnings = [];

    fcount = 0; % the number of times we called computeA()

    switch gsMethod
        case 1 % BallBerry's stomatal conductance
            if  ~isempty(Ci_input)
                Ci = Ci_input; % in units of bar.
                if any(Ci_input > 1)
                    % assume Ci_input is in units of ppm. Convert to bar
                    Ci = Ci_input .* ppm2bar;
                end
                A =  computeA(Ci);
            
            elseif all(BallBerry0 == 0)
                % b = 0: no need to iterate:
                Ci = BallBerry(Cs, RH, [], BallBerrySlope, BallBerry0, minCi);
                A =  computeA(Ci);
            
            else
                % compute Ci using iteration (JAK)
                % it would be nice to use a built-in root-seeking function but fzero requires scalar inputs and outputs,
                % Here I use a fully vectorized method based on Brent's method (like fzero) with some optimizations.
                tol = 1e-6;  % 0.1 ppm more-or-less
                % Setting the "corner" argument to Gamma may be useful for low Ci cases, but not very useful for atmospheric CO2, so it's ignored.
                %                     (fn,                           x0, corner, tolerance)
                Ci = equations.fixedp_brent_ari(@(x) Ci_next(x, Cs, RH, minCi), Cs, [], tol); % [] in place of Gamma: it didn't make much difference
                % NOTE: A is computed in Ci_next on the final returned Ci. fixedp_brent_ari() guarantees that it was done on the returned values.
                % A =  computeA(Ci);
            end

        case 2 % Medlyn's stomatal conductance
            if  ~isempty(Ci_input) 
                Ci = Ci_input; % in units of bar.
                if any(Ci_input > 1)
                    % assume Ci_input is in units of ppm. Convert to bar
                    Ci = Ci_input .* ppm2bar;
                end
                A =  computeA(Ci);
    
            elseif all(g0Med == 0)
                % b = 0: no need to iterate:
                Ci = Medlyn(Cs, A, VPD_l2b, g1Med, g0Med, minCi);
                A =  computeA(Ci);
    
            else
                % compute Ci using iteration (JAK)
                % it would be nice to use a built-in root-seeking function but fzero requires scalar inputs and outputs,
                % Here I use a fully vectorized method based on Brent's method (like fzero) with some optimizations.
                tol = 1e-7;  % 0.1 ppm more-or-less
                % Setting the "corner" argument to Gamma may be useful for low Ci cases, but not very useful for atmospheric CO2, so it's ignored.
                %                     (fn,                           x0, corner, tolerance)
                Ci = equations.fixedp_brent_ari(@(x) Ci_next_ME(x, Cs, VPD_l2b, minCi), Cs, [], tol); % [] in place of Gamma: it didn't make much difference
                %NOTE: A is computed in Ci_next on the final returned Ci. fixedp_brent_ari() guarantees that it was done on the returned values.
                %A =  computeA(Ci);
            end
    end

    %% Test-function for iteration
    %   (note that it assigns A in the function's context.)
    %   As with the next section, this code can be read as if the function body executed at this point.
    %    (if iteration was used). In other words, A is assigned at this point in the file (when iterating).
    function [err, Ci_out] = Ci_next_BB(Ci_in, Cs, RH, minCi)
        % compute the difference between "guessed" Ci (Ci_in) and Ci computed using BB after computing A
        A = computeA(Ci_in);  % A: ppm
        A_bar = A .* ppm2bar; % A: bar
        Ci_out = BallBerry(Cs, RH, A_bar, BallBerrySlope, BallBerry0, minCi); %[Ci_out, gs]  Ci: bar
       
        err = Ci_out - Ci_in; % f(x) - x
    end
    function [err, Ci_out] = Ci_next_ME(Ci_in, Cs, VPD_l2b, minCi)
        % compute the difference between "guessed" Ci (Ci_in) and Ci computed using BB after computing A
        A = computeA(Ci_in);  % A: ppm
        A_bar = A .* ppm2bar; % A: bar
        Ci_out = Medlyn(Cs, A_bar, VPD_l2b,g1Med, g0Med, minCi); %[Ci_out, gs]  Ci: bar
       
        err = Ci_out - Ci_in; % f(x) - x
    end
    %% Compute Assimilation.
    %  Note: even though computeA() is written as a separate function,
    %    the code is, in fact, executed exactly this point in the file (i.e. between the previous if clause and the next section
    function [A, biochem_out] = computeA(Ci)
        % global: Type, Vcmax, Gamma_star, MM_consts, Vs_C3, effcon, Je, atheta, Rd    %Kc, O, Ko, Vcmax25, qt

        if strcmpi('C3', Type)
            % [Ci, gs] = BallBerry(Cs, RH, A_bar, BallBerrySlope, BallBerry0, 0.3, Ci_input);
            % effcon      = 0.2;
            % without g_m:
            Vs          = Vs_C3; % = (Vcmax25/2) .* exp(log(1.8).*qt);    % doesn't change on iteration.
            if any(g_m < Inf)
                % with g_m:
                Vc = sel_root(1 ./ g_m, -(MM_consts + Ci + (Rd + Vcmax) ./ g_m), Vcmax .* (Ci - Gamma_star + Rd ./ g_m), -1);
                Ve = sel_root(1 ./ g_m, -(Ci + 2 * Gamma_star + (Rd + Je .* effcon) ./ g_m), Je .* effcon .* (Ci - Gamma_star + Rd ./ g_m), -1);
                CO2_per_electron = Ve ./ Je;
            else
                Vc          = Vcmax .* (Ci - Gamma_star) ./ (MM_consts + Ci);  % MM_consts = (Kc .* (1+O./Ko)) % doesn't change on iteration.
                CO2_per_electron = (Ci - Gamma_star) ./ (Ci + 2 * Gamma_star) .* effcon;
                Ve          = Je .* CO2_per_electron;
            end
        else  % C4
            % [Ci, gs] = BallBerry(Cs, RH, A_bar, BallBerrySlope, BallBerry0, 0.1, Ci_input);
            Vc          = Vcmax;
            Vs          = kpepcase .* Ci;
            % effcon      = 0.17;                    % Berry and Farquhar (1978): 1/0.167 = 6
            CO2_per_electron = effcon; % note: (Ci-Gamma_star)./(Ci+2*Gamma_star) = 1 for C4 (since O = 0); this line avoids 0/0 when Ci = 0
            Ve          = Je .* CO2_per_electron;
        end

        % find the smoothed minimum of Ve, Vc = V, then V, Vs
        %         [a1,a2]     = abc(atheta,-(Vc+Ve),Vc.*Ve);
        %         % select the min or max  depending on the side of the CO2 compensation point
        %         %  note that Vc, Ve < 0 when Ci < Gamma_star (as long as Q > 0; Q = 0 is also ok),
        %         %     so the original construction selects the value closest to zero.
        %         V           = min(a1,a2).*(Ci>Gamma_star) + max(a1,a2).*(Ci<=Gamma_star);
        %         [a1,a2]     = abc(0.98,-(V+Vs),V.*Vs);
        %         Ag          = min(a1,a2);
        V           = sel_root(atheta, -(Vc + Ve), Vc .* Ve, sign(-Vc)); % i.e. sign(Gamma_star - Ci)
        Ag          = sel_root(0.98, -(V + Vs), V .* Vs, -1);
        A           = Ag - Rd;

        if nargout > 1
            biochem_out.A = A;
            biochem_out.Ag = Ag;
            biochem_out.Vc = Vc;
            biochem_out.Vs = Vs;
            biochem_out.Ve = Ve;
            biochem_out.CO2_per_electron = CO2_per_electron;
        end
        fcount = fcount + 1; % # of times we called computeA

    end

    % (ppm2bar), A_bar
    % tic;
    % toc
    % fprintf('Ball-Berry converged in %d steps (largest_diff = %.4g)\n', counter, largest_diff/ mean(ppm2bar));
    %% Compute A, etc.

    % note: the following sets a bunch of "global" values in the nested function. Prob better to use [A biochem_out] = ....
    % A =  computeA(Ci);  % done above
    % % For debugging:
    % if any(A ~= computeA(Ci) & ~isnan(A))
    %     error('My algorithm didn''t work!');
    % end
    % [~, gs1] = BallBerry(Cs, RH, A .* ppm2bar, BallBerrySlope, BallBerry0, minCi, Ci);
    gs = 1.6 * A .* ppm2bar ./ (Cs - Ci);

    Ja          = Ag ./ CO2_per_electron;        % actual electron transport rate

    % stomatal resistance
    % old: rcw         = 0.625*(Cs-Ci)./A *rhoa/Mair*1E3  ./ ppm2bar; %  * 1e6 ./ p .* 1E3;
    % if BallBerry0 == 0  %if B-B intercept was specified, then we computed gs "correctly" above and don't need this.
    %     rcw(A<=0 & rcw~=0)   = 0.625*1E6;
    % end
    % rcw         = (1./gs) *rhoa/Mair*1E3  ./ ppm2bar; %  * 1e6 ./ p .* 1E3;
    rcw      =  (rhoa ./ (Mair * 1E-3)) ./ gs;

    %% fluorescence (Replace this part by Magnani or other model if needed)
    %ps          = po0 .* Ja ./ Je;               % this is the photochemical yield
    ps = po0;
    nanPs = isnan(ps);
    if any(nanPs)
        if numel(po0) == 1
            ps(nanPs) = po0;
        else
            ps(nanPs) = po0(nanPs);  % happens when Q = 0, so ps = po0 (other cases of NaN have been resolved)
        end
    end
    ps_rel   = max(0,  1 - ps ./ po0);       % degree of light saturation: 'x' (van der Tol e.a. 2014)
    
    if FluorescenceModelOption == 1
        [eta, qE, qQ, fs, fo, fm, fo0, fm0, Kn]    = Fluorescencemodel(ps, ps_rel, Kp, Kf, Kd, Knparams);
    else 
        [eta,qE,qQ,fs,fo,fm,fo0,fm0,Kn,J_PSII_o,q_PSII_o]    = Fluorescencemodel_MLROC(PAR,J_PSII,q_PSII,SIF_O,po0, Kp,Kf,Kd);
    end
    
    Kpa         = ps ./ fs * Kf;

    %% convert back to ppm
    Cc = [];
    if ~isempty(g_m)
        Cc    = (Ci - A / g_m) ./ ppm2bar;
    end
    Ci          = Ci  ./ ppm2bar;
    % Cs          = Cs  ./ ppm2bar;

    %% Collect outputs

    biochem_out.A       = A;
    biochem_out.Ag       = Ag;
    biochem_out.Ci      = Ci;
    if ~isempty(Cc)
        biochem_out.Cc = Cc;
    end
    biochem_out.rcw     = rcw;
    biochem_out.gs      =  gs;
    %  this would be the same if we apply the rcw(A<=0) cutoff:
    % biochem_out.gs      = BallBerrySlope.*A.*RH./Cs; % mol/m2/s no intercept term.
    biochem_out.RH      =  RH;
    biochem_out.warnings = warnings;
    biochem_out.fcount = fcount;  % the number of times we called computeA()
    % fprintf('fcount = %d\n', fcount);

    biochem_out.Vcmax   = Vcmax;
    biochem_out.Vc = Vc;  % export the components of A for diagnostic charts
    biochem_out.Ve = Ve;
    biochem_out.Vs = Vs;
    biochem_out.Rd = Rd;

    biochem_out.Ja      = Ja;
    biochem_out.ps      = ps; % photochemical yield
    biochem_out.ps_rel  = ps_rel;   % degree of ETR saturation 'x' (van der Tol e.a. 2014)

    % fluoresence outputs:
    % note on Kn: technically, NPQ = (Fm - Fm')/Fm' = Kn/(Kf + Kd);
    %     In this model Kf + Kd is close to but NOT equal to 1 @ 25C Kf + Kd = 0.8798
    %     vdT 2013 fitted Kn assuming NPQ = Kn, but maybe we shouldn't?
    biochem_out.Kd      = Kd;  % K_dark(T)
    biochem_out.Kn      = Kn;  % K_n(x);  x = 1 - ps/p00 == 1 - Ja/Je
    biochem_out.NPQ     = Kn ./ (Kf + Kd); % why not be honest!
    biochem_out.Kf      = Kf;  % Kf = 0.05 (const)
    biochem_out.Kp0     = Kp;  % Kp = 4.0 (const): Kp, max
    biochem_out.Kp      = Kpa; % Kp,actual
    biochem_out.eta     = eta;
    biochem_out.qE      = qE;
    biochem_out.fs      = fs;  % keep this for compatibility with SCOPE
    biochem_out.ft      = fs;  % keep this for the GUI ft is a synonym for what we're calling fs
    biochem_out.SIF     = fs .* Q;
    biochem_out.fo0     = fo0;
    biochem_out.fm0     = fm0;
    biochem_out.fo      = fo;
    biochem_out.fm      = fm;
    biochem_out.Fm_Fo    = fm ./ fo;  % parameters used for curve fitting
    biochem_out.Ft_Fo    = fs ./ fo;  % parameters used for curve fitting
    biochem_out.qQ      = qQ;
    biochem_out.VPD_l2b  = mean(VPD_l2b,'all');
    return

end  % end of function biochemical

%% quadratic formula, root of least magnitude
function x = sel_root(a, b, c, dsign)
    %  sel_root - select a root based on the fourth arg (dsign = discriminant sign)
    %    for the eqn ax^2 + bx + c,
    %    if dsign is:
    %       -1, 0: choose the smaller root
    %       +1: choose the larger root
    %  NOTE: technically, we should check a, but in biochemical, a is always > 0
    if a == 0  % note: this works because 'a' is a scalar parameter!
        x      = -c ./ b;
    else
        if any(dsign == 0)
            dsign(dsign == 0) = -1; % technically, dsign==0 iff b = c = 0, so this isn't strictly necessary except, possibly for ill-formed cases)
        end
        % disc_root = sqrt(b.^2 - 4.*a.*c); % square root of the discriminant (doesn't need a separate line anymore)
        %  in MATLAB (2013b) assigning the intermediate variable actually slows down the code! (~25%)
        x = (-b + dsign .* sqrt(b.^2 - 4 .* a .* c)) ./ (2 .* a);
    end
end % of min_root of quadratic formula

%% Ball Berry Model
function [Ci, gs] = BallBerry(Cs, RH, A, BallBerrySlope, BallBerry0, minCi, Ci_input)
    %  Cs  : CO2 at leaf surface
    %  RH  : relative humidity
    %  A   : Net assimilation in 'same units of CO2 as Cs'/m2/s
    % BallBerrySlope, BallBerry0,
    % minCi : minimum Ci as a fraction of Cs (in case RH is very low?)
    % Ci_input : will calculate gs if A is specified.
    if nargin > 6 && ~isempty(Ci_input)
        % Ci is given: try and compute gs
        Ci = Ci_input;
        gs = [];
        if ~isempty(A) && nargout > 1
            gs = gsFun_BB(Cs, RH, A, BallBerrySlope, BallBerry0);
        end
    elseif all(BallBerry0 == 0) || isempty(A)
        % EXPLANATION:   *at equilibrium* CO2_in = CO2_out => A = gs(Cs - Ci) [1]
        %  so Ci = Cs - A/gs (at equilibrium)                                 [2]
        %  Ball-Berry suggest: gs = m (A RH)/Cs + b   (also at equilib., see Leuning 1990)
        %  if b = 0 we can rearrange B-B for the second term in [2]:  A/gs = Cs/(m RH)
        %  Substituting into [2]
        %  Ci = Cs - Cs/(m RH) = Cs ( 1- 1/(m RH)  [ the 1.6 converts from CO2- to H2O-diffusion ]
        Ci      = max(minCi .* Cs,  Cs .* (1 - 1.6 ./ (BallBerrySlope .* RH)));
        gs = [];
    else
        %  if b > 0  Ci = Cs( 1 - 1/(m RH + b Cs/A) )
        % if we use Leuning 1990, Ci = Cs - (Cs - Gamma)/(m RH + b(Cs - Gamma)/A)  [see def of Gamma, above]
        % note: the original B-B units are A: umol/m2/s, ci ppm (umol/mol), RH (unitless)
        %   Cs input was ppm but was multiplied by ppm2bar above, so multiply A by ppm2bar to put them on the same scale.
        %  don't let gs go below its minimum value (i.e. when A goes negative)
        gs = gsFun_BB(Cs, RH, A, BallBerrySlope, BallBerry0);
        Ci = max(minCi .* Cs,  Cs - 1.6 * A ./ gs);
    end

end % function

function gs = gsFun_BB(Cs, RH, A, BallBerrySlope, BallBerry0)
    % add in a bit just to avoid div zero. 1 ppm = 1e-6 (note since A < 0 if Cs ==0, it gives a small gs rather than maximal gs
    gs = max(BallBerry0,  BallBerrySlope .* A .* RH ./ (Cs + 1e-9)  + BallBerry0);
    % clean it up:
    % gs( Cs == 0 ) = would need to be max gs here;  % eliminate infinities
    gs(isnan(Cs)) = NaN;  % max(NaN, X) = X  (MATLAB 2013b) so fix it here
end

%% Medlyn gs
function [Ci, gs] = Medlyn(Cs, A, VPD_l2b, g1Med, g0Med, minCi, Ci_input)
    %  Cs  : CO2 at leaf surface
    %  A   : Net assimilation in 'same units of CO2 as Cs'/m2/s
    %  VPD_l2b: vapour pressure deficit from leaf to leaf boundary  [mbar or hPa]
    % BallBerrySlope, BallBerry0: Medlynslope, Medlyn0
    % minCi : minimum Ci as a fraction of Cs (in case RH is very low?)
    % Ci_input : will calculate gs if A is specified.
    if nargin > 6 && ~isempty(Ci_input)
        % Ci is given: try and compute gs
        Ci = Ci_input;
        gs = [];
        if ~isempty(A) && nargout > 1
            gs = gsFun_ME(Cs,  A, VPD_l2b, g1Med, g0Med);
        end
    elseif all(g0Med == 0) || isempty(A)
        % EXPLANATION:   *at equilibrium* CO2_in = CO2_out => A = gs(Cs - Ci) [1]
        %  so Ci = Cs - A/gs (at equilibrium)                                 [2]
        %  Medlyn suggest: gs = g0+(1+g1/VPD^0.5)* A/Cs  ( see. Medlyn 2010 GCB)
    %     %  if g0 = 0 we can rearrange B-B for the second term in [2]:

    %     %  Ci = Cs - Cs/(VPD^0.5/(m+VPD^0.5)) = Cs ( 1- 1/(VPD^0.5/(m+VPD^0.5)  [ the 1.6 converts from CO2- to H2O-diffusion ]
        Ci      = max(minCi .* Cs,  Cs.*(1-(1.6.*VPD_l2b.^0.5./(g1Med + VPD_l2b.^0.5))));
        gs = [];
    else
    %     %  if b > 0  Ci = Cs( 1 - 1/(m RH + b Cs/A) )
    %     % if we use Leuning 1990, Ci = Cs - (Cs - Gamma)/(m RH + b(Cs - Gamma)/A)  [see def of Gamma, above]
    %     % note: the original B-B units are A: umol/m2/s, ci ppm (umol/mol), RH (unitless)
    %     %   Cs input was ppm but was multiplied by ppm2bar above, so multiply A by ppm2bar to put them on the same scale.
    %     %  don't let gs go below its minimum value (i.e. when A goes negative)
        gs = gsFun_ME(Cs, A,  VPD_l2b, g1Med, g0Med);
        Ci = max(minCi .* Cs,  Cs - 1.6 * A./gs) ;
    end

end % function

function gs = gsFun_ME(Cs, A, VPD_l2b, g1Med, g0Med)
    % add in a bit just to avoid div zero. 1 ppm = 1e-6 (note since A < 0 if Cs ==0, it gives a small gs rather than maximal gs
    gs = max(g0Med,  1.6.*(1+(g1Med./ VPD_l2b .^ 0.5)) .* A ./ (Cs+1e-9)  + g0Med );

    %gs( Cs == 0 ) = would need to be max gs here;  % eliminate infinities
    gs( isnan(Cs) ) = NaN;  % max(NaN, X) = X  (MATLAB 2013b) so fix it here
end

%% Fluorescence model
function [eta, qE, qQ, fs, fo, fm, fo0, fm0, Kn] = Fluorescencemodel(ps, x, Kp, Kf, Kd, Knparams)
    % note: x isn't strictly needed as an input parameter but it avoids code-duplication (of po0) and it's inherent risks.

    Kno = Knparams(1);
    alpha = Knparams(2);
    beta = Knparams(3);

    % switch model_choice
    %     case 0, % drought
    %         Kno = 5.01;
    %         alpha = 1.93;
    %         beta = 10;
    %         %Kn          = (6.2473 * x - 0.5944).*x; % empirical fit to Flexas' data
    %         %Kn          = (3.9867 * x - 1.0589).*x;  % empirical fit to Flexas, Daumard, Rascher, Berry data
    %     case 1, healthy (cotton)
    %         Kno = 2.48;
    %         alpha = 2.83;
    %         beta = 0.114;
    %         %p = [4.5531;8.5595;1.8510];
    %         %Kn   = p(1)./(p(3)+exp(-p(2)*(x-.5)));
    % end

    % using exp(-beta) expands the interesting region between 0-1
    % beta = exp(-beta);
    x_alpha = exp(log(x) .* alpha); % this is the most expensive operation in this fn; doing it twice almost doubles the time spent here (MATLAB 2013b doesn't optimize the duplicate code)
    Kn = Kno * (1 + beta) .* x_alpha ./ (beta + x_alpha);

    % Kn          = Kn .* Kd/0.8738;          % temperature correction of Kn similar to that of Kd

    fo0         = Kf ./ (Kf + Kp + Kd);        % dark-adapted fluorescence yield Fo,0
    fo          = Kf ./ (Kf + Kp + Kd + Kn);     % light-adapted fluorescence yield in the dark Fo
    fm          = Kf ./ (Kf   + Kd + Kn);     % light-adapted fluorescence yield Fm
    fm0         = Kf ./ (Kf   + Kd);        % dark-adapted fluorescence yield Fm
    fs          = fm .* (1 - ps);            % steady-state (light-adapted) yield Ft (aka Fs)
    eta         = fs ./ fo0;
    qQ          = 1 - (fs - fo) ./ (fm - fo);    % photochemical quenching
    qE          = 1 - (fm - fo) ./ (fm0 - fo0);  % non-photochemical quenching

    % eta         = eta*(1+5)/5 - 1/5;     % this corrects for 29% PSI contribution in PAM data, but it is quick and dirty correction that needs to be improved in the next

end

%% Function MLROC
function [J_PSII, q_PSII] = MLROC(biochem_in)
    % Parameters for MLROC
    % Estimate q_PSII
    % q_PSII:    [] the fraction of open PSII reaction center
    % Select parameters for C3 or C4
    Type = biochem_in.Type;
    if strcmp(Type, 'C3')
    % [a_PSII, b_PSII] = [0.80+-0.13,(0.95+-0.24)*e-3] for C3 plants
      [a_PSII, b_PSII] = [0.80,0.95*e-3]; 
    else
    % [a_PSII, b_PSII] = [0.83+-0.12,(0.63+-0.09)*e-3] for C4 plants
      [a_PSII, b_PSII] = [0.83,0.63*e-3];
    end
    %%%%% q_PSII = a_PSII * exp(-b_PSII*PAR) (eq.5, Han et al., 2022, nph) 
    PAR = biochem_in.PAR;
    q_PSII = a_PSII .* exp(-b_PSII .* PAR);
    %%%%% Estimate J_PSII
    %  J_PSII:   [μmol m−2 s−1] the linear electron transport rate from PSII to PSI
    %  Parameters [Umop, R1, R2, q_r, a_q, b_s, c_s, E_T] for different PFTs
    %%%%% J_PSII =  (2*Umop*f_T*f_s*f_q*(q_r - q_PSII)*q_PSII) / (R1 + 2*R2*f_s*f_q)*q_PSII + q_r)
    %             % (eq.25, Gu et al., 2023, PCE)
    
    % Retrieve parameters from function MLROCparameters
    % 9 Species are included, s1-s9
    [p1,p2,p3,p4,p5,p6,p7,p8,p9]            =   MLROC_struct.PFT;
    [c1,c2,c3,c4,c5,c6,c7,c8,c9]            =   MLROC_struct.C3C4;
    [s1,s2,s3,s4,s5,s6,s7,s8,s9]            =   MLROC_struct.Species;
    [oc1,oc2,oc3,oc4,oc5,oc6,oc7,oc8,oc9]   =   MLROC_struct.OCparams;
    % each oc* contains 7 records of parameters [U R1 R2 qr aq bs cs] for each Species
    
    %%%%% needs to decide which PFT C3/C4 parameter set to use
    %%%%% [Umop, R1, R2, q_r, a_q, b_s, c_s] = MLROCparameters(PFT, C3C4, Species)
    oc1     = MLROC_struct.OCparams;
    Umop    = oc1(1);
    R1      = oc1(2);
    R2      = oc1(3);
    q_r     = oc1(4);
    a_q     = oc1(5);
    b_s     = oc1(6);
    c_s     = oc1(7);
    
    % f_T:      [-] the standardized temperature response function of electron transport in proteins
    %           according to the Marcus theory
    %%%%%          f_T = sqrt(To/T)*exp(E_T*(1/To - 1/T)), (eq. 19, Gu et al., 2023, PCE)
    %           E_T = (lambda + delGo)^2/(4*lambda*k_B)
    
    nelectrons = 2;     % two electrons are needed to reduce Q_B (the loosely bound plastoquinone)
    lambda    = 112000;   %[J mol-1], reorganisation energy for the intramolecular electron transfer
                        % between the reduced type 1 copper site and the peroxy intermediate of the trinuclear cluster in
                        % the multicopper oxidase CueO calculated  at the combined quantum
                        % mechanics and molecular mechanics (QM/MM) level, based on molecular dynamics
                        % simulations with tailored potentials for the two copper sites.
                        % (Hu et al., 2011 J Phys. Chem. B, reorganization energy of electron transport)
    %%%%% added, ZS 2023-09-05
    %%%%%    const.Faraday   = 96485.3321233100184; % [C mol-1]     Faraday constant
    %%%%%    const.k_B       = 1.380649E-23;         % [J k-1]       Boltzmann constant
    %%%%% Faraday      = const.Faraday    % [C mol-1]  Faraday constant (should be introduced in constants.m)
    %%%%% k_B          = const.k_B        % [J K-1]    Boltzmann constant
    %%%%% Avogardro    = const.A          % [mol-1]    Constant of Avogadro
    
    Faraday     = 96485.3321233100184; % [C mol-1] Faraday constant (should be introduced in constants.m)
    k_B         = 1.380649E-23;        % [J k-1]   Boltzmann constant (should  be introduced in constants.m)
    Avogardro   = 6.02214E23;          % [mol-1]   Constant of Avogadro
    Ecell_o = -.32;      % [V = J C-1] standard redox potentials for NADP+/NADPH
    delGo  = -nelectrons * Faraday * Ecell_o;    % Gibbs free energy of activation 
    E_T    = (lambda + delGo)^2/(4 * lambda * k_B * Avogardro);
    
    To = Tref;         % [K] reference temperature (To =  273.15+25 K), same as Tref 
    %%%%% leaf temperature, input passed from ebal.m
    % below Tleaf = 290.15 for test value, same as T above
    Tleaf = 290.15;      % [k] leaf temperature, input from ebal.m
    
    %%Tleaf             = biochem_in.T + 273.15*(biochem_in.T<200); % convert temperatures to K if not already
    f_T = sqrt(To/Tleaf) .* exp(E_T .* (1/To - 1/Tleaf)); % (eq. 19, Gu et al., 2023, PCE)
    %           To, Tl: [k] the reference and leaf temperature (input from ebal.m),
    %                   To = 298.15 [K]
    %          
    
    % f_s:       [-] the light‐induced thylakoid swelling and shrinking function
    %%%%%          f_s = V_t/Vmax = 1/(1+c_s+exp(-b_s*aPAR)) 
    %%%%% aPAR needs to be passed from ebal.m
    aPAR = Q * fPAR; 
    f_s = 1/(1+c_s+exp(-b_s*aPAR)); 
    
    % f_q:      [-] the redox poise balance function between cytochrome b6f complex and photosystem II
    %%          f_q = (1+a_q)/(1+a_q*q_PSII)
    f_q = (1+a_q)/(1+a_q*q_PSII);
    
    %%%%% J_PSII =  (2*Umop*f_T*f_s*f_q*(q_r - q_PSII)*q_PSII) / (R1 + 2*R2*f_s*f_q)*q_PSII + q_r) (eq. 25, Gu_2023_PCE)
    J_PSII =  (2*Umop*f_T*f_s*f_q*(q_r - q_PSII)*q_PSII) / (R1 + 2*R2*f_s*f_q)*q_PSII + q_r);
    
    % Umop:     [μmol m−2 s−1] the maximum oxidation potential of free plastoquinone and plastoquinol 
    %                          by the cytochrome b6f complex, 
    %%%%%          Umop = u*[N_PQT]*[N_cytT]; 
    %           u:    : [μmol m−2 s-1] is the the second‐order rate constant for the oxidation of plastoquinol 
    %                   by the RieskeFeS protein of cytochrome b6f complex;
    %           N_PQT : [μmol m−2] the foliar concentration of the free plastoquinone and plastoquinol pool per unit leaf area
    %           N_cytT: [μmol m−2] the total foliar concentration of the cytochrome b6f complex, including both uninhibited
    %                   and inhibited complexes for linear electron transport per unit leaf area
    % 
    % f_T:      [-] the standardized temperature response function of electron transport in proteins
    %           according to the Marcus theory
    %%%%%         f_T = sqrt(To/T)*exp(E_T*(1/To - 1/T)), (eq. 19, Gu et al., 2023, PCE)
    %           To, T: [k] the reference and leaf temperature,
    %                   To = 298.15 [K]
    %%%%%         E_T = (lambda + delGo)^2/(4*lambda*k_B)
    %           E_T  :  E_T is a composite temperature sensitivity parameter (K) related to the
    %                   Gibbs free energy of activation. f_T = 1 for T = T0.
    %           lambda: [J] outer shell reorganization energy 
    %           delGo : [J] The Gibbs free energy of activation
    %
    % f_s       [-] the light‐induced thylakoid swelling and shrinking function
    %%%%%         f_s = V_t/Vmax = 1/(1+c_s+exp(-b_s*aPAR)) 
    %           V_t, Vmax: [m3] V_t is the volume of the thylakoid at a given set of environmental
    %           conditions and Vmax is the maximum achievable volume of a fully
    %           swollen thylakoid.
    %           c_s, b_s: parameters for a sigmoid fitting function, 
    %                     b_s controls how fast the thylakoid expands and 
    %                     c_s sets the maximum impact of macromolecular crowding on h_cyt. 
    %                     f_s equals 1/(1 + c_s) in the dark and
    %                     approaches 1 (V_t → Vmax) as PAR increases.
    %           aPAR:     [μmol m−2 s−1] absorbed photosynthetically active radiation (PAR)
    %
    % f_q:      [-] the redox poise balance function between cytochrome b6f complex and photosystem II
    %%%%%        f_q = (1+a_q)/(1+a_q*q_PSII)
    %           h_cyt: [-] fraction of cytochrome b6f complex available for linear electron transport
    %           f_q derived from h_cyt = N_cytL/N_cytT = f_q*q_PSII = (1+a_q)*q_PSII/(1+a_q*q_PSII) (eq. 14, Gu et al., 2023 PCE)
    %           a_q: a stoichiometry parameter determines how h_cyt varies with q_PSII.
    %           N_cytL: [μmol m−2] the foliar concentration of the cytochrome b6f complex available (uninhibited) 
    %                   for linear electron transport per unit leaf area
    %
    % q_r:      [-] the fraction of reversible photosystem II reaction centres
    %%%%%         q_r = ([O]+[C])/N_PSII, 
    %           qr denotes the fraction of the PSII reaction centres that are in the O (Open) or C (Closed) states, 
    %           that is, the reversible reaction centres, N_PSII=[O]+[C]+[I],
    %           [I] denotes the number of functionally inactive (irreversible) PSII reaction centres per unit leaf area.
    %           N_PSII: [μmol m−2] The foliar concentrations of total photosystem II reaction centres per unit leaf area
    %
    % R1 :      [] the first resistance of electron transport = rr/rd
    %           rd, rr: [m2 μmol−1 s−1]  the second‐order rate constant for the electron transfer 
    %                   from the reduced acceptor to PQ to form PQH2 (rd) and 
    %                   for the reverse reaction (rr), respectively
    % R2 :      [] the second resistance of electron transport = u_RFes*N_cytT/(rd*N_PSII)
    %           u_RFes: [m2 μmol−1 s−1] The second‐order rate constant for the oxidation of plastoquinol 
    %                   by the RieskeFeS protein of cytochrome b6f complex
    %
    % Parameters [Umop, R1, R2, q_r, a_q, b_s, c_s, E_T] for different PFTs
    % can be obtained from Table S4, Gu et al., 2023, PCE which are fitted to
    % gas exahnge and fluorescence measurments.

end

%% MLROC Fluorescence model
function [eta,qE,qQ,fs,fo,fm,fo0,fm0,Kn,J_PSII,q_PSII] = Fluorescencemodel_MLROC(PAR,J_PSII,q_PSII,SIF_O,po0, Kp,Kf,Kd)
  % MLROC can be used as a simple observation operator, because J_PSII and q_PSII 
  % can be updated based on observed SIF; 
  %
  % usage:   
  % SIF = (J_PSII ./ q_PSII) .* (1/po0 - 1) / (1+Kdf);             % (eq.21, Gu et al., 2019, nph)
  % delSIF = SIF_O - SIF; 
  % if abc(delSIF) > 0;  
  % SIF = SIF + delSIF; update SIF and then NPQ
  % NPQ = (beta * alpha .* PAR - J_PSII) / ((1+Kdf) .* SIF) - 1;   % (eq.20, Gu et al., 2019, nph)
  
  
  %%%% po0=Kp/(Kf+Kd+Kp)=0.8, for Kp=4, Kf=0.1, Kd=0.9, maximum photochemical yield 

%    Kno = Knparams(1);
%    alpha = Knparams(2);
%    beta = Knparams(3);

    % switch model_choice
    %     case 0, % drought 
    %         Kno = 5.01;
    %         alpha = 1.93;
    %         beta = 10;
    %         %Kn          = (6.2473 * x - 0.5944).*x; % empirical fit to Flexas' data
    %         %Kn          = (3.9867 * x - 1.0589).*x;  % empirical fit to Flexas, Daumard, Rascher, Berry data
    %     case 1, healthy (cotton)
    %         Kno = 2.48;
    %         alpha = 2.83;
    %         beta = 0.114;
    %         %p = [4.5531;8.5595;1.8510];
    %         %Kn   = p(1)./(p(3)+exp(-p(2)*(x-.5)));
    % end

    % using exp(-beta) expands the interesting region between 0-1
    %beta = exp(-beta);
    %x_alpha = exp(log(x).*alpha); % this is the most expensive operation in this fn; doing it twice almost doubles the time spent here (MATLAB 2013b doesn't optimize the duplicate code)
    %Kn = Kno * (1+beta).* x_alpha./(beta + x_alpha);
    
    % values for test, actual input from biochemical_MLROC
%    Kp=4; Kf=0.1; Kd=0.9; Kdf=Kd/Kf;
%    po0=Kp/(Kf+Kd+Kp);
%    PAR=800; J_PSII=199; q_PSII = 3/8;
    if J_PSII > 199
        J_PSII = 198; % We limit J_PSII to prevent negative NPQ
        q_PSII = J_PSII/PAR; % update q_PSII 
    end 
                     % the maximum observed J_PSII is 130+-9 [umol e^-1 m-2 s-1]
                     % in cyanobacteria (Masojidek et al., 2001, J Plankton Res.) 
        
    beta    = 0.5;  % fraction of aPAR (alpha*PAR) allocated to PSII
    alpha   = 0.83; % absorptance of PAR by green leaves, input from ebal.m
                    % alpha should be replaced by calcualted values
    %%%% MLR model
    SIF = (J_PSII ./ q_PSII) .* (1/po0 - 1) / (1+Kdf);             % (eq.21, Gu et al., 2019, nph)
    NPQ = (beta * alpha .* PAR - J_PSII) / ((1+Kdf) .* SIF) - 1;   % (eq.20, Gu et al., 2019, nph)
    Kn  = NPQ .* (Kd+Kf);                                           % eq.13, Gu etal., 2019, nph

    %Kn          = Kn .* Kd/0.8738;          % temperature correction of Kn similar to that of Kd

    fo0         = Kf./(Kf+Kp+Kd);        % dark-adapted fluorescence yield Fo,0
    fo          = Kf./(Kf+Kp+Kd+Kn);     % light-adapted fluorescence yield in the dark Fo
    fm          = Kf./(Kf   +Kd+Kn);     % light-adapted fluorescence yield Fm'
    fm0         = Kf./(Kf   +Kd);        % dark-adapted fluorescence yield Fm
   %ps          = po0.*Ja./Je;      % this is the photochemical yield
   %fs          = fm.*(1-ps);            % steady-state (light-adapted) yield Ft (aka Fs)
    fs          = fm.*(1-q_PSII);        % steady-state (light-adapted) yield Ft (aka Fs)
    eta         = fs./fo0;
    qQ          = 1-(fs-fo)./(fm-fo);    % photochemical quenching
    qE          = 1-(fm-fo)./(fm0-fo0);  % non-photochemical quenching

    %eta         = eta*(1+5)/5 - 1/5;     % this corrects for 29% PSI contribution in PAM data, but it is quick and dirty correction that needs to be improved in the next 

end

%% MLROC parameters for different plants
% we make sutrcture from Tabel S4
function [Umop, R1, R2, q_r, a_q, b_s, c_s] = MLROCparameters(PFT, C3C4, Species)

    %'VariableNames',["PFT" "C3C4"     "Species"            "OCparams"]
    %                 "PFT" "C3 or C4" "individual Species" 
    %                               [U R1 R2 qr aq bs cs] = "OC parameters"
    % 9 Species are included, *1-*9
    % Use: [p1,p2,p3,p4,p5,p6,p7,p8,p9]=MLROC_struct.PFT
    % Use: [c1,c2,c3,c4,c5,c6,c7,c8,c9]=MLROC_struct.C3C4
    % Use: [s1,s2,s3,s4,s5,s6,s7,s8,s9]=MLROC_struct.Species
    % Use: [oc1,oc2,oc3,oc4,oc5,oc6,oc7,oc8,oc9]=MLROC_struct.OCparams
    % each oc* contains 7 records of parameters [U R1 R2 qr aq bs cs] for each Species
    
    MLROC_table = table(categorical( ...
    ["CRO";"CRO";"CRO";"DBF";"DBF";"DBF";"DBF";"GRA";"CRO"]), ...
    categorical( ...
    [ "C3"; "C3"; "C3"; "C3"; "C3"; "C3"; "C3"; "C4"; "C4"]),...
    categorical( ...
    ["Solanum lycopersicum (tomato, C3)";...
    "Oryza sativa (rice, C3)";...
    "Gossypium hirsutum (cotton, C3)";...
    "Betula alleghaniensis (birch, deciduous tree)";...
    "Carya ovata (shagbark hickory, deciduous tree)";...
    "Juglans nigra (black walnut, deciduous tree)";...
    "Liquidambar styraciflua (sweet gum, deciduous tree)";...
    "Andropogon gerardii (big bluestem grass, C4)";...
    "Zea mays (Maize, C4)"]), ...
    [1714.1947 0.3111 0.0000 0.8598 -0.8017 0.0042 15.5232;...
      963.4558 0.5733 0.0000 0.7623 -0.5597 0.0024  7.2908;...
     1486.867  0.3988 0.0011 0.9480 -0.6342 0.0016  5.5211;...
     1189.025  0.4702 0.0000 0.8636 -0.6134	0.0014	6.8590;...
      981.3335 0.5668 0.0000 0.7805 -0.5548	0.0015	4.8562;...
     1312.615  0.4113 0.0000 0.8110 -0.7258	0.0021	5.5501;...
      846.8143 0.5016 0.0000 0.8906 -0.5597	0.0020	4.6041;...
     571.5778  0.4538 0.0000 0.9564 -0.5711 0.0021  4.5994;...
     726.9816  0.3761 0.0000 0.9196 -0.6785 0.0021  5.5157],...
    'VariableNames',["PFT" "C3C4" "Species" "OCparams"]);

    MLROC_struct = table2struct(MLROC_table);
    
    % Extact values from MLROC_struct
    % [U, R1, R2, qr, aq, bs, cs]=MLROC_struct.OCparams
    
    % Table S4 The values of parameters optimized for species shown in Fig. 7. 
    % U is in the unit of µmol m-2 s-1, bs is in the unit of µmol-1 m2 s, 
    % (ET is in the unit of K, calcualted with eq.20), and all other parameters are unitless. 
    %
    % Species                                             U	        R1	R2	    qr	    aq	    bs	    cs
    %Solanum lycopersicum (tomato, C3, CRO)	           1714.1947 0.3111	0.0000	0.8598	-0.8017	0.0042	15.5232
    %Oryza sativa (rice, C3, CRO)	                    963.4558 0.5733	0.0000	0.7623	-0.5597	0.0024	7.2908
    %Gossypium hirsutum (cotton, C3, CRO)              1486.867	 0.3988	0.0011	0.9480	-0.6342	0.0016	5.5211
    %
    %Betula alleghaniensis (birch, DBF)	               1189.025	 0.4702	0.0000	0.8636	-0.6134	0.0014	6.8590
    %Carya ovata (shagbark hickory, DBF)	            981.3335 0.5668	0.0000	0.7805	-0.5548	0.0015	4.8562
    %Juglans nigra (black walnut, DBF)	               1312.615	 0.4113	0.0000	0.8110	-0.7258	0.0021	5.5501
    %Liquidambar styraciflua (sweetgum, DBF)	        846.8143 0.5016	0.0000	0.8906	-0.5597	0.0020	4.6041
    %
    %Andropogon gerardii (big bluestem grass, C4, GRA)	571.5778 0.4538	0.0000	0.9564	-0.5711	0.0021	4.5994
    %Zea mays (Maize, C4, CRO)	                        726.9816 0.3761	0.0000	0.9196	-0.6785	0.0021	5.5157
    
    % each species can be selected if known
    % otherwise if PFT is knwon, average can be used for each PFT
    % lastly average can be made for C3 or C4, if only C3/C4 is provided.

end 

