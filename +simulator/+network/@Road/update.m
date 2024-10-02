function update(obj, property_name)
    if strcmp(property_name, 'Vehicles')
        % 車両情報のテーブルを初期化
        size = [0, 5];
        variable_names = {'id', 'pos', 'route', 'stop_lane', 'branch_flag'};
        variable_types = {'double', 'double', 'double', 'double', 'double'};

        obj.vehicles = table('Size', size, 'VariableNames', variable_names, 'VariableTypes', variable_types);

        % メインリンクのVehiclesのComオブジェクトを取得
        Vehicles = obj.links.main.Vissim.Vehs;

        if isprop(obj, 'routing_decision')
            % RouteOrderMapを取得
            RouteOrderMap = obj.routing_decision.routes.RouteOrderMap;

            % 各車両について走査
            for Vehicle = Vehicles.GetAll()'
                % セルから取り出し
                Vehicle = Vehicle{1};

                % 車両情報を取得（id, pos, route）
                id = Vehicle.get('AttValue', 'No');
                pos = Vehicle.get('AttValue', 'Pos');
                route = RouteOrderMap(Vehicle.get('AttValue', 'RouteNo'));

                % NextLinkを取得
                NextLink = Vehicle.NextLink;

                % stop_laneを取得
                stop_lane = NextLink.FromLane.get('AttValue', 'Index');

                % next_link_idを取得
                next_link_id = NextLink.get('AttValue', 'No');

                branch_flag = 0;

                if isfield(obj.links, 'branch')
                    if isfield(obj.links.branch, 'left')
                        if next_link_id == obj.links.branch.left.connector.id
                            % branch_flagを取得
                            branch_flag = 2;
                        end
                    end

                    if isfield(obj.links.branch, 'right')
                        if next_link_id == obj.links.branch.right.connector.id
                            % branch_flagを取得
                            branch_flag = 1;
                        end
                    end
                end

                % 車両情報をテーブルにプッシュ
                obj.vehicles(end + 1, :) = {id, pos, route, stop_lane, branch_flag};
            end

        else
            % 各車両について走査
            for Vehicle = Vehicles.GetAll()'
                % セルから取り出し
                Vehicle = Vehicle{1};

                % 車両情報を取得（id, pos, route）
                id = Vehicle.get('AttValue', 'No');
                pos = Vehicle.get('AttValue', 'Pos');
                route = -1;            

                % stop_laneを取得
                stop_lane = Vehicle.Lane.get('AttValue', 'Index');

                % branch_flagを取得
                branch_flag = 0;

                % 車両情報をテーブルにプッシュ
                obj.vehicles(end + 1, :) = {id, pos, route, stop_lane, branch_flag};
            end
        end

        
        % 分岐車線があるとき
        if isfield(obj.links, 'branch')
            for direction = ["left", "right"]

                if isfield(obj.links.branch, direction)
                    % コネクタのComオブジェクトを取得
                    Connector = obj.links.branch.(direction).connector.Vissim;

                    % コネクタのfrom_posとto_posとlengthを取得
                    from_pos = obj.links.branch.(direction).connector.from_pos;
                    to_pos = obj.links.branch.(direction).connector.to_pos;
                    length = obj.links.branch.(direction).connector.length;

                    % VehiclesのCOMオブジェクトを取得
                    Vehicles = Connector.Vehs;

                    % 各車両を走査
                    for Vehicle = Vehicles.GetAll()'
                        % セルから取り出し
                        Vehicle = Vehicle{1};

                        % 車両情報を取得（id, pos, route）
                        id = Vehicle.get('AttValue', 'No');
                        pos = Vehicle.get('AttValue', 'Pos') + from_pos;
                        route = RouteOrderMap(Vehicle.get('AttValue', 'RouteNo'));

                        % stop_laneを取得
                        stop_lane = Connector.FromLane.get('AttValue', 'Index');

                        % branch_flagを取得
                        if direction == "left"
                            branch_flag = 2;
                        elseif direction == "right"
                            branch_flag = 1;
                        else 
                            error('error: direction is invalid.');
                        end

                        % 車両情報をテーブルにプッシュ
                        obj.vehicles(end + 1, :) = {id, pos, route, stop_lane, branch_flag};
                    end

                    % リンクのComオブジェクトを取得
                    Link = obj.links.branch.(direction).link.Vissim;

                    % VehiclesのCOMオブジェクトを取得
                    Vehicles = Link.Vehs;

                    % 各車両を走査
                    for Vehicle = Vehicles.GetAll()'
                        % セルから取り出し
                        Vehicle = Vehicle{1};

                        % 車両情報を取得（id, pos, route）
                        id = Vehicle.get('AttValue', 'No');
                        pos = Vehicle.get('AttValue', 'Pos') + length + from_pos - to_pos;
                        route = RouteOrderMap(Vehicle.get('AttValue', 'RouteNo'));

                        % stop_laneを取得
                        stop_lane = Connector.FromLane.get('AttValue', 'Index');

                        % branch_flagを取得
                        if direction == "left"
                            branch_flag = 2;
                        elseif direction == "right"
                            branch_flag = 1;
                        else 
                            error('error: direction is invalid.');
                        end

                        % 車両情報をテーブルにプッシュ
                        obj.vehicles(end + 1, :) = {id, pos, route, stop_lane, branch_flag};
                    end
                end
            end 
        end

        % vehiclesをソート
        obj.vehicles = sortrows(obj.vehicles, {'stop_lane', 'pos'}, [1, -1]);
    else
        error('error: Property name is invalid.');
    end
end