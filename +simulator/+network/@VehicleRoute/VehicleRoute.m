classdef VehicleRoute < utils.class.Common
    properties
        Config;
        Timer;
        VehicleRoutes;
        Connector;
        ToLink;
        FromLink;
        FromRoad;
        ToRoad;
    end

    properties
        id;
        order;
        rel_flow;
        Vissim;
    end

    methods
        function obj = VehicleRoute(VehicleRoutes, id)
            % ConfigクラスとTimerクラスとVehicleRoutesクラスを設定
            obj.Config = VehicleRoutes.get('Config');
            obj.Timer = VehicleRoutes.get('Timer');
            obj.VehicleRoutes = VehicleRoutes;

            % idを設定
            obj.id = id;

            % VissimのCOMオブジェクトを設定
            obj.create('Vissim');

            % Linkクラス関連の設定
            obj.create('Links');

            % Roadクラス関連の設定
            obj.create('Roads');

            % vehicle_routeを作成
            obj.create('vehicle_route');
        end
    end

    methods
        create(obj, property_name);
    end
end
