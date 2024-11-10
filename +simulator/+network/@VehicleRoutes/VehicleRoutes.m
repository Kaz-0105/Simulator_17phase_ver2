classdef VehicleRoutes < utils.class.Container
    properties
        Config;
        VehicleRoutingDecision;
    end

    properties
        Elements;
    end

    properties
        Vissim;
    end

    methods
        function obj = VehicleRoutes(VehicleRoutingDecision)
            % ConfigクラスとVehicleRoutingDecisionsクラスを設定
            obj.Config = VehicleRoutingDecision.get('Config');
            obj.VehicleRoutingDecision = VehicleRoutingDecision;

            % VissimのCOMオブジェクトを設定
            obj.create('Vissim');

            % 下位クラスを作成
            obj.create('Elements');
        end
    end

    methods
        create(obj, property_name);
    end

end