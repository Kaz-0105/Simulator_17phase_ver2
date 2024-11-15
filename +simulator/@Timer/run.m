function run(obj, seconds)
    % 引数の初期化
    if nargin == 1
        seconds = obj.time_step;
    end

    % current_timeの更新
    obj.current_time = obj.current_time + seconds;

    % finish_flagの更新
    if obj.current_time >= obj.finish_time
        obj.finish_flag = true;
    end

    % evaluation_flagの更新
    if mod(obj.current_time, obj.evaluation_time_step) == 0
        obj.evaluation_flag = true;
    else
        obj.evaluation_flag = false;
    end
end
