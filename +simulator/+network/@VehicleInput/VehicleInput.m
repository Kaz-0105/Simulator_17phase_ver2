classdef VehicleInput < utils.class.Common
    properties
        Config;
        VehicleInputs;
        Link;
        Road;
    end

    properties
        id;
        Vissim;
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

            % Linkクラスの設定
            obj.create('Link');

            % Roadクラスを設定
            obj.create('Road');

            % volumeの設定
            obj.create('volume');
        end
    end
end