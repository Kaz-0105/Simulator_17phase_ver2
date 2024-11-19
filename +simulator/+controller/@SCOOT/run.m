function run(obj)
    for objective = obj.objectives
        % char型に変換
        objective = char(objective);

        % オブジェクトの目的によって処理を分岐
        if strcmp(objective, 'split')
            % 流入率と流出率の更新
            obj.update('PhaseInflowRateMap');
            obj.update('PhaseOutflowRateMap');

            % 飽和率の更新
            obj.update('PhaseSaturationMap');

            % 次のフェーズへの移行時間の更新
            obj.update('next_split_start', objective);

        elseif strcmp(objective, 'cycle')
            % サイクル時間の更新
            obj.update('cycle_time');

        elseif strcmp(objective, 'split_change')
            % current_split_startを更新
            obj.update('current_split_start');

            % SignalControllerクラスを取得
            SignalController = obj.Intersection.get('SignalController');

            % Intersectionクラスから信号を変更する
            SignalController.run(obj.phase_ids(2), 'green');

            % phase_idsを更新
            obj.phase_ids = [obj.phase_ids(2:end), obj.phase_ids(1)];

            % next_split_startを更新
            obj.update('next_split_start', objective);

        elseif strcmp(objective, 'cycle_change')
            % current_cycle_timeとnext_cycle_startを更新
            obj.update('current_cycle_start');
            obj.update('next_cycle_start');

        elseif strcmp(objective, 'yellow')
            % IntersectionクラスからSignalControllerクラスを取得
            SignalController = obj.Intersection.get('SignalController');

            % Intersectionクラスから信号を変更する
            SignalController.run(obj.phase_ids(1), 'yellow');

        elseif strcmp(objective, 'red')
            % IntersectionクラスからSignalControllerクラスを取得
            SignalController = obj.Intersection.get('SignalController');

            % Intersectionクラスから信号を変更する
            SignalController.run(obj.phase_ids(1), 'red');  
        else
            error('Objective is invalid.');
        end
    end
end