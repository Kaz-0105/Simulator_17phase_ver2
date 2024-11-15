function create(obj, property_name)
    if strcmp(property_name, 'time_step')
        % time_stepを取得
        obj.time_step = obj.Config.get('simulator').time_step;

    elseif strcmp(property_name, 'finish_time')
        % finish_timeを取得
        obj.finish_time = obj.Config.get('simulator').finish_time;

        % Vissimにシミュレーション時間を設定
        obj.Simulator.get('Vissim').set('AttValue', 'SimPeriod', obj.finish_time);

    elseif strcmp(property_name, 'evaluation_interval')
        % evaluation_time_stepを取得
        obj.evaluation_time_step = obj.Config.get('simulator').evaluation.time_step;
        
    else
        error('Property name is not correct');
    end
end