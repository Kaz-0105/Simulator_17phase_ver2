classdef VehicleRoutingDecision < utils.class.Common
    properties
        Config;
        Timer;
        VehicleRoutingDecisions;
        Link;
        Road;
        Intersection;
        VehicleRoutes;
    end

    properties
        id;
        Vissim;
        vehicle_routes;
    end

    methods
        % VehicleRoutingDecisionクラスのコンストラクタ
        function obj = VehicleRoutingDecision(VehicleRoutingDecisions, id)
            % ConfigクラスとTimerクラスとVehicleRoutingDecisionsクラスを設定
            obj.Config = VehicleRoutingDecisions.get('Config');
            obj.Timer = VehicleRoutingDecisions.get('Timer');
            obj.VehicleRoutingDecisions = VehicleRoutingDecisions;

            % idを設定
            obj.id = id;

            % VissimのCOMオブジェクトを設定
            obj.create('Vissim');

            % Linkクラスを設定
            obj.create('Link');

            % Roadクラスを設定
            obj.create('Road');

            % Intersectionクラスを取得
            obj.Intersection = obj.Road.get('Intersections').output;

            % vehicle_routesを初期化
            obj.vehicle_routes = [];

            % VehicleRoutesクラスを作成
            obj.VehicleRoutes = simulator.network.VehicleRoutes(obj);
        end
    end

    methods
        create(obj, property_name);
    end

    methods
        function relflows = getRelFlows(obj)
            relflows = zeros(1, obj.VehicleRoutes.count());
            for route_id = obj.VehicleRoutes.getKeys()
                VehicleRoute = obj.VehicleRoutes.itemByKey(route_id);
                relflows(route_id) = VehicleRoute.get('rel_flow');
            end
        end
    end
end