function save(obj)
    % Simulatorクラス用の設定を取得する
    simulator = obj.Config.get('simulator');

    % 結果の保存フラグがfalseの場合は保存しない
    if simulator.save.results == false
        return;
    end

    % フォルダが存在しない場合は作成する
    if ~exist([pwd, '/results/', simulator.folder], 'dir')
        mkdir([pwd, '/results/', simulator.folder]);
    end

    % 結果の保存
    saveForMscs(obj, simulator);
end

function saveForMscs(obj, simulator)
    % Tableの取得
    if exist([pwd, '/results/', simulator.folder, '/scoot.csv'], 'file')
        results = readtable([pwd, '/results/', simulator.folder, '/scoot.csv']);
    else
        results = table(...
            'Size', [0, 5], ...
            'VariableNames', {'id', 'inflows_id', 'relflows_id', 'queue_length', 'delay_time'}, ...
            'VariableTypes', {'double', 'double', 'double', 'double', 'double'}...
        );
    end

    % idの取得
    id = results.id(end) + 1; 

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

    % relflows_idの取得
    RoadRelFlowsTypeMap = containers.Map('KeyType', 'int32', 'ValueType', 'int32');

    RelFlowsTypeValuesMap = containers.Map('KeyType', 'int32', 'ValueType', 'any');
    RelFlowsTypeValuesMap(1) = [1, 1, 1];
    RelFlowsTypeValuesMap(2) = [3, 1, 1];
    RelFlowsTypeValuesMap(3) = [1, 3, 1];
    RelFlowsTypeValuesMap(4) = [1, 1, 3];
    RelFlowsTypeValuesMap(5) = [1, 3, 3];
    RelFlowsTypeValuesMap(6) = [3, 1, 3];
    RelFlowsTypeValuesMap(7) = [3, 3, 1];
    relflows_type = ["same", "left_heavy", "straight_heavy", "right_heavy", "left_light", "straight_light", "right_light"];

    Intersections = obj.Network.get('Intersections');
    Intersection = Intersections.itemByKey(1);
    Roads = Intersection.get('Roads').input;
    for order = Roads.getKeys()
        Road = Roads.itemByKey(order);
        VehicleRoutingDecision = Road.get('VehicleRoutingDecision');
        relflows = VehicleRoutingDecision.getRelFlows();
        found_flag = false;
        for relflows_id = cell2mat(RelFlowsTypeValuesMap.keys())
            if isequal(relflows, RelFlowsTypeValuesMap(relflows_id))
                break;
            end
        end
        if ~found_flag
            return;
        end
        RoadRelFlowsTypeMap(order) = relflows_id;
    end

    relflows_id = unique(cell2mat(RoadRelFlowsTypeMap.values()));
    if length(relflows_id) ~= 1
        return;
    end

    % queue_lengthの取得
end