function create(obj, property_name)
    if strcmp(property_name, 'RoadParameterMap')
        % RoadParameterMapの初期化
        RoadParameterMap = containers.Map('KeyType', 'double', 'ValueType', 'any');

        % Roadクラスを走査
        for road_id = 1: obj.Roads.count()
            % Roadクラスを取得
            Road = obj.Roads.itemByKey(road_id);

            % links構造体を取得
            links = Road.get('links');

            % 車線数を取得
            num_lanes = links.main.lanes;

            % road_parameter構造体を初期化
            road_parameter = struct();

            % LaneParameterMapの初期化
            LaneParameterMap = containers.Map('KeyType', 'double', 'ValueType', 'any');

            if num_lanes == 1
            else
                % 車線を走査
                for lane_id = 1: num_lanes
                    % lane_parameter構造体を初期化
                    lane_parameter = struct();

                    % main構造体を初期化
                    main = struct();

                    % p_sを計算
                    main.p_s = links.main.length;

                    % D_oを取得
                    controllers = obj.Config.get('controllers');
                    main.D_o = controllers.MPC.D_o;

                    % 

                    % 端の車線かどうかで場合分け
                    if lane_id == 1
                        % 右の分岐車線があるかどうか
                        if isfield(links, 'branch') 
                            if isfield(links.branch, 'right')
                                
                            end
                        end

                    elseif lane_id == num_lanes
                        % 左の分岐車線があるかどうか
                        if isfield(links, 'branch')
                            if isfield(links.branch, 'left')
                            end
                        end
                    else
                    end
                end
            end
        end
    else
        error('Property name is invalid.');
    end
end