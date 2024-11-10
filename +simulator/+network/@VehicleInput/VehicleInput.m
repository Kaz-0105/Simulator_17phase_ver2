classdef VehicleInput < utils.class.Common
    properties
        Config;
        VehicleInputs;
        Road;
    end

    properties
        id;
        Vissim;
    end

    properties
        volume;
    end

    methods
        function obj = VehicleInput(VehicleInputs, id)
            % ConfigクラスとVehicleInputsクラスを設定
            obj.Config = VehicleInputs.get('Config');
            obj.VehicleInputs = VehicleInputs;

            % idを設定
            obj.id = id;

            % VissimのCOMオブジェクトを設定
            obj.create('Vissim');
        end
    end
end