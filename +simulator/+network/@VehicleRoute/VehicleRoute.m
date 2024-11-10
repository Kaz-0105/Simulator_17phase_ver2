classdef VehicleRoute < utils.class.Common
    properties
        Config;
        VehicleRoutes;
        Road;
    end

    properties
        id;
        order;
        rel_flow;
        Vissim;
    end

    methods
        function obj = VehicleRoute(VehicleRoutes, id)
            % ConfigクラスとVehicleRoutesクラスを設定
            obj.Config = VehicleRoutes.get('Config');
            obj.VehicleRoutes = VehicleRoutes;

            % idを設定
            obj.id = id;

            % VissimのCOMオブジェクトを設定
            obj.create('Vissim');

            % Roadクラスをセット
            obj.create('Road');
        end
    end

    methods
        create(obj, property_name);
    end
end
