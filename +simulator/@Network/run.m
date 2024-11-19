function run(obj)
    average_queue_length = 0;
    max_queue_length = 0;
    average_delay_time = 0;
    max_delay_time = 0;

    % Intersectionクラスを走査
    for intersection_id = obj.Intersections.getKeys()
        Intersection = obj.Intersections.itemByKey(intersection_id);

        if Intersection.get('record_flags').queue_length
            queue_table = Intersection.get('queue_table');

            tmp_average_queue_length = round(mean(queue_table.average_queue_length), 1);
            tmp_max_queue_length = round(max(queue_table.max_queue_length), 1);

            average_queue_length = round(average_queue_length + tmp_average_queue_length / obj.Intersections.count(), 1);
            max_queue_length = round(max(max_queue_length, tmp_max_queue_length), 1);
        end

        if Intersection.get('record_flags').delay_time
            delay_table = Intersection.get('delay_table');

            tmp_average_delay_time = round(mean(delay_table.average_delay_time), 1);
            tmp_max_delay_time = round(max(delay_table.max_delay_time), 1);

            average_delay_time = round(average_delay_time + tmp_average_delay_time / obj.Intersections.count(), 1);
            max_delay_time = round(max(max_delay_time, tmp_max_delay_time), 1);
        end
    end

    % 性能指標表示
    fprintf('average_queue_length: %f\n', average_queue_length);
    fprintf('max_queue_length: %f\n', max_queue_length);
    fprintf('average_delay_time: %f\n', average_delay_time);
    fprintf('max_delay_time: %f\n', max_delay_time);
end