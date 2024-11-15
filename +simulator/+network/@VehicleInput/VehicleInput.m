classdef VehicleInput < utils.class.Common
    properties
        Config;
        Timer;
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
            % ConfigクラスとTimerクラスとVehicleInputsクラスを設定
            obj.Config = VehicleInputs.get('Config');
            obj.Timer = VehicleInputs.get('Timer');
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