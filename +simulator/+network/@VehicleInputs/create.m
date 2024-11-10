function create(obj, property_name)
    if strcmp(property_name, 'Elements')
        % Elementsを初期化
        obj.Elements = containers.Map('KeyType', 'int32', 'ValueType', 'any');

        % NetworkクラスのComオブジェクトを取得
        Net = obj.Network.get('Vissim');

        % VehicleInputsクラスのComオブジェクトを取得    
        VehicleInputs = Net.VehicleInputs;

        % VehicleInputを走査
        for vehicle_input_id = utils.class.Container.getVissimKeys(VehicleInputs)
            % VehicleInputクラスを作成
            VehicleInput = simulator.network.VehicleInput(obj, vehicle_input_id);

            % VehicleInputクラスを追加
            obj.add(VehicleInput);
        end
    elseif strcmp(property_name, 'Road')
        % NetworkクラスのComオブジェクトを取得
        Net = obj.Network.get('Vissim');

        % VehicleInputsのComオブジェクトを取得
        VehicleInputs = Net.VehicleInputs;

        % InputMainLinkMapの初期化
        InputMainLinkMap = containers.Map('KeyType', 'int32', 'ValueType', 'int32');

        % VehicleInputの走査
        for VehicleInput = VehicleInputs.GetAll()'
            % セルから取り出し
            VehicleInput = VehicleInput{1};

            % IDを取得
            vehicle_input_id = VehicleInput.get('AttValue', 'No');

            % LinkのComオブジェクトを取得
            Link = VehicleInput.Link;

            % LinkのIDを取得
            main_link_id = Link.get('AttValue', 'No');

            % InputMainLinkMapに追加
            InputMainLinkMap(vehicle_input_id) = main_link_id;
        end

        % MainLinkRoadMapの初期化
        MainLinkRoadMap = containers.Map('KeyType', 'int32', 'ValueType', 'int32');

        % Roadsクラスを取得
        Roads = obj.Network.get('Roads');

        % Roadクラスを走査
        for road_id = Roads.getKeys()
            % Roadクラスを取得
            Road = Roads.itemByKey(road_id);

            % links構造体を取得
            links = Road.get('links');

            % メインリンクのIDを取得
            main_link_id = links.main.id;

            % MainLinkRoadMapに追加
            MainLinkRoadMap(main_link_id) = road_id;
        end

        % vehicle_input_idを走査
        for vehicle_input_id = cell2mat(InputMainLinkMap.keys)
            % VehicleInputクラスを取得
            VehicleInput = obj.itemByKey(vehicle_input_id);

            % road_idを取得
            road_id = MainLinkRoadMap(InputMainLinkMap(vehicle_input_id));

            % Roadクラスを取得
            Road = Roads.itemByKey(road_id);

            % それぞれのクラスにセット
            Road.set('VehicleInput', obj.itemByKey(vehicle_input_id));
            VehicleInput.set('Road', Road);
        end
    elseif strcmp(property_name, 'volume')
        % Networkクラス用の設定を取得
        network_config = obj.Config.get('network');

        % RoadsMapを取得
        RoadsMap = network_config.roads.RoadsMap;

        % VehicleInputクラスを走査
        for vehicle_input_id = obj.getKeys()
            % VehicleInputクラスを取得
            VehicleInput = obj.itemByKey(vehicle_input_id);

            % road_idを取得
            road_id = VehicleInput.get('Road').get('id');

            % 道路の設定を取得
            road_config = RoadsMap(road_id);

            % volumeをセット
            VehicleInput.set('volume', road_config.inflows);

            % Vissimに値をセット
            VehicleInput.get('Vissim').set('AttValue', 'Volume(1)', road_config.inflows);
        end
    else
        error('Property name is invalid.'); 
    end
end