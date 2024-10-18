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

        
    elseif strcmp(property_name, 'pos_vehs')








        
    elseif strcmp(property_name, 'Objective')
        
    elseif strcmp(property_name, 'Intcon')
        
    else
        error('Property name is invalid.');
    end
end