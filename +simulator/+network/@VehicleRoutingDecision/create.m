function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % VehicleRoutingDecisionsクラスのComオブジェクトを取得  
        VehicleRoutingDecisions = obj.get('VehicleRoutingDecisions').get('Vissim');

        % Comオブジェクトを設定
        obj.Vissim = VehicleRoutingDecisions.ItemByKey(obj.id);

    elseif strcmp(property_name, 'Link')
        % Linkクラスを取得
        link_id = obj.Vissim.Link.get('AttValue', 'No');
        Links = obj.VehicleRoutingDecisions.get('Network').get('Links');
        obj.Link = Links.itemByKey(link_id);

    elseif strcmp(property_name, 'Road')
        % Roadクラスの取得
        Roads = obj.VehicleRoutingDecisions.get('Network').get('Roads');
        LinkRoadMap = Roads.get('LinkRoadMap'); 

        % Roadクラスの取得
        obj.Road = Roads.itemByKey(LinkRoadMap(obj.Link.get('id')));
        obj.Road.set('VehicleRoutingDecision', obj);
    else
        error('Property name is invalid.');
    end
end