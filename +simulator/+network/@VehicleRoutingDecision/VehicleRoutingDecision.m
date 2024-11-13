classdef VehicleRoutingDecision < utils.class.Common
    properties
        Config;
        VehicleRoutingDecisions;
        Road;
        Intersection;
        VehicleRoutes;
    end

    properties
        id;
        link_id;
        Vissim;
    end

    methods
        function obj = VehicleRoutingDecision(VehicleRoutingDecisions, id)
            % ConfigクラスとVehicleRoutingDecisionsクラスを設定
            obj.Config = VehicleRoutingDecisions.get('Config');
            obj.VehicleRoutingDecisions = VehicleRoutingDecisions;

            % idを設定
            obj.id = id;

            % VissimのCOMオブジェクトを設定
            obj.create('Vissim');

            % link_idの取得
            obj.link_id = obj.Vissim.Link.get('AttValue', 'No');
        end
    end
end