function save(obj)
    % Simulatorクラス用の設定を取得する
    simulator = obj.Config.get('simulator');

    % フォルダが存在しない場合は作成する
    if ~exist([pwd, '/results/', simulator.folder], 'dir')
        mkdir([pwd, '/results/', simulator.folder]);
    end

    % 結果の保存フラグがfalseの場合は保存しない
    if simulator.save.results == true
        % 結果の保存
        saveResultsForMscs(obj, simulator);
    end

    if simulator.save.time_series == true
        % 時系列データの保存
        saveTimeSeriesForMscs(obj, simulator);
    end
end

function saveResultsForMscs(obj, simulator)
    % Tableの取得
    if exist([pwd, '/results/', simulator.folder, '/scoot.csv'], 'file')
        results = readtable([pwd, '/results/', simulator.folder, '/scoot.csv']);
    else
        results = table(...
            'Size', [0, 5], ...
            'VariableNames', {'id', 'inflows_id', 'rel_flows_id', 'queue_length', 'delay_time'}, ...
            'VariableTypes', {'double', 'double', 'double', 'double', 'double'}...
        );
    end

    % idの取得
    if isempty(results.id)
        id = 1;
    else
        id = results.id(end) + 1;
    end 

    % inflows_idの取得
    inflows = zeros(1, 4);
    VehicleInputs = obj.Network.get('VehicleInputs');

    for vehicle_input_id = VehicleInputs.getKeys()
        VehicleInput = VehicleInputs.itemByKey(vehicle_input_id);
        Road = VehicleInput.get('Road');
        Intersection = Road.get('Intersections').output;
        RoadOrderMap = Intersection.get('RoadOrderMap');
        order_id = RoadOrderMap(Road.get('id'));
        inflows(order_id) = VehicleInput.get('volume');
    end

    InflowsTypeValuesMap = containers.Map('KeyType', 'int32', 'ValueType', 'any');
    InflowsTypeValuesMap(1) = [700, 700, 700, 700];
    InflowsTypeValuesMap(2) = [900, 900, 500, 500];
    InflowsTypeValuesMap(3) = [900, 500, 900, 500];

    inflows_type = ["balanced", "unbalanced", "main_sub"];

    found_flag = false;
    for inflows_id = cell2mat(InflowsTypeValuesMap.keys())
        if isequal(inflows, InflowsTypeValuesMap(inflows_id))
            found_flag = true;
            break;
        end
    end
    if ~found_flag
        return;
    end

    % rel_flows_idの取得
    RoadRelFlowsTypeMap = containers.Map('KeyType', 'int32', 'ValueType', 'int32');

    RelFlowsTypeValuesMap = containers.Map('KeyType', 'int32', 'ValueType', 'any');
    RelFlowsTypeValuesMap(1) = [1, 1, 1];
    RelFlowsTypeValuesMap(2) = [3, 1, 1];
    RelFlowsTypeValuesMap(3) = [1, 3, 1];
    RelFlowsTypeValuesMap(4) = [1, 1, 3];
    RelFlowsTypeValuesMap(5) = [1, 3, 3];
    RelFlowsTypeValuesMap(6) = [3, 1, 3];
    RelFlowsTypeValuesMap(7) = [3, 3, 1];

    Intersections = obj.Network.get('Intersections');
    Intersection = Intersections.itemByKey(1);

    Roads = Intersection.get('Roads').input;
    for order = Roads.getKeys()
        Road = Roads.itemByKey(order);
        VehicleRoutingDecision = Road.get('VehicleRoutingDecision');
        rel_flows = VehicleRoutingDecision.getRelFlows();
        found_flag = false;
        for rel_flows_id = cell2mat(RelFlowsTypeValuesMap.keys())
            if isequal(rel_flows, RelFlowsTypeValuesMap(rel_flows_id))
                found_flag = true;
                break;
            end
        end
        if ~found_flag
            return;
        end
        RoadRelFlowsTypeMap(order) = rel_flows_id;
    end

    rel_flows_id = unique(cell2mat(RoadRelFlowsTypeMap.values()));
    if length(rel_flows_id) ~= 1
        return;
    end

    % queue_lengthとdelay_timeの取得
    queue_length = 0;
    delay_time = 0;

    Intersections = obj.Network.get('Intersections');
    for intersection_id = Intersections.getKeys()
        Intersection = Intersections.itemByKey(intersection_id);

        if Intersection.get('record_flags').queue_length
            queue_table = Intersection.get('queue_table');
            tmp_queue_length = round(mean(queue_table.average_queue_length), 1);
            queue_length = round(queue_length + tmp_queue_length / Intersections.count(), 1);
        end

        if Intersection.get('record_flags').delay_time
            delay_table = Intersection.get('delay_table');
            tmp_delay_time = round(mean(delay_table.average_delay_time), 1);
            delay_time = round(delay_time + tmp_delay_time / Intersections.count(), 1);
        end
    end

    % 結果の保存
    if isempty(results(results.inflows_id == inflows_id & results.rel_flows_id == rel_flows_id, :))
        results(end + 1, :) = {id, inflows_id, rel_flows_id, queue_length, delay_time};    
    else
        results(results.inflows_id == inflows_id & results.rel_flows_id == rel_flows_id, 4:5) = {queue_length, delay_time};
    end
    writetable(results, [pwd, '/results/', simulator.folder, '/scoot.csv']); 
end

function saveTimeSeriesForMscs(obj, simulator)
    % queue_tableとdelay_tableの取得
    Intersections = obj.Network.get('Intersections');   
    Intersection = Intersections.itemByKey(1);

    if Intersection.get('record_flags').queue_length
        queue_table = Intersection.get('queue_table');
    end
    if Intersection.get('record_flags').delay_time
        delay_table = Intersection.get('delay_table');
    end

    time_series_table = table(...
        queue_table.time, ...
        queue_table.average_queue_length, ...
        delay_table.average_delay_time,...
        'VariableNames', {'time', 'queue_length', 'delay_time'}...
    );

    if ~exist([pwd, '/results/', simulator.folder, '/time_series'], 'dir')
        mkdir([pwd, '/results/', simulator.folder, '/time_series']);
    end
    files = dir([pwd, '/results/', simulator.folder, '/time_series']);

    last_number = 0;
    for file_struct = files'
        if strcmp(file_struct.name, '.') || strcmp(file_struct.name, '..')
            continue;
        end

        number = str2double(strrep(file_struct.name, 'time_series'));

        if number > last_number
            last_number = number;
        end
    end

    writetable(time_series_table, [pwd, '/results/', simulator.folder, '/time_series/time_series', num2str(last_number + 1), '.csv']);

end