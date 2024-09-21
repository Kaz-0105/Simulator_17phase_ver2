function create(obj, property_name)
    if strcmp(property_name, 'Intersections')
        % Intersectionsクラスを取得
        Intersections = obj.Roads.get('Intersections');

        % Intersectionクラスを走査
        for intersection_id = 1: Intersections.count()
            Intersection = Intersections.itemByKey(intersection_id);

            % InputRoadsクラスを取得
            InputRoads = Intersection.get('InputRoads');

            for input_road_id = InputRoads.getKeys()
                if input_road_id == obj.id
                    % プロパティにOutputIntersectionクラスを追加
                    prop = addprop(obj, 'OutputIntersection');
                    prop.SetAccess = 'public';
                    prop.GetAccess = 'public';

                    % OutputIntersectionクラスを設定
                    obj.OutputIntersection = Intersection;
                end
            end

            % OutputRoadsクラスを取得
            OutputRoads = Intersection.get('OutputRoads');

            for output_road_id = OutputRoads.getKeys()
                if output_road_id == obj.id
                    % プロパティにInputIntersectionクラスを追加
                    prop = addprop(obj, 'InputIntersection');
                    prop.SetAccess = 'public';
                    prop.GetAccess = 'public';

                    % InputIntersectionクラスを設定
                    obj.InputIntersection = Intersection;
                end
            end
        end
    elseif strcmp(property_name, 'links')
        % NetworkクラスのComオブジェクトを取得
        Network = obj.Roads.get('Network');
        Net = Network.get('Vissim');

        % LinksのComオブジェクトを取得
        Links = Net.Links;

        % main_linkを初期化
        main_link = struct();

        % idを取得
        main_link.id = obj.links.main;

        % Comオブジェクトを取得
        main_link.Vissim = Links.ItemByKey(main_link.id);

        % linksにmain_linkをプッシュ
        obj.links.main = main_link;

        % 分岐が存在する場合
        if isfield(obj.links, 'branch')
            % 左に分岐が存在する場合
            if isfield(obj.links.branch, 'left')
                % branch_leftを初期化
                branch_left = struct();

                % linkを初期化
                link = struct();

                % linkのidを取得
                link.id = obj.links.branch.left;

                % Comオブジェクトを取得
                link.Vissim = Links.ItemByKey(link.id);

                % linkをbranch_leftにプッシュ
                branch_left.link = link;

                % connectorを探す
                for Link = Links.GetAll()'
                    % セルから取り出し
                    Link = Link{1};

                    % FromLinkを取得
                    FromLink = Link.FromLink;

                    if isempty(FromLink)
                        continue;
                    end

                    if FromLink.get('AttValue', 'No') == main_link.id
                        % connectorを初期化
                        connector = struct();

                        % idを設定
                        connector.id = Link.get('AttValue', 'No');

                        % Comオブジェクトを設定
                        connector.Vissim = Link;

                        % branch_leftにconnectorをプッシュ
                        branch_left.connector = connector;

                        % branch_leftをlinksにプッシュ
                        obj.links.branch.left = branch_left;

                        break;
                    end
                end
            end

            % 右に分岐が存在する
            if isfield(obj.links.branch, 'right')
                % branch_rightを初期化
                branch_right = struct();

                % linkを初期化
                link = struct();

                % linkのidを取得
                link.id = obj.links.branch.right;

                % Comオブジェクトを取得
                link.Vissim = Links.ItemByKey(link.id);

                % linkをbranch_rightにプッシュ
                branch_right.link = link;

                % connectorを探す
                for Link = Links.GetAll()'
                    % セルから取り出し
                    Link = Link{1};

                    % FromLinkを取得
                    FromLink = Link.FromLink;

                    if isempty(FromLink)
                        continue;
                    end

                    if FromLink.get('AttValue', 'No') == main_link.id
                        % connectorを初期化
                        connector = struct();

                        % idを設定
                        connector.id = Link.get('AttValue', 'No');

                        % Comオブジェクトを設定
                        connector.Vissim = Link;

                        % branch_rightにconnectorをプッシュ
                        branch_right.connector = connector;

                        % branch_rightをlinksにプッシュ
                        obj.links.branch.right = branch_right;

                        break;
                    end
                end
            end
        end
    else
        error('error: Property name is invalid.');
    end
end