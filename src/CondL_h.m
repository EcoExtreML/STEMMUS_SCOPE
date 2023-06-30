function [Theta_LL, Se, KfL_h, KfL_T, DTheta_LLh, hh, hh_frez, Theta_UU, DTheta_UUh, Theta_II, KL_h] = CondL_h(SoilVariables, Theta_r, Theta_s, Alpha, hh, hh_frez, h_frez, n, m, Ks, NL, Theta_L, h, KIT, TT, Thmrlefc, POR, SWCC, Theta_U, XCAP, Phi_s, RHOI, RHOL, Lamda, Imped, L_f, g, T0, TT_CRIT, Theta_II, KfL_h, KfL_T, KL_h, Theta_UU, Theta_LL, DTheta_LLh, DTheta_UUh, Se)

    % load Constants
    Constants = io.define_constants();

    % get soil constants for StartInit
    SoilConstants = io.getSoilConstants();
    hd = SoilConstants.hd;
    hm = SoilConstants.hm;

    Gama_hh = SoilVariables.Gama_hh;

    function theta = ThetaFunc1(gama_hh, theta_r, A, B, alpha, n, m)
        % for Theta_m, A = Theta_s, B = -1
        % for Theta_LL, A =  Theta_m, B = hh + hh_frez
        theta = gama_hh * theta_r + (A - gama_hh * theta_r) * (1 + abs(alpha * (B))^n)^m;
    end

    function DTheta = DThetaFunc1(theta_r, hh , hh_frez, hd, hm, alpha, n, m)
        A = (-theta_r) / (abs(hh + hh_frez) * log(abs(hd / hm))) * (1 - (1 + abs(alpha * (hh + hh_frez))^n)^(-m));
        B = alpha * n * m * (Theta_m - Gama_hh * theta_r);
        C = ((1 + abs(alpha * (hh + hh_frez))^n)^(-m - 1));
        D = (abs(alpha * (hh + hh_frez))^(n - 1));
        DTheta = A -  B * C * D;
    end

    function DTheta = DThetaFunc2(theta_r, theta_m, hh , hh_frez, alpha, n, m)
        A = (theta_m - theta_r) * alpha * n ;
        B =  abs(alpha * (hh( + hh_frez())^(n - 1) * (-m);
        C = (1 + abs(alpha * (hh( + hh_frez())^n)^(-m - 1);
        DTheta = A * B * C;
    end

    function DTheta = DThetaFunc3(Theta_LL, Theta_L, hh , hh_frez, h, h_frez)
        A = Theta_LL - Theta_L;
        B = hh + hh_frez - h - h_frez;
        DTheta = A / B;
    end

    SFCC = 1;  % TODO move to seetings
    MN = 0;
    for i = 1:NL
        for ND = 1:2
            MN = i + ND - 1;
            if SWCC == 1
                if SFCC == 1
                    if abs(hh(MN)) >= abs(hd)
                        Gama_hh(MN) = 0;
                    elseif abs(hh(MN)) >= abs(hm)
                        Gama_hh(MN) = log(abs(hd) / abs(hh(MN))) / log(abs(hd) / abs(hm));
                    else
                        Gama_hh(MN) = 1;
                    end
                    Theta_m(i) = ThetaFunc1(Gama_hh(MN), Theta_r(i), Theta_s(i), -1, Alpha(i), n(i), m(i));
                    if Theta_m(i) >= POR(i)
                        Theta_m(i) = POR(i);
                    elseif Theta_m(i) <= Theta_s(i)
                        Theta_m(i) = Theta_s(i);
                    end

                    if hh(MN) >= -1
                        Theta_UU(i, ND) = Theta_s(i);
                        DTheta_LLh(i, ND) = 0;
                        if (hh_frez(MN)) >= 0
                            Theta_LL(i, ND) = Theta_s(i);
                            DTheta_UUh(i, ND) = 0;
                            Se(i, ND) = 1;
                        else
                            if Thmrlefc
                                if (hh(MN) + hh_frez(MN)) <= hd
                                    Theta_LL(i, ND) = 0;
                                    DTheta_UUh(i, ND) = 0;
                                    Se(i, ND) = 0;
                                else
                                    Theta_LL(i, ND) = ThetaFunc1(Gama_hh(MN), Theta_r(i), Theta_m(i), (hh(MN) + hh_frez(MN)), Alpha(i), n(i), m(i));
                                    DTheta_UUh(i, ND) = DThetaFunc1(Theta_r(i), hh(MN) , hh_frez(MN), hd, hm, Alpha(i), n(i), m(i));
                                    Se(i, ND) = Theta_LL(i, ND) / POR(i);
                                end

                            else
                                if abs(hh(MN) - h(MN)) < 1e-3
                                    DTheta_UUh(i, ND) = DThetaFunc2(Theta_r(i), theta_m(i), hh(MN), hh_frez(MN), alpha(i), n(i), m(i));
                                else
                                    DTheta_UUh(i, ND) = DThetaFunc3(Theta_LL(i, ND), Theta_L(i, ND), hh(MN) , hh_frez(MN), h(MN), h_frez(MN));
                                end
                            end
                        end
                    else
                        if Thmrlefc
                            if Gama_hh(MN) == 0
                                Theta_UU(i, ND) = 0;
                                DTheta_LLh(i, ND) = 0;
                                if (hh(MN) + hh_frez(MN)) <= hd
                                    Theta_LL(i, ND) = 0;
                                    DTheta_UUh(i, ND) = 0;
                                    Se(i, ND) = 0;
                                else
                                    Theta_LL(i, ND) = ThetaFunc1(Gama_hh(MN), Theta_r(i), Theta_m(i), (hh(MN) + hh_frez(MN)), Alpha(i), n(i), m(i));
                                    DTheta_UUh(i, ND) = DThetaFunc1(Theta_r(i), hh(MN) , hh_frez(MN), hd, hm, Alpha(i), n(i), m(i));
                                    Se(i, ND) = Theta_LL(i, ND) / POR(i);
                                end
                            else
                                % TODO replace with ThetaFunc1!
                                Theta_UU(i, ND) = Gama_hh(MN) * Theta_r(i) + (Theta_m(i) - Gama_hh(MN) * Theta_r(i)) / (1 + abs(Alpha(i) * hh(MN))^n(i))^m(i);
                                DTheta_LLh(i, ND) = (-Theta_r(i)) / (abs(hh(MN)) * log(abs(hd / hm))) * (1 - (1 + abs(Alpha(i) * hh(MN))^n(i))^(-m(i))) - Alpha(i) * n(i) * m(i) * (Theta_m(i) - Gama_hh(MN) * Theta_r(i)) * ((1 + abs(Alpha(i) * hh(MN))^n(i))^(-m(i) - 1)) * (abs(Alpha(i) * hh(MN))^(n(i) - 1));
                                if (hh(MN) + hh_frez(MN)) <= hd
                                    Theta_LL(i, ND) = 0;
                                    DTheta_UUh(i, ND) = 0;
                                    Se(i, ND) = 0;
                                else
                                    Theta_LL(i, ND) = ThetaFunc1(Gama_hh(MN), Theta_r(i), Theta_m(i), (hh(MN) + hh_frez(MN)), Alpha(i), n(i), m(i));
                                    DTheta_UUh(i, ND) = DThetaFunc1(Theta_r(i), hh(MN) , hh_frez(MN), hd, hm, Alpha(i), n(i), m(i));
                                    Se(i, ND) = Theta_LL(i, ND) / POR(i);
                                end
                            end
                        else
                            if abs(hh(MN) - h(MN)) < 1e-3
                                DTheta_LLh(i, ND) = (Theta_m(i) - Theta_r(i)) * Alpha(i) * n(i) * abs(Alpha(i) * (hh(MN)))^(n(i) - 1) * (-m(i)) * (1 + abs(Alpha(i) * (hh(MN)))^n(i))^(-m(i) - 1);
                            else
                                DTheta_LLh(i, ND) = (Theta_UU(i, ND) - Theta_U(i, ND)) / (hh(MN) - h(MN));
                            end
                        end
                    end
                    %%%%%%%%%%%%%%%%%%%% Sin function for ice calculation %%%%%%%%%%%%%%%%%%%%%
                else
                    Tf1 = 273.15 + 1;
                    Tf2 = 273.15 - 3; % XCAP(i)=0.23;
                    if hh(MN) >= -1e-6
                        Theta_UU(i, ND) = Theta_s(i);
                        hh(MN) = -1e-6;
                        DTheta_UUh(i, ND) = 0;
                        if TT(MN) + 273.15 > Tf1
                            Theta_II(i, ND) = 0;
                            Theta_LL(i, ND) = Theta_s(i);

                        elseif TT(MN) + 273.15 >= Tf2
                            Theta_II(i, ND) = 0.5 * (1 - sin(pi() * (TT(MN) + 273.15 - 0.5 * Tf1 - 0.5 * Tf2) / (Tf1 - Tf2))) * XCAP(i);
                            Theta_LL(i, ND) = Theta_UU(i, ND) - Theta_II(i, ND) * RHOI / RHOL;

                        else
                            Theta_II(i, ND) = XCAP(i);
                            Theta_LL(i, ND) = Theta_UU(i, ND) - Theta_II(i, ND) * RHOI / RHOL;

                        end
                        if Theta_LL(i, ND) <= 0.06
                            Theta_LL(i, ND) = 0.06;
                            DTheta_LLh(i, ND) = 0;
                            Se(i, ND) = 0;
                        else
                            Theta_LL(i, ND) = Theta_LL(i, ND);
                            Se(i, ND) = Theta_LL(i, ND) / POR(i);
                            DTheta_LLh(i, ND) = DTheta_UUh(i, ND);
                        end
                    elseif hh(MN) <= -1e7
                        Theta_UU(i, ND) = Theta_r(i);
                        hh(MN) = -1e7;
                        DTheta_UUh(i, ND) = 0;
                        Theta_II(i, ND) = 0;
                        Theta_LL(i, ND) = Theta_r(i);
                        Se(i, ND) = 0;
                        DTheta_LLh(i, ND) = 0;
                    else
                        Theta_UU(i, ND) = Theta_r(i) + (Theta_s(i) - Theta_r(i)) / (1 + abs(Alpha(i) * hh(MN))^n(i))^m(i);

                        if Thmrlefc
                            DTheta_UUh(i, ND) = (Theta_s(i) - Theta_r(i)) * Alpha(i) * n(i) * abs(Alpha(i) * hh(MN))^(n(i) - 1) * (-m(i)) * (1 + abs(Alpha(i) * hh(MN))^n(i))^(-m(i) - 1);
                        else
                            if abs(hh(MN) - h(MN)) < 1e-3
                                DTheta_UUh(i, ND) = (Theta_s(i) - Theta_r(i)) * Alpha(i) * n(i) * abs(Alpha(i) * hh(MN))^(n(i) - 1) * (-m(i)) * (1 + abs(Alpha(i) * hh(MN))^n(i))^(-m(i) - 1);
                            else
                                DTheta_UUh(i, ND) = (Theta_UU(i, ND) - Theta_U(i, ND)) / (hh(MN) - h(MN));
                            end
                        end
                        if TT(MN) + 273.15 > Tf1
                            Theta_II(i, ND) = 0;
                            Theta_LL(i, ND) = Theta_r(i) + (Theta_s(i) - Theta_r(i)) / (1 + abs(Alpha(i) * (hh(MN) + hh_frez(MN)))^n(i))^m(i);

                        elseif TT(MN) + 273.15 >= Tf2
                            Theta_II(i, ND) = 0.5 * (1 - sin(pi() * (TT(MN) + 273.15 - 0.5 * Tf1 - 0.5 * Tf2) / (Tf1 - Tf2))) * XCAP(i);
                            Theta_LL(i, ND) = Theta_UU(i, ND) - Theta_II(i, ND) * RHOI / RHOL;

                        else
                            Theta_II(i, ND) = XCAP(i);
                            Theta_LL(i, ND) = Theta_UU(i, ND) - Theta_II(i, ND) * RHOI / RHOL;

                        end
                        if Theta_LL(i, ND) <= 0.06
                            Theta_LL(i, ND) = 0.06;
                            DTheta_LLh(i, ND) = 0;
                            Se(i, ND) = 0;
                        else
                            Theta_LL(i, ND) = Theta_LL(i, ND);
                            Se(i, ND) = Theta_LL(i, ND) / POR(i);
                            DTheta_LLh(i, ND) = DTheta_UUh(i, ND);
                        end

                    end
                end
            else
                if hh(MN) >= Phi_s(i)
                    Theta_UU(i, ND) = Theta_s(i);
                    hh(MN) = Phi_s(i);
                    DTheta_UUh(i, ND) = 0;
                    if hh(MN) + hh_frez(MN) <= -1e7
                        Theta_LL(i, ND) = Theta_r(i);
                        DTheta_LLh(i, ND) = 0;
                        Se(i, ND) = 0;
                    elseif hh(MN) + hh_frez(MN) >= Phi_s(i)
                        Theta_LL(i, ND) = Theta_s(i);
                        DTheta_LLh(i, ND) = 0;
                        Se(i, ND) = 1;
                    else
                        Theta_LL(i, ND) = Theta_s(i) * ((hh(MN) + hh_frez(MN)) / Phi_s(i))^(-1 * Lamda(i));
                        if Thmrlefc
                            DTheta_LLh(i, ND) = Theta_s(i) / Phi_s(i) * ((hh(MN) + hh_frez(MN)) / Phi_s(i))^(-1 * Lamda(i) - 1);
                        else
                            if abs(hh(MN) - h(MN)) < 1e-3
                                DTheta_LLh(i, ND) = (Theta_s(i) - Theta_r(i)) * Alpha(i) * n(i) * abs(Alpha(i) * (hh(MN) + hh_frez(MN)))^(n(i) - 1) * (-m(i)) * (1 + abs(Alpha(i) * (hh(MN) + hh_frez(MN)))^n(i))^(-m(i) - 1);
                            else
                                DTheta_LLh(i, ND) = DThetaFunc3(Theta_LL(i, ND), Theta_L(i, ND), hh(MN) , hh_frez(MN), h(MN), h_frez(MN));
                            end
                        end
                        Se(i, ND) = Theta_LL(i, ND) / POR(i);
                    end
                elseif hh(MN) <= -1e7
                    Theta_LL(i, ND) = Theta_r(i);
                    Theta_UU(i, ND) = Theta_r(i);
                    Theta_II(i, ND) = 0;
                    hh(MN) = -1e7;
                    hh_frez(MN) = -1e-6;
                    DTheta_UUh(i, ND) = 0;
                    DTheta_LLh(i, ND) = 0;
                    Se(i, ND) = 0;
                else
                    Theta_UU(i, ND) = Theta_s(i) * ((hh(MN)) / Phi_s(i))^(-1 * Lamda(i));
                    if Thmrlefc
                        DTheta_UUh(i, ND) = Theta_s(i) / Phi_s(i) * ((hh(MN)) / Phi_s(i))^(-1 * Lamda(i) - 1);
                    else
                        if abs(hh(MN) - h(MN)) < 1e-3
                            DTheta_UUh(i, ND) = (Theta_s(i) - Theta_r(i)) * Alpha(i) * n(i) * abs(Alpha(i) * (hh(MN)))^(n(i) - 1) * (-m(i)) * (1 + abs(Alpha(i) * (hh(MN)))^n(i))^(-m(i) - 1);
                        else
                            DTheta_UUh(i, ND) = (Theta_UU(i, ND) - Theta_U(i, ND)) / (hh(MN) - h(MN));
                        end
                    end

                    if hh(MN) + hh_frez(MN) <= -1e7
                        Theta_LL(i, ND) = Theta_r(i);
                        DTheta_LLh(i, ND) = 0;
                        Se(i, ND) = 0;
                    elseif hh(MN) + hh_frez(MN) >= Phi_s(i)
                        Theta_LL(i, ND) = Theta_s(i);
                        DTheta_LLh(i, ND) = 0;
                        Se(i, ND) = 1;
                    else
                        Theta_LL(i, ND) = Theta_s(i) * ((hh(MN) + hh_frez(MN)) / Phi_s(i))^(-1 * Lamda(i));
                        if Thmrlefc
                            DTheta_LLh(i, ND) = Theta_s(i) / Phi_s(i) * ((hh(MN) + hh_frez(MN)) / Phi_s(i))^(-1 * Lamda(i) - 1);
                        else
                            if abs(hh(MN) - h(MN)) < 1e-3
                                DTheta_LLh(i, ND) = (Theta_s(i) - Theta_r(i)) * Alpha(i) * n(i) * abs(Alpha(i) * (hh(MN) + hh_frez(MN)))^(n(i) - 1) * (-m(i)) * (1 + abs(Alpha(i) * (hh(MN) + hh_frez(MN)))^n(i))^(-m(i) - 1);
                            else
                                DTheta_LLh(i, ND) = DThetaFunc3(Theta_LL(i, ND), Theta_L(i, ND), hh(MN) , hh_frez(MN), h(MN), h_frez(MN));
                            end
                        end
                        Se(i, ND) = Theta_LL(i, ND) / POR(i);

                    end
                end
            end
            if Se(i, ND) >= 1
                Se(i, ND) = 1;
            elseif Se(i, ND) <= 0
                Se(i, ND) = 0;
            end
            if isnan(Se(i, ND)) == 1
                warning('\n case "isnan(Se(i, ND)) == 1" happens. Dont know what to do! \r');
            end
            Theta_II(i, ND) = (Theta_UU(i, ND) - Theta_LL(i, ND)) * RHOL / RHOI;  % ice water content
            if Theta_UU(i, ND) ~= 0
                Ratio_ice(i, ND) = RHOI * Theta_II(i, ND) / (RHOL * Theta_UU(i, ND)); % ice ratio
            else
                Ratio_ice(i, ND) = 0;
            end
            if KIT
                MU_WN = Constants.MU_W0 * exp(Constants.MU1 / (8.31441 * (20 + 133.3)));
                if TT(MN) < -20
                    MU_W(i, ND) = 3.71e-2;
                elseif TT(MN) > 150
                    MU_W(i, ND) = 1.81e-3;
                else
                    MU_W(i, ND) = Constants.MU_W0 * exp(Constants.MU1 / (8.31441 * (TT(MN) + 133.3)));

                end
                CKT(MN) = MU_WN / MU_W(i, ND);
                if Se(i, ND) == 0
                    KL_h(i, ND) = 0;
                else
                    KL_h(i, ND) = CKT(MN) * Ks(i) * (Se(i, ND)^(0.5)) * (1 - (1 - Se(i, ND)^(1 / m(i)))^m(i))^2;
                end

                CORF = 1;
                FILM = 1;   % indicator for film flow parameterization; =1, Zhang (2010); =2, Lebeau and Konrad (2010)
                if FILM == 1
                    AGR(i) = 0.00035;
                    % %%%%%%%%% see Zeng (2011) and Zhang (2010)
                    RHOW0 = 1e3;
                    GVA = 9.81;
                    uw0 = 2.4152e-5; % Pa s
                    u1 = 4.7428; % kJ mol-1
                    R = 8.314472; % i mol-1 K-1
                    e = 78.54;
                    e0 = 8.85e-12;
                    B_sig = 235.8E-3;
                    Tc = 647.15;
                    e_sig = 1.256;
                    c_sig = -0.625;
                    kb = 1.381e-23; % Boltzmann constant
                    Bi = 1;
                    Ba = 1.602e-19 * Bi;
                    uw = uw0 * exp(u1 / R / (TT(MN) + 133.3));
                    sigma = B_sig * ((Tc - (TT(MN) + 273.15)) / Tc)^e_sig * (1 + c_sig * (Tc - (TT(MN) + 273.15)) / Tc);
                    B(i) = 2^0.5 * pi()^2 * RHOW0 * GVA / uw * (e * e0 / 2 / sigma)^1.5 * (kb * (TT(MN) + 273.15) / (Bi * Ba))^3;

                    Coef_f = 0.0373 * (2 * AGR(i))^3.109;
                    Ks_flm(i, ND) = B(i) * (1 - POR(i)) * (2 * AGR(i))^0.5; % m2
                    if hh(MN) < -1
                        Kr(i, ND) = Coef_f * (1 + 2 * AGR(i) * RHOW0 * GVA * abs(hh(MN) / 100) / 2 / sigma)^(-1.5);
                    else
                        Kr(i, ND) = 1;
                    end
                    KL_h_flm(i, ND) = Ks_flm(i, ND) * Kr(i, ND) * 1e4; % m2 --> cm2
                else
                    %%%%%%%%% see sutraset --> perfilm.f based on Lebeau and Konrad (2010)
                    %  EFFECTIVE DIAMETER
                    ASVL = -6e-20;
                    GVA = 9.8;
                    PERMVAC = 8.854e-12; % (VAC)CUM (PERM)EABILITY [PERMFS] [C2J-1M-1 OR F/M OR S4A2/KG/M3]
                    ELECTRC = 1.602e-19;
                    BOTZC = 1.381e-23;
                    RHOW0 = 1000;
                    PSICM = 1000;
                    SWM = 0.1; % THE SATURATION WHEN SURFACE ROUGHNESS OF THE SOLID GRAIN BECOMES NEGNIGIBLE (-) IT IS EQUIVALENT TO
                    %       SATURATION BEEN 1000M FROM TULLER AND OR (2005)
                    RELPW = 78.54;
                    ED = 6.0 * (1 - POR(i)) * (-ASVL / (6.0 * pi() * RHOW0 * GVA * PSICM))^(1.0 / 3.0) / POR(i) / SWM;
                    %  FILM THICKNESS (WARNING) THIS IS NOT THE FULL PART
                    DEL = (RELPW * PERMVAC / (2 * RHOW0 * GVA))^0.50 * (pi() * BOTZC * 298.15 / ELECTRC);
                    Ks_flm(i, ND) = CORF * 4.0 * (1 - POR(i)) * DEL^3.0 / pi() / ED;

                    if hh(MN) <= -1
                        Kr(i, ND) = (1 - Se(i, ND)) * abs(hh(MN) / 100)^(-1.50);
                    else
                        Kr(i, ND) = 1;
                    end
                    KL_h_flm(i, ND) = Ks_flm(i, ND) * Kr(i, ND) * 1e4; % m2 --> cm2
                end
                if KL_h_flm(i, ND) <= 0
                    KL_h_flm(i, ND) = 0;
                elseif KL_h_flm(i, ND) >= 1e-6
                    KL_h_flm(i, ND) = 1e-6;
                end
                if KL_h(i, ND) <= 1E-20
                    KL_h(i, ND) = 1E-20;
                end
                if Gama_hh(MN) ~= 1
                    KfL_h(i, ND) = KL_h(i, ND) * 10^(-1 * Imped(MN) * Ratio_ice(i, ND));  % hydraulic conductivity for freezing soil
                else
                    KfL_h(i, ND) = KL_h(i, ND) * 10^(-1 * Imped(MN) * Ratio_ice(i, ND));  % hydraulic conductivity for freezing soil
                end
                if isnan(KL_h(i, ND)) == 1
                    KL_h(i, ND) = 0;
                    warning('\n case "isnan(KL_h(i, ND)) == 1", set "KL_h(i, ND) = 0" \r');
                end
                if ~isreal(KL_h(i, ND))
                    warning('\n case "~isreal(KL_h(i, ND))", dont know what to do! \r');
                end
                KfL_T(i, ND) = helpers.heaviside1(TT_CRIT(MN) - (TT(MN) + T0)) * L_f * 1e4 / (g * (T0));   % thermal consider for freezing soil
            else
                KL_h(i, ND) = 0;
                KfL_h(i, ND) = 0;
                KfL_T(i, ND) = 0;
            end
        end
    end
