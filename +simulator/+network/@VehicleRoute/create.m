function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % VehicleRoutesクラスのComオブジェクトを取得  
        VehicleRoutes = obj.VehicleRoutes.get('Vissim');

        % Comオブジェクトを設定
        obj.Vissim = VehicleRoutes.ItemByKey(obj.id);
    elseif strcmp(property_name, 'Road')
        % 現在のコネクタのComオブジェクトを取得
        Connector = obj.Vissim.DestLink;

        % to_link_idを取得
        to_link_id = Connector.ToLink.get('AttValue', 'No');

        % RoutingDecisionsクラスを取得
        RoutingDecisions = obj.VehicleRoutes.get('VehicleRoutingDecision').get('VehicleRoutingDecisions');

        % Roadsクラスを取得
        Roads = RoutingDecisions.get('Network').get('Roads');

        % LinkRoadMapを取得
        LinkRoadMap = Roads.get('LinkRoadMap');

        % Roadクラスを取得
        obj.Road = Roads.itemByKey(LinkRoadMap(to_link_id));
    else
        error('Property name is invalid.');
    end
end