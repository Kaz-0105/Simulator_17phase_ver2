classdef VehicleRoutingDecision < utils.class.Common
    properties
        Config;
        VehicleRoutingDecisions;
        VehicleRoutes;
    end

    properties
        id;
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

            % VehicleRoutesクラスを作成
            obj.VehicleRoutes = simulator.network.VehicleRoutes(obj);
        end
    end
end