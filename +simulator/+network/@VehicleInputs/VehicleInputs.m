classdef VehicleInputs < utils.class.Container
    properties
        Config;
        Network;
    end

    methods
        function obj = VehicleInputs(Network)
            % ConfigクラスとNetworkクラスを設定
            obj.Config = Network.get('Config');
            obj.Network = Network;

            % 下位クラスを作成
            obj.create('Elements');
        end
    end
end