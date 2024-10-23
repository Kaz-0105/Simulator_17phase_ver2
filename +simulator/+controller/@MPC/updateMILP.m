function updateMILP(obj, property_name)
    if strcmp(property_name, 'Constraints')
        % 不等式制約、等式制約を初期化
        P = [];
        Q = [];
        Peq = [];
        Qeq = [];

        % MLDの各行列を取得
        A = obj.MLDsMap('A');
        B = obj.MLDsMap('B');
        C = obj.MLDsMap('C');
        D = obj.MLDsMap('D');
        E = obj.MLDsMap('E');
        F = obj.MLDsMap('F');
        G = obj.MLDsMap('G');


        % A_bar, B_bar, C_bar, D_bar, E_bar, F_bar, G_barを計算
        A_bar = kron(ones(obj.N_p, 1), A);
        B_bar = kron(tril(ones(obj.N_p), -1), B); 
        C_bar = kron(eye(obj.N_p), C); 
        D_bar = kron(eye(obj.N_p), D);
        E_bar = kron(ones(obj.N_p, 1), E);
        F_bar = kron(eye(obj.N_p), F);
        G_bar = kron(ones(obj.N_p, 1), G);

        % P, Qにプッシュ
        P = C_bar*B_bar + D_bar;
        Q = E_bar - C_bar*A_bar*obj.pos_vehs;

        % Peq, Qeqにプッシュ
        Peq = F_bar;
        Qeq = G_bar;

        % MILPsMapにプッシュ
        obj.MILPsMap('P') = P;
        obj.MILPsMap('Q') = Q;
        obj.MILPsMap('Peq') = Peq;
        obj.MILPsMap('Qeq') = Qeq;
        
    elseif strcmp(property_name, 'Objective')
        % 目的関数を初期化
        F = zeros(1, obj.v_length * obj.N_p);

        % delta_tsを取得
        delta_ts = obj.VariableListMap('delta_t');

        % delta_tsを１ステップ全体での場所に変換
        delta_ts = delta_ts + (obj.u_length + obj.z_length);

        % 各ステップを走査
        for step = 1: obj.N_p
            for delta_t_id = delta_ts
                F(delta_t_id) = 1;
            end

            % delta_tsを更新
            delta_ts = delta_ts + obj.v_length;
        end

    elseif strcmp(property_name, 'Intcon')
        
    else
        error('Property name is invalid.');
    end
end