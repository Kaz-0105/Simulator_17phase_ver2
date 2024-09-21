function update(obj, property_name)
    if strcmp(property_name, 'Vehicles')
        % 車両情報のテーブルを初期化
        size = [0, 5];
        variable_names = {'id', 'pos', 'route', 'stop_lane', 'branch_flag'};
        variable_types = {'int32', 'double', 'int32', 'int32', 'int32'};

        obj.vehicles = table('Size', size, 'VariableNames', variable_names, 'VariableTypes', variable_types);

        % メインリンクのVehiclesのComオブジェクトを取得
        Vehicles = obj.links.main.link.Vissim.Vehicles;

        % 各車両について走査
        for Vehicle = Vehicles.GetAll()'
            % セルから取り出し
            Vehicle = Vehicle{1};

            % 車両情報を取得（id, pos, route）
            id = Vehicle.get('AttValue', 'No');
            pos = Vehicle.get('AttValue', 'Pos');
            route = Vehicle.get('AttValue', 'RouteNo');

            % NextLinkを取得
            NextLink = Vehicle.NextLink;

            if isempty(NextLink)
                % stop_laneを取得
                stop_lane = Vehicle.Lane.get('AttValue', 'Index');

                % branch_flagを取得
                branch_flag = 0;
            else
                % stop_laneを取得
                stop_lane = NextLink.FromLane.get('AttValue', 'Index');

                % next_link_idを取得
                next_link_id = NextLink.get('AttValue', 'No');

                if next_link_id == obj.links.branch.right.connector.id
                    % branch_flagを取得
                    branch_flag = 1;
                elseif next_link_id == obj.links.branch.left.connector.id
                    % branch_flagを取得
                    branch_flag = 1;
                else
                    % branch_flagを取得
                    branch_flag = 0;
                end
            end

            % 車両情報をテーブルにプッシュ
            obj.vehicles(end + 1, :) = {id, pos, route, stop_lane, branch_flag};

        end

    else
        error('error: Property name is invalid.');
    end
end