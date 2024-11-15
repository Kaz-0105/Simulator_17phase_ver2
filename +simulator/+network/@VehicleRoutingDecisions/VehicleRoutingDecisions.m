classdef VehicleRoutingDecisions < utils.class.Container
    properties
        Config;
        Timer;
        Network;
    end

    properties
        Vissim;
    end

    methods
        function obj = VehicleRoutingDecisions(Network)
            % ConfigクラスとTimerクラスとNetworkクラスを設定
            obj.Config = Network.get('Config');
            obj.Timer = Network.get('Timer');
            obj.Network = Network;

            % VissimのCOMオブジェクトを設定
            obj.create('Vissim');

            % 下位クラスを作成
            obj.create('Elements');
        end
    end

    methods
        create(obj, property_name);
        delate(obj, property_name);
    end

end