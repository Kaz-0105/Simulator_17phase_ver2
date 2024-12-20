function create(obj, property_name)
    if strcmp(property_name, 'current_time')
        % Simulatorクラスを取得
        Simulator = obj.Controllers.get('Simulator');

        % current_timeを取得
        obj.current_time = Simulator.get('current_time');
        
    elseif strcmp(property_name, 'MPC')
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

    elseif strcmp(property_name, 'SCOOT')
        % プロパティとしてSCOOTを追加
        prop = addprop(obj, 'SCOOT');
        prop.SetAccess = 'public';
        prop.GetAccess = 'public';

        % SCOOTクラスを作成
        obj.SCOOT = simulator.controller.SCOOT(obj);
        
    else
        error('Error: property name is invalid.');
    end
end