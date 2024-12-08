classdef VehicleInputs < utils.class.Container
    properties
        Config;
        Timer;
        Network;
    end

    methods
        function obj = VehicleInputs(Network)
            % ConfigクラスとTimerクラスとNetworkクラスを設定
            obj.Config = Network.get('Config');
            obj.Timer = Network.get('Timer');
            obj.Network = Network;

            % 下位クラスを作成
            obj.create('Elements');
        end
    end

    methods
        create(obj, property_name);
    end
end