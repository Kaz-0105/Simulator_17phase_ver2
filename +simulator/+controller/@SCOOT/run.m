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
            obj.update('next_split_start');

        elseif strcmp(objective, 'cycle')
            % サイクル時間の更新
            obj.update('cycle_time');

        elseif strcmp(objective, 'split_change')
            % Intersectionクラスから信号を変更する
            obj.Intersection.run(obj.current_phase_id, 'red');
            obj.Intersection.run(obj.next_phase_id, 'green');

            % current_phase_idとnext_phase_idを更新
            obj.update('current_phase_id');
            obj.update('next_phase_id');

            % PhaseSplitStartMapの更新
            obj.PhaseSplitStartMap(obj.current_phase_id) = obj.PhaseSplitStartMap(obj.current_phase_id) + obj.cycle_time;

        elseif strcmp(objective, 'cycle_change')
        else
            error('Objective is invalid.');
        end
    end
end