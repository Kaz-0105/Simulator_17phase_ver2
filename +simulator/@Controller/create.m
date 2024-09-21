function create(obj, property_name)
    if strcmp(property_name, 'MPC')
        % プロパティとしてMPCを追加
        prop = addprop(obj, 'MPC');
        prop.SetAccess = 'public';
        prop.GetAccess = 'public';

        % MPCクラスを作成
        obj.MPC = simulator.controller.MPC(obj);

    elseif strcmp(property_name, 'Fix')
        % プロパティとしてFixを追加
        prop = addprop(obj, 'Fix');
        prop.SetAccess = 'public';
        prop.GetAccess = 'public';

        % Fixクラスを作成
        obj.Fix = simulator.controller.Fix(obj);
        
    else
        error('Error: property name is invalid.');
    end
end